<script setup lang="ts">
import { useI18n } from 'vue-i18n'

defineProps<{
  staff: boolean
}>()

const { t } = useI18n()
</script>

<template>
  <div :class="{ 'is-staff': staff }">
    <div v-if="staff" class="staff-head mb-3 flex items-center gap-2.5 px-1">
      <v-icon class="staff-icon" size="18">mdi-shield-account-outline</v-icon>
      <span class="staff-title">{{ t('chat_staff_title') }}</span>
      <span class="staff-badge">{{ t('chat_staff_badge') }}</span>
      <span class="staff-hint">{{ t('chat_staff_hint') }}</span>
    </div>

    <div v-else class="mb-3 flex items-center gap-3 px-1">
      <v-icon class="text-glacier-100/50" size="18">mdi-message-outline</v-icon>
      <span class="ice-title text-[13px]">{{ t('chat_title') }}</span>
    </div>

    <div class="chat-sep"></div>
  </div>
</template>

<style scoped>
.staff-icon {
  color: rgba(168, 222, 250, 0.95);
  filter: drop-shadow(0 0 6px rgba(118, 198, 244, 0.55));
}

.staff-title {
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(226, 244, 255, 0.98);
  text-shadow:
    0 0 14px rgba(130, 202, 245, 0.5),
    0 1px 3px rgba(0, 0, 0, 0.4);
}

.staff-badge {
  padding: 2px 8px;
  border-radius: 9999px;
  border: 1px solid rgba(168, 222, 250, 0.5);
  background: linear-gradient(180deg, rgba(118, 198, 244, 0.24) 0%, rgba(118, 198, 244, 0.12) 100%);
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: rgba(228, 245, 255, 0.96);
  text-shadow: 0 0 8px rgba(130, 202, 245, 0.5);
  box-shadow:
    0 0 14px -4px rgba(118, 198, 244, 0.5),
    inset 0 1px 0 rgba(233, 244, 253, 0.22);
}

.staff-hint {
  margin-left: auto;
  font-size: 10px;
  font-weight: 300;
  letter-spacing: 0.04em;
  color: rgba(176, 214, 240, 0.4);
}

.chat-sep {
  position: relative;
  height: 1px;
  margin: 4px 0 16px;
  background: linear-gradient(
    to right,
    transparent 6%,
    rgba(196, 224, 243, 0.28) 30%,
    rgba(240, 248, 254, 0.72) 50%,
    rgba(196, 224, 243, 0.28) 70%,
    transparent 94%
  );
  box-shadow: 0 7px 13px -7px rgba(46, 73, 108, 0.34);
}

.chat-sep::before {
  content: '';
  position: absolute;
  left: 50%;
  top: 50%;
  width: 62%;
  height: 22px;
  transform: translate(-50%, -50%);
  background: radial-gradient(
    ellipse 55% 100% at center,
    rgba(174, 212, 240, 0.28) 0%,
    rgba(174, 212, 240, 0.08) 44%,
    transparent 78%
  );
  pointer-events: none;
}

.chat-sep::after {
  content: '';
  position: absolute;
  left: 50%;
  top: 50%;
  width: 3px;
  height: 3px;
  transform: translate(-50%, -50%) rotate(45deg);
  background: rgba(243, 249, 254, 0.95);
  box-shadow:
    0 0 10px rgba(196, 224, 243, 0.8),
    0 0 3px rgba(243, 249, 254, 0.9);
  pointer-events: none;
}

.is-staff .chat-sep {
  background: linear-gradient(
    to right,
    transparent 6%,
    rgba(150, 210, 245, 0.4) 30%,
    rgba(206, 236, 255, 0.85) 50%,
    rgba(150, 210, 245, 0.4) 70%,
    transparent 94%
  );
}

.is-staff .chat-sep::after {
  background: rgba(226, 245, 255, 0.98);
  box-shadow:
    0 0 12px rgba(130, 202, 245, 0.9),
    0 0 3px rgba(226, 245, 255, 0.95);
}
</style>
