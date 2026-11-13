import { describe, expect, it } from 'vitest'
import { applyTranslations, m, tr } from './i18n.svelte'
import { locale } from './locale.svelte'

describe('i18n', () => {
  it('serves the compiled message when the game sent nothing', () => {
    expect(m.chat_send()).toBe('Envoyer')
  })

  it('prefers the string the game pushed for the running language', () => {
    applyTranslations(locale.current, { chat_send: 'Poster' })

    expect(m.chat_send()).toBe('Poster')
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
    applyTranslations('en', { chat_send: 'Post' })

    expect(locale.current).toBe('en')
    expect(m.chat_send()).toBe('Post')
    expect(m.chat_empty()).toBe('No messages yet.')
  })
})
