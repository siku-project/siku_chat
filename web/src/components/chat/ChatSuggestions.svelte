<script lang="ts">
  import { Hint, Surface } from '@siku/ui'
  import { formatParam, type Suggestion } from '@/lib/chat/commands'
  import { m } from '@/lib/i18n.svelte'

  let {
    suggestions,
    prefix,
    selected,
    keyboard,
    onselect,
  }: {
    suggestions: Suggestion[]
    prefix: string
    selected: number
    keyboard: boolean
    onselect: (suggestion: Suggestion) => void
  } = $props()

  let list = $state<HTMLUListElement | null>(null)

  $effect(() => {
    list?.children[selected]?.scrollIntoView({ block: 'nearest' })
  })

  const pick = (event: MouseEvent, suggestion: Suggestion): void => {
    event.preventDefault()
    onselect(suggestion)
  }
</script>

<Surface level="raised" elevated radius="lg" padding="none" class="chat-suggest">
  <ul class="chat-suggest__list" bind:this={list} role="listbox" aria-label={m.chat_commands()}>
    {#each suggestions as item, index (item.command.name)}
      <li
        class="chat-suggest__row"
        class:is-selected={keyboard && index === selected}
        class:is-mouse={!keyboard}
        role="option"
        aria-selected={keyboard && index === selected}
      >
        <button
          type="button"
          tabindex="-1"
          class="chat-suggest__button"
          onmousedown={(event) => pick(event, item)}
        >
          <span class="chat-suggest__signature">
            <span class="chat-suggest__name t-body-sm" class:is-active={item.highlightName}>
              {prefix}{item.command.name}
            </span>
            {#each item.command.params as param, position (param.name)}
              <span
                class="chat-suggest__param t-caption"
                class:is-active={item.activeParam === position}
              >
                {formatParam(param)}
              </span>
            {/each}
          </span>
          {#if item.description}
            <span class="chat-suggest__description t-caption">{item.description}</span>
          {/if}
        </button>
      </li>
    {/each}
  </ul>

  {#if keyboard}
    <div class="chat-suggest__foot">
      <Hint keys={['↑', '↓']} label={m.chat_choose()} />
      <Hint keys={['Tab']} label={m.chat_complete()} />
    </div>
  {/if}
</Surface>
