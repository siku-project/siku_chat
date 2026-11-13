PassiveConfig = {
  --- Mode
  ---
  --- Controls the passive overlay (recent incoming messages shown while
  --- the chat is closed).
  ---
  --- 'dynamic' : the passive overlay is shown. Each player may toggle it
  ---   off for their own session with KeybindsConfig.passiveKey.
  --- 'hidden'  : the passive overlay is disabled and players cannot enable
  ---   it.
  ---
  --- Available: 'dynamic', 'hidden'
  ---
  --- Default: 'dynamic'
  mode = 'dynamic',

  --- Position
  ---
  --- Where the incoming messages appear while the chat is closed, inside
  --- the GTA safe zone. Usually the same place as ChatConfig.position so
  --- the chat opens where the messages were.
  ---
  --- Available: 'top-left', 'top-center', 'top-right',
  ---            'left', 'center', 'right',
  ---            'bottom-left', 'bottom-center', 'bottom-right'
  ---
  --- Default: 'top-left'
  position = 'top-left',

  --- Duration
  ---
  --- How long, in milliseconds, each message stays in the passive overlay
  --- before it fades out.
  ---
  --- Default: 10000
  duration = 10000,

  --- Max messages
  ---
  --- The maximum number of messages shown at once in the passive overlay.
  --- When exceeded, the oldest one is removed immediately.
  ---
  --- Default: 3
  maxMessages = 3,
}
