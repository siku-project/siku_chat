<script setup lang="ts">
import { computed, ref } from 'vue'

const props = defineProps<{
  modelValue: string
  placeholder: string
  canSend: boolean
  maxLength: number
  keyboard: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
  submit: []
  complete: []
  nav: [delta: number]
  focus: []
  blur: []
}>()

const inputRef = ref<HTMLInputElement | null>(null)

const model = computed({
  get: () => props.modelValue,
  set: (value: string) => emit('update:modelValue', value),
})

const onEnter = (event: KeyboardEvent): void => {
  event.preventDefault()
  emit('submit')
}

const onTab = (event: KeyboardEvent): void => {
  if (!props.keyboard) {
    return
  }
  event.preventDefault()
  emit('complete')
}

const onNav = (event: KeyboardEvent, delta: number): void => {
  event.preventDefault()
  emit('nav', delta)
}

const focus = (): void => {
  inputRef.value?.focus()
}

const blur = (): void => {
  inputRef.value?.blur()
}

defineExpose({ focus, blur })
</script>

<template>
  <div class="chat-field">
    <input
      ref="inputRef"
      v-model="model"
      type="text"
      class="chat-field-input"
      :placeholder="placeholder"
      :maxlength="maxLength"
      @focus="emit('focus')"
      @blur="emit('blur')"
      @keydown.enter="onEnter"
      @keydown.tab="onTab"
      @keydown.down="onNav($event, 1)"
      @keydown.up="onNav($event, -1)"
    />

    <span class="chat-count" :class="{ 'is-full': modelValue.length >= maxLength }">
      {{ modelValue.length }}/{{ maxLength }}
    </span>

    <button
      type="button"
      class="chat-send"
      :disabled="!canSend"
      @mousedown.prevent="emit('submit')"
    >
      <v-icon size="18">mdi-send</v-icon>
    </button>
  </div>
</template>

<style scoped>
.chat-field {
  display: flex;
  align-items: center;
  margin-top: 14px;
  border-radius: 0.85rem;
  border: 1px solid rgba(216, 234, 250, 0.26);
  background: linear-gradient(180deg, rgba(18, 37, 60, 0.78) 0%, rgba(11, 25, 44, 0.85) 100%);
  box-shadow:
    inset 0 2px 6px -2px rgba(46, 73, 108, 0.42),
    inset 0 1px 0 rgba(233, 244, 253, 0.1),
    inset 0 -1px 0 rgba(233, 244, 253, 0.06),
    0 6px 20px -14px rgba(46, 73, 108, 0.4);
  transition:
    border-color 0.3s ease,
    box-shadow 0.3s ease;
}

.chat-field:focus-within {
  border-color: rgba(216, 234, 250, 0.38);
  box-shadow:
    inset 0 2px 6px -2px rgba(46, 73, 108, 0.36),
    inset 0 1px 0 rgba(233, 244, 253, 0.14),
    0 0 22px -8px rgba(170, 208, 236, 0.32);
}

.chat-field-input {
  flex: 1 1 0;
  min-width: 0;
  padding: 10px 6px 10px 15px;
  border: none;
  outline: none;
  background: transparent;
  font-size: 13px;
  font-weight: 300;
  letter-spacing: 0.01em;
  color: rgba(242, 248, 253, 0.92);
  caret-color: rgba(226, 240, 250, 0.9);
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.45);
}

.chat-field-input::placeholder {
  color: rgba(161, 203, 232, 0.32);
}

.chat-count {
  flex-shrink: 0;
  padding-left: 4px;
  font-size: 10px;
  font-variant-numeric: tabular-nums;
  letter-spacing: 0.02em;
  color: rgba(161, 203, 232, 0.32);
  transition: color 0.2s ease;
}

.chat-count.is-full {
  color: rgba(174, 212, 240, 0.75);
}

.chat-send {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  padding: 0 14px;
  color: rgba(161, 203, 232, 0.3);
  cursor: default;
  transition:
    color 0.2s ease,
    text-shadow 0.2s ease;
}

.chat-send:not(:disabled) {
  color: rgba(244, 250, 255, 0.96);
  cursor: pointer;
  text-shadow: 0 0 10px rgba(170, 208, 236, 0.4);
}
</style>
