<script setup lang="ts">
import { ref, computed, watch, nextTick, onMounted, onBeforeUnmount } from 'vue'
import { storeToRefs } from 'pinia'
import { useI18n } from 'vue-i18n'
import IcePanel from '@/components/ui/IcePanel.vue'
import ChatHeader from '@/components/chat/ChatHeader.vue'
import ChatMessages from '@/components/chat/ChatMessages.vue'
import ChatInput from '@/components/chat/ChatInput.vue'
import ChatSuggestions from '@/components/chat/ChatSuggestions.vue'
import ChatPassive from '@/components/chat/ChatPassive.vue'
import { useChatStore } from '@/stores/chat'
import type { ChatMessageInput, ChatConfigInput } from '@/stores/chat'
import { sendNuiCallback } from '@/utils/nui'
import { applyLocale } from '@/utils/locale'
import type { LocalePayload } from '@/utils/locale'
import { isCommand, parseCommand } from '@/utils/command'
import type { CommandDef, CommandSuggestion, ParsedCommand } from '@/utils/command'
import { DEMO_MESSAGES, LOCAL_NAME, LOCAL_RANK } from '@/mock/messages'
import { MOCK_COMMANDS } from '@/mock/commands'

const chat = useChatStore()
const {
  messages,
  visibleMessages,
  mode,
  commands,
  commandPrefix,
  maxMessageLength,
  messageCooldown,
  allowMessages,
  inputMode,
  isNavigatingHistory,
  visible,
} = storeToRefs(chat)
const { t } = useI18n()

const active = ref(false)
const draft = ref('')
const cooldown = ref(false)
const selectedIndex = ref(0)
const inputRef = ref<InstanceType<typeof ChatInput> | null>(null)

const staff = computed(() => mode.value === 'staff')
const keyboard = computed(() => inputMode.value === 'keyboard')
const placeholder = computed(() =>
  staff.value ? t('chat_staff_placeholder') : t('chat_placeholder'),
)
const panelStyle = computed(() =>
  active.value ? { '--ice-top': '0.7', '--ice-bottom': '0.82' } : {},
)

const canSend = computed(() => {
  const value = draft.value
  if (cooldown.value || value.trim().length === 0 || value.length > maxMessageLength.value) {
    return false
  }
  return allowMessages.value || isCommand(value, commandPrefix.value)
})

const availableCommands = computed<CommandDef[]>(() => {
  const base = commands.value
  return mode.value === 'staff' ? base.filter((command) => command.staff) : base
})

const suggestions = computed<CommandSuggestion[]>(() => {
  if (!active.value || !draft.value.startsWith(commandPrefix.value)) {
    return []
  }
  const tokens = draft.value.slice(commandPrefix.value.length).split(' ')
  const typedName = (tokens[0] ?? '').toLowerCase()
  const tokenIndex = tokens.length - 1
  const list = availableCommands.value

  if (tokenIndex === 0) {
    return list
      .filter((command) => command.name.toLowerCase().startsWith(typedName))
      .map((command) => ({
        command,
        description: command.description,
        highlightName: true,
        activeParam: -1,
      }))
  }

  const command = list.find((entry) => entry.name.toLowerCase() === typedName)
  if (!command) {
    return []
  }
  const paramIndex = tokenIndex - 1
  const param = command.params[paramIndex]
  return [
    {
      command,
      description: param ? param.description : command.description,
      highlightName: false,
      activeParam: param ? paramIndex : -1,
    },
  ]
})

const inCommandNameStage = computed(
  () =>
    draft.value.startsWith(commandPrefix.value) &&
    !draft.value.slice(commandPrefix.value.length).includes(' '),
)

watch(draft, () => {
  selectedIndex.value = 0
})

const navigate = (delta: number): void => {
  if (keyboard.value && suggestions.value.length > 0 && !isNavigatingHistory.value) {
    const count = suggestions.value.length
    selectedIndex.value = (selectedIndex.value + delta + count) % count
    return
  }
  const value = delta < 0 ? chat.historyUp(draft.value) : chat.historyDown()
  if (value !== null) {
    draft.value = value
  }
}

const onDraftInput = (value: string): void => {
  draft.value = value
  chat.resetHistoryNav()
}

const complete = (suggestion: CommandSuggestion): void => {
  draft.value = `${commandPrefix.value}${suggestion.command.name} `
  nextTick(() => inputRef.value?.focus())
}

const completeSelected = (): void => {
  const suggestion = suggestions.value[selectedIndex.value]
  if (suggestion) {
    complete(suggestion)
  }
}

const openChat = (): void => {
  chat.show()
  if (keyboard.value) {
    nextTick(() => inputRef.value?.focus())
  }
}

const previewPassive = (): void => {
  chat.hide()
  const demo = [
    { author: 'Léa Marchand', text: 'Salut, quelqu’un dans le coin ?' },
    { author: 'Tom Rivera', text: 'Je passe au marché, besoin de rien ?' },
    { author: 'Noah Bennett', text: 'Rendez-vous au spot dans 5 minutes.' },
    { author: 'Camille Laurent', text: 'J’arrive, deux minutes !' },
  ]
  demo.forEach((entry, index) => {
    window.setTimeout(() => chat.addPlayerMessage(entry.author, entry.text), 700 * (index + 1))
  })
}

const closeChat = (): void => {
  chat.resetHistoryNav()
  chat.hide()
  sendNuiCallback('siku_chat:nui:close')
}

const open = (): void => {
  inputRef.value?.focus()
}

const close = (): void => {
  chat.resetHistoryNav()
  if (import.meta.env.DEV) {
    inputRef.value?.blur()
  } else {
    closeChat()
  }
}

const dispatchCommand = (command: ParsedCommand): void => {
  if (import.meta.env.DEV) {
    chat.addSystemMessage(
      t('chat_command', { command: `${commandPrefix.value}${command.raw}` }),
      chat.mode,
    )
  } else {
    sendNuiCallback('siku_chat:nui:command', command)
  }
}

const dispatchMessage = (text: string): void => {
  const channel = chat.mode
  if (import.meta.env.DEV) {
    chat.addPlayerMessage(LOCAL_NAME, text, channel, channel === 'staff' ? LOCAL_RANK : undefined)
  } else {
    const event =
      channel === 'staff' ? 'siku_chat:nui:sendStaffMessage' : 'siku_chat:nui:sendMessage'
    sendNuiCallback(event, { text })
  }
}

const startCooldown = (): void => {
  if (messageCooldown.value <= 0) {
    return
  }
  cooldown.value = true
  window.setTimeout(() => {
    cooldown.value = false
  }, messageCooldown.value)
}

const send = (): void => {
  const text = draft.value.trim()

  if (text && !canSend.value) {
    return
  }
  draft.value = ''

  if (text) {
    chat.pushHistory(text)
    if (isCommand(text, commandPrefix.value)) {
      const command = parseCommand(text, commandPrefix.value)
      if (import.meta.env.DEV && command.name === 'staffchat') {
        chat.setMode('staff')
        return
      }
      if (import.meta.env.DEV && command.name === 'passif') {
        previewPassive()
        return
      }
      dispatchCommand(command)
    } else {
      dispatchMessage(text)
    }
    startCooldown()
  }

  inputRef.value?.focus()
}

const onSubmit = (): void => {
  if (isNavigatingHistory.value && isCommand(draft.value, commandPrefix.value)) {
    chat.resetHistoryNav()
    return
  }
  if (keyboard.value && suggestions.value.length > 0 && inCommandNameStage.value) {
    completeSelected()
  } else {
    send()
  }
}

const handleKeydown = (event: KeyboardEvent): void => {
  if (event.key === 'Escape' && visible.value) {
    event.preventDefault()
    if (chat.mode === 'staff') {
      chat.setMode('public')
      return
    }
    close()
    return
  }
  if (!active.value && event.key === 'Enter') {
    event.preventDefault()
    if (visible.value) {
      open()
    } else {
      openChat()
    }
  }
}

interface NuiSyncState {
  suggestions?: CommandDef[]
  messages?: ChatMessageInput[]
}

interface NuiMessage {
  action?: string
  message?: ChatMessageInput
  config?: ChatConfigInput
  locale?: LocalePayload
  suggestion?: CommandDef
  name?: string
  state?: NuiSyncState
  enabled?: boolean
}

const handleNuiMessage = (event: MessageEvent): void => {
  const payload = event.data as NuiMessage | null
  if (!payload || typeof payload !== 'object') {
    return
  }
  if (payload.action === 'siku_chat:nui:open') {
    openChat()
  } else if (payload.action === 'siku_chat:nui:addMessage' && payload.message) {
    chat.addMessage(payload.message)
  } else if (payload.action === 'siku_chat:nui:setConfig' && payload.config) {
    chat.setConfig(payload.config)
  } else if (payload.action === 'siku_chat:nui:setLocale' && payload.locale) {
    applyLocale(payload.locale)
  } else if (payload.action === 'siku_chat:nui:addSuggestion' && payload.suggestion) {
    chat.registerCommand(payload.suggestion)
  } else if (payload.action === 'siku_chat:nui:removeSuggestion' && payload.name) {
    chat.unregisterCommand(payload.name)
  } else if (payload.action === 'siku_chat:nui:sync' && payload.state) {
    if (Array.isArray(payload.state.suggestions)) {
      payload.state.suggestions.forEach((suggestion) => chat.registerCommand(suggestion))
    }
    if (Array.isArray(payload.state.messages)) {
      chat.replayMessages(payload.state.messages)
    }
  } else if (payload.action === 'siku_chat:nui:setStaffMode') {
    chat.setMode(payload.enabled ? 'staff' : 'public')
  } else if (payload.action === 'siku_chat:nui:clear') {
    chat.clear()
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
  window.addEventListener('message', handleNuiMessage)

  if (import.meta.env.DEV) {
    chat.show()
    MOCK_COMMANDS.forEach((command) => chat.registerCommand(command))
    if (messages.value.length === 0) {
      DEMO_MESSAGES.forEach((message, index) => {
        window.setTimeout(() => chat.addMessage(message), 130 * index)
      })
    }
  } else {
    sendNuiCallback('siku_chat:nui:ready')
  }
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown)
  window.removeEventListener('message', handleNuiMessage)
})
</script>

<template>
  <ChatPassive />

  <Transition name="chat">
    <div
      v-if="visible"
      class="chat-shell fixed top-10 left-10 z-40 w-[36rem] max-w-[90vw]"
      :class="{ 'is-staff': staff }"
    >
      <IcePanel variant="primary" :style="panelStyle">
        <div class="px-6 py-5">
          <ChatHeader :staff="staff" />
          <ChatMessages :messages="visibleMessages" />
          <ChatInput
            ref="inputRef"
            :model-value="draft"
            :placeholder="placeholder"
            :can-send="canSend"
            :max-length="maxMessageLength"
            :keyboard="keyboard"
            @update:model-value="onDraftInput"
            @submit="onSubmit"
            @complete="completeSelected"
            @nav="navigate"
            @focus="active = true"
            @blur="active = false"
          />
        </div>
      </IcePanel>

      <ChatSuggestions
        :suggestions="suggestions"
        :prefix="commandPrefix"
        :selected-index="selectedIndex"
        :keyboard="keyboard"
        @select="complete"
      />
    </div>
  </Transition>
</template>

<style scoped>
.chat-shell :deep(.ice) {
  border-color: rgba(222, 237, 250, 0.26);
  box-shadow:
    0 0 0 1px rgba(233, 244, 253, 0.14),
    0 0 0 2px rgba(16, 34, 56, 0.32),
    0 42px 84px -34px rgba(3, 9, 22, 0.82),
    0 18px 44px -26px rgba(3, 9, 22, 0.68),
    0 0 66px -14px rgba(120, 178, 224, 0.2),
    inset 0 1px 0 rgba(233, 244, 253, 0.26),
    inset 0 0 0 1px rgba(233, 244, 253, 0.04),
    inset 0 -30px 54px -38px rgba(5, 14, 30, 0.46);
}

.chat-shell.is-staff :deep(.ice) {
  border-color: rgba(150, 212, 246, 0.42);
  box-shadow:
    0 0 0 1px rgba(176, 224, 250, 0.22),
    0 0 0 2px rgba(16, 34, 56, 0.32),
    0 42px 84px -34px rgba(3, 9, 22, 0.82),
    0 18px 44px -26px rgba(3, 9, 22, 0.68),
    0 0 82px -10px rgba(118, 198, 244, 0.42),
    inset 0 1px 0 rgba(233, 244, 253, 0.3),
    inset 0 0 0 1px rgba(176, 224, 250, 0.09),
    inset 0 -30px 54px -38px rgba(5, 14, 30, 0.46);
}

.chat-enter-active {
  transition:
    opacity 0.55s ease,
    transform 0.55s cubic-bezier(0.22, 1, 0.36, 1);
}

.chat-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.chat-leave-active {
  transition:
    opacity 0.3s ease,
    transform 0.3s ease;
}

.chat-leave-to {
  opacity: 0;
  transform: translateY(10px);
}
</style>
