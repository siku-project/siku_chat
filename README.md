# siku_chat

A modern, modular and high-performance chat system for the SIKU ecosystem. Built with clean architecture, seamless UI integration, scalability, and immersive roleplay communication in mind.

![Version](https://img.shields.io/badge/version-1.0.0-4785bd)
![FiveM](https://img.shields.io/badge/fx__version-cerulean-4785bd)
![Lua](https://img.shields.io/badge/Lua-5.4-4785bd)
![Vue](https://img.shields.io/badge/NUI-Vue%203-4785bd)

## Features

- **Server-authoritative by design** — every message, suggestion and permission check is validated server-side. The client and the NUI are never trusted.
- **Ice Glass interface** — a Vue 3 NUI following the SIKU art direction: no blur, glacier palette, thin luminous borders, calm animations.
- **Public chat** with anti-flood cooldown, UTF-8 aware length limits, color-code sanitization and command-prefix rejection.
- **Staff channel** gated by the SIKU RBAC permission `chat.staff.join`, with per-recipient delivery and role badges.
- **Command execution** through the native FiveM command system — fully compatible with `Siku.RegisterCommand` typed commands and their auto-registered suggestions.
- **Command suggestions** kept in a server-side registry: permission-filtered, replayed on connection, cleaned up when the owning resource stops.
- **Message replay** — the server keeps the last public messages (configurable) and replays them with their original server timestamps when a player connects or the resource restarts.
- **Server hooks** — intercept, modify or cancel any public message from any resource.
- **Passive overlay** — recent messages stay visible while the chat is closed, with a per-session toggle.
- **Input history**, command auto-completion, per-argument hints.
- **i18n** — French and English out of the box, pushed from Lua to the NUI.

## Dependencies

| Resource | Required | Purpose |
|---|---|---|
| [`siku_core`](https://github.com/siku-project/siku_core) | Yes | Framework core: exports the `Siku` API (RBAC, cache, command library, notification proxy). |
| [`siku_notification`](https://github.com/siku-project/siku_notification) | Recommended | Player feedback (passive toggle confirmation, command errors). The chat degrades gracefully without it. |

`siku_core` must be started **before** `siku_chat`.

## Installation

### From a release (recommended)

Download the latest [release](https://github.com/siku-project/siku_chat/releases) zip and extract it into your server resources folder. The zip ships with the NUI **already built** (`web/dist` only) — no build step, ready to run.

> The release does not include the NUI source code. If you want to customize the interface, install from source instead.

### From source

The repository contains the full NUI source but **no build** (`web/dist` is not versioned) — you must build it yourself:

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

`siku_core` must be first. The order between `siku_notification` and `siku_chat` does not matter.

## Configuration

All options live in `config/` and are documented inline.

| File | Options |
|---|---|
| `config/chat.lua` | `commandPrefix`, `maxMessages`, `maxMessageLength`, `messageCooldown`, `allowMessages`, `replayMessages`, `inputMode` (`keyboard` / `mouse`) |
| `config/keybinds.lua` | `openKey` (default `T`), `passiveKey` (default `L`) |
| `config/history.lua` | `enable`, `max` |
| `config/passive.lua` | `mode` (`dynamic` / `hidden`), `duration`, `maxMessages` |
| `config/translation.lua` | `language` (`fr` / `en`) |

## Keybinds

| Key | Action |
|---|---|
| `T` | Open the chat |
| `L` | Toggle the passive overlay |
| `Escape` | Leave the staff channel, then close the chat |
| `↑` / `↓` | Navigate input history or suggestions |
| `Tab` / `Enter` | Complete the selected command suggestion |

Keys are registered through FiveM key mappings — players can rebind them in their GTA settings.

## API

### Server exports

```lua
-- Show a message to one player (server id) or everyone (-1).
exports.siku_chat:AddMessage(target, {
  content = 'Welcome to SIKU.',      -- required
  type = 'info',                     -- 'system' | 'info' | 'success' | 'warning' | 'error'
  author = nil,                      -- optional display name
  icon = 'mdi-snowflake',            -- optional mdi icon
  metadata = { origin = 'greeter' }, -- optional free-form table
})

-- Clear the chat of one player or everyone. Clearing everyone also empties the replay buffer.
exports.siku_chat:Clear(-1)

-- Register / remove a command suggestion.
exports.siku_chat:AddSuggestion(target, {
  name = 'me',                       -- required, with or without the prefix
  description = 'Describe an action.',
  params = {
    { name = 'action', description = 'The action performed.', optional = false },
  },
})
exports.siku_chat:RemoveSuggestion(target, 'me')
```

### Client exports

Same surface, scoped to the local player: `AddMessage(data)`, `Clear()`, `AddSuggestion(suggestion)`, `RemoveSuggestion(name)`.

### Server hooks

Intercept public messages from any resource. Hooks run before broadcast, sorted by ascending priority, each isolated — a failing hook is logged and skipped.

```lua
local id = exports.siku_chat:RegisterHook('beforeMessage', function(ctx)
  -- ctx: { source, author, content, channel, type, metadata }
  if ctx.content:find('forbidden') then
    return false                                   -- cancel the message
  end
  return { content = ctx.content, metadata = { checked = true } } -- modify it
end, { priority = -10 })

exports.siku_chat:RegisterHook('afterMessage', function(ctx)
  -- observation only, runs after broadcast (logging, analytics…)
end)

exports.siku_chat:RemoveHook(id)
```

Hooks are removed automatically when their owning resource stops.

### Events

The `siku_chat:client:*` events are `RegisterNetEvent` handlers — usable from the server (`TriggerClientEvent`) or locally from another client resource (`TriggerEvent`): `addMessage`, `clear`, `addSuggestion`, `removeSuggestion`. Payloads match the export signatures.

## Commands

The chat does not execute commands itself: anything starting with the command prefix is forwarded to the native FiveM command system (`ExecuteCommand`), with the caller's own privileges. Commands registered through `Siku.RegisterCommand` (siku_core) get typed arguments, RBAC permission checks, cooldowns — and their suggestions appear in the chat automatically, filtered by permission per player.

## Staff channel

- Access requires the RBAC permission **`chat.staff.join`** on the player's active character.
- `/staffchat` joins the channel; `Escape` leaves it.
- Every staff message is re-validated server-side and delivered only to permitted players — never broadcast.
- The sender's primary role is displayed as a badge (`mod`, `dev`, `admin`, `owner`).

The staff channel requires the SIKU character system to be active, since permissions are resolved per character.

## Translations

`translations/fr.lua` and `translations/en.lua` hold every player-facing string. The active language (`config/translation.lua`) is loaded by the server and pushed to the NUI at runtime — no rebuild needed to switch.

## Development

The NUI lives in `web/` (Vue 3, Pinia, Tailwind, Vite — built with [bun](https://bun.sh)).

```bash
cd web
bun install
bun dev          # dev playground with mock data (BoilerplateView)
bun run build    # production build → web/dist
bun run check    # format + type-check + lint
```

In development the app boots into a playground with mock messages and commands; in production only the chat view ships.

```
siku_chat/
├── client/            # NUI bridge, keybinds, net event handlers
├── server/
│   ├── main.lua       # message flow, replay buffer, exports
│   └── modules/       # hooks, suggestion registry, staff channel
├── shared/utils/      # locale, payload normalization
├── config/            # all configuration
├── translations/      # fr / en
└── web/               # Vue 3 NUI
```

## Credits

Part of the [SIKU project](https://github.com/siku-project) — © Siku Studio.
