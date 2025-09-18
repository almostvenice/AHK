# Keyboard Logic Requirements

## Overview
This document outlines the logic and functionality of the quadrant-based virtual keyboard system implemented in the word prediction application.

## Keyboard Structure

### Quadrant Layout
- The keyboard is divided into 5 quadrants, each containing specific letters:
  - Quadrant 1: Q, W, A, S, Z
  - Quadrant 2: E, R, D, F, X, C
  - Quadrant 3: T, Y, G, H, V
  - Quadrant 4: U, I, J, K, B, M
  - Quadrant 5: O, P, L, N

### Special Keys
- Space: Inserts a space character or selects the currently highlighted predicted word
- Enter: Inserts a new line
- Period: Inserts a period character
- Comma: Inserts a comma character

## Core Functionality

### Quadrant Selection Logic
1. When a user clicks on a quadrant or presses a key that belongs to a quadrant, that quadrant is added to the current sequence.
2. The application maintains a "quadrant sequence" representing the user's input pattern.
3. Each letter on a standard keyboard is mapped to its corresponding quadrant position.
4. As quadrants are selected, the system predicts possible words based on the sequence.

### Word Prediction System
1. **Quadrant-Based Prediction**:
   - The system maps common words to their corresponding quadrant sequences.
   - For example, the word "the" maps to quadrant sequence "1-3-2" (t=3, h=3, e=2).
   - As the user selects quadrants, the system identifies words that match the current sequence.
   - Predictions are shown in real-time and can be selected with the space key or by clicking.

2. **API-Based Suggestions**:
   - The system also fetches word suggestions from an external API (OpenAI).
   - These suggestions are based on the current text context rather than quadrant sequences.
   - API suggestions can be selected using the Tab key or by clicking.

### Navigation and Selection
- Arrow keys allow navigation between different suggestions:
  - Up/Down: Navigate through API suggestions
  - Left/Right: Navigate through quadrant-based predictions
- Tab key: Select the currently highlighted API suggestion
- Space key: Select the currently highlighted quadrant prediction or insert a space
- Backspace/Delete: Remove the last quadrant from the sequence
- Escape: Clear the entire quadrant sequence

## User Interaction Flow
1. User selects quadrants by clicking or pressing corresponding keys
2. System displays predicted words based on the quadrant sequence
3. User can:
   - Continue selecting quadrants to refine predictions
   - Select a predicted word (automatically adds a space after)
   - Use special keys for punctuation and formatting
   - Clear or modify the quadrant sequence
   - Use API suggestions for more context-aware completions

## Technical Implementation
- The system uses React hooks (useState, useEffect, useRef) for state management
- Keyboard events are captured globally when the text area is not focused
- The prediction algorithm uses a combination of:
  - Direct mapping of quadrant sequences to common words
  - Prefix matching for partial sequences
  - Fallback predictions for sequences with no exact matches

## Accessibility Considerations
- Visual feedback shows the current quadrant sequence
- Selected suggestions are highlighted
- Keyboard shortcuts provide alternative input methods
- Clear visual distinction between quadrants and special keys
