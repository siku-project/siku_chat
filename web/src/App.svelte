<script lang="ts">
  import { onMount } from 'svelte'
  import type { Component } from 'svelte'
  import { Toaster } from '@siku/ui'
  import { game } from '@/lib/chat/bridge'
  import { store } from '@/lib/chat/store.svelte'
  import { applyTranslations } from '@/lib/i18n.svelte'
  import { locale } from '@/lib/locale.svelte'
  import { RESOURCE } from '@/lib/nui'
  import ChatView from '@/views/ChatView.svelte'

  interface LocalePayload {
    language?: string
    translations?: { web?: Record<string, string> }
  }

  interface ReadyResponse {
    locale?: LocalePayload
  }

  interface NuiMessage {
    action?: string
    locale?: LocalePayload
  }

  let Shell = $state<Component | null>(null)

  const applyLocale = (payload?: LocalePayload): void => {
    if (!payload?.language) {
      return
    }

    const web = payload.translations?.web

    if (web && typeof web === 'object') {
      applyTranslations(payload.language, web)
    } else {
      locale.set(payload.language)
    }
  }

  const handleMessage = (event: MessageEvent<NuiMessage>): void => {
    const data = event.data

    if (data?.action === `${RESOURCE}:nui:setLocale`) {
      applyLocale(data.locale)
      return
    }

    store.applyMessage(data)
  }

  onMount(() => {
    window.addEventListener('message', handleMessage)

    void (game.ready() as Promise<ReadyResponse | null>).then((answer) => {
      if (answer) {
        applyLocale(answer.locale)
      }
    })

    if (import.meta.env.DEV) {
      void Promise.all([import('@/lib/chat/mock'), import('@/views/BoilerplateView.svelte')]).then(
        ([mock, module]) => {
          mock.loadMocks()
          Shell = module.default
        },
      )
    }

    return () => window.removeEventListener('message', handleMessage)
  })
</script>

{#key locale.current}
  {#if Shell}
    <Shell />
  {:else if !import.meta.env.DEV}
    <ChatView />
  {/if}
{/key}

<Toaster />
