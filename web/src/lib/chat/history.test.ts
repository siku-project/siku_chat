import { describe, expect, it } from 'vitest'
import { createHistory } from './history'

describe('input history', () => {
  it('recalls the entries from the latest and gives the draft back at the end', () => {
    const history = createHistory()

    history.push('first', 20)
    history.push('second', 20)

    expect(history.up('typing')).toBe('second')
    expect(history.navigating).toBe(true)
    expect(history.up('typing')).toBe('first')
    expect(history.up('typing')).toBe('first')
    expect(history.down()).toBe('second')
    expect(history.down()).toBe('typing')
    expect(history.navigating).toBe(false)
    expect(history.down()).toBeNull()
  })

  it('keeps only the latest entries and ignores blanks', () => {
    const history = createHistory()

    history.push('  ', 2)
    history.push('a', 2)
    history.push('b', 2)
    history.push('c', 2)

    expect(history.entries).toEqual(['b', 'c'])
    expect(history.up('')).toBe('c')

    history.reset()

    expect(history.navigating).toBe(false)
  })

  it('does nothing without entries or when the history is off', () => {
    const history = createHistory()

    expect(history.up('x')).toBeNull()

    history.push('ignored', 0)

    expect(history.entries).toEqual([])
  })
})
