export const CHANNELS = ['public', 'staff'] as const
export const MESSAGE_TYPES = ['player', 'system', 'info', 'success', 'warning', 'error'] as const
export const INPUT_MODES = ['keyboard', 'mouse'] as const
export const POSITIONS = [
  'top-left',
  'top-center',
  'top-right',
  'left',
  'center',
  'right',
  'bottom-left',
  'bottom-center',
  'bottom-right',
] as const

export type ChatChannel = (typeof CHANNELS)[number]
export type ChatMessageType = (typeof MESSAGE_TYPES)[number]
export type ChatInputMode = (typeof INPUT_MODES)[number]
export type ChatPosition = (typeof POSITIONS)[number]

export interface ChatMessage {
  id: number
  type: ChatMessageType
  channel: ChatChannel
  timestamp: number
  text: string
  author?: string
  rank?: string
  icon?: string
}

/** A message as the game sends it: only the text is required. */
export interface ChatMessageInput {
  text: string
  type?: string
  channel?: string
  timestamp?: number
  author?: string
  rank?: string
  icon?: string
}

export interface ChatConfig {
  commandPrefix: string
  maxMessages: number
  maxMessageLength: number
  messageCooldown: number
  allowMessages: boolean
  inputMode: ChatInputMode
  position: ChatPosition
  passiveEnabled: boolean
  passiveDuration: number
  passiveMaxMessages: number
  passivePosition: ChatPosition
  historyEnable: boolean
  historyMax: number
}

export const DEFAULT_CONFIG: ChatConfig = {
  commandPrefix: '/',
  maxMessages: 100,
  maxMessageLength: 256,
  messageCooldown: 1000,
  allowMessages: true,
  inputMode: 'keyboard',
  position: 'top-left',
  passiveEnabled: true,
  passiveDuration: 10_000,
  passiveMaxMessages: 3,
  passivePosition: 'top-left',
  historyEnable: true,
  historyMax: 20,
}

export interface CommandParam {
  name: string
  description: string
  optional: boolean
}

export interface CommandDef {
  name: string
  description: string
  params: CommandParam[]
}

const isRecord = (value: unknown): value is Record<string, unknown> =>
  !!value && typeof value === 'object' && !Array.isArray(value)

export const isChannel = (value: unknown): value is ChatChannel =>
  typeof value === 'string' && (CHANNELS as readonly string[]).includes(value)

export const isMessageType = (value: unknown): value is ChatMessageType =>
  typeof value === 'string' && (MESSAGE_TYPES as readonly string[]).includes(value)

export const isInputMode = (value: unknown): value is ChatInputMode =>
  typeof value === 'string' && (INPUT_MODES as readonly string[]).includes(value)

export const isPosition = (value: unknown): value is ChatPosition =>
  typeof value === 'string' && (POSITIONS as readonly string[]).includes(value)

export const isMessageInput = (value: unknown): value is ChatMessageInput =>
  isRecord(value) && typeof value.text === 'string' && value.text.length > 0

export const isCommandDef = (value: unknown): value is Partial<CommandDef> & { name: string } =>
  isRecord(value) && typeof value.name === 'string' && value.name.length > 0

export const isConfigInput = (value: unknown): value is Partial<ChatConfig> => isRecord(value)

/** The shape every suggestion takes in the interface, whatever the game left out. */
export const normalizeCommand = (input: Partial<CommandDef> & { name: string }): CommandDef => ({
  name: input.name,
  description: typeof input.description === 'string' ? input.description : '',
  params: Array.isArray(input.params)
    ? input.params
        .filter((param): param is CommandParam => isRecord(param) && typeof param.name === 'string')
        .map((param) => ({
          name: param.name,
          description: typeof param.description === 'string' ? param.description : '',
          optional: param.optional === true,
        }))
    : [],
})

/** Keeps the known fields of a configuration, with their types, over the current one. */
export const mergeConfig = (current: ChatConfig, input: Partial<ChatConfig>): ChatConfig => {
  const next = { ...current }

  for (const key of Object.keys(DEFAULT_CONFIG) as (keyof ChatConfig)[]) {
    const value = input[key]

    if (value === undefined) {
      continue
    }

    if (key === 'inputMode') {
      if (isInputMode(value)) {
        next.inputMode = value
      }
    } else if (key === 'position' || key === 'passivePosition') {
      if (isPosition(value)) {
        next[key] = value
      }
    } else if (typeof value === typeof DEFAULT_CONFIG[key]) {
      ;(next as Record<keyof ChatConfig, unknown>)[key] = value
    }
  }

  return next
}
