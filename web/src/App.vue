<script setup lang="ts">
import BoilerplateView from './views/BoilerplateView.vue'
import ChatView from './views/ChatView.vue'

const isDevelopment = import.meta.env.DEV
</script>

<template>
  <VApp>
    <BoilerplateView v-if="isDevelopment" />
    <ChatView v-if="!isDevelopment" />
  </VApp>
</template>
