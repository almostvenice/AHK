import { app, BrowserWindow, ipcMain } from "electron";
import { createRequire } from "node:module";
import { fileURLToPath as fileURLToPath$1 } from "node:url";
import path$1 from "node:path";
import path, { dirname } from "path";
import fs from "fs";
import { fileURLToPath } from "url";
const envPath = path.join(app.getAppPath(), ".env");
let OPENAI_API_KEY = "";
if (process.env.VITE_OPENAI_API_KEY) {
  OPENAI_API_KEY = process.env.VITE_OPENAI_API_KEY;
} else if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, "utf8");
  const match = envContent.match(/VITE_OPENAI_API_KEY=(.+)/);
  if (match && match[1]) {
    OPENAI_API_KEY = match[1].trim();
  }
}
async function fetchSuggestions(prompt) {
  var _a;
  if (!OPENAI_API_KEY) {
    console.error("OpenAI API key not found");
    return [];
  }
  try {
    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json",
        "Accept": "text/event-stream"
      },
      body: JSON.stringify({
        model: "gpt-4o",
        input: prompt,
        instructions: 'You are an autocomplete engine. Generate 5 different COMPLETE single-word suggestions for what might come next after this text. Never return partial words or single letters. Return ONLY complete words separated by commas, like: "complete, words, suggestions, only, please".',
        temperature: 0.7,
        max_output_tokens: 20,
        stream: true
      })
    });
    if (!response.ok) {
      const errorData = await response.json();
      console.error("API Error:", errorData);
      return [];
    }
    const reader = (_a = response.body) == null ? void 0 : _a.getReader();
    if (!reader) {
      console.error("Failed to get reader from response");
      return [];
    }
    let accumulatedText = "";
    while (true) {
      const { done, value } = await reader.read();
      if (done) {
        break;
      }
      const chunk = new TextDecoder().decode(value);
      const lines = chunk.split("\n");
      for (const line of lines) {
        if (line.startsWith("data: ")) {
          try {
            const eventData = JSON.parse(line.substring(6));
            if (eventData.type === "response.output_text.delta") {
              accumulatedText += eventData.delta || "";
            }
          } catch (e) {
            console.error("Error parsing SSE data:", e);
          }
        }
      }
    }
    if (accumulatedText) {
      const finalSuggestions = accumulatedText.split(",").map((word) => word.trim()).filter((word) => word.length > 0);
      console.log("Final parsed suggestions:", finalSuggestions);
      return finalSuggestions;
    } else {
      return [];
    }
  } catch (error) {
    console.error("Error fetching suggestions:", error);
    return [];
  }
}
const __filename = fileURLToPath(import.meta.url);
const __dirname$1 = dirname(__filename);
let wordDictionary = [];
function loadDictionary() {
  try {
    const possiblePaths = [
      path.join(__dirname$1, "word-dictionary.json"),
      path.join(__dirname$1, "..", "services", "word-dictionary.json"),
      path.join(app.getAppPath(), "electron", "services", "word-dictionary.json"),
      // Keep the original paths as fallbacks
      path.join(app.getAppPath(), "src", "assets", "word-dictionary.json"),
      path.join(app.getAppPath(), "dist", "assets", "word-dictionary.json"),
      path.join(process.env.APP_ROOT || "", "src", "assets", "word-dictionary.json"),
      path.join(process.env.APP_ROOT || "", "dist", "assets", "word-dictionary.json")
    ];
    let dictionaryData = null;
    for (const dictionaryPath of possiblePaths) {
      if (fs.existsSync(dictionaryPath)) {
        console.log(`Found dictionary at: ${dictionaryPath}`);
        dictionaryData = fs.readFileSync(dictionaryPath, "utf8");
        break;
      }
    }
    if (!dictionaryData) {
      throw new Error("Dictionary file not found in any of the expected locations");
    }
    wordDictionary = JSON.parse(dictionaryData);
    console.log(`Loaded ${wordDictionary.length} words into dictionary`);
  } catch (error) {
    console.error("Error loading dictionary:", error);
  }
}
function predictWordsFromQuadrants(positionSequence) {
  if (positionSequence.length === 0) {
    return getDefaultWords(10);
  }
  if (wordDictionary.length === 0) {
    loadDictionary();
    if (wordDictionary.length === 0) {
      return getDefaultWords(10);
    }
  }
  const positionString = positionSequence.join("");
  let predictions = [];
  const exactMatches = wordDictionary.filter((entry) => entry.quadrant === positionString).sort((a, b) => a.rank - b.rank).slice(0, 10).map((entry) => entry.word);
  if (exactMatches.length > 0) {
    predictions = exactMatches;
  } else {
    const getThresholdForLength = (length) => {
      switch (length) {
        case 1:
          return 1;
        case 2:
          return 0.5;
        case 3:
          return 0.67;
        case 4:
          return 0.75;
        case 5:
        case 6:
          return 0.7;
        case 7:
        case 8:
          return 0.65;
        default:
          return 0.6;
      }
    };
    const matchThreshold = getThresholdForLength(positionString.length);
    console.log(`Using match threshold of ${(matchThreshold * 100).toFixed(1)}% for sequence length ${positionString.length}`);
    const similarityMatches = wordDictionary.map((entry) => {
      if (entry.quadrant.length < positionString.length * 0.75 || entry.quadrant.length > positionString.length * 1.25) {
        return { entry, score: 0 };
      }
      let matchCount = 0;
      const minLength = Math.min(positionString.length, entry.quadrant.length);
      for (let i = 0; i < minLength; i++) {
        if (positionString[i] === entry.quadrant[i]) {
          matchCount++;
        }
      }
      const score = matchCount / positionString.length;
      return { entry, score };
    }).filter((item) => item.score >= matchThreshold).sort((a, b) => {
      if (b.score !== a.score) {
        return b.score - a.score;
      }
      return a.entry.rank - b.entry.rank;
    }).slice(0, 10).map((item) => item.entry.word);
    if (similarityMatches.length > 0) {
      predictions = similarityMatches;
    } else {
      const partialMatches = wordDictionary.filter((entry) => entry.quadrant.startsWith(positionString)).sort((a, b) => a.rank - b.rank).slice(0, 10).map((entry) => entry.word);
      if (partialMatches.length > 0) {
        predictions = partialMatches;
      } else if (positionString.length >= 3) {
        const endMatches = wordDictionary.filter((entry) => entry.quadrant.includes(positionString.slice(-3))).sort((a, b) => a.rank - b.rank).slice(0, 10).map((entry) => entry.word);
        predictions = endMatches;
      }
    }
  }
  return ensureExactlyTenWords(predictions);
}
function ensureExactlyTenWords(predictions) {
  if (predictions.length === 10) {
    return predictions;
  }
  if (predictions.length > 10) {
    return predictions.slice(0, 10);
  }
  const defaultWords = getDefaultWords(10 - predictions.length);
  return [...predictions, ...defaultWords];
}
function getDefaultWords(count) {
  const commonWords = [
    "the",
    "and",
    "to",
    "of",
    "in",
    "that",
    "have",
    "for",
    "not",
    "on",
    "with",
    "he",
    "as",
    "you",
    "do",
    "at",
    "this",
    "but",
    "his",
    "by",
    "from",
    "they",
    "we",
    "say",
    "her",
    "she",
    "or",
    "an",
    "will",
    "my"
  ];
  const result = [];
  for (let i = 0; i < count; i++) {
    result.push(commonWords[i % commonWords.length]);
  }
  return result;
}
createRequire(import.meta.url);
const __dirname = path$1.dirname(fileURLToPath$1(import.meta.url));
process.env.APP_ROOT = path$1.join(__dirname, "..");
const VITE_DEV_SERVER_URL = process.env["VITE_DEV_SERVER_URL"];
const MAIN_DIST = path$1.join(process.env.APP_ROOT, "dist-electron");
const RENDERER_DIST = path$1.join(process.env.APP_ROOT, "dist");
process.env.VITE_PUBLIC = VITE_DEV_SERVER_URL ? path$1.join(process.env.APP_ROOT, "public") : RENDERER_DIST;
let win;
function createWindow() {
  win = new BrowserWindow({
    icon: path$1.join(process.env.VITE_PUBLIC, "electron-vite.svg"),
    webPreferences: {
      preload: path$1.join(__dirname, "preload.mjs"),
      nodeIntegration: false,
      contextIsolation: true
    }
  });
  win.webContents.on("did-finish-load", () => {
    win == null ? void 0 : win.webContents.send("main-process-message", (/* @__PURE__ */ new Date()).toLocaleString());
    loadDictionary();
  });
  if (VITE_DEV_SERVER_URL) {
    win.loadURL(VITE_DEV_SERVER_URL);
  } else {
    win.loadFile(path$1.join(RENDERER_DIST, "index.html"));
  }
}
function setupIpcHandlers() {
  ipcMain.handle("fetch-suggestions", async (_, prompt) => {
    console.log("Fetching suggestions for:", prompt);
    try {
      const suggestions = await fetchSuggestions(prompt);
      return suggestions;
    } catch (error) {
      console.error("Error in fetch-suggestions handler:", error);
      return [];
    }
  });
  ipcMain.handle("predict-words", (_, positionSequence) => {
    console.log("Predicting words for sequence:", positionSequence);
    try {
      const predictions = predictWordsFromQuadrants(positionSequence);
      return predictions;
    } catch (error) {
      console.error("Error in predict-words handler:", error);
      return [];
    }
  });
}
app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
    win = null;
  }
});
app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
app.whenReady().then(() => {
  setupIpcHandlers();
  createWindow();
});
export {
  MAIN_DIST,
  RENDERER_DIST,
  VITE_DEV_SERVER_URL
};
