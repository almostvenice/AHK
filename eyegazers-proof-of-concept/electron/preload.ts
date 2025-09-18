import { ipcRenderer, contextBridge } from 'electron'

// --------- Expose some API to the Renderer process ---------
contextBridge.exposeInMainWorld('ipcRenderer', {
  on(...args: Parameters<typeof ipcRenderer.on>) {
    const [channel, listener] = args
    return ipcRenderer.on(channel, (event, ...args) => listener(event, ...args))
  },
  off(...args: Parameters<typeof ipcRenderer.off>) {
    const [channel, ...omit] = args
    return ipcRenderer.off(channel, ...omit)
  },
  send(...args: Parameters<typeof ipcRenderer.send>) {
    const [channel, ...omit] = args
    return ipcRenderer.send(channel, ...omit)
  },
  invoke(...args: Parameters<typeof ipcRenderer.invoke>) {
    const [channel, ...omit] = args
    return ipcRenderer.invoke(channel, ...omit)
  },

  // You can expose other APTs you need here.
  // ...
})

// Expose specific API methods for word prediction app
contextBridge.exposeInMainWorld('wordPredictionAPI', {
  // Fetch suggestions from OpenAI API
  fetchSuggestions: (prompt: string) => {
    return ipcRenderer.invoke('fetch-suggestions', prompt)
  },
  
  // Predict words based on quadrant sequence
  predictWords: (positionSequence: number[]) => {
    return ipcRenderer.invoke('predict-words', positionSequence)
  }
})
