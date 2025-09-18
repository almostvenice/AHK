import { app } from 'electron';
import path from 'path';
import fs from 'fs';

// Load environment variables from .env file
const envPath = path.join(app.getAppPath(), '.env');
let OPENAI_API_KEY = '';

// Try to load API key from environment variables or .env file
if (process.env.VITE_OPENAI_API_KEY) {
  OPENAI_API_KEY = process.env.VITE_OPENAI_API_KEY;
} else if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf8');
  const match = envContent.match(/VITE_OPENAI_API_KEY=(.+)/);
  if (match && match[1]) {
    OPENAI_API_KEY = match[1].trim();
  }
}

/**
 * Fetches word suggestions from OpenAI API
 * @param prompt The text prompt to generate suggestions for
 * @returns A promise that resolves to an array of suggestion strings
 */
export async function fetchSuggestions(prompt: string): Promise<string[]> {
  if (!OPENAI_API_KEY) {
    console.error('OpenAI API key not found');
    return [];
  }

  try {
    // Create a fetch request with streaming enabled
    const response = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      },
      body: JSON.stringify({
        model: 'gpt-4o',
        input: prompt,
        instructions: 'You are an autocomplete engine. Generate 5 different COMPLETE single-word suggestions for what might come next after this text. Never return partial words or single letters. Return ONLY complete words separated by commas, like: "complete, words, suggestions, only, please".',
        temperature: 0.7,
        max_output_tokens: 20,
        stream: true,
      }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('API Error:', errorData);
      return [];
    }

    // Get the reader from the response body stream
    const reader = response.body?.getReader();
    if (!reader) {
      console.error('Failed to get reader from response');
      return [];
    }

    // Accumulated text from the stream
    let accumulatedText = '';

    // Process the stream
    while (true) {
      const { done, value } = await reader.read();

      if (done) {
        break;
      }

      // Convert the chunk to text
      const chunk = new TextDecoder().decode(value);

      // Look for data lines in the SSE format
      const lines = chunk.split('\n');
      for (const line of lines) {
        if (line.startsWith('data: ')) {
          try {
            const eventData = JSON.parse(line.substring(6));

            // Check for text delta events
            if (eventData.type === 'response.output_text.delta') {
              accumulatedText += eventData.delta || '';
            }
          } catch (e) {
            console.error('Error parsing SSE data:', e);
          }
        }
      }
    }

    // Final processing of accumulated text
    if (accumulatedText) {
      const finalSuggestions = accumulatedText
        .split(',')
        .map(word => word.trim())
        .filter(word => word.length > 0);

      console.log('Final parsed suggestions:', finalSuggestions);
      return finalSuggestions;
    } else {
      return [];
    }
  } catch (error) {
    console.error('Error fetching suggestions:', error);
    return [];
  }
}
