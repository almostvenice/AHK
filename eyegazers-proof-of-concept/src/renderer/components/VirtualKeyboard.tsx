import { LetterKey, QuadrantKey, SpecialKey } from "../types/keyboard";
import "../VirtualKeyboard.css";

interface VirtualKeyboardProps {
  keyboardQuadrants: QuadrantKey[];
  individualLetterKeys: LetterKey[];
  specialKeys: SpecialKey[];
  handleLetterClick: (key: LetterKey) => void;
  handleSpecialKeyClick: (key: SpecialKey) => void;
}

export const VirtualKeyboard: React.FC<VirtualKeyboardProps> = ({
  keyboardQuadrants,
  individualLetterKeys,
  specialKeys,
  handleLetterClick,
  handleSpecialKeyClick,
}) => {
  return (
    <div className="w-full">
      <div>
        <div className="keyboard-row">
          {keyboardQuadrants.slice(0, 3).map((quadrant) => (
            <div key={quadrant.id} className="quadrant">
              <div className="quadrant-letters">
                {quadrant.letters.split("").map((letter) => {
                  const letterKey = individualLetterKeys.find(
                    (l) => l.letter === letter && l.quadrantId === quadrant.id
                  );
                  return (
                    <button
                      key={`${quadrant.id}-${letter}`}
                      className="keyboard-letter"
                      onClick={() => handleLetterClick(letterKey!)}
                      title={`Group ${quadrant.position}`}
                    >
                      <span className="letter">{letter}</span>
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
        <div className="keyboard-row">
          {keyboardQuadrants.slice(3).map((quadrant) => (
            <div key={quadrant.id} className="quadrant">
              <div className="quadrant-letters">
                {quadrant.letters.split("").map((letter) => {
                  const letterKey = individualLetterKeys.find(
                    (l) => l.letter === letter && l.quadrantId === quadrant.id
                  );
                  return (
                    <button
                      key={`${quadrant.id}-${letter}`}
                      className="keyboard-letter"
                      onClick={() => handleLetterClick(letterKey!)}
                      title={`Group ${quadrant.position}`}
                    >
                      <span className="letter">{letter}</span>
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
        <div className="grid grid-cols-3 gap-8 mb-4 w-full">
          <button
            onClick={() => handleSpecialKeyClick(specialKeys[0])}
            className="special-key col-span-2 w-full space-key"
          >
            {specialKeys[0].label}
          </button>
          <div className="col-span-1 justify-between">
            <div className="grid grid-cols-3 gap-4">
              {specialKeys
              .filter((key) => key.id !== "space")
              .map((key) => (
                <div
                  key={key.id}
                  className="w-full mb-2 col-span-1"
                >
                  <button
                    key={key.id}
                    className="special-key"
                    onClick={() => handleSpecialKeyClick(key)}
                  >
                    {key.label}
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
