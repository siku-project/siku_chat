import type { IconName } from '@siku/ui'
import { m } from '@/lib/i18n.svelte'
import type { ChatMessageType } from './types'

export interface Voice {
  icon: IconName
  label: () => string
}

/** The messages spoken by the server or the staff, shown with their icon and badge instead of an author. */
export const VOICES: Partial<Record<ChatMessageType, Voice>> = {
  server: { icon: 'server', label: () => m.chat_server_badge() },
  staff: { icon: 'shield', label: () => m.chat_staff_badge() },
}
