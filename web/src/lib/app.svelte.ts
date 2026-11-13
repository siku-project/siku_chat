import { inGame, sendNuiCallback } from '@/lib/nui'

/** In the browser, `?visible=0` starts hidden; in the game the ready call decides. */
const initialVisible = (): boolean => {
  if (!import.meta.env.DEV) {
    return false
  }

  return new URLSearchParams(window.location.search).get('visible') !== '0'
}

let visible = $state(initialVisible())

/** What the game shows. The game patches it, the interface only reads it. */
export const app = {
  get visible(): boolean {
    return visible
  },

  setVisible(value: boolean): void {
    visible = value
  },

  /** Asks the game to hide the interface; the browser hides it on its own. */
  close(): void {
    if (inGame) {
      void sendNuiCallback('close')
      return
    }

    visible = false
  },
}
