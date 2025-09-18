interface APISuggestionsProps {
  suggestions: string[];
  selectedApiSuggestion: number;
  insertSuggestion: (suggestion: string) => void;
}

export const APISuggestions: React.FC<APISuggestionsProps> = ({
  suggestions,
  selectedApiSuggestion,
  insertSuggestion,
}) => {
  return (
    <div
      style={{
        background: "#2d2d2d",
        border: "1px solid #444",
        padding: 10,
        borderRadius: 5,
        width: "100%",
        minHeight: "150px",
        height: "100%",
        overflowY: "auto",
        flexShrink: 0,
      }}
    >
      <strong style={{ color: "#61dafb" }}>API Suggestions:</strong>
      <ul
        style={{
          listStyleType: "none",
          padding: 0,
          overflowY: "auto",
          maxHeight: "calc(100% - 30px)",
        }}
      >
        {suggestions.length > 0 ? (
          suggestions.map((s, i) => (
            <li key={i} style={{ margin: "5px 0" }}>
              <button
                onClick={() => insertSuggestion(s)}
                style={{
                  padding: "5px 10px",
                  background: i === selectedApiSuggestion ? "#61dafb" : "#333",
                  color: i === selectedApiSuggestion ? "#000" : "#e0e0e0",
                  border: "1px solid #555",
                  borderRadius: "3px",
                  cursor: "pointer",
                  width: "100%",
                  textAlign: "left",
                }}
              >
                {i === 0 && <span style={{ marginRight: 5 }}>⇥</span>}
                {s}
              </button>
            </li>
          ))
        ) : (
          <div style={{ color: "#888", fontSize: "14px" }}>
            No API suggestions available
          </div>
        )}
      </ul>
    </div>
  );
};
