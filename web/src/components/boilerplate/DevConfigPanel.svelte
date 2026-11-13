<script lang="ts">
  import { Button, Modal, Segmented, Tooltip } from '@siku/ui'
  import { simulateIncoming } from '@/lib/chat/mock'
  import { store } from '@/lib/chat/store.svelte'
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
      <span class="sk-field__label">Chat</span>
      <Segmented
        label="Chat"
        block
        value={store.visible ? 'open' : 'closed'}
        options={[
          { value: 'open', label: 'Open' },
          { value: 'closed', label: 'Closed' },
        ]}
        onchange={(value) => (value === 'open' ? store.show() : store.hide())}
      />
      <span class="sk-field__help">Closed, incoming messages show in the passive overlay.</span>
    </div>

    <div class="sk-field">
      <span class="sk-field__label">Channel</span>
      <Segmented
        label="Channel"
        block
        value={store.mode}
        options={[
          { value: 'public', label: 'Public' },
          { value: 'staff', label: 'Staff' },
        ]}
        onchange={(value) => store.setMode(value === 'staff' ? 'staff' : 'public')}
      />
    </div>

    <div class="sk-field">
      <span class="sk-field__label">Input</span>
      <Segmented
        label="Input"
        block
        value={store.config.inputMode}
        options={[
          { value: 'keyboard', label: 'Keyboard' },
          { value: 'mouse', label: 'Mouse' },
        ]}
        onchange={(value) =>
          store.setConfig({ inputMode: value === 'mouse' ? 'mouse' : 'keyboard' })}
      />
    </div>

    <div class="sk-field">
      <span class="sk-field__label">Messages</span>
      <Segmented
        label="Messages"
        block
        value={store.config.allowMessages ? 'all' : 'commands'}
        options={[
          { value: 'all', label: 'Allowed' },
          { value: 'commands', label: 'Commands only' },
        ]}
        onchange={(value) => store.setConfig({ allowMessages: value === 'all' })}
      />
    </div>

    <div class="sk-field">
      <span class="sk-field__label">Passive overlay</span>
      <Segmented
        label="Passive overlay"
        block
        value={store.config.passiveEnabled ? 'on' : 'off'}
        options={[
          { value: 'on', label: 'Shown' },
          { value: 'off', label: 'Hidden' },
        ]}
        onchange={(value) => store.setConfig({ passiveEnabled: value === 'on' })}
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

    <Button variant="secondary" icon="msg" onclick={simulateIncoming}>Incoming message</Button>
  </div>

  {#snippet actions()}
    <Button variant="primary" data-autofocus onclick={() => (open = false)}>Done</Button>
  {/snippet}
</Modal>
