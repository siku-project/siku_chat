<script setup lang="ts">
import { ref, watch, nextTick } from 'vue'
import IcePanel from '@/components/ui/IcePanel.vue'
import type { CommandDef, CommandSuggestion } from '@/utils/command'

const props = defineProps<{
  suggestions: CommandSuggestion[]
  prefix: string
  selectedIndex: number
  keyboard: boolean
}>()

const emit = defineEmits<{
  select: [suggestion: CommandSuggestion]
}>()

const listRef = ref<HTMLElement | null>(null)

const formatParam = (param: CommandDef['params'][number]): string =>
  param.optional ? `[${param.name}]` : `<${param.name}>`

watch(
  () => props.selectedIndex,
  (index) => {
    if (!props.keyboard) {
      return
    }
    nextTick(() => {
      listRef.value?.children[index]?.scrollIntoView({ block: 'nearest' })
    })
  },
)
</script>

<template>
  <Transition name="suggest">
    <IcePanel
      v-if="suggestions.length"
      variant="primary"
      class="cmd-suggest mt-2"
      :style="{ '--ice-top': '0.84', '--ice-bottom': '0.9' }"
    >
      <ul ref="listRef" class="cmd-list" :class="{ 'is-keyboard': keyboard }">
        <li
          v-for="(item, index) in suggestions"
          :key="item.command.name"
          class="cmd-row"
          :class="{ 'is-selected': keyboard && index === selectedIndex }"
          @mousedown.prevent="emit('select', item)"
        >
          <div class="cmd-sig">
            <span class="cmd-name" :class="{ hl: item.highlightName }"
              >{{ prefix }}{{ item.command.name }}</span
            >
            <span
              v-for="(param, paramIndex) in item.command.params"
              :key="param.name"
              class="cmd-param"
              :class="{ hl: item.activeParam === paramIndex }"
              >{{ formatParam(param) }}</span
            >
          </div>
          <div class="cmd-desc">{{ item.description }}</div>
        </li>
      </ul>
    </IcePanel>
  </Transition>
</template>

<style scoped>
.cmd-list {
  padding: 6px 0;
  max-height: 15rem;
  overflow-y: auto;
  overscroll-behavior: contain;
  scrollbar-width: none;
}

.cmd-list::-webkit-scrollbar {
  width: 0;
  height: 0;
  display: none;
}

.cmd-row {
  padding: 6px 18px;
  transition: background-color 0.25s ease;
}

.cmd-list:not(.is-keyboard) .cmd-row:hover {
  background-color: rgba(233, 244, 253, 0.03);
}

.cmd-row.is-selected {
  background-color: rgba(118, 198, 244, 0.1);
  box-shadow: inset 2px 0 0 rgba(150, 210, 245, 0.7);
}

.cmd-sig {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 8px;
  line-height: 1.4;
}

.cmd-name {
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0.01em;
  color: rgba(224, 238, 251, 0.72);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.cmd-param {
  font-size: 12px;
  font-weight: 400;
  color: rgba(161, 203, 232, 0.42);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.35);
}

.cmd-name.hl {
  color: rgba(233, 247, 255, 0.98);
  text-shadow:
    0 0 10px rgba(130, 202, 245, 0.5),
    0 1px 2px rgba(0, 0, 0, 0.4);
}

.cmd-param.hl {
  font-weight: 600;
  color: rgba(228, 245, 255, 0.96);
  text-shadow:
    0 0 10px rgba(130, 202, 245, 0.55),
    0 1px 2px rgba(0, 0, 0, 0.35);
}

.cmd-desc {
  margin-top: 3px;
  font-size: 11.5px;
  font-weight: 300;
  line-height: 1.5;
  color: rgba(178, 214, 240, 0.55);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.35);
}

.suggest-enter-active,
.suggest-leave-active {
  transition:
    opacity 0.22s ease,
    transform 0.22s cubic-bezier(0.22, 1, 0.36, 1);
}

.suggest-enter-from,
.suggest-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}
</style>
