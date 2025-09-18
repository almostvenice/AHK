import { useState, useEffect, useRef, useCallback } from "react";
import { VirtualKeyboard } from "./VirtualKeyboard";
import { QuadrantSequenceDisplay } from "./QuadrantSequenceDisplay";
import { WordPredictions } from "./WordPredictions";
import { APISuggestions } from "./APISuggestions";
import { TextAreaWithClear } from "./TextAreaWithClear";
import {
  QuadrantKey,
  LetterKey,
  SpecialKey,
  SequenceItem,
} from "../types/keyboard";
import { SuggestionBadges } from "./SuggestionBadges";

const keyboardQuadrants: QuadrantKey[] = [
  { id: "q1", letters: "PWBM", position: 1 },
  { id: "q2", letters: "FGCY", position: 2 },
  { id: "q3", letters: "VJZKXQ", position: 3 },
  { id: "q4", letters: "UHLD", position: 4 },
  { id: "q5", letters: "REST", position: 5 },
  { id: "q6", letters: "AION", position: 6 },
];

const individualLetterKeys: LetterKey[] = [];
keyboardQuadrants.forEach((quadrant) => {
  quadrant.letters.split("").forEach((letter) => {
    individualLetterKeys.push({
      letter,
      quadrantId: quadrant.id,
      position: quadrant.position,
    });
  });
});

const specialKeys: SpecialKey[] = [
  { id: "space", label: "Space", action: " " },
  { id: "enter", label: "Enter", action: "\n" },
  { id: "period", label: ".", action: "." },
  { id: "comma", label: ",", action: "," },
];

export const Index = () => {
  const [text, setText] = useState("");
  const [suggestions, setSuggestions] = useState<string[]>([]);
  const [quadrantSequence, setQuadrantSequence] = useState<SequenceItem[]>([]);
  const [predictedWords, setPredictedWords] = useState<string[]>([]);
  const [selectedApiSuggestion, setSelectedApiSuggestion] = useState(0);
  const [selectedQuadrantPrediction, setSelectedQuadrantPrediction] =
    useState(0);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const [isTextareaFocused, setIsTextareaFocused] = useState(false);
  const [displayOption, setDisplayOption] = useState<'right' | 'bottom'>('right');

  useEffect(() => {
    if (text.trim() === "") {
      setSuggestions([]);
      return;
    }
    const debounceTimer = setTimeout(() => {
      fetchSuggestions(text);
    }, 500);
    return () => clearTimeout(debounceTimer);
  }, [text]);

  const fetchSuggestions = useCallback(async (prompt: string) => {
    setSuggestions(["Loading..."]);
    try {
      const suggestions = await window.wordPredictionAPI.fetchSuggestions(
        prompt
      );
      setSuggestions(suggestions);
    } catch (error) {
      console.error("Error fetching suggestions:", error);
      setSuggestions([]);
    }
  }, []);

  const insertSuggestion = useCallback(
    (suggestion: string) => {
      setText((prev) => {
        const lastSpaceIndex = prev.lastIndexOf(" ");
        if (lastSpaceIndex === -1) {
          return suggestion + " ";
        }
        const textBeforeLastWord = prev.substring(0, lastSpaceIndex + 1);
        return textBeforeLastWord + suggestion + " ";
      });
      setSuggestions([]);
      textareaRef.current?.focus();
    },
    [textareaRef]
  );

  const predictWordsFromQuadrants = useCallback(
    async (sequence: SequenceItem[]) => {
      if (sequence.length === 0) {
        setPredictedWords([]);
        return;
      }
      const positionSequence = sequence.map((item) => item.position);
      try {
        const predictions = await window.wordPredictionAPI.predictWords(
          positionSequence
        );
        setPredictedWords(predictions);
      } catch (error) {
        console.error("Error predicting words:", error);
        setPredictedWords(["the", "and", "to", "of", "in"]);
      }
    },
    []
  );

  const handleLetterClick = useCallback(
    (letterKey: LetterKey) => {
      const newItem = {
        position: letterKey.position,
        letter: letterKey.letter,
      };
      const newSequence = [...quadrantSequence, newItem];
      setQuadrantSequence(newSequence);
      setText((prev) => prev + letterKey.letter);
      predictWordsFromQuadrants(newSequence);
    },
    [quadrantSequence, predictWordsFromQuadrants]
  );

  const handleSpecialKeyClick = useCallback((key: SpecialKey) => {
    setText((prev) => prev + key.action);
    if (key.action === " " || key.action === "\n") {
      setQuadrantSequence([]);
      setPredictedWords([]);
    }
  }, []);

  const removeQuadrant = useCallback(
    (index: number) => {
      const newSequence = [...quadrantSequence];
      newSequence.splice(index, 1);
      setQuadrantSequence(newSequence);
      const newText = text.slice(0, -1);
      setText(newText);
      predictWordsFromQuadrants(newSequence);
    },
    [quadrantSequence, text, predictWordsFromQuadrants]
  );

  const clearQuadrantSequence = useCallback(() => {
    setQuadrantSequence([]);
    setPredictedWords([]);
  }, []);

  const insertPredictedWord = useCallback(
    (word: string) => {
      setText((prev) => {
        const lastSpaceIndex = prev.lastIndexOf(" ");
        if (lastSpaceIndex === -1) {
          return word + " ";
        }
        return prev.substring(0, lastSpaceIndex + 1) + word + " ";
      });
      clearQuadrantSequence();
      textareaRef.current?.focus();
    },
    [textareaRef, clearQuadrantSequence]
  );

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.key === "Tab" && suggestions.length > 0) {
        e.preventDefault();
        insertSuggestion(suggestions[0]);
      }
    },
    [suggestions, insertSuggestion]
  );

  useEffect(() => {
    setSelectedApiSuggestion(0);
  }, [suggestions]);

  useEffect(() => {
    setSelectedQuadrantPrediction(0);
  }, [predictedWords]);

  const clearText = useCallback(() => {
    setText("");
    setSuggestions([]);
    setQuadrantSequence([]);
    setPredictedWords([]);
    textareaRef.current?.focus();
  }, [textareaRef]);

  useEffect(() => {
    const handleGlobalKeyDown = (e: KeyboardEvent) => {
      if (isTextareaFocused) return;
      const key = e.key.toUpperCase();
      for (const letterKey of individualLetterKeys) {
        if (letterKey.letter === key) {
          handleLetterClick(letterKey);
          e.preventDefault();
          return;
        }
      }
      if (e.key === "ArrowUp" && suggestions.length > 0) {
        setSelectedApiSuggestion((prev) =>
          prev > 0 ? prev - 1 : suggestions.length - 1
        );
        e.preventDefault();
      } else if (e.key === "ArrowDown" && suggestions.length > 0) {
        setSelectedApiSuggestion((prev) =>
          prev < suggestions.length - 1 ? prev + 1 : 0
        );
        e.preventDefault();
      } else if (e.key === "ArrowLeft" && predictedWords.length > 0) {
        setSelectedQuadrantPrediction((prev) =>
          prev > 0 ? prev - 1 : predictedWords.length - 1
        );
        e.preventDefault();
      } else if (e.key === "ArrowRight" && predictedWords.length > 0) {
        setSelectedQuadrantPrediction((prev) =>
          prev < predictedWords.length - 1 ? prev + 1 : 0
        );
        e.preventDefault();
      } else if (e.key === " ") {
        if (predictedWords.length > 0) {
          insertPredictedWord(predictedWords[selectedQuadrantPrediction]);
        } else {
          handleSpecialKeyClick(specialKeys[0]);
        }
        e.preventDefault();
      } else if (e.key === "Enter") {
        handleSpecialKeyClick(specialKeys[1]);
        e.preventDefault();
      } else if (e.key === ".") {
        handleSpecialKeyClick(specialKeys[2]);
        e.preventDefault();
      } else if (e.key === ",") {
        handleSpecialKeyClick(specialKeys[3]);
        e.preventDefault();
      } else if (e.key === "Backspace" || e.key === "Delete") {
        if (quadrantSequence.length > 0) {
          const newSequence = [...quadrantSequence];
          newSequence.pop();
          setQuadrantSequence(newSequence);
          const newText = text.slice(0, -1);
          setText(newText);
          predictWordsFromQuadrants(newSequence);
        }
        e.preventDefault();
      } else if (e.key === "Escape") {
        clearQuadrantSequence();
        e.preventDefault();
      } else if (e.key === "Tab" && suggestions.length > 0) {
        insertSuggestion(suggestions[selectedApiSuggestion]);
        e.preventDefault();
      }
    };
    document.addEventListener("keydown", handleGlobalKeyDown);
    return () => {
      document.removeEventListener("keydown", handleGlobalKeyDown);
    };
  }, [
    isTextareaFocused,
    quadrantSequence,
    predictedWords,
    suggestions,
    selectedApiSuggestion,
    selectedQuadrantPrediction,
    text,
    handleLetterClick,
    insertPredictedWord,
    handleSpecialKeyClick,
    clearQuadrantSequence,
    removeQuadrant,
    insertSuggestion,
    predictWordsFromQuadrants,
  ]);

  const handleToggleDisplay = () => {
  setDisplayOption(prev => prev === 'right' ? 'bottom' : 'right');
};

  return (
    <div className="grid grid-cols-3 gap-4">
      <div style={{ position: 'absolute', top: '20px', right: '20px' }}>
        <button
          onClick={handleToggleDisplay}
          style={{
            background: "#61dafb",
            color: "#000",
            border: "none",
            padding: "10px 15px",
            borderRadius: "5px",
            cursor: "pointer"
          }}
        >
          Switch to {displayOption === 'right' ? 'bottom' : 'right'} view 
        </button>
      </div>
      {displayOption === 'right' ? (
        <>
          <div className="col-span-2 w-full ">
            <TextAreaWithClear
          text={text}
          setText={setText}
          clearText={clearText}
          textareaRef={textareaRef}
          handleKeyDown={handleKeyDown}
          setIsTextareaFocused={setIsTextareaFocused}
          rows={3}
        />
            <VirtualKeyboard
              keyboardQuadrants={keyboardQuadrants}
              individualLetterKeys={individualLetterKeys}
              specialKeys={specialKeys}
              handleLetterClick={handleLetterClick}
              handleSpecialKeyClick={handleSpecialKeyClick}
            />
          </div>
          <div className="col-span-1 p-4 pt-0">
            <QuadrantSequenceDisplay
              quadrantSequence={quadrantSequence}
              removeQuadrant={removeQuadrant}
              clearQuadrantSequence={clearQuadrantSequence}
            />
            <WordPredictions
              predictedWords={predictedWords}
              selectedQuadrantPrediction={selectedQuadrantPrediction}
              insertPredictedWord={insertPredictedWord}
            />
            {/* <APISuggestions
              suggestions={suggestions}
              selectedApiSuggestion={selectedApiSuggestion}
              insertSuggestion={insertSuggestion}
            /> */}
          </div>
        </>
      ) : (
        <div className="col-span-3 w-full">
          <div>
             <TextAreaWithClear
              text={text}
              setText={setText}
              clearText={clearText}
              textareaRef={textareaRef}
              handleKeyDown={handleKeyDown}
              setIsTextareaFocused={setIsTextareaFocused}
              rows={2}
            />
            <SuggestionBadges
              predictedWords={predictedWords}
              suggestions={suggestions}
              insertPredictedWord={insertPredictedWord}
              insertSuggestion={insertSuggestion}
            />
          </div>
           <VirtualKeyboard
          keyboardQuadrants={keyboardQuadrants}
          individualLetterKeys={individualLetterKeys}
          specialKeys={specialKeys}
          handleLetterClick={handleLetterClick}
          handleSpecialKeyClick={handleSpecialKeyClick}
        />
        </div>
      )}
      <div className="col-span-1 w-full h-full pb-[50px]">
         {displayOption === 'bottom' && (
        <div className="h-full">
        {/* <APISuggestions
          suggestions={suggestions}
          selectedApiSuggestion={selectedApiSuggestion}
          insertSuggestion={insertSuggestion}
        /> */}
        </div>
      )}
      </div>
    </div>
  );
};
