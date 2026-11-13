import { describe, expect, it } from 'vitest'
import { applyTranslations, m, tr } from './i18n.svelte'
import { locale } from './locale.svelte'

describe('i18n', () => {
  it('serves the compiled message when the game sent nothing', () => {
    expect(m.chat_close()).toBe('Fermer')
  })

  it('prefers the string the game pushed for the running language', () => {
    applyTranslations(locale.current, { chat_close: 'Quitter' })

    expect(m.chat_close()).toBe('Quitter')
  })

  it('fills placeholders in a pushed string', () => {
    applyTranslations(locale.current, {
      chat_commands_only: 'Commandes seulement, préfixe {prefix}',
    })

    expect(m.chat_commands_only({ prefix: '!' })).toBe('Commandes seulement, préfixe !')
  })

  it('reads a message by runtime key', () => {
    expect(tr('chat_empty')).toBe(m.chat_empty())
  })

  it('switches the language along with the strings', () => {
    applyTranslations('en', { chat_close: 'Leave' })

    expect(locale.current).toBe('en')
    expect(m.chat_close()).toBe('Leave')
    expect(m.chat_empty()).toBe('No messages yet.')
  })
})
