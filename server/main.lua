local READY_COOLDOWN_MS <const> = 5000

local cooldowns <const> = {}
local readyStamps <const> = {}
local recentMessages <const> = {}

---Returns the current server time as a millisecond timestamp.
---@return number timestamp
local function now()
  return os.time() * 1000
end

---Checks the sender against the message cooldown, stamping the send time on success.
---@param src number The player's server id.
---@return boolean allowed Whether the sender may send a message now.
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

---Stores a broadcasted message in the replay buffer, dropping the oldest past the cap.
---@param message table The message in its NUI shape.
---@return nil
local function pushRecent(message)
  if ChatConfig.replayMessages <= 0 then
    return
  end

  recentMessages[#recentMessages + 1] = message

  while #recentMessages > ChatConfig.replayMessages do
    table.remove(recentMessages, 1)
  end
end

---Sends a chat message to one player or everyone.
---@param target number The player's server id, or -1 for everyone.
---@param data table The message data: content, and optionally type, author, icon, channel, metadata.
---@return boolean sent Whether the message was dispatched.
local function addMessage(target, data)
  if type(target) ~= 'number' then
    Siku.print.error('AddMessage: target must be a number (server id or -1)')
    return false
  end

  if type(data) == 'table' and data.type ~= nil and not ChatNormalize.IsValidType(data.type) then
    Siku.print.error(('AddMessage: invalid type %q'):format(tostring(data.type)))
    return false
  end

  local message <const> = ChatNormalize.Message(data)

  if not message then
    Siku.print.error('AddMessage: data.content must be a non-empty string')
    return false
  end

  message.timestamp = message.timestamp or now()

  TriggerClientEvent('siku_chat:client:addMessage', target, message)

  if target == -1 then
    pushRecent(message)
  end

  return true
end

---Clears the chat of one player or everyone.
---Clearing everyone also empties the server replay buffer.
---@param target number The player's server id, or -1 for everyone.
---@return boolean cleared Whether the clear was dispatched.
local function clear(target)
  if type(target) ~= 'number' then
    Siku.print.error('Clear: target must be a number (server id or -1)')
    return false
  end

  if target == -1 then
    for index = #recentMessages, 1, -1 do
      recentMessages[index] = nil
    end
  end

  TriggerClientEvent('siku_chat:client:clear', target)

  return true
end

---Registers a command suggestion for one player or everyone.
---@param target number The player's server id, or -1 for everyone.
---@param suggestion table The suggestion data: name, and optionally description, params, staff.
---@return boolean added Whether the suggestion was accepted and dispatched.
local function addSuggestion(target, suggestion)
  if type(target) ~= 'number' then
    Siku.print.error('AddSuggestion: target must be a number (server id or -1)')
    return false
  end

  if not ChatSuggestions.Add(target, suggestion) then
    Siku.print.error('AddSuggestion: suggestion.name must be a non-empty string')
    return false
  end

  return true
end

---Removes a command suggestion for one player or everyone.
---@param target number The player's server id, or -1 for everyone.
---@param name string The suggestion name, with or without the command prefix.
---@return boolean removed Whether the removal was dispatched.
local function removeSuggestion(target, name)
  if type(target) ~= 'number' then
    Siku.print.error('RemoveSuggestion: target must be a number (server id or -1)')
    return false
  end

  if type(name) ~= 'string' or #name == 0 then
    Siku.print.error('RemoveSuggestion: name must be a non-empty string')
    return false
  end

  return ChatSuggestions.Remove(target, name)
end

RegisterNetEvent('siku_chat:server:sendMessage', function(content)
  local src <const> = source

  if not ChatConfig.allowMessages or type(content) ~= 'string' then
    return
  end

  local trimmed <const> = content:match('^%s*(.-)%s*$')
  local length <const> = utf8.len(trimmed)

  if not length or length == 0 or length > ChatConfig.maxMessageLength then
    return
  end

  if trimmed:sub(1, #ChatConfig.commandPrefix) == ChatConfig.commandPrefix then
    return
  end

  if not passesCooldown(src) then
    return
  end

  local author <const> = GetPlayerName(tostring(src))

  if not author then
    return
  end

  local ctx <const> = ChatHooks.RunBefore({
    source = src,
    author = ChatNormalize.Sanitize(author),
    content = ChatNormalize.Sanitize(trimmed),
    channel = 'public',
    type = 'player',
    metadata = {},
  })

  if not ctx then
    return
  end

  local timestamp <const> = now()

  TriggerClientEvent('siku_chat:client:receiveMessage', -1, {
    author = ctx.author,
    content = ctx.content,
    metadata = ctx.metadata,
    timestamp = timestamp,
  })

  pushRecent({
    type = 'player',
    channel = 'public',
    author = ctx.author,
    text = ctx.content,
    metadata = ctx.metadata,
    timestamp = timestamp,
  })

  ChatHooks.RunAfter(ctx)
end)

RegisterNetEvent('siku_chat:server:ready', function()
  local src <const> = source
  local time <const> = GetGameTimer()
  local lastReady <const> = readyStamps[src]

  if lastReady and time - lastReady < READY_COOLDOWN_MS then
    return
  end

  readyStamps[src] = time

  if type(Siku.GetCommandSuggestions) == 'function' then
    for _, suggestion in ipairs(Siku.GetCommandSuggestions(src)) do
      ChatSuggestions.Add(src, suggestion)
    end
  end

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
