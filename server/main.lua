local EVERYONE <const> = -1
local CONSOLE_SOURCE <const> = 0
local READY_COOLDOWN_MS <const> = 5000
local ERROR_NOTIFICATION_DURATION <const> = 5000

local cooldowns <const> = {}
local readyStamps <const> = {}
local recentMessages <const> = {}

---@param src number
---@return table entity
local function playerEntity(src)
  return { type = 'player', id = src, role = 'actor' }
end

---Checks a sender against the message cooldown, stamping the send time when they pass.
---@param src number The player's server id.
---@return boolean allowed
local function passesCooldown(src)
  if ChatConfig.messageCooldown <= 0 then
    return true
  end

  local time <const> = GetGameTimer()
  local lastSent <const> = cooldowns[src]

  if lastSent and time - lastSent < ChatConfig.messageCooldown then
    return false
  end

  cooldowns[src] = time

  return true
end

---Keeps a public message for the players who connect later, dropping the oldest past the cap.
---@param message table The message in its interface shape.
local function remember(message)
  if ChatConfig.replayMessages <= 0 then
    return
  end

  recentMessages[#recentMessages + 1] = message

  while #recentMessages > ChatConfig.replayMessages do
    table.remove(recentMessages, 1)
  end
end

---Delivers a message to everyone or to the staff only.
---@param message table The message in its interface shape.
local function deliver(message)
  if message.channel == ChatNormalize.STAFF_CHANNEL then
    for _, target in ipairs(ChatStaff.Recipients()) do
      TriggerClientEvent('siku_chat:client:addMessage', target, message)
    end

    return
  end

  TriggerClientEvent('siku_chat:client:addMessage', EVERYONE, message)
  remember(message)
end

---Validates, filters and delivers what a player typed in one channel.
---@param src number The player's server id.
---@param content any What the client sent.
---@param channel string The channel the player wrote in.
local function receive(src, content, channel)
  local staff <const> = channel == ChatNormalize.STAFF_CHANNEL

  if staff and not ChatStaff.IsStaff(src) then
    Siku.log.warn('chat.message_rejected', ('%s wrote in the staff channel without the permission'):format(GetPlayerName(tostring(src)) or src), {
      channel = channel,
      reason = 'staff_denied',
    }, { outcome = 'denied', entities = { playerEntity(src) } })
    return
  end

  if not staff and not ChatConfig.allowMessages then
    return
  end

  if type(content) ~= 'string' then
    return
  end

  local text <const> = ChatNormalize.Trim(content)
  local length <const> = ChatNormalize.Length(text)

  if not length or length == 0 or length > ChatConfig.maxMessageLength then
    Siku.log.debug('chat.message_rejected', ('Message of %s refused: %s'):format(GetPlayerName(tostring(src)) or src, length and 'too long' or 'invalid text'), {
      channel = channel,
      reason = length and 'too_long' or 'text_invalid',
      length = length,
    }, { entities = { playerEntity(src) } })
    return
  end

  if text:sub(1, #ChatPrefix) == ChatPrefix then
    return
  end

  if not passesCooldown(src) then
    Siku.log.debug('chat.message_rejected', ('Message of %s refused by the cooldown'):format(GetPlayerName(tostring(src)) or src), {
      channel = channel,
      reason = 'cooldown',
    }, { entities = { playerEntity(src) } })
    return
  end

  local author <const> = GetPlayerName(tostring(src))

  if not author then
    return
  end

  local ctx <const> = ChatHooks.RunBefore({
    source = src,
    author = ChatNormalize.Sanitize(author),
    content = ChatNormalize.Sanitize(text),
    channel = channel,
    type = 'player',
    metadata = {},
  })

  if not ctx then
    Siku.log.debug('chat.message_rejected', ('Message of %s cancelled by a hook'):format(author), {
      channel = channel,
      reason = 'hook',
    }, { entities = { playerEntity(src) } })
    return
  end

  deliver({
    type = 'player',
    channel = channel,
    author = ctx.author,
    rank = staff and ChatStaff.Rank(src) or nil,
    text = ctx.content,
    timestamp = ChatClock.now(),
  })

  ChatHooks.RunAfter(ctx)
end

---Shows a message to one player or everyone.
---@param target number The player's server id, or -1 for everyone.
---@param data table The message data: content, and optionally type, author, icon.
---@return boolean sent Whether the message was accepted.
local function addMessage(target, data)
  local resource <const> = GetInvokingResource() or GetCurrentResourceName()

  local function refuse(reason, detail)
    Siku.log.warn('chat.export_invalid', ('AddMessage from %s refused: %s'):format(resource, detail), {
      export = 'AddMessage',
      resource = resource,
      reason = reason,
    }, { entities = { { type = 'resource', id = resource, role = 'subject', label = resource } } })
    return false
  end

  if type(target) ~= 'number' then
    return refuse('target_invalid', 'target must be a server id or -1')
  end

  if type(data) ~= 'table' or type(data.content) ~= 'string' or #data.content == 0 then
    return refuse('content_invalid', 'data.content must be a non-empty string')
  end

  if data.type ~= nil and not ChatNormalize.IsExportType(data.type) then
    return refuse('type_invalid', ('type %s is not server, system, info, success, warning or error'):format(tostring(data.type)))
  end

  if data.channel ~= nil and data.channel ~= ChatNormalize.PUBLIC_CHANNEL then
    return refuse('channel_invalid', 'only the public channel takes resource messages')
  end

  local message <const> = ChatNormalize.Message(data)

  message.channel = ChatNormalize.PUBLIC_CHANNEL
  message.timestamp = message.timestamp or ChatClock.now()

  TriggerClientEvent('siku_chat:client:addMessage', target, message)

  if target == EVERYONE then
    remember(message)
  end

  return true
end

---Clears the chat of one player or everyone. Clearing everyone also forgets the replayed messages.
---@param target number The player's server id, or -1 for everyone.
---@return boolean cleared Whether the clear was sent.
local function clear(target)
  local resource <const> = GetInvokingResource() or GetCurrentResourceName()

  if type(target) ~= 'number' then
    Siku.log.warn('chat.export_invalid', ('Clear from %s refused: target must be a server id or -1'):format(resource), {
      export = 'Clear',
      resource = resource,
      reason = 'target_invalid',
    }, { entities = { { type = 'resource', id = resource, role = 'subject', label = resource } } })
    return false
  end

  if target == EVERYONE then
    for index = #recentMessages, 1, -1 do
      recentMessages[index] = nil
    end

    Siku.log.info('chat.cleared', ('%s cleared the chat of everyone'):format(resource), {
      resource = resource,
    }, { entities = { { type = 'resource', id = resource, role = 'actor', label = resource } } })
  end

  TriggerClientEvent('siku_chat:client:clear', target)

  return true
end

---Registers a command suggestion for one player or everyone.
---@param target number The player's server id, or -1 for everyone.
---@param suggestion table The suggestion data: name, and optionally description, params.
---@return boolean added Whether the suggestion was accepted.
local function addSuggestion(target, suggestion)
  local resource <const> = GetInvokingResource() or GetCurrentResourceName()

  if type(target) ~= 'number' then
    Siku.log.warn('chat.export_invalid', ('AddSuggestion from %s refused: target must be a server id or -1'):format(resource), {
      export = 'AddSuggestion',
      resource = resource,
      reason = 'target_invalid',
    }, { entities = { { type = 'resource', id = resource, role = 'subject', label = resource } } })
    return false
  end

  if not ChatSuggestions.Add(target, suggestion, resource) then
    Siku.log.warn('chat.export_invalid', ('AddSuggestion from %s refused: suggestion.name must be a non-empty string'):format(resource), {
      export = 'AddSuggestion',
      resource = resource,
      reason = 'name_invalid',
    }, { entities = { { type = 'resource', id = resource, role = 'subject', label = resource } } })
    return false
  end

  return true
end

---Removes a command suggestion for one player or everyone.
---@param target number The player's server id, or -1 for everyone.
---@param name string The suggestion name, with or without the command prefix.
---@return boolean removed Whether the removal was sent.
local function removeSuggestion(target, name)
  local resource <const> = GetInvokingResource() or GetCurrentResourceName()

  if type(target) ~= 'number' or type(name) ~= 'string' or #name == 0 then
    Siku.log.warn('chat.export_invalid', ('RemoveSuggestion from %s refused: target must be a server id or -1 and name a non-empty string'):format(resource), {
      export = 'RemoveSuggestion',
      resource = resource,
      reason = type(target) ~= 'number' and 'target_invalid' or 'name_invalid',
    }, { entities = { { type = 'resource', id = resource, role = 'subject', label = resource } } })
    return false
  end

  return ChatSuggestions.Remove(target, name)
end

Siku.command.register('announce', function(src, args)
  if src ~= CONSOLE_SOURCE then
    Siku.log.warn('chat.message_rejected', ('%s used /announce from the game, it only runs from the console'):format(GetPlayerName(tostring(src)) or src), {
      channel = ChatNormalize.PUBLIC_CHANNEL,
      reason = 'console_only',
    }, { outcome = 'denied', entities = { playerEntity(src) } })
    Siku.notification.show(src, {
      type = 'error',
      title = '/announce',
      description = T('chat_announce_console_only'),
      duration = ERROR_NOTIFICATION_DURATION,
    })
    return
  end

  local text <const> = ChatNormalize.Sanitize(ChatNormalize.Trim(args.message))
  local length <const> = ChatNormalize.Length(text)

  if not length or length == 0 or length > ChatConfig.maxMessageLength then
    Siku.print.warn(('/announce: the message must hold 1 to %d characters'):format(ChatConfig.maxMessageLength))
    return
  end

  addMessage(EVERYONE, { content = text, type = 'server' })
  Siku.print.info(('/announce: shown to everyone: %s'):format(text))
end, {
  description = T('chat_announce_description'),
  permission = 'chat.announce',
  allowConsole = true,
  arguments = {
    { name = 'message', type = 'merge', help = T('chat_announce_message_help') },
  },
})

RegisterNetEvent('siku_chat:server:sendMessage', function(content)
  receive(source, content, ChatNormalize.PUBLIC_CHANNEL)
end)

RegisterNetEvent('siku_chat:server:sendStaffMessage', function(content)
  receive(source, content, ChatNormalize.STAFF_CHANNEL)
end)

RegisterNetEvent('siku_chat:server:ready', function()
  local src <const> = source
  local time <const> = GetGameTimer()
  local lastReady <const> = readyStamps[src]

  if lastReady and time - lastReady < READY_COOLDOWN_MS then
    return
  end

  readyStamps[src] = time

  ChatSuggestions.RefreshCore(src)

  local suggestions <const> = ChatSuggestions.Collect(src)

  if #suggestions == 0 and #recentMessages == 0 then
    return
  end

  TriggerClientEvent('siku_chat:client:sync', src, {
    suggestions = suggestions,
    messages = recentMessages,
  })
end)

AddEventHandler('playerDropped', function()
  cooldowns[source] = nil
  readyStamps[source] = nil
end)

exports('AddMessage', addMessage)
exports('Clear', clear)
exports('AddSuggestion', addSuggestion)
exports('RemoveSuggestion', removeSuggestion)
