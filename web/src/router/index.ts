import {
  createRouter,
  createMemoryHistory,
  createWebHistory,
  type RouteRecordRaw,
} from 'vue-router'

const routes: RouteRecordRaw[] = []

const router = createRouter({
  history: import.meta.env.DEV ? createWebHistory() : createMemoryHistory(),
  routes,
})

export default router
