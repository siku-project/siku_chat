<script lang="ts">
  import { Button, Modal, Segmented, Tooltip } from '@siku/ui'
  import { app } from '@/lib/app.svelte'
  import { locale } from '@/lib/locale.svelte'

  let open = $state(false)

  const languages = $derived(
    locale.all.map((language) => ({ value: language, label: language.toUpperCase() })),
  )
</script>

<Tooltip text="Simulation">
  <Button
    variant="secondary"
    iconOnly
    icon="settings"
    label="Simulation"
    class="rounded-full"
    onclick={() => (open = true)}
  />
</Tooltip>

<Modal bind:open title="Simulation">
  <div class="flex flex-col gap-5">
    <p class="t-body-sm text-fg-tertiary">
      What the server would send. Nothing here reaches the game.
    </p>

    <div class="sk-field">
      <span class="sk-field__label">Interface</span>
      <Segmented
        label="Interface"
        block
        value={app.visible ? 'shown' : 'hidden'}
        options={[
          { value: 'shown', label: 'Shown' },
          { value: 'hidden', label: 'Hidden' },
        ]}
        onchange={(value) => app.setVisible(value === 'shown')}
      />
    </div>

    <div class="sk-field">
      <span class="sk-field__label">Language</span>
      <Segmented
        label="Language"
        block
        value={locale.current}
        options={languages}
        onchange={(value) => locale.set(value)}
      />
    </div>
  </div>

  {#snippet actions()}
    <Button variant="primary" data-autofocus onclick={() => (open = false)}>Done</Button>
  {/snippet}
</Modal>
