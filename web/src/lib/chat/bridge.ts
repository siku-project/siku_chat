import { sendNuiCallback, sendNuiEvent } from '@/lib/nui'

/** Every call the interface makes to the game, by name. The browser playground swaps them for local echoes. */
export const game = {
  ready: () => sendNuiCallback('ready'),
  close: () => sendNuiEvent('close'),
  sendMessage: (text: string) => sendNuiEvent('sendMessage', { text }),
  sendStaffMessage: (text: string) => sendNuiEvent('sendStaffMessage', { text }),
  command: (raw: string) => sendNuiEvent('command', { raw }),
}
