# siku_chat

A modern, modular and high-performance chat system for the SIKU ecosystem. Built with clean architecture, seamless UI integration, scalability, and immersive roleplay communication in mind.

![Version](https://img.shields.io/badge/version-2.0.2-4785bd)
![FiveM](https://img.shields.io/badge/fx__version-cerulean-4785bd)
![Lua](https://img.shields.io/badge/Lua-5.4-4785bd)
![Svelte](https://img.shields.io/badge/NUI-Svelte%205-4785bd)
![Design system](https://img.shields.io/badge/%40siku%2Fui-1.19-4785bd)

## Features

- **Server-authoritative by design**: every message, suggestion and permission check is validated on the server. The client and the interface are never trusted.
- **SIKU interface**: a Svelte 5 NUI built with the official `@siku/ui` design system, placed in the GTA safe zone, keyboard first, with visible keys and compact density on small screens.
- **Nine positions** for the chat panel and for the incoming messages: top, middle and bottom, left, center and right.
- **Public chat** with anti-flood cooldown, UTF-8 aware length limits, color-code sanitization and command-prefix rejection.
- **Staff channel** gated by the SIKU RBAC permission `chat.staff.join`, delivered only to permitted players, with rank badges.
- **Commands** through the native FiveM command system, with the typed commands of `siku_core` and their suggestions, filtered by permission per player and kept in step when roles change.
- **Message replay**: the server keeps the last public messages and replays them, with their server timestamps, to a player whose chat loads.
- **Server hooks** to observe, change or cancel any message of any channel, from any resource.
- **Passive overlay**: incoming messages stay visible while the chat is closed, with a per-session toggle.
- **Input history**, command completion and per-argument hints.
- **Structured logs** through `Siku.log`, read in the SIKU Control Center.
- **French and English** out of the box, pushed from Lua to the interface at runtime.

## Dependencies

| Resource | Required | Purpose |
|---|---|---|
| [`siku_core`](https://github.com/siku-project/siku_core) ≥ 1.7.1 | Yes | The `Siku` SDK: RBAC, session cache, command service, keybinds, logs. |
| [`siku_notification`](https://github.com/siku-project/siku_notification) | Recommended | Feedback when the passive overlay is toggled. The chat works without it. |

`siku_core` must be started **before** `siku_chat`.

## Installation

### From a release (recommended)

Download the latest [release](https://github.com/siku-project/siku_chat/releases) zip and extract it into your resources folder. The zip ships the interface **already built**: no build step.

### From source

The repository holds the interface sources but no build: build it once.

```bash
git clone git@github.com:siku-project/siku_chat.git
cd siku_chat/web
bun install
bun run build
```

### server.cfg

```cfg
ensure siku_core
ensure siku_notification
ensure siku_chat
```

## Configuration

Every option lives in `config/` and is documented in place.

| File | Options |
|---|---|
| `config/chat.lua` | `commandPrefix`, `position`, `maxMessages`, `maxMessageLength`, `messageCooldown`, `allowMessages`, `replayMessages`, `inputMode` (`keyboard` / `mouse`) |
| `config/passive.lua` | `mode` (`dynamic` / `hidden`), `position`, `duration`, `maxMessages` |
| `config/keybinds.lua` | `openKey` (default `T`), `passiveKey` (default `U`) |
| `config/history.lua` | `enable`, `max` |
| `config/translation.lua` | `language` (`fr` / `en`) |

Positions: `top-left`, `top-center`, `top-right`, `left`, `center`, `right`, `bottom-left`, `bottom-center`, `bottom-right`. In the bottom positions, the command suggestions open above the panel.

A `commandPrefix` outside the allowed set (`? , ; . : / = + %`) is replaced by `/` and reported as a `chat.prefix_invalid` warning: the chat keeps working.

## Keybinds

| Key | Action |
|---|---|
| `T` | Open the chat |
| `U` | Show or hide the incoming messages |
| `Escape` | Leave the staff channel, then close the chat |
| `Enter` | Complete the highlighted command while its name is being typed, send otherwise |
| `Tab` | Complete the highlighted command |
| `↑` / `↓` | Move in the suggestions, or recall the input history |

Keys are registered through the SIKU keybind library: players rebind them in the GTA settings.

## API

### Server exports

```lua
-- Show a message to one player (server id) or everyone (-1).
exports.siku_chat:AddMessage(target, {
  content = 'Welcome to SIKU.',   -- required
  type = 'info',                  -- 'server' | 'staff' | 'system' | 'info' | 'success' | 'warning' | 'error'
  author = nil,                   -- optional display name
  icon = 'snowflake',             -- optional @siku/ui icon name
})

-- Clear the chat of one player or everyone. Clearing everyone also forgets the replayed messages.
exports.siku_chat:Clear(-1)

-- Register or remove a command suggestion.
exports.siku_chat:AddSuggestion(target, {
  name = 'me',                    -- required, with or without the prefix
  description = 'Describe an action.',
  params = {
    { name = 'action', description = 'The action performed.', optional = false },
  },
})
exports.siku_chat:RemoveSuggestion(target, 'me')
```

Resource messages always go to the public channel. The `server` and `staff` types are voices: the line carries an icon (server, shield), a glacier badge (« Server », « Staff ») and white text, in the chat and in the incoming messages. Behind the incoming messages, a radial scrim rises from the edge of the screen at the chosen position so the text stays readable on bright scenes. Suggestions belong to the resource that registered them and are removed when it stops.

### Client exports

The same surface, for the local player: `AddMessage(data)`, `Clear()`, `AddSuggestion(suggestion)`, `RemoveSuggestion(name)`.

### Server hooks

Hooks see every message a player sends, in the public **and** the staff channel: a word filter registered once covers both. They run before delivery, by ascending priority, each isolated: a failing hook is recorded as `chat.hook_failed` and skipped.

```lua
local id = exports.siku_chat:RegisterHook('beforeMessage', function(ctx)
  -- ctx: { source, author, content, channel, type, metadata }
  if ctx.channel == 'public' and ctx.content:find('forbidden') then
    return false                                           -- cancel the message
  end

  return { content = ctx.content, metadata = { checked = true } }  -- change it
end, { priority = -10 })

exports.siku_chat:RegisterHook('afterMessage', function(ctx)
  -- observation only, after delivery
end)

exports.siku_chat:RemoveHook(id)
```

`ctx.metadata` is a table hooks share between them on the server. It never leaves the server: nothing a hook stores there reaches a client.

Hooks are removed when their resource stops.

### Events

The `siku_chat:client:*` events are network events, usable from the server with `TriggerClientEvent` or locally from another client resource: `addMessage` (a message in its interface shape: `text`, and optionally `type`, `channel`, `author`, `rank`, `icon`, `timestamp`), `clear`, `addSuggestion`, `removeSuggestion`, `sync`, `setStaffMode`.

## Commands

The chat executes no command itself: a line starting with the prefix goes to the native FiveM command system with the player's own privileges. Commands registered through `Siku.command.register` get typed arguments, permission checks and cooldowns, and their suggestions appear in the chat on their own.

The core pushes a player's suggestions when their character loads and whenever their roles change. The chat takes each push as the sign that the allowed set changed and rebuilds it: a suggestion the player is no longer allowed to use disappears at once, a new one appears. Every suggestion coming from the core belongs to `siku_core`, whether the core pushed it or the chat asked for it.

The cooldown only applies to messages: a command is never delayed, on the server nor in the interface.

| Command | Where | Effect |
|---|---|---|
| `/announce <message>` | `chat.announce`, and the server console | Shows an announcement to every player: a `staff` message with the shield icon and the Staff badge when a player sends it, a `server` message with the server icon and badge from the console. Kept for the replay like any public message. |
| `/staffchat` | Players with `chat.staff.join` | Opens the chat in the staff channel. |

Give `chat.announce` to the roles allowed to speak to everyone.

## Staff channel

- Access needs the RBAC permission **`chat.staff.join`** on the player's active character.
- `/staffchat` joins the channel, `Escape` leaves it.
- Every staff message is validated again on the server, goes through the hooks with `channel = 'staff'`, and is delivered only to permitted players.
- The sender's primary role shows as a badge: `mod`, `dev`, `admin`, `owner`.

## Logs

| Event | Level | When |
|---|---|---|
| `chat.message_rejected` | debug, warn for `staff_denied` | A message is refused: `reason` is `text_invalid`, `too_long`, `cooldown`, `hook` or `staff_denied`. |
| `chat.export_invalid` | warn | A resource called an export with a wrong argument: `export` and `reason`. |
| `chat.hook_rejected`, `chat.hook_failed` | warn, error | A hook registration is refused, or a hook raised. |
| `chat.prefix_invalid` | warn | The configured prefix is not allowed and `/` is used. |
| `chat.cleared` | info | A resource cleared the chat of everyone. |

Commands typed in the chat are audited by the core as `command.executed`.

## Translations

`translations/fr.lua` and `translations/en.lua` hold every player-facing string: the Lua ones at the top level, the interface ones in the `web` block. The active language is pushed to the interface at runtime, and `bun run messages` in `web/` regenerates the Paraglide messages from the Lua files.

## Development

The interface lives in `web/` (Svelte 5, TypeScript, Tailwind, `@siku/ui`, Paraglide, Vite, built with [Bun](https://bun.sh)).

```bash
cd web
bun install
bun run dev          # playground with mock messages, commands and a Simulation panel
bun run build        # production build → web/dist
bun run check        # locales, svelte-check, lint, siku check, siku doctor
bun run test:unit    # vitest
```

In development the app boots into a playground: the Simulation panel opens or closes the chat, switches channel, input mode, positions and language, and injects incoming messages. In production only the chat ships.

```
siku_chat/
├── client/            # siku_ui bridge, NUI transport, chat logic, keybinds, exports
├── server/
│   ├── init.lua       # core version check, prefix resolution
│   ├── main.lua       # message pipeline, replay, exports
│   └── modules/       # clock, hooks, suggestion registry, staff channel
├── shared/            # payload normalization
├── config/            # every option
├── translations/      # fr / en
└── web/               # Svelte 5 interface
```

## Credits

Part of the [SIKU project](https://github.com/siku-project), © Siku Studio.
