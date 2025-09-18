import "../VirtualKeyboard.css";
import { SequenceItem } from "../types/keyboard";

interface QuadrantSequenceDisplayProps {
  quadrantSequence: SequenceItem[];
  removeQuadrant: (index: number) => void;
  clearQuadrantSequence: () => void;
}

export const QuadrantSequenceDisplay: React.FC<
  QuadrantSequenceDisplayProps
> = ({ quadrantSequence, removeQuadrant, clearQuadrantSequence }) => {
  return (
    <div
      className="quadrant-sequence pt-0 mt-0"
      style={{
        marginTop: 0,
        width: "100%",
        minHeight: "130px",
        overflowY: "auto",
        background: "#2d2d2d",
        border: "1px solid #444",
        borderRadius: "5px",
        marginBottom: "20px",
      }}
    >
      <div className="mt-0 flex justify-between items-center w-full">
        <strong style={{ color: "#61dafb" }}>Quadrant Sequence:</strong>
        <button
          onClick={clearQuadrantSequence}
          style={{
            background: "#333",
            color: "#e0e0e0",
            border: "1px solid #555",
            borderRadius: "3px",
            padding: "2px 8px",
            cursor: "pointer",
          }}
        >
          Clear
        </button>
      </div>
      <div
        style={{
          display: "flex",
          flexWrap: "wrap",
          gap: "5px",
          maxHeight: "80px",
          overflowY: "auto",
        }}
      >
        {quadrantSequence.length > 0 ? (
          quadrantSequence.map((item, index) => (
            <div key={index} className="quadrant-chip">
              <span>
                {item.position} {item.letter}
              </span>
              <button onClick={() => removeQuadrant(index)}> X</button>
            </div>
          ))
        ) : (
          <div style={{ color: "#888", fontSize: "14px" }}>
            No letters selected
          </div>
        )}
      </div>
    </div>
  );
};
