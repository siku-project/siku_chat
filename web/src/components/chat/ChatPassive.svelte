<script lang="ts">
  import { fade } from 'svelte/transition'
  import { Badge, Icon } from '@siku/ui'
  import ChatAnchor from '@/components/chat/ChatAnchor.svelte'
  import { store } from '@/lib/chat/store.svelte'
  import { VOICES } from '@/lib/chat/voices'

  const position = $derived(store.config.passivePosition)
</script>

{#if !store.visible && store.passiveMessages.length > 0}
  <div
    class="chat-scrim chat-scrim--{position}"
    aria-hidden="true"
    transition:fade={{ duration: 200 }}
  ></div>

  <ChatAnchor {position}>
    <div class="chat-passive chat-passive--{position}" aria-live="polite">
      {#each store.passiveMessages as message (message.id)}
        {@const voice = VOICES[message.type]}
        <div
          class="chat-passive__row t-body-sm"
          class:chat-passive__row--voice={voice}
          transition:fade={{ duration: 200 }}
        >
          {#if voice}
            <Icon name={voice.icon} size="sm" class="chat-passive__icon" />
            <Badge tone="live" label={voice.label()} />
            <span class="chat-passive__voice">{message.text}</span>
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
