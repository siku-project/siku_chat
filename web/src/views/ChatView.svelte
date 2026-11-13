<script lang="ts">
  import { tick } from 'svelte'
  import { fly } from 'svelte/transition'
  import { Divider, Hint, Surface } from '@siku/ui'
  import ChatHeader from '@/components/chat/ChatHeader.svelte'
  import ChatInput from '@/components/chat/ChatInput.svelte'
  import ChatMessages from '@/components/chat/ChatMessages.svelte'
  import ChatPassive from '@/components/chat/ChatPassive.svelte'
  import ChatSuggestions from '@/components/chat/ChatSuggestions.svelte'
  import { game } from '@/lib/chat/bridge'
  import {
    completeCommand,
    inNameStage,
    isCommand,
    parseCommand,
    suggestionsFor,
    type Suggestion,
  } from '@/lib/chat/commands'
  import { history, store } from '@/lib/chat/store.svelte'
  import { m } from '@/lib/i18n.svelte'

  let draft = $state('')
  let active = $state(false)
  let cooldown = $state(false)
  let selected = $state(0)
  let input = $state<ReturnType<typeof ChatInput> | null>(null)

  const prefix = $derived(store.config.commandPrefix)
  const staff = $derived(store.mode === 'staff')
  const keyboard = $derived(store.config.inputMode === 'keyboard')
  const command = $derived(isCommand(draft, prefix))
  const suggestions = $derived(active ? suggestionsFor(draft, prefix, store.commands) : [])
  const canSend = $derived(
    draft.trim().length > 0 &&
      draft.length <= store.config.maxMessageLength &&
      (command || (store.config.allowMessages && !cooldown)),
  )
  const help = $derived(
    !store.config.allowMessages && draft.trim().length > 0 && !command
      ? m.chat_commands_only({ prefix })
      : undefined,
  )

  const focusInput = (): void => {
    void tick().then(() => input?.focus())
  }

  $effect(() => {
    if (store.visible && keyboard) {
      focusInput()
    }
  })

  const close = (): void => {
    draft = ''
    store.hide()
    void game.close()
  }

  const complete = (suggestion: Suggestion): void => {
    draft = completeCommand(prefix, suggestion.command.name)
    history.reset()
    focusInput()
  }

  const startCooldown = (): void => {
    if (store.config.messageCooldown <= 0) {
      return
    }

    cooldown = true
    window.setTimeout(() => {
      cooldown = false
    }, store.config.messageCooldown)
  }

  const send = (): void => {
    const text = draft.trim()

    if (!text || !canSend) {
      return
    }

    draft = ''
    history.push(text, store.config.historyEnable ? store.config.historyMax : 0)

    if (isCommand(text, prefix)) {
      void game.command(parseCommand(text, prefix).raw)
      close()
      return
    }

    void (staff ? game.sendStaffMessage(text) : game.sendMessage(text))
    startCooldown()
    focusInput()
  }

  /** Enter completes the highlighted command while its name is still being typed, and sends otherwise. */
  const submit = (): void => {
    const top = suggestions[selected]

    if (
      keyboard &&
      top &&
      inNameStage(draft, prefix) &&
      top.command.name.toLowerCase() !== parseCommand(draft, prefix).name.toLowerCase()
    ) {
      complete(top)
      return
    }

    send()
  }

  const navigate = (delta: number): void => {
    if (keyboard && suggestions.length > 0 && !history.navigating) {
      selected = (selected + delta + suggestions.length) % suggestions.length
      return
    }

    const value = delta < 0 ? history.up(draft) : history.down()

    if (value !== null) {
      draft = value
    }
  }

  const onInput = (): void => {
    selected = 0
    history.reset()
  }

  const onKeydown = (event: KeyboardEvent): void => {
    switch (event.key) {
      case 'Enter':
        event.preventDefault()
        submit()
        break
      case 'Tab': {
        const top = suggestions[selected]

        if (keyboard && top) {
          event.preventDefault()
          complete(top)
        }
        break
      }
      case 'ArrowUp':
        event.preventDefault()
        navigate(-1)
        break
      case 'ArrowDown':
        event.preventDefault()
        navigate(1)
        break
    }
  }

  const onWindowKeydown = (event: KeyboardEvent): void => {
    if (!store.visible) {
      return
    }

    if (event.key === 'Escape') {
      event.preventDefault()

      if (staff) {
        store.setMode('public')
      } else {
        close()
      }

      return
    }

    if (event.key === 'Enter' && !active) {
      event.preventDefault()
      focusInput()
    }
  }
</script>

<svelte:window onkeydown={onWindowKeydown} />

<ChatPassive />

{#if store.visible}
  <div class="chat-shell" class:is-staff={staff} transition:fly={{ y: 8, duration: 200 }}>
    <Surface elevated padding="none" class="chat-panel">
      <ChatHeader {staff} />
      <Divider />
      <ChatMessages messages={store.visibleMessages} />
      <div class="chat-compose">
        <ChatInput
          bind:this={input}
          bind:value={draft}
          placeholder={staff ? m.chat_staff_placeholder() : m.chat_placeholder()}
          maxLength={store.config.maxMessageLength}
          mouse={!keyboard}
          {canSend}
          {help}
          sendLabel={m.chat_send()}
          onkeydown={onKeydown}
          oninput={onInput}
          onfocus={() => (active = true)}
          onblur={() => (active = false)}
          onsend={send}
        />
        {#if keyboard}
          <div class="chat-hints">
            <Hint keys={['Entrée']} label={m.chat_send()} />
            <Hint keys={['↑', '↓']} label={m.chat_history()} />
          </div>
        {/if}
      </div>
    </Surface>

    {#if suggestions.length > 0}
      <ChatSuggestions {suggestions} {prefix} {selected} {keyboard} onselect={complete} />
    {/if}
  </div>
{/if}
