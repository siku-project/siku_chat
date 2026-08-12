<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { ChatMessage } from '@/stores/chat'
import { rankLabel } from '@/utils/ranks'

const props = defineProps<{
  message: ChatMessage
}>()

const { locale } = useI18n()

const time = computed(() =>
  new Date(props.message.timestamp).toLocaleTimeString(locale.value, {
    hour: '2-digit',
    minute: '2-digit',
  }),
)
</script>

<template>
  <div class="msg" :class="{ 'msg--staff': message.channel === 'staff' }">
    <template v-if="message.author">
      <span v-if="message.rank" class="rank" :class="`rank--${message.rank}`">
        {{ rankLabel(message.rank) }}
      </span>
      <span class="msg-author">{{ message.author }}</span>
      <span class="msg-text">{{ message.text }}</span>
      <span class="msg-time">{{ time }}</span>
    </template>

    <span v-else class="msg-system" :class="`msg-system--${message.type}`">
      <v-icon v-if="message.icon" class="msg-icon" :icon="message.icon" size="13" />
      <span v-else class="msg-dot"></span>{{ message.text }}
    </span>
  </div>
</template>

<style scoped>
.msg {
  display: flex;
  align-items: baseline;
  column-gap: 12px;
  padding-block: 2px;
  border-radius: 6px;
  transition: background-color 0.35s ease;
}

.msg:hover {
  background-color: rgba(233, 244, 253, 0.03);
}

.rank {
  flex-shrink: 0;
  width: var(--rank-col, 3.5rem);
  padding: 1px 0;
  border-radius: 5px;
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 0.08em;
  line-height: 1.5;
  text-align: center;
  text-transform: uppercase;
  transform: translateY(-1px);
}

.rank--owner {
  color: rgba(232, 247, 255, 0.98);
  border: 1px solid rgba(176, 224, 250, 0.7);
  background: linear-gradient(180deg, rgba(140, 210, 245, 0.36) 0%, rgba(140, 210, 245, 0.18) 100%);
  box-shadow:
    0 0 12px -3px rgba(130, 202, 245, 0.7),
    inset 0 1px 0 rgba(255, 255, 255, 0.28);
  text-shadow: 0 0 8px rgba(130, 202, 245, 0.6);
}

.rank--dev {
  color: rgba(216, 240, 255, 0.95);
  border: 1px solid rgba(150, 210, 245, 0.5);
  background: linear-gradient(180deg, rgba(120, 190, 240, 0.24) 0%, rgba(120, 190, 240, 0.1) 100%);
  box-shadow: inset 0 1px 0 rgba(233, 244, 253, 0.18);
}

.rank--admin {
  color: rgba(198, 226, 246, 0.9);
  border: 1px solid rgba(140, 190, 230, 0.42);
  background: rgba(90, 140, 190, 0.15);
}

.rank--mod {
  color: rgba(178, 208, 232, 0.82);
  border: 1px solid rgba(130, 170, 210, 0.32);
  background: rgba(70, 110, 160, 0.12);
}

.msg-author {
  width: var(--name-col, auto);
  flex-shrink: 0;
  white-space: nowrap;
  font-size: 13px;
  font-weight: 600;
  color: rgba(244, 249, 254, 0.96);
  text-shadow:
    0 1px 3px rgba(0, 0, 0, 0.5),
    0 0 11px rgba(174, 212, 240, 0.16);
}

.msg-text {
  flex: 1 1 0;
  min-width: 0;
  font-size: 13px;
  font-weight: 400;
  line-height: 1.6;
  color: rgba(228, 241, 251, 0.87);
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.45);
}

.msg-time {
  flex-shrink: 0;
  margin-left: auto;
  padding-left: 8px;
  font-size: 10.5px;
  font-variant-numeric: tabular-nums;
  letter-spacing: 0.04em;
  color: rgba(180, 214, 240, 0.55);
  text-shadow:
    0 1px 2px rgba(0, 0, 0, 0.4),
    0 0 9px rgba(150, 196, 232, 0.14);
}

.msg-system {
  flex: 1 1 0;
  min-width: 0;
  margin-left: calc(var(--name-col, 0px) + 12px);
  font-size: 12.5px;
  font-weight: 400;
  font-style: italic;
  line-height: 1.6;
  color: rgba(192, 221, 243, 0.8);
  text-shadow:
    0 1px 3px rgba(0, 0, 0, 0.42),
    0 0 10px rgba(150, 196, 232, 0.16);
}

.msg--staff .msg-system {
  margin-left: calc(var(--rank-col, 3.5rem) + var(--name-col, 0px) + 24px);
}

.msg-dot {
  display: inline-block;
  width: 5px;
  height: 5px;
  margin-right: 8px;
  margin-bottom: 2px;
  border-radius: 9999px;
  background: rgba(198, 226, 246, 0.85);
  box-shadow:
    0 0 8px rgba(174, 212, 240, 0.55),
    0 0 3px rgba(220, 238, 251, 0.7);
  vertical-align: middle;
}

.msg-icon {
  margin-right: 8px;
  margin-bottom: 2px;
  color: rgba(198, 226, 246, 0.78);
  vertical-align: middle;
}

.msg-system--info .msg-dot {
  background: rgba(120, 190, 236, 0.9);
  box-shadow: 0 0 8px rgba(120, 190, 236, 0.5);
}

.msg-system--info .msg-icon {
  color: rgba(140, 200, 240, 0.85);
}

.msg-system--success .msg-dot {
  background: rgba(112, 218, 182, 0.85);
  box-shadow: 0 0 8px rgba(112, 218, 182, 0.45);
}

.msg-system--success .msg-icon {
  color: rgba(134, 224, 192, 0.85);
}

.msg-system--warning .msg-dot {
  background: rgba(235, 200, 122, 0.85);
  box-shadow: 0 0 8px rgba(235, 200, 122, 0.45);
}

.msg-system--warning .msg-icon {
  color: rgba(238, 208, 140, 0.85);
}

.msg-system--error .msg-dot {
  background: rgba(240, 134, 144, 0.85);
  box-shadow: 0 0 8px rgba(240, 134, 144, 0.45);
}

.msg-system--error .msg-icon {
  color: rgba(243, 152, 160, 0.85);
}

.msg-enter-active {
  transition:
    opacity 0.2s ease,
    transform 0.2s cubic-bezier(0.22, 1, 0.36, 1);
}

.msg-enter-from {
  opacity: 0;
  transform: translateY(5px);
}

.msg-leave-active {
  transition:
    opacity 0.25s ease,
    transform 0.25s ease;
}

.msg-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

.msg-move {
  transition: transform 0.28s cubic-bezier(0.22, 1, 0.36, 1);
}
</style>
