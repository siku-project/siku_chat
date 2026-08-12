HistoryConfig = {
  --- Enable
  ---
  --- When true, each player keeps a per-session history of the messages
  --- and commands they send, recalled with the Up / Down arrow keys in the
  --- input. When false, no history is kept.
  ---
  --- Default: true
  enable = true,

  --- Max
  ---
  --- The maximum number of entries kept in a player's history. When the
  --- limit is reached, the oldest entry is dropped (FIFO).
  ---
  --- Default: 20
  max = 20,
}
