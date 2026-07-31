<script setup lang="ts">
import { version as vueVersion } from 'vue'
import { ref } from 'vue'
import axios from 'axios'

defineProps<{
  currentView: string
}>()

const expanded = ref(false)

const resourceName = 'siku_chat'

const deps = [
  { name: 'Vue', version: vueVersion },
  { name: 'Vuetify', version: '4.x' },
  { name: 'Pinia', version: '3.x' },
  { name: 'Axios', version: axios.VERSION ?? '1.x' },
  { name: 'Tailwind', version: '3.x' },
]
</script>

<template>
  <div
    class="fixed top-4 right-4 z-50"
    @mouseenter="expanded = true"
    @mouseleave="expanded = false"
  >
    <div
      class="overflow-hidden transition-all duration-300 ease-in-out bg-zinc-950/85 backdrop-blur-xl border border-emerald-500/30 shadow-[0_8px_32px_rgba(0,0,0,0.6)]"
      :class="expanded ? 'w-56 rounded-2xl' : 'w-12 h-12 rounded-full'"
    >
      <div v-if="!expanded" class="w-12 h-12 flex items-center justify-center">
        <v-icon class="text-emerald-500" size="20">mdi-code-tags</v-icon>
      </div>

      <div v-else class="p-4 flex flex-col gap-3">
        <span class="text-emerald-500 font-semibold text-sm tracking-wide text-center">{{
          resourceName
        }}</span>

        <div
          class="w-full h-0.5 bg-gradient-to-r from-transparent via-emerald-700 to-transparent"
        ></div>

        <div class="flex flex-col gap-1.5">
          <div v-for="dep in deps" :key="dep.name" class="flex items-center justify-between">
            <span class="text-zinc-400 text-xs">{{ dep.name }}</span>
            <span class="text-emerald-500/70 text-xs font-mono">{{ dep.version }}</span>
          </div>
        </div>

        <div
          class="w-full h-0.5 bg-gradient-to-r from-transparent via-emerald-700 to-transparent"
        ></div>

        <div class="flex items-center justify-between">
          <span class="text-zinc-400 text-xs">Vue actuelle</span>
          <span
            class="text-xs font-medium"
            :class="currentView !== 'none' ? 'text-emerald-400' : 'text-red-400/70'"
          >
            {{ currentView !== 'none' ? currentView : 'None' }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>
