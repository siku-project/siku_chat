<script setup lang="ts">
import { ref } from 'vue'

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
  <div class="fixed bottom-4 right-4 z-50">
    <div
      class="w-12 h-12 rounded-full bg-zinc-950/85 backdrop-blur-xl border border-emerald-500/30 shadow-[0_8px_32px_rgba(0,0,0,0.6)] flex items-center justify-center cursor-pointer transition-all duration-300 hover:border-emerald-500/50 hover:shadow-[0_8px_32px_rgba(16,185,129,0.15)]"
      @click="open = true"
    >
      <v-icon class="text-emerald-500" size="20">mdi-view-dashboard-outline</v-icon>
    </div>

    <v-dialog v-model="open" max-width="420">
      <v-card class="bg-zinc-950/95 backdrop-blur-xl border border-emerald-500/20 rounded-2xl">
        <v-card-title
          class="text-emerald-500 text-center text-sm font-semibold tracking-wide pt-5 pb-0"
        >
          Selection d'interface
        </v-card-title>

        <v-card-text class="pt-4 pb-5 px-5">
          <div v-if="views.length > 0" class="flex flex-col gap-2">
            <div
              v-for="view in views"
              :key="view"
              class="flex items-center justify-between px-4 py-3 rounded-xl cursor-pointer transition-all duration-200 border"
              :class="
                currentView === view
                  ? 'bg-emerald-500/10 border-emerald-500/30'
                  : 'bg-zinc-900/50 border-zinc-800/50 hover:bg-zinc-900 hover:border-emerald-500/20'
              "
              @click="emit('selectView', currentView === view ? 'none' : view)"
            >
              <span
                class="text-sm"
                :class="currentView === view ? 'text-emerald-400 font-medium' : 'text-zinc-300'"
              >
                {{ view }}
              </span>
              <v-icon v-if="currentView === view" class="text-emerald-500" size="16"
                >mdi-check-circle</v-icon
              >
            </div>
          </div>

          <div v-else class="flex flex-col items-center gap-4 py-6">
            <v-icon class="text-zinc-600" size="48">mdi-monitor-off</v-icon>
            <span class="text-zinc-500 text-sm text-center">Aucune interface disponible</span>
            <span class="text-zinc-600 text-xs text-center"
              >Developpes-en une et ajoute-la ici</span
            >
          </div>
        </v-card-text>
      </v-card>
    </v-dialog>
  </div>
</template>
