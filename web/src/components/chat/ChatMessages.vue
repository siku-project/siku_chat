<script setup lang="ts">
import { ref, watch, nextTick, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import ChatMessage from '@/components/chat/ChatMessage.vue'
import type { ChatMessage as ChatMessageModel } from '@/stores/chat'

const props = defineProps<{
  messages: ChatMessageModel[]
}>()

const { t } = useI18n()

const probeRef = ref<HTMLElement | null>(null)
const scrollRef = ref<HTMLElement | null>(null)
const nameColPx = ref(0)
const scrolled = ref(false)

const onScroll = (): void => {
  const el = scrollRef.value
  scrolled.value = !!el && el.scrollTop > 2
}

const scrollToBottom = (): void => {
  const el = scrollRef.value
  if (el) {
    el.scrollTop = el.scrollHeight
    onScroll()
  }
}

const measureNames = (): void => {
  const probe = probeRef.value
  if (!probe) {
    return
  }
  let max = 0
  for (const message of props.messages) {
    if (message.type === 'player' && message.author) {
      probe.textContent = message.author
      max = Math.max(max, probe.offsetWidth)
    }
  }
  nameColPx.value = Math.ceil(max)
}

const refreshView = (): void => {
  nextTick(() => {
    measureNames()
    scrollToBottom()
  })
}

watch(() => props.messages, refreshView)
onMounted(refreshView)
</script>

<template>
  <div>
    <span ref="probeRef" class="name-probe" aria-hidden="true"></span>

    <div ref="scrollRef" class="msg-scroll" :class="{ 'is-scrolled': scrolled }" @scroll="onScroll">
      <div v-if="messages.length === 0" class="msg-empty">{{ t('chat_empty') }}</div>
      <TransitionGroup
        v-else
        name="msg"
        tag="div"
        class="msg-well"
        :style="{ '--name-col': nameColPx + 'px' }"
      >
        <ChatMessage v-for="message in messages" :key="message.id" :message="message" />
      </TransitionGroup>
    </div>
  </div>
</template>

<style scoped>
.name-probe {
  position: absolute;
  visibility: hidden;
  white-space: nowrap;
  pointer-events: none;
  font-size: 13px;
  font-weight: 600;
}

.msg-scroll {
  max-height: 13rem;
  overflow-y: auto;
  overscroll-behavior: contain;
  scrollbar-width: none;
}

.msg-scroll.is-scrolled {
  -webkit-mask-image: linear-gradient(to bottom, transparent 0, #000 20px);
  mask-image: linear-gradient(to bottom, transparent 0, #000 20px);
}

.msg-scroll::-webkit-scrollbar {
  width: 0;
  height: 0;
  display: none;
}

.msg-well {
  --rank-col: 3.5rem;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.msg-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 13rem;
  font-size: 12px;
  letter-spacing: 0.08em;
  color: rgba(226, 240, 250, 0.32);
}
</style>
