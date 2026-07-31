<script setup lang="ts">
import BoilerplateView from './views/BoilerplateView.vue'

const isDevelopment = import.meta.env.DEV
</script>

<template>
  <VApp>
    <BoilerplateView v-if="isDevelopment" />
    <RouterView v-if="!isDevelopment" />
  </VApp>
</template>
