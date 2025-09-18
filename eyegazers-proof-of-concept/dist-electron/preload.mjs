"use strict";
const electron = require("electron");
electron.contextBridge.exposeInMainWorld("ipcRenderer", {
  on(...args) {
    const [channel, listener] = args;
    return electron.ipcRenderer.on(channel, (event, ...args2) => listener(event, ...args2));
  },
  off(...args) {
    const [channel, ...omit] = args;
    return electron.ipcRenderer.off(channel, ...omit);
  },
  send(...args) {
    const [channel, ...omit] = args;
    return electron.ipcRenderer.send(channel, ...omit);
  },
  invoke(...args) {
    const [channel, ...omit] = args;
    return electron.ipcRenderer.invoke(channel, ...omit);
  }
  // You can expose other APTs you need here.
  // ...
});
electron.contextBridge.exposeInMainWorld("wordPredictionAPI", {
  // Fetch suggestions from OpenAI API
  fetchSuggestions: (prompt) => {
    return electron.ipcRenderer.invoke("fetch-suggestions", prompt);
  },
  // Predict words based on quadrant sequence
  predictWords: (positionSequence) => {
    return electron.ipcRenderer.invoke("predict-words", positionSequence);
  }
});
