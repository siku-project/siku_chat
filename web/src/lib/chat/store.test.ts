import { beforeEach, describe, expect, it, vi } from 'vitest'
import { store } from './store.svelte'

const action = (name: string) => `siku_chat:nui:${name}`

describe('store', () => {
  beforeEach(() => {
    vi.useFakeTimers()
    store.clear()
    store.hide()
    store.setMode('public')
    store.setConfig({ passiveEnabled: true, passiveDuration: 1000, passiveMaxMessages: 2 })
  })

  it('ignores messages that are not ours', () => {
    expect(store.applyMessage({ action: 'other:thing' })).toBe(false)
    expect(store.applyMessage(null)).toBe(false)
    expect(store.applyMessage({ action: action('unknown') })).toBe(false)
  })

  it('normalizes what the game sends and keeps the latest messages', () => {
    store.setConfig({ maxMessages: 2 })
    store.applyMessage({ action: action('addMessage'), message: { text: 'one', type: 'weird' } })
    store.applyMessage({
      action: action('addMessage'),
      message: { text: 'two', type: 'player', author: 'Léa', channel: 'nowhere' },
    })
    store.applyMessage({ action: action('addMessage'), message: { text: 'three', type: 'info' } })
    store.applyMessage({ action: action('addMessage'), message: { nope: true } })

    expect(store.messages.map((message) => message.text)).toEqual(['two', 'three'])
    expect(store.messages[0]?.channel).toBe('public')
    expect(store.messages[0]?.author).toBe('Léa')
    expect(store.messages[1]?.type).toBe('info')

    store.setConfig({ maxMessages: 100 })
  })

  it('shows the latest public messages in the passive overlay while the chat is closed', () => {
    store.addMessage({ text: 'a', type: 'player', author: 'A' })
    store.addMessage({ text: 'b', type: 'player', author: 'B' })
    store.addMessage({ text: 'c', type: 'player', author: 'C' })
    store.addMessage({ text: 'staff', type: 'player', author: 'S', channel: 'staff' })

    expect(store.passiveMessages.map((message) => message.text)).toEqual(['b', 'c'])

    vi.advanceTimersByTime(1000)

    expect(store.passiveMessages).toEqual([])

    store.addMessage({ text: 'd' })
    store.show()

    expect(store.visible).toBe(true)
    expect(store.passiveMessages).toEqual([])

    store.addMessage({ text: 'e' })

    expect(store.passiveMessages).toEqual([])
  })

  it('filters the visible messages by channel', () => {
    store.addMessage({ text: 'public' })
    store.addMessage({ text: 'staff', channel: 'staff' })

    expect(store.visibleMessages.map((message) => message.text)).toEqual(['public'])

    store.applyMessage({ action: action('setStaffMode'), enabled: true })

    expect(store.mode).toBe('staff')
    expect(store.visibleMessages.map((message) => message.text)).toEqual(['staff'])
  })

  it('replays the kept messages only on an empty chat and registers the suggestions', () => {
    store.applyMessage({
      action: action('sync'),
      state: {
        suggestions: [{ name: 'me', params: [{ name: 'action' }, 'junk'] }, { bad: true }],
        messages: [{ text: 'kept', timestamp: 42 }, { nope: 1 }],
      },
    })

    expect(store.commands).toEqual([
      {
        name: 'me',
        description: '',
        params: [{ name: 'action', description: '', optional: false }],
      },
    ])
    expect(store.messages.map((message) => message.timestamp)).toEqual([42])

    store.applyMessage({ action: action('sync'), state: { messages: [{ text: 'again' }] } })

    expect(store.messages).toHaveLength(1)

    store.applyMessage({
      action: action('addSuggestion'),
      suggestion: { name: 'me', description: 'Do.' },
    })
    store.applyMessage({ action: action('addSuggestion'), suggestion: { name: 'do' } })
    store.applyMessage({ action: action('removeSuggestion'), name: 'me' })

    expect(store.commands.map((command) => command.name)).toEqual(['do'])

    store.unregisterCommand('do')
  })

  it('keeps only the typed configuration fields', () => {
    store.applyMessage({
      action: action('setConfig'),
      config: {
        commandPrefix: '!',
        inputMode: 'touch',
        maxMessageLength: '12',
        allowMessages: false,
      },
    })

    expect(store.config.commandPrefix).toBe('!')
    expect(store.config.inputMode).toBe('keyboard')
    expect(store.config.maxMessageLength).toBe(256)
    expect(store.config.allowMessages).toBe(false)

    store.setConfig({ commandPrefix: '/', allowMessages: true })
  })
})
