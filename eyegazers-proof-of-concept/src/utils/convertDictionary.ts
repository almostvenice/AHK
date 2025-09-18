import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Get current file directory with ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Define the letter to quadrant mapping
const letterToQuadrant: Record<string, number> = {
    'Q': 3, 'W': 1, 'E': 5, 'A': 6, 'S': 5, 'D': 4,
    'R': 5, 'T': 5, 'Y': 2, 'F': 2,
    'U': 4, 'I': 6, 'O': 6, 'P': 1, 'G': 2, 'H': 4,
    'Z': 3, 'X': 3, 'C': 2, 'V': 3,
    'B': 1, 'N': 6, 'M': 1,
    'J': 3, 'K': 3, 'L': 4
};

// Function to convert a word to its quadrant sequence
const wordToQuadrantSequence = (word: string): string => {
  return word.toUpperCase().split('')
    .map(letter => letterToQuadrant[letter] || '')
    .join('');
};

// Main conversion function
const convertDictionary = () => {
  try {
    // Read the input file
    const inputPath = path.resolve(__dirname, '../../../10000-english.txt');
    const outputPath = path.resolve(__dirname, '../../assets/word-dictionary.json');
    
    console.log('Input path:', inputPath);
    console.log('Output path:', outputPath);
    
    const fileContent = fs.readFileSync(inputPath, 'utf-8');
    const words = fileContent.split('\n').filter(word => word.trim() !== '');
    
    // Convert each word to the required format
    const dictionary = words.map((word, index) => {
      return {
        word: word.trim(),
        quadrant: wordToQuadrantSequence(word),
        rank: index + 1 // 1-based ranking
      };
    });
    
    // Filter out words with empty quadrant sequences
    const validDictionary = dictionary.filter(entry => entry.quadrant !== '');
    
    // Create directory if it doesn't exist
    const outputDir = path.dirname(outputPath);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }
    
    // Write the output file
    fs.writeFileSync(outputPath, JSON.stringify(validDictionary, null, 2));
    
    console.log(`Dictionary conversion complete. ${validDictionary.length} words processed.`);
    console.log(`Output saved to: ${outputPath}`);
  } catch (error) {
    console.error('Error converting dictionary:', error);
  }
};

// Run the conversion
convertDictionary();
