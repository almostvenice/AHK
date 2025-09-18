import path from 'path';
import fs from 'fs';
import { app } from 'electron';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Get current directory for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Define the type for dictionary entries
interface DictionaryEntry {
  word: string;
  quadrant: string;
  rank: number;
}

// Load the word dictionary
let wordDictionary: DictionaryEntry[] = [];

export function loadDictionary(): void {
  try {
    // Try multiple possible paths for the dictionary
    const possiblePaths = [
      path.join(__dirname, 'word-dictionary.json'),
      path.join(__dirname, '..', 'services', 'word-dictionary.json'),
      path.join(app.getAppPath(), 'electron', 'services', 'word-dictionary.json'),
      // Keep the original paths as fallbacks
      path.join(app.getAppPath(), 'src', 'assets', 'word-dictionary.json'),
      path.join(app.getAppPath(), 'dist', 'assets', 'word-dictionary.json'),
      path.join(process.env.APP_ROOT || '', 'src', 'assets', 'word-dictionary.json'),
      path.join(process.env.APP_ROOT || '', 'dist', 'assets', 'word-dictionary.json')
    ];
    
    let dictionaryData: string | null = null;
    
    // Try each path until we find the file
    for (const dictionaryPath of possiblePaths) {
      if (fs.existsSync(dictionaryPath)) {
        console.log(`Found dictionary at: ${dictionaryPath}`);
        dictionaryData = fs.readFileSync(dictionaryPath, 'utf8');
        break;
      }
    }
    
    if (!dictionaryData) {
      throw new Error('Dictionary file not found in any of the expected locations');
    }
    
    wordDictionary = JSON.parse(dictionaryData);
    console.log(`Loaded ${wordDictionary.length} words into dictionary`);
  } catch (error) {
    console.error('Error loading dictionary:', error);
  }
}

/**
 * Predicts words based on a sequence of quadrant positions
 * @param positionSequence Array of quadrant positions (numbers)
 * @returns Array of predicted words (always exactly 10 words)
 */
export function predictWordsFromQuadrants(positionSequence: number[]): string[] {
  if (positionSequence.length === 0) {
    return getDefaultWords(10);
  }

  // If dictionary is empty, try to load it
  if (wordDictionary.length === 0) {
    loadDictionary();
    // If still empty after loading attempt, return default words
    if (wordDictionary.length === 0) {
      return getDefaultWords(10);
    }
  }

  // Convert the position sequence to a string
  const positionString = positionSequence.join('');
  
  // Find words that match our quadrant sequence
  let predictions: string[] = [];
  
  // First try exact matches
  const exactMatches = wordDictionary
    .filter(entry => entry.quadrant === positionString)
    .sort((a, b) => a.rank - b.rank)
    .slice(0, 10)
    .map(entry => entry.word);
    
  if (exactMatches.length > 0) {
    predictions = exactMatches;
  }
  // Then try high percentage matches (dynamic threshold based on sequence length)
  else {
    // Calculate dynamic threshold based on sequence length
    // Shorter sequences need higher match percentage, longer sequences can be more forgiving
    const getThresholdForLength = (length: number): number => {
      switch (length) {
        case 1:
          return 1.0;       // 100% match for single digit
        case 2:
          return 0.5;       // 50% match for 2 digits (1 of 2 digits)
        case 3:
          return 0.67;      // 67% match for 3 digits (2 of 3 digits)
        case 4:
          return 0.75;      // 75% match for 4 digits (3 of 4 digits)
        case 5:
        case 6:
          return 0.7;       // 70% match for 5-6 digits
        case 7:
        case 8:
          return 0.65;      // 65% match for 7-8 digits
        default:
          return 0.6;       // 60% match for 9+ digits
      }
    };
    
    const matchThreshold = getThresholdForLength(positionString.length);
    console.log(`Using match threshold of ${(matchThreshold * 100).toFixed(1)}% for sequence length ${positionString.length}`);
    
    // Calculate similarity scores for each word
    const similarityMatches = wordDictionary
      .map(entry => {
        // Skip entries that are too different in length
        if (entry.quadrant.length < positionString.length * 0.75 || 
            entry.quadrant.length > positionString.length * 1.25) {
          return { entry, score: 0 };
        }
        
        // Calculate how many positions match
        let matchCount = 0;
        const minLength = Math.min(positionString.length, entry.quadrant.length);
        
        // Compare each position
        for (let i = 0; i < minLength; i++) {
          if (positionString[i] === entry.quadrant[i]) {
            matchCount++;
          }
        }
        
        // Calculate percentage match
        const score = matchCount / positionString.length;
        return { entry, score };
      })
      .filter(item => item.score >= matchThreshold) // Keep only matches above dynamic threshold
      .sort((a, b) => {
        // Sort by score first, then by rank
        if (b.score !== a.score) {
          return b.score - a.score;
        }
        return a.entry.rank - b.entry.rank;
      })
      .slice(0, 10)
      .map(item => item.entry.word);
    
    if (similarityMatches.length > 0) {
      predictions = similarityMatches;
    }
    // Then try partial matches - words that start with our sequence
    else {
      const partialMatches = wordDictionary
        .filter(entry => entry.quadrant.startsWith(positionString))
        .sort((a, b) => a.rank - b.rank)
        .slice(0, 10)
        .map(entry => entry.word);
        
      if (partialMatches.length > 0) {
        predictions = partialMatches;
      }
      // If still no matches and sequence is long enough, try matching the end
      else if (positionString.length >= 3) {
        const endMatches = wordDictionary
          .filter(entry => entry.quadrant.includes(positionString.slice(-3)))
          .sort((a, b) => a.rank - b.rank)
          .slice(0, 10)
          .map(entry => entry.word);
          
        predictions = endMatches;
      }
    }
  }

  // Ensure we always have exactly 10 words
  return ensureExactlyTenWords(predictions);
}

/**
 * Ensures the predictions array contains exactly 10 words
 * @param predictions Current array of predicted words
 * @returns Array with exactly 10 words
 */
function ensureExactlyTenWords(predictions: string[]): string[] {
  if (predictions.length === 10) {
    return predictions;
  }
  
  if (predictions.length > 10) {
    return predictions.slice(0, 10);
  }
  
  // If we have fewer than 10 words, add default words to fill the gap
  const defaultWords = getDefaultWords(10 - predictions.length);
  return [...predictions, ...defaultWords];
}

/**
 * Returns an array of default common words
 * @param count Number of default words to return
 * @returns Array of default words
 */
function getDefaultWords(count: number): string[] {
  const commonWords = [
    'the', 'and', 'to', 'of', 'in', 
    'that', 'have', 'for', 'not', 'on', 
    'with', 'he', 'as', 'you', 'do', 
    'at', 'this', 'but', 'his', 'by',
    'from', 'they', 'we', 'say', 'her',
    'she', 'or', 'an', 'will', 'my'
  ];
  
  // Return the requested number of words, cycling through the list if needed
  const result: string[] = [];
  for (let i = 0; i < count; i++) {
    result.push(commonWords[i % commonWords.length]);
  }
  
  return result;
}
