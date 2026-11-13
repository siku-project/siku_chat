<script lang="ts">
  import { tick } from 'svelte'
  import type { ChatMessage } from '@/lib/chat/types'
  import { m } from '@/lib/i18n.svelte'
  import ChatMessageRow from './ChatMessageRow.svelte'

  let { messages }: { messages: ChatMessage[] } = $props()

  let log = $state<HTMLDivElement | null>(null)

  $effect(() => {
    const last = messages.at(-1)

    if (!last) {
      return
    }

    void tick().then(() => {
      if (log) {
        log.scrollTop = log.scrollHeight
      }
    })
  })
</script>

<div class="chat-log" bind:this={log}>
  <div class="chat-log__anchor">
    {#if messages.length === 0}
      <p class="chat-log__empty t-caption">{m.chat_empty()}</p>
    {:else}
      {#each messages as message (message.id)}
        <ChatMessageRow {message} />
      {/each}
    {/if}
  </div>
</div>
