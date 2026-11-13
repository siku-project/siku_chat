import { RESOURCE } from '@/lib/nui'
import { createHistory } from './history'
import {
  DEFAULT_CONFIG,
  isChannel,
  isCommandDef,
  isConfigInput,
  isMessageInput,
  isMessageType,
  mergeConfig,
  normalizeCommand,
  type ChatChannel,
  type ChatConfig,
  type ChatMessage,
  type ChatMessageInput,
  type CommandDef,
} from './types'

interface PassiveEntry {
  message: ChatMessage
  timer: number
}

interface NuiMessage {
  action?: unknown
  message?: unknown
  config?: unknown
  suggestion?: unknown
  name?: unknown
  state?: unknown
  enabled?: unknown
}

interface SyncState {
  suggestions?: unknown
  messages?: unknown
}

const PREFIX = `${RESOURCE}:nui:`

let visible = $state(false)
let mode = $state<ChatChannel>('public')
let config = $state<ChatConfig>({ ...DEFAULT_CONFIG })
let messages = $state<ChatMessage[]>([])
let commands = $state<CommandDef[]>([])
let passive = $state<PassiveEntry[]>([])
let nextId = 1

export const history = createHistory()

const removePassive = (id: number): void => {
  const entry = passive.find((candidate) => candidate.message.id === id)

  if (!entry) {
    return
  }

  window.clearTimeout(entry.timer)
  passive = passive.filter((candidate) => candidate !== entry)
}

const clearPassive = (): void => {
  for (const entry of passive) {
    window.clearTimeout(entry.timer)
  }

  passive = []
}

const insert = (input: ChatMessageInput, allowPassive: boolean): ChatMessage => {
  const message: ChatMessage = {
    id: nextId++,
    type: isMessageType(input.type) ? input.type : 'system',
    channel: isChannel(input.channel) ? input.channel : 'public',
    timestamp: typeof input.timestamp === 'number' ? input.timestamp : Date.now(),
    text: input.text,
    author: typeof input.author === 'string' ? input.author : undefined,
    rank: typeof input.rank === 'string' ? input.rank : undefined,
    icon: typeof input.icon === 'string' ? input.icon : undefined,
  }

  messages = [...messages, message].slice(-Math.max(config.maxMessages, 1))

  if (allowPassive && config.passiveEnabled && !visible && message.channel === 'public') {
    const timer = window.setTimeout(() => removePassive(message.id), config.passiveDuration)

    passive = [...passive, { message, timer }]

    while (passive.length > Math.max(config.passiveMaxMessages, 1)) {
      const [oldest, ...rest] = passive

      if (oldest) {
        window.clearTimeout(oldest.timer)
      }

      passive = rest
    }
  }

  return message
}

/** Everything the game tells the chat, and what the player sees of it. */
export const store = {
  get visible(): boolean {
    return visible
  },
  get mode(): ChatChannel {
    return mode
  },
  get config(): ChatConfig {
    return config
  },
  get messages(): ChatMessage[] {
    return messages
  },
  get commands(): CommandDef[] {
    return commands
  },
  get visibleMessages(): ChatMessage[] {
    return messages.filter((message) => message.channel === mode)
  },
  get passiveMessages(): ChatMessage[] {
    return passive.map((entry) => entry.message)
  },

  show(): void {
    visible = true
    clearPassive()
  },

  hide(): void {
    visible = false
    history.reset()
  },

  setMode(next: ChatChannel): void {
    mode = next
  },

  setConfig(input: Partial<ChatConfig>): void {
    config = mergeConfig(config, input)

    if (!config.passiveEnabled) {
      clearPassive()
    }
  },

  addMessage(input: ChatMessageInput): ChatMessage {
    return insert(input, true)
  },

  /** The messages the server kept for a reconnecting player, shown only on an empty chat. */
  replayMessages(list: ChatMessageInput[]): void {
    if (messages.length > 0) {
      return
    }

    for (const input of list) {
      insert(input, false)
    }
  },

  clear(): void {
    messages = []
    clearPassive()
  },

  registerCommand(input: Partial<CommandDef> & { name: string }): void {
    const command = normalizeCommand(input)
    const index = commands.findIndex((entry) => entry.name === command.name)

    commands =
      index === -1
        ? [...commands, command]
        : commands.map((entry, position) => (position === index ? command : entry))
  },

  unregisterCommand(name: string): void {
    commands = commands.filter((entry) => entry.name !== name)
  },

  /** Applies a message the game posted; false when it is not one of ours. */
  applyMessage(data: unknown): boolean {
    if (!data || typeof data !== 'object') {
      return false
    }

    const message = data as NuiMessage

    if (typeof message.action !== 'string' || !message.action.startsWith(PREFIX)) {
      return false
    }

    switch (message.action.slice(PREFIX.length)) {
      case 'open':
        store.show()
        return true
      case 'hide':
        store.hide()
        return true
      case 'addMessage':
        if (isMessageInput(message.message)) {
          store.addMessage(message.message)
        }
        return true
      case 'clear':
        store.clear()
        return true
      case 'setConfig':
        if (isConfigInput(message.config)) {
          store.setConfig(message.config)
        }
        return true
      case 'addSuggestion':
        if (isCommandDef(message.suggestion)) {
          store.registerCommand(message.suggestion)
        }
        return true
      case 'removeSuggestion':
        if (typeof message.name === 'string') {
          store.unregisterCommand(message.name)
        }
        return true
      case 'sync': {
        const state = (message.state ?? {}) as SyncState

        if (Array.isArray(state.suggestions)) {
          for (const suggestion of state.suggestions) {
            if (isCommandDef(suggestion)) {
              store.registerCommand(suggestion)
            }
          }
        }

        if (Array.isArray(state.messages)) {
          store.replayMessages(state.messages.filter(isMessageInput))
        }

        return true
      }
      case 'setStaffMode':
        store.setMode(message.enabled === true ? 'staff' : 'public')
        return true
      default:
        return false
    }
  },
}
