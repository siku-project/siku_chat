<script lang="ts">
  import type { Snippet } from 'svelte'
  import type { ChatPosition } from '@/lib/chat/types'

  interface Props {
    position: ChatPosition
    interactive?: boolean
    children: Snippet
  }

  let { position, interactive = false, children }: Props = $props()
</script>

<div class="chat-anchor chat-anchor--{position}" class:is-interactive={interactive}>
  {@render children()}
</div>
