import React from "react";

interface TextAreaWithClearProps {
  text: string;
  setText: (text: string) => void;
  clearText: () => void;
  textareaRef: React.RefObject<HTMLTextAreaElement>;
  handleKeyDown: (e: React.KeyboardEvent<HTMLTextAreaElement>) => void;
  setIsTextareaFocused: (isFocused: boolean) => void;
  rows: number;
}

export const TextAreaWithClear: React.FC<TextAreaWithClearProps> = ({
  text,
  setText,
  clearText,
  textareaRef,
  handleKeyDown,
  setIsTextareaFocused,
  rows
}) => {
  return (
    <div style={{ position: "relative", marginBottom: "10px" }}>
      <textarea
        ref={textareaRef}
        value={text.toUpperCase()}
        onChange={(e) => setText(e.target.value)}
        onKeyDown={handleKeyDown}
        onFocus={() => setIsTextareaFocused(true)}
        onBlur={() => setIsTextareaFocused(false)}
        rows={rows}
        style={{
          width: "100%",
          fontSize: 24,
          backgroundColor: "#2d2d2d",
          color: "#e0e0e0",
          border: "1px solid #444",
          borderRadius: "4px",
          outline: "none",
        }}
      />
      {text && (
        <button
          onClick={clearText}
          style={{
            position: "absolute",
            right: "10px",
            top: "10px",
            background: "#444",
            color: "#e0e0e0",
            border: "1px solid #666",
            borderRadius: "5px",
            width: "80px",
            height: "40px",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "16px",
          }}
          title="Clear text"
        >
          Clear
        </button>
      )}
    </div>
  );
};
