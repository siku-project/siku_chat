<script lang="ts">
  import type { Snippet } from 'svelte'
  import { HudAnchor } from '@siku/ui'
  import type { ChatPosition } from '@/lib/chat/types'

  interface Props {
    position: ChatPosition
    interactive?: boolean
    children: Snippet
  }

  let { position, interactive = false, children }: Props = $props()

  /** The positions the design system anchors itself, with its local scrim in the corners. */
  const HUD_CORNERS = {
    'top-left': 'top-left',
    'top-right': 'top-right',
    'bottom-left': 'bottom-left',
    'bottom-right': 'bottom-right',
    'top-center': 'top',
    'bottom-center': 'bottom',
  } as const

  const corner = $derived(
    interactive ? undefined : HUD_CORNERS[position as keyof typeof HUD_CORNERS],
  )
</script>

{#if corner}
  <HudAnchor {corner}>
    {@render children()}
  </HudAnchor>
{:else}
  <div class="chat-anchor chat-anchor--{position}" class:is-interactive={interactive}>
    {@render children()}
  </div>
{/if}
