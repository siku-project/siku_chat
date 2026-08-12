<script setup lang="ts">
import IcePanel from '@/components/ui/IcePanel.vue'

const resourceName = 'siku_chat'
const framework = 'Vue 3'
const isDev = import.meta.env.DEV
</script>

<template>
  <div class="fixed top-7 left-1/2 z-50 -translate-x-1/2">
    <IcePanel variant="primary" class="px-7 py-3.5">
      <div class="flex items-center gap-6">
        <span class="ice-title text-[10px]">{{ resourceName }}</span>

        <span class="ice-divider h-4 w-px"></span>

        <span class="text-xs font-light tracking-wider text-glacier-200/50">{{ framework }}</span>

        <span class="ice-divider h-4 w-px"></span>

        <span
          class="flex items-center gap-2.5 text-[10px] font-light uppercase tracking-[0.22em]"
          :class="isDev ? 'text-glacier-200/85' : 'text-glacier-50'"
        >
          <span
            class="h-1 w-1 rounded-full"
            :class="
              isDev
                ? 'bg-glacier-200 shadow-[0_0_10px_rgba(198,224,243,0.6)]'
                : 'bg-white shadow-[0_0_10px_rgba(255,255,255,0.7)]'
            "
          ></span>
          {{ isDev ? 'Dev' : 'Prod' }}
        </span>
      </div>
    </IcePanel>
  </div>
</template>
