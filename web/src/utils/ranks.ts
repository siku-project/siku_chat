export type StaffRank = 'owner' | 'dev' | 'admin' | 'mod'

export interface RankMeta {
  label: string
}

export const STAFF_RANKS: Record<StaffRank, RankMeta> = {
  owner: { label: 'Owner' },
  dev: { label: 'Dev' },
  admin: { label: 'Admin' },
  mod: { label: 'Mod' },
}

export function isStaffRank(rank: string | undefined): rank is StaffRank {
  return rank !== undefined && rank in STAFF_RANKS
}

export function rankLabel(rank: string | undefined): string {
  return isStaffRank(rank) ? STAFF_RANKS[rank].label : ''
}
