<script setup lang="ts">
const resourceName = 'siku_chat'
const framework = 'Vue 3'
const isDev = import.meta.env.DEV
</script>

<template>
  <div
    class="fixed top-4 left-1/2 -translate-x-1/2 z-50 px-6 py-2.5 flex items-center gap-4 rounded-2xl bg-zinc-950/85 backdrop-blur-xl border border-emerald-500/30 shadow-[0_8px_32px_rgba(0,0,0,0.6)]"
  >
    <span class="text-emerald-500 font-semibold text-sm tracking-wide">{{ resourceName }}</span>

    <span class="w-0.5 h-6 bg-gradient-to-b from-transparent via-emerald-700 to-transparent"></span>

    <span class="text-zinc-400 text-xs font-medium">{{ framework }}</span>

    <span class="w-0.5 h-6 bg-gradient-to-b from-transparent via-emerald-700 to-transparent"></span>

    <span
      class="flex items-center gap-1.5 text-xs font-medium"
      :class="isDev ? 'text-amber-400' : 'text-emerald-400'"
    >
      <span
        class="w-2 h-2 rounded-full animate-pulse"
        :class="
          isDev
            ? 'bg-amber-400 shadow-[0_0_6px_rgba(251,191,36,0.5)]'
            : 'bg-emerald-400 shadow-[0_0_6px_rgba(52,211,153,0.5)]'
        "
      ></span>
      {{ isDev ? 'DEV' : 'PROD' }}
    </span>
  </div>
</template>
