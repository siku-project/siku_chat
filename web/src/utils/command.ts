export interface ParsedCommand {
  name: string
  args: string[]
  raw: string
}

export interface CommandParam {
  name: string
  description: string
  optional?: boolean
}

export interface CommandDef {
  name: string
  description: string
  params: CommandParam[]
  staff?: boolean
}

export interface CommandSuggestion {
  command: CommandDef
  description: string
  highlightName: boolean
  activeParam: number
}

export function isCommand(input: string, prefix: string): boolean {
  return input.trimStart().startsWith(prefix)
}

export function parseCommand(input: string, prefix: string): ParsedCommand {
  const body = input.trim().slice(prefix.length).trim()
  const parts = body.length > 0 ? body.split(/\s+/) : []
  const name = parts.shift() ?? ''
  return { name, args: parts, raw: body }
}
