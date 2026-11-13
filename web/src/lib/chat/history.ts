/** What the player typed before, recalled with the arrows while the draft is kept aside. */
export interface InputHistory {
  readonly entries: readonly string[]
  readonly navigating: boolean
  push(entry: string, max: number): void
  up(current: string): string | null
  down(): string | null
  reset(): void
}

export const createHistory = (): InputHistory => {
  let entries: string[] = []
  let index = -1
  let draft = ''

  return {
    get entries(): readonly string[] {
      return entries
    },

    get navigating(): boolean {
      return index !== -1
    },

    push(entry: string, max: number): void {
      index = -1
      draft = ''

      const trimmed = entry.trim()

      if (trimmed.length === 0 || max <= 0) {
        return
      }

      entries = [...entries, trimmed].slice(-max)
    },

    up(current: string): string | null {
      if (entries.length === 0) {
        return null
      }

      if (index === -1) {
        draft = current
        index = entries.length - 1
      } else if (index > 0) {
        index -= 1
      }

      return entries[index] ?? null
    },

    down(): string | null {
      if (index === -1) {
        return null
      }

      if (index < entries.length - 1) {
        index += 1
        return entries[index] ?? null
      }

      index = -1

      return draft
    },

    reset(): void {
      index = -1
      draft = ''
    },
  }
}
