// Define las interfaces para la estructura del teclado
export interface QuadrantKey {
  id: string;
  letters: string;
  position: number;
}

export interface LetterKey {
  letter: string;
  quadrantId: string;
  position: number;
}

export interface SpecialKey {
  id: string;
  label: string;
  action: string;
}

// Define la interfaz para los elementos de la secuencia de cuadrantes
export interface SequenceItem {
  position: number;
  letter: string;
}

// Interfaz para la API de predicción
declare global {
  interface Window {
    wordPredictionAPI: {
      fetchSuggestions: (prompt: string) => Promise<string[]>;
      predictWords: (positionSequence: number[]) => Promise<string[]>;
    };
  }
}