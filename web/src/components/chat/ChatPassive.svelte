<script lang="ts">
  import { fade } from 'svelte/transition'
  import { Badge, HudAnchor, Icon } from '@siku/ui'
  import ChatAnchor from '@/components/chat/ChatAnchor.svelte'
  import { store } from '@/lib/chat/store.svelte'
  import { m } from '@/lib/i18n.svelte'

  /** The corners where the design system lays its local scrim, so the text stays readable on bright scenes. */
  const SCRIM_CORNERS = {
    'top-left': 'top-left',
    'top-right': 'top-right',
    'bottom-left': 'bottom-left',
    'bottom-right': 'bottom-right',
  } as const

  const corner = $derived(SCRIM_CORNERS[store.config.passivePosition as keyof typeof SCRIM_CORNERS])
</script>

{#snippet nothing()}{/snippet}

{#if !store.visible && store.passiveMessages.length > 0}
  {#if corner}
    <HudAnchor {corner}>{@render nothing()}</HudAnchor>
  {/if}

  <ChatAnchor position={store.config.passivePosition}>
    <div class="chat-passive chat-passive--{store.config.passivePosition}" aria-live="polite">
      {#each store.passiveMessages as message (message.id)}
        <div
          class="chat-passive__row t-body-sm"
          class:chat-passive__row--server={message.type === 'server'}
          transition:fade={{ duration: 200 }}
        >
          {#if message.type === 'server'}
            <Icon name="server" size="sm" class="chat-passive__icon" />
            <Badge tone="solid" label={m.chat_server_badge()} />
            <span class="chat-passive__server">{message.text}</span>
          {:else if message.author}
            <span class="chat-passive__author">{message.author}</span>
            <span class="chat-passive__text">{message.text}</span>
          {:else}
            <span class="chat-passive__system">{message.text}</span>
          {/if}
        </div>
      {/each}
    </div>
  </ChatAnchor>
{/if}
