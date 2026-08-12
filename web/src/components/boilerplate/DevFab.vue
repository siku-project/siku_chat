<script setup lang="ts">
import { version as vueVersion } from 'vue'
import { ref } from 'vue'
import axios from 'axios'
import IcePanel from '@/components/ui/IcePanel.vue'

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
    class="fixed top-7 right-7 z-50"
    @mouseenter="expanded = true"
    @mouseleave="expanded = false"
  >
    <IcePanel
      variant="secondary"
      :circle="!expanded"
      interactive
      class="overflow-hidden transition-all duration-500 ease-out"
      :class="expanded ? 'w-64' : 'h-12 w-12'"
    >
      <div v-if="!expanded" class="flex h-12 w-12 items-center justify-center">
        <v-icon class="text-glacier-100/55" size="17">mdi-code-tags</v-icon>
      </div>

      <div v-else class="flex flex-col gap-4 p-6">
        <span class="ice-title text-center text-[10px]">{{ resourceName }}</span>

        <div class="ice-divider h-px w-full"></div>

        <div class="flex flex-col gap-2.5">
          <div v-for="dep in deps" :key="dep.name" class="flex items-center justify-between">
            <span class="text-xs font-light tracking-wide text-glacier-200/45">{{ dep.name }}</span>
            <span class="font-mono text-[11px] text-glacier-100/70">{{ dep.version }}</span>
          </div>
        </div>

        <div class="ice-divider h-px w-full"></div>

        <div class="flex items-center justify-between">
          <span class="text-xs font-light tracking-wide text-glacier-200/45">View</span>
          <span
            class="text-xs font-light"
            :class="currentView !== 'none' ? 'text-glacier-200/85' : 'text-glacier-300/25'"
          >
            {{ currentView !== 'none' ? currentView : 'None' }}
          </span>
        </div>
      </div>
    </IcePanel>
  </div>
</template>
