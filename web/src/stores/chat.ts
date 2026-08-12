import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import type { CommandDef } from '@/utils/command'

export type ChatMessageType = 'player' | 'system' | 'info' | 'success' | 'warning' | 'error'
export type ChatChannel = 'public' | 'staff'
export type ChatInputMode = 'keyboard' | 'mouse'

export interface ChatMessage {
  id: number
  type: ChatMessageType
  channel: ChatChannel
  timestamp: number
  author?: string
  rank?: string
  icon?: string
  metadata?: Record<string, unknown>
  text: string
}

export interface ChatMessageInput {
  type: ChatMessageType
  text: string
  channel?: ChatChannel
  author?: string
  rank?: string
  icon?: string
  metadata?: Record<string, unknown>
  timestamp?: number
}

export interface ChatConfigInput {
  commandPrefix?: string
  maxMessages?: number
  maxMessageLength?: number
  messageCooldown?: number
  allowMessages?: boolean
  inputMode?: ChatInputMode
  passiveEnabled?: boolean
  passiveDuration?: number
  passiveMaxMessages?: number
  historyEnable?: boolean
  historyMax?: number
}

interface PassiveEntry {
  message: ChatMessage
  timer: number
}

export const useChatStore = defineStore('chat', () => {
  const messages = ref<ChatMessage[]>([])
  const mode = ref<ChatChannel>('public')
  const commandPrefix = ref('/')
  const maxMessages = ref(100)
  const maxMessageLength = ref(256)
  const messageCooldown = ref(1000)
  const allowMessages = ref(true)
  const inputMode = ref<ChatInputMode>('keyboard')
  const passiveEnabled = ref(true)
  const passiveDuration = ref(10000)
  const passiveMaxMessages = ref(3)
  const passiveEntries = ref<PassiveEntry[]>([])
  const historyEnable = ref(true)
  const historyMax = ref(20)
  const history = ref<string[]>([])
  const historyIndex = ref(-1)
  const historyDraft = ref('')
  const visible = ref(false)
  const commands = ref<CommandDef[]>([])
  let nextId = 1

  const registerCommand = (def: CommandDef): void => {
    const index = commands.value.findIndex((entry) => entry.name === def.name)
    if (index === -1) {
      commands.value.push(def)
    } else {
      commands.value.splice(index, 1, def)
    }
  }

  const unregisterCommand = (name: string): void => {
    commands.value = commands.value.filter((entry) => entry.name !== name)
  }

  const pushHistory = (entry: string): void => {
    historyIndex.value = -1
    historyDraft.value = ''
    if (!historyEnable.value) {
      return
    }
    const trimmed = entry.trim()
    if (trimmed.length === 0) {
      return
    }
    history.value.push(trimmed)
    while (history.value.length > historyMax.value) {
      history.value.shift()
    }
  }

  const historyUp = (currentInput: string): string | null => {
    if (!historyEnable.value || history.value.length === 0) {
      return null
    }
    if (historyIndex.value === -1) {
      historyDraft.value = currentInput
      historyIndex.value = history.value.length - 1
    } else if (historyIndex.value > 0) {
      historyIndex.value -= 1
    }
    return history.value[historyIndex.value] ?? null
  }

  const historyDown = (): string | null => {
    if (historyIndex.value === -1) {
      return null
    }
    if (historyIndex.value < history.value.length - 1) {
      historyIndex.value += 1
      return history.value[historyIndex.value] ?? null
    }
    historyIndex.value = -1
    return historyDraft.value
  }

  const resetHistoryNav = (): void => {
    historyIndex.value = -1
    historyDraft.value = ''
  }

  const removePassiveEntry = (id: number): void => {
    const index = passiveEntries.value.findIndex((entry) => entry.message.id === id)
    const entry = passiveEntries.value[index]
    if (!entry) {
      return
    }
    clearTimeout(entry.timer)
    passiveEntries.value.splice(index, 1)
  }

  const clearPassive = (): void => {
    for (const entry of passiveEntries.value) {
      clearTimeout(entry.timer)
    }
    passiveEntries.value = []
  }

  const show = (): void => {
    visible.value = true
    clearPassive()
  }

  const hide = (): void => {
    visible.value = false
  }

  const setConfig = (config: ChatConfigInput): void => {
    if (config.commandPrefix !== undefined) {
      commandPrefix.value = config.commandPrefix
    }
    if (config.maxMessages !== undefined) {
      maxMessages.value = config.maxMessages
    }
    if (config.maxMessageLength !== undefined) {
      maxMessageLength.value = config.maxMessageLength
    }
    if (config.messageCooldown !== undefined) {
      messageCooldown.value = config.messageCooldown
    }
    if (config.allowMessages !== undefined) {
      allowMessages.value = config.allowMessages
    }
    if (config.inputMode !== undefined) {
      inputMode.value = config.inputMode
    }
    if (config.passiveEnabled !== undefined) {
      passiveEnabled.value = config.passiveEnabled
      if (!config.passiveEnabled) {
        clearPassive()
      }
    }
    if (config.passiveDuration !== undefined) {
      passiveDuration.value = config.passiveDuration
    }
    if (config.passiveMaxMessages !== undefined) {
      passiveMaxMessages.value = config.passiveMaxMessages
    }
    if (config.historyEnable !== undefined) {
      historyEnable.value = config.historyEnable
    }
    if (config.historyMax !== undefined) {
      historyMax.value = config.historyMax
    }
  }

  const visibleMessages = computed<ChatMessage[]>(() =>
    messages.value.filter((message) => message.channel === mode.value),
  )

  const passiveMessages = computed<ChatMessage[]>(() =>
    passiveEntries.value.map((entry) => entry.message),
  )

  const isPassiveVisible = computed(() => !visible.value && passiveEntries.value.length > 0)

  const isNavigatingHistory = computed(() => historyIndex.value !== -1)

  const insertMessage = (input: ChatMessageInput, allowPassive: boolean): ChatMessage => {
    const message: ChatMessage = {
      id: nextId++,
      type: input.type,
      channel: input.channel ?? 'public',
      timestamp: input.timestamp ?? Date.now(),
      author: input.author,
      rank: input.rank,
      icon: input.icon,
      metadata: input.metadata,
      text: input.text,
    }
    messages.value.push(message)

    while (maxMessages.value > 0 && messages.value.length > maxMessages.value) {
      messages.value.shift()
    }

    if (allowPassive && passiveEnabled.value && !visible.value && message.channel === 'public') {
      const timer = window.setTimeout(() => removePassiveEntry(message.id), passiveDuration.value)
      passiveEntries.value.push({ message, timer })

      while (passiveEntries.value.length > passiveMaxMessages.value) {
        const removed = passiveEntries.value.shift()
        if (removed) {
          clearTimeout(removed.timer)
        }
      }
    }

    return message
  }

  const addMessage = (input: ChatMessageInput): ChatMessage => insertMessage(input, true)

  const replayMessages = (list: ChatMessageInput[]): void => {
    if (messages.value.length > 0) {
      return
    }
    for (const input of list) {
      insertMessage(input, false)
    }
  }

  const addPlayerMessage = (
    author: string,
    text: string,
    channel: ChatChannel = 'public',
    rank?: string,
  ): ChatMessage => addMessage({ type: 'player', author, text, channel, rank })

  const addSystemMessage = (text: string, channel: ChatChannel = 'public'): ChatMessage =>
    addMessage({ type: 'system', text, channel })

  const setMode = (next: ChatChannel): void => {
    mode.value = next
  }

  const clear = (): void => {
    messages.value = []
    nextId = 1
  }

  return {
    messages,
    visibleMessages,
    passiveMessages,
    isPassiveVisible,
    isNavigatingHistory,
    mode,
    commandPrefix,
    maxMessageLength,
    messageCooldown,
    allowMessages,
    inputMode,
    visible,
    commands,
    registerCommand,
    unregisterCommand,
    show,
    hide,
    addMessage,
    replayMessages,
    addPlayerMessage,
    addSystemMessage,
    setMode,
    setConfig,
    pushHistory,
    historyUp,
    historyDown,
    resetHistoryNav,
    clear,
  }
})
