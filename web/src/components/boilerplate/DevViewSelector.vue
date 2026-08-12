<script setup lang="ts">
import { ref } from 'vue'
import IcePanel from '@/components/ui/IcePanel.vue'

defineProps<{
  views: string[]
  currentView: string
}>()

const emit = defineEmits<{
  selectView: [view: string]
}>()

const open = ref(false)
</script>

<template>
  <div class="fixed bottom-7 right-7 z-50">
    <IcePanel variant="secondary" circle interactive class="h-12 w-12" @click="open = true">
      <div class="flex h-12 w-12 items-center justify-center">
        <v-icon class="text-glacier-100/55" size="17">mdi-view-dashboard-outline</v-icon>
      </div>
    </IcePanel>

    <v-dialog v-model="open" max-width="440">
      <IcePanel variant="primary" class="px-7 py-7">
        <p class="ice-title mb-6 text-center text-[10px]">Interfaces</p>

        <div v-if="views.length > 0" class="flex flex-col gap-2.5">
          <div
            v-for="view in views"
            :key="view"
            class="flex items-center justify-between rounded-2xl border px-5 py-3.5 transition-all duration-300"
            :class="
              currentView === view
                ? 'border-glacier-200/25 bg-glacier-200/[0.05]'
                : 'cursor-pointer border-white/[0.04] bg-white/[0.015] hover:border-white/[0.12] hover:bg-white/[0.035]'
            "
            @click="emit('selectView', currentView === view ? 'none' : view)"
          >
            <span
              class="text-sm font-light tracking-wide"
              :class="currentView === view ? 'text-glacier-50' : 'text-glacier-200/60'"
            >
              {{ view }}
            </span>
            <v-icon v-if="currentView === view" class="text-glacier-200/75" size="14">
              mdi-check
            </v-icon>
          </div>
        </div>

        <div v-else class="flex flex-col items-center gap-5 py-10">
          <v-icon class="text-glacier-300/25" size="36">mdi-monitor-off</v-icon>
          <span class="text-sm font-light tracking-wide text-glacier-200/50"
            >No interface available</span
          >
          <span class="text-xs font-light text-glacier-300/25">Build one and register it here</span>
        </div>
      </IcePanel>
    </v-dialog>
  </div>
</template>
