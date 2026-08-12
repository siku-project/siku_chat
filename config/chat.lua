ChatConfig = {
  --- Command prefix
  ---
  --- The character used to initiate a command in the chat.
  --- When a player types this character at the beginning of a message,
  --- the system treats it as a command instead of a regular message.
  ---
  --- Allowed characters: ? , ; . : / = + %
  ---
  --- Default: '/'
  commandPrefix = '/',

  --- Max messages
  ---
  --- The maximum number of messages kept in the chat history.
  --- When the limit is reached, the oldest message is removed
  --- to make room for the new one.
  ---
  --- Default: 100
  maxMessages = 100,

  --- Max message length
  ---
  --- The maximum number of characters allowed in a single chat message.
  --- The input stops accepting characters past this limit.
  ---
  --- Default: 256
  maxMessageLength = 256,

  --- Message cooldown
  ---
  --- The minimum delay, in milliseconds, between two messages from the
  --- same player. A message sent before the cooldown has elapsed is blocked.
  --- Set to 0 to disable the cooldown.
  ---
  --- Default: 1000
  messageCooldown = 1000,

  --- Allow messages
  ---
  --- When true, players can send regular chat messages (normal behaviour).
  --- When false, only commands are allowed — a plain message is neither
  --- sent nor displayed; only commands can be sent and executed.
  ---
  --- Default: true
  allowMessages = true,

  --- Replay messages
  ---
  --- The number of recent public messages the server keeps and replays to a
  --- player when their chat loads (connection or resource restart), so the
  --- chat content survives reloads and stays server-authoritative.
  --- Set to 0 to disable the replay.
  ---
  --- Default: 20
  replayMessages = 20,

  --- Input mode
  ---
  --- Controls how the player interacts with the chat.
  ---
  --- 'keyboard' : full keyboard control, no mouse cursor. The input is
  ---   focused as soon as the chat opens; command suggestions are navigated
  ---   with the arrow keys and confirmed with Tab or Enter.
  --- 'mouse'    : the mouse cursor is shown. Click the input to type and
  ---   click a suggestion to select it.
  ---
  --- Available: 'keyboard', 'mouse'
  ---
  --- Default: 'keyboard'
  inputMode = 'keyboard',
}
