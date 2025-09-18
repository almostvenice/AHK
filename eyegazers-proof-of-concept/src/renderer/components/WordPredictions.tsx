import "../VirtualKeyboard.css";

interface WordPredictionsProps {
  predictedWords: string[];
  selectedQuadrantPrediction: number;
  insertPredictedWord: (word: string) => void;
}

export const WordPredictions: React.FC<WordPredictionsProps> = ({
  predictedWords,
  selectedQuadrantPrediction,
  insertPredictedWord,
}) => {
  return (
    <div
      className="word-predictions"
      style={{
        background: "#2d2d2d",
        border: "1px solid #444",
        padding: 10,
        borderRadius: 5,
        width: "100%",
        height: "300px",
        minHeight: "300px",
        maxHeight: "300px",
        overflowY: "auto",
        flexShrink: 0,
        marginBottom: "20px",
      }}
    >
      <strong style={{ color: "#61dafb" }}>Predicted Words:</strong>
      <div
        style={{
          marginTop: "10px",
          overflowY: "auto",
          maxHeight: "calc(100% - 30px)",
        }}
      >
        {predictedWords.length > 0 ? (
          <div
            style={{
              display: "flex",
              flexWrap: "wrap",
              gap: "10px",
              justifyContent: "space-between",
            }}
          >
            {predictedWords.slice(0, 8).map((word, index) => (
              <div
                key={index}
                style={{
                  display: "flex",
                  alignItems: "center",
                  width: "48%",
                  marginBottom: "10px",
                  background:
                    index === selectedQuadrantPrediction ? "#2a2a2a" : "#333",
                  padding: "8px",
                  borderRadius: "3px",
                }}
              >
                <span
                  style={{
                    flexGrow: 1,
                    textAlign: "left",
                    paddingLeft: "5px",
                    color:
                      index === selectedQuadrantPrediction
                        ? "#61dafb"
                        : "#e0e0e0",
                  }}
                >
                  {word}
                </span>
                <button
                  onClick={() => insertPredictedWord(word)}
                  style={{
            padding: "15px 20px", // Aumentar el padding para hacerlo más grande
            background:
              index === selectedQuadrantPrediction ? "#61dafb" : "#444",
            color: index === selectedQuadrantPrediction ? "#000" : "#fff",
            border: "none",
            borderRadius: "3px",
            cursor: "pointer",
            marginLeft: "10px",
            height: "auto",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "24px", // Aumentar el tamaño del ícono o texto
          }}
                >
                  <span style={{ fontSize: "24px" }}>➤</span>
                </button>
              </div>
            ))}
          </div>
        ) : (
          <div
            style={{
              color: "#888",
              textAlign: "center",
              marginTop: "20px",
            }}
          >
            No predictions available
          </div>
        )}
      </div>
    </div>
  );
};
