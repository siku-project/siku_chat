import type { CommandDef, CommandParam } from './types'

export interface ParsedCommand {
  name: string
  args: string[]
  raw: string
}

/** One row of the suggestion list: which command, which part of it to stress, what to say about it. */
export interface Suggestion {
  command: CommandDef
  description: string
  highlightName: boolean
  activeParam: number
}

export const isCommand = (input: string, prefix: string): boolean =>
  input.trimStart().startsWith(prefix)

/** Whether the caret still writes the command name, before any space. */
export const inNameStage = (input: string, prefix: string): boolean =>
  input.startsWith(prefix) && !input.slice(prefix.length).includes(' ')

export const parseCommand = (input: string, prefix: string): ParsedCommand => {
  const body = input.trim().slice(prefix.length).trim()
  const parts = body.length > 0 ? body.split(/\s+/) : []
  const name = parts.shift() ?? ''

  return { name, args: parts, raw: body }
}

export const completeCommand = (prefix: string, name: string): string => `${prefix}${name} `

export const formatParam = (param: CommandParam): string =>
  param.optional ? `[${param.name}]` : `<${param.name}>`

/**
 * The suggestions for what is typed: every command whose name starts the
 * same way while the name is being written, then the one command typed with
 * the hint of the argument the caret is on.
 */
export const suggestionsFor = (
  input: string,
  prefix: string,
  commands: CommandDef[],
): Suggestion[] => {
  if (!input.startsWith(prefix)) {
    return []
  }

  const tokens = input.slice(prefix.length).split(' ')
  const typedName = (tokens[0] ?? '').toLowerCase()
  const tokenIndex = tokens.length - 1

  if (tokenIndex === 0) {
    return commands
      .filter((command) => command.name.toLowerCase().startsWith(typedName))
      .map((command) => ({
        command,
        description: command.description,
        highlightName: true,
        activeParam: -1,
      }))
  }

  const command = commands.find((entry) => entry.name.toLowerCase() === typedName)

  if (!command) {
    return []
  }

  const paramIndex = tokenIndex - 1
  const param = command.params[paramIndex]

  return [
    {
      command,
      description: param ? param.description : command.description,
      highlightName: false,
      activeParam: param ? paramIndex : -1,
    },
  ]
}
