<script lang="ts">
  import { Button, TextField } from '@siku/ui'

  let {
    value = $bindable(''),
    placeholder,
    maxLength,
    mouse,
    canSend,
    help,
    sendLabel,
    onkeydown,
    oninput,
    onfocus,
    onblur,
    onsend,
  }: {
    value?: string
    placeholder: string
    maxLength: number
    mouse: boolean
    canSend: boolean
    help?: string
    sendLabel: string
    onkeydown: (event: KeyboardEvent) => void
    oninput: () => void
    onfocus: () => void
    onblur: () => void
    onsend: () => void
  } = $props()

  let root = $state<HTMLDivElement | null>(null)

  export const focus = (): void => {
    root?.querySelector('input')?.focus()
  }
</script>

<div class="chat-field" bind:this={root}>
  <div class="chat-field__input">
    <TextField
      bind:value
      size="sm"
      {placeholder}
      {help}
      aria-label={placeholder}
      maxlength={maxLength}
      autocomplete="off"
      spellcheck={false}
      {onkeydown}
      {oninput}
      {onfocus}
      {onblur}
    >
      {#snippet end()}
        <span class="chat-field__count t-caption">{value.length}/{maxLength}</span>
      {/snippet}
    </TextField>
  </div>

  {#if mouse}
    <Button variant="primary" size="sm" disabled={!canSend} onclick={onsend}>{sendLabel}</Button>
  {/if}
</div>
