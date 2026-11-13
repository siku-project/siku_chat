<script lang="ts">
  import { fade } from 'svelte/transition'
  import { Button, Divider, Surface } from '@siku/ui'
  import { app } from '@/lib/app.svelte'
  import { m } from '@/lib/i18n.svelte'
  import { RESOURCE } from '@/lib/nui'
</script>

{#if app.visible}
  <div
    class="fixed inset-0 z-overlay flex items-center justify-center"
    transition:fade={{ duration: 200 }}
  >
    <Surface elevated padding="lg" class="flex w-[26rem] flex-col gap-5">
      <div class="flex items-center justify-between gap-4">
        <span class="t-title-sm text-fg-primary">{m.app_title({ name: RESOURCE })}</span>
        <Button variant="quiet" size="sm" key="Échap" onclick={() => app.close()}>
          {m.app_close()}
        </Button>
      </div>

      <Divider />

      <p class="t-body-sm text-fg-secondary">{m.app_hint()}</p>
    </Surface>
  </div>
{/if}
