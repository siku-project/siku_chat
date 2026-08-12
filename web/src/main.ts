import './assets/main.css'
import '@mdi/font/css/materialdesignicons.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createVuetify } from 'vuetify'
import { aliases, mdi } from 'vuetify/iconsets/mdi'
import 'vuetify/styles'

import App from './App.vue'
import i18n from './i18n'
import { DEV_MESSAGES } from '@/mock/locale'

const vuetify = createVuetify({
  theme: {
    defaultTheme: 'dark',
  },
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi,
    },
  },
})

const app = createApp(App)

app.use(createPinia())
app.use(vuetify)
app.use(i18n)

if (import.meta.env.DEV) {
  for (const [language, messages] of Object.entries(DEV_MESSAGES)) {
    i18n.global.setLocaleMessage(language, messages)
  }
}

app.mount('#app')
