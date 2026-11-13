<script lang="ts">
  import { fade } from 'svelte/transition'
  import ChatAnchor from '@/components/chat/ChatAnchor.svelte'
  import { store } from '@/lib/chat/store.svelte'
</script>

{#if !store.visible && store.passiveMessages.length > 0}
  <ChatAnchor position={store.config.passivePosition}>
    <div class="chat-passive chat-passive--{store.config.passivePosition}" aria-live="polite">
      {#each store.passiveMessages as message (message.id)}
        <div class="chat-passive__row t-body-sm" transition:fade={{ duration: 200 }}>
          {#if message.author}
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
