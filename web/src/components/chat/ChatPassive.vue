<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useChatStore } from '@/stores/chat'

const chat = useChatStore()
const { passiveMessages, isPassiveVisible } = storeToRefs(chat)
</script>

<template>
  <Transition name="passive">
    <div v-if="isPassiveVisible" class="passive" aria-hidden="true">
      <TransitionGroup name="passive-msg" tag="div" class="passive-list">
        <div v-for="message in passiveMessages" :key="message.id" class="passive-row">
          <template v-if="message.type === 'player'">
            <span class="passive-author">{{ message.author }}</span>
            <span class="passive-text">{{ message.text }}</span>
          </template>

          <span v-else class="passive-system">{{ message.text }}</span>
        </div>
      </TransitionGroup>
    </div>
  </Transition>
</template>

<style scoped>
.passive {
  position: fixed;
  top: 2.5rem;
  left: 2.5rem;
  z-index: 30;
  width: 36rem;
  max-width: 90vw;
  pointer-events: none;
}

.passive-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.passive-row {
  align-self: flex-start;
  max-width: 100%;
  padding: 7px 14px;
  border-radius: 0.7rem;
  border: 1px solid rgba(216, 234, 250, 0.14);
  background: linear-gradient(180deg, rgba(18, 37, 60, 0.72) 0%, rgba(11, 25, 44, 0.8) 100%);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.08),
    0 10px 28px -16px rgba(3, 9, 22, 0.7);
  font-size: 13px;
  line-height: 1.55;
}

.passive-author {
  margin-right: 8px;
  font-weight: 600;
  color: rgba(244, 249, 254, 0.96);
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5);
}

.passive-text {
  font-weight: 400;
  color: rgba(228, 241, 251, 0.9);
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.45);
}

.passive-system {
  font-style: italic;
  color: rgba(192, 221, 243, 0.82);
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.42);
}

.passive-enter-active,
.passive-leave-active {
  transition: opacity 0.4s ease;
}

.passive-enter-from,
.passive-leave-to {
  opacity: 0;
}

.passive-msg-enter-active {
  transition:
    opacity 0.35s ease,
    transform 0.35s cubic-bezier(0.22, 1, 0.36, 1);
}

.passive-msg-enter-from {
  opacity: 0;
  transform: translateY(8px);
}

.passive-msg-leave-active {
  transition:
    opacity 0.4s ease,
    transform 0.4s ease;
}

.passive-msg-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

.passive-msg-move {
  transition: transform 0.35s cubic-bezier(0.22, 1, 0.36, 1);
}
</style>
