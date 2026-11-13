import { describe, expect, it } from 'vitest'
import { applyTranslations, m, tr } from './i18n.svelte'
import { locale } from './locale.svelte'

describe('i18n', () => {
  it('serves the compiled message when the game sent nothing', () => {
    expect(m.app_close()).toBe('Fermer')
  })

  it('prefers the string the game pushed for the running language', () => {
    applyTranslations(locale.current, { app_close: 'Quitter' })

    expect(m.app_close()).toBe('Quitter')
  })

  it('fills placeholders in a pushed string', () => {
    applyTranslations(locale.current, { app_title: 'Interface {name}' })

    expect(m.app_title({ name: 'demo' })).toBe('Interface demo')
  })

  it('reads a message by runtime key', () => {
    expect(tr('app_hint')).toBe(m.app_hint())
  })

  it('switches the language along with the strings', () => {
    applyTranslations('en', { app_close: 'Leave' })

    expect(locale.current).toBe('en')
    expect(m.app_close()).toBe('Leave')
    expect(m.app_hint()).toBe('Register your views in BoilerplateView and build from here.')
  })
})
