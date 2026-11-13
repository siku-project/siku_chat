import { describe, expect, it } from 'vitest'
import {
  completeCommand,
  formatParam,
  inNameStage,
  isCommand,
  parseCommand,
  suggestionsFor,
} from './commands'
import type { CommandDef } from './types'

const COMMANDS: CommandDef[] = [
  {
    name: 'me',
    description: 'Describe an action.',
    params: [{ name: 'action', description: 'What happens.', optional: false }],
  },
  {
    name: 'pay',
    description: 'Give money.',
    params: [
      { name: 'player', description: 'Who gets it.', optional: false },
      { name: 'amount', description: 'How much.', optional: true },
    ],
  },
  { name: 'staffchat', description: 'Join the staff channel.', params: [] },
]

describe('commands', () => {
  it('tells a command from a message by the prefix', () => {
    expect(isCommand('/me waves', '/')).toBe(true)
    expect(isCommand('  /me', '/')).toBe(true)
    expect(isCommand('hello /me', '/')).toBe(false)
    expect(inNameStage('/m', '/')).toBe(true)
    expect(inNameStage('/me ', '/')).toBe(false)
  })

  it('parses the name, the arguments and the raw body', () => {
    expect(parseCommand('/pay  12   500 ', '/')).toEqual({
      name: 'pay',
      args: ['12', '500'],
      raw: 'pay  12   500',
    })
    expect(parseCommand('/', '/')).toEqual({ name: '', args: [], raw: '' })
    expect(completeCommand('/', 'me')).toBe('/me ')
  })

  it('lists the commands whose name starts like the typed one', () => {
    const list = suggestionsFor('/', '/', COMMANDS)

    expect(list.map((entry) => entry.command.name)).toEqual(['me', 'pay', 'staffchat'])
    expect(list[0]?.highlightName).toBe(true)
    expect(suggestionsFor('/ST', '/', COMMANDS).map((entry) => entry.command.name)).toEqual([
      'staffchat',
    ])
    expect(suggestionsFor('hello', '/', COMMANDS)).toEqual([])
  })

  it('points at the argument being typed once the name is complete', () => {
    const [first] = suggestionsFor('/pay ', '/', COMMANDS)
    const [second] = suggestionsFor('/pay 12 ', '/', COMMANDS)
    const [past] = suggestionsFor('/pay 12 500 ', '/', COMMANDS)

    expect(first?.activeParam).toBe(0)
    expect(first?.description).toBe('Who gets it.')
    expect(second?.activeParam).toBe(1)
    expect(past?.activeParam).toBe(-1)
    expect(past?.description).toBe('Give money.')
    expect(suggestionsFor('/nope ', '/', COMMANDS)).toEqual([])
  })

  it('writes optional parameters in brackets', () => {
    expect(formatParam({ name: 'player', description: '', optional: false })).toBe('<player>')
    expect(formatParam({ name: 'amount', description: '', optional: true })).toBe('[amount]')
  })
})
