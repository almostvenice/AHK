import React from "react";

interface SuggestionBadgesProps {
  predictedWords: string[];
  suggestions: string[];
  insertPredictedWord: (word: string) => void;
  insertSuggestion: (suggestion: string) => void;
}

export const SuggestionBadges: React.FC<SuggestionBadgesProps> = ({
  predictedWords,
  suggestions,
  insertPredictedWord,
  insertSuggestion,
}) => {
  const allSuggestions = [...predictedWords, ...suggestions].slice(0, 8); // Combina y limita a 8

  return (
    <div
      style={{
        display: "flex",
        gap: "10px",
        flexWrap: "wrap",
        marginBottom: "10px",
      }}
    >
      {allSuggestions.length > 0 ? (
        allSuggestions.map((word, index) => (
          <div
            style={{
              padding: "15px 20px",
              background: "#333",
              color: "#e0e0e0",
              border: "1px solid #444",
              borderRadius: "20px",
              cursor: "pointer",
              transition: "background 0.2s ease",
              fontSize: "18px",
            }}
          >
            <span style={{ fontSize: "24px" }}>{word} </span>
            <button
              style={{
                background: "transparent",
                border: "none",
                color: "#e0e0e0",
                padding: "0 8px",
                marginLeft: "65px",
              }}
              className="hover-effect"
              key={index}
              onClick={() => {
                if (predictedWords.includes(word)) {
                  insertPredictedWord(word);
                } else {
                  insertSuggestion(word);
                }
              }}
            >
              <span style={{ fontSize: "24px" }}>➤</span>
            </button>
          </div>
        ))
      ) : (
        <span style={{ color: "#888", fontSize: "14px" }}>
          No suggestions available
        </span>
      )}
    </div>
  );
};
