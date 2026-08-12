<script setup lang="ts">
import { ref, computed } from 'vue'
import type { Component } from 'vue'
import DevTopBar from '@/components/boilerplate/DevTopBar.vue'
import DevFab from '@/components/boilerplate/DevFab.vue'
import DevViewSelector from '@/components/boilerplate/DevViewSelector.vue'
import ChatView from '@/views/ChatView.vue'

const viewComponents: Record<string, Component> = {
  Chat: ChatView,
}

const views: string[] = Object.keys(viewComponents)
const currentView = ref('none')

const activeComponent = computed<Component | null>(() =>
  currentView.value !== 'none' ? (viewComponents[currentView.value] ?? null) : null,
)

const handleSelectView = (view: string) => {
  currentView.value = view
}
</script>

<template>
  <div
    class="fixed inset-0 w-full h-full bg-contain bg-center bg-no-repeat bg-gray-900 sm:bg-contain md:bg-cover lg:bg-cover xl:bg-cover 2xl:bg-cover bg-[url('/boilerplate-background.jpg')] transition-all duration-300"
  >
    <component :is="activeComponent" v-if="activeComponent" />

    <DevTopBar />
    <DevFab :current-view="currentView" />
    <DevViewSelector :views="views" :current-view="currentView" @select-view="handleSelectView" />
  </div>
</template>
