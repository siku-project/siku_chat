local MAX_COMMAND_LENGTH <const> = 512
local NOTIFICATION_DURATION <const> = 3000

local prefix <const>, prefixValid <const> = ChatNormalize.Prefix(ChatConfig.commandPrefix)

if not prefixValid then
  Siku.log.warn('chat.prefix_invalid', ('commandPrefix %s is not allowed, the chat uses %s'):format(tostring(ChatConfig.commandPrefix), prefix), {
    configured = tostring(ChatConfig.commandPrefix),
    fallback = prefix,
    allowed = ChatNormalize.AllowedPrefixes(),
    reason = 'not_allowed',
  }, { entities = { { type = 'resource', id = Siku.name, role = 'subject', label = Siku.name } } })
end

local isOpen = false
local passiveShown = PassiveConfig.mode == 'dynamic'

---Pushes the whole configuration to the interface.
local function sendConfig()
  Nui.send('setConfig', {
    config = {
      commandPrefix = prefix,
      maxMessages = ChatConfig.maxMessages,
      maxMessageLength = ChatConfig.maxMessageLength,
      messageCooldown = ChatConfig.messageCooldown,
      allowMessages = ChatConfig.allowMessages,
      inputMode = ChatConfig.inputMode,
      position = ChatConfig.position,
      passiveEnabled = passiveShown,
      passiveDuration = PassiveConfig.duration,
      passiveMaxMessages = PassiveConfig.maxMessages,
      passivePosition = PassiveConfig.position,
      historyEnable = HistoryConfig.enable,
      historyMax = HistoryConfig.max,
    },
  })
end

---Opens the chat on the next frame, so the key that opened it never lands in the input.
local function openChat()
  if isOpen then
    return
  end

  isOpen = true

  CreateThread(function()
    Wait(0)
    Nui.show(ChatConfig.inputMode == 'mouse')
  end)
end

local function closeChat()
  isOpen = false
  Nui.hide()
end

---Shows or hides the incoming messages for this session, when the server leaves the choice.
local function togglePassive()
  if PassiveConfig.mode ~= 'dynamic' then
    return
  end

  passiveShown = not passiveShown
  sendConfig()

  Siku.notification.show({
    type = 'info',
    title = T('chat_notification_title'),
    description = passiveShown and T('chat_passive_enabled') or T('chat_passive_disabled'),
    duration = NOTIFICATION_DURATION,
  })
end

---Shows a message in this player's chat.
---@param data table The message data: content, and optionally type, author, icon.
---@return boolean shown Whether the message was accepted.
local function addMessage(data)
  local resource <const> = GetInvokingResource() or GetCurrentResourceName()

  local function refuse(reason, detail)
    Siku.log.warn('chat.export_invalid', ('AddMessage from %s refused: %s'):format(resource, detail), {
      export = 'AddMessage',
      resource = resource,
      reason = reason,
    }, { entities = { { type = 'resource', id = resource, role = 'subject', label = resource } } })
    return false
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

  Nui.send('addMessage', { message = message })

  return true
end

---Clears every message of this player's chat.
---@return boolean cleared Always true.
local function clear()
  Nui.send('clear')

  return true
end

---Registers a command suggestion in this player's chat.
---@param data table The suggestion data: name, and optionally description, params.
---@return boolean added Whether the suggestion was accepted.
local function addSuggestion(data)
  local suggestion <const> = ChatNormalize.Suggestion(data, prefix)

  if not suggestion then
    local resource <const> = GetInvokingResource() or GetCurrentResourceName()

    Siku.log.warn('chat.export_invalid', ('AddSuggestion from %s refused: data.name must be a non-empty string'):format(resource), {
      export = 'AddSuggestion',
      resource = resource,
      reason = 'name_invalid',
    }, { entities = { { type = 'resource', id = resource, role = 'subject', label = resource } } })
    return false
  end

  Nui.send('addSuggestion', { suggestion = suggestion })

  return true
end

---Removes a command suggestion from this player's chat.
---@param name string The suggestion name, with or without the command prefix.
---@return boolean removed Whether the removal was accepted.
local function removeSuggestion(name)
  local stripped <const> = type(name) == 'string' and ChatNormalize.StripPrefix(name, prefix) or ''

  if #stripped == 0 then
    local resource <const> = GetInvokingResource() or GetCurrentResourceName()

    Siku.log.warn('chat.export_invalid', ('RemoveSuggestion from %s refused: name must be a non-empty string'):format(resource), {
      export = 'RemoveSuggestion',
      resource = resource,
      reason = 'name_invalid',
    }, { entities = { { type = 'resource', id = resource, role = 'subject', label = resource } } })
    return false
  end

  Nui.send('removeSuggestion', { name = stripped })

  return true
end

Siku.keybind.add({
  name = 'siku_chat_open',
  description = T('chat_keybind_open'),
  defaultKey = KeybindsConfig.openKey,
  onPressed = openChat,
})

if PassiveConfig.mode == 'dynamic' then
  Siku.keybind.add({
    name = 'siku_chat_passive',
    description = T('chat_keybind_passive'),
    defaultKey = KeybindsConfig.passiveKey,
    onPressed = togglePassive,
  })
end

Nui.reply('ready', function()
  sendConfig()
  TriggerServerEvent('siku_chat:server:ready')

  return {
    locale = {
      language = TranslationConfig.language,
      translations = { web = Siku.locale.translations().web },
    },
  }
end)

Nui.on('close', closeChat)

Nui.on('sendMessage', function(data)
  if type(data.text) == 'string' then
    TriggerServerEvent('siku_chat:server:sendMessage', data.text)
  end
end)

Nui.on('sendStaffMessage', function(data)
  if type(data.text) == 'string' then
    TriggerServerEvent('siku_chat:server:sendStaffMessage', data.text)
  end
end)

Nui.on('command', function(data)
  if type(data.raw) ~= 'string' then
    return
  end

  local command <const> = ChatNormalize.Sanitize(data.raw)

  if #command > 0 and #command <= MAX_COMMAND_LENGTH then
    ExecuteCommand(command)
  end
end)

RegisterNetEvent('siku_chat:client:addMessage', function(message)
  if type(message) == 'table' and type(message.text) == 'string' then
    Nui.send('addMessage', { message = message })
  end
end)

RegisterNetEvent('siku_chat:client:clear', function()
  Nui.send('clear')
end)

RegisterNetEvent('siku_chat:client:addSuggestion', function(suggestion)
  if type(suggestion) == 'table' and type(suggestion.name) == 'string' then
    Nui.send('addSuggestion', { suggestion = suggestion })
  end
end)

RegisterNetEvent('siku_chat:client:removeSuggestion', function(name)
  if type(name) == 'string' and #name > 0 then
    Nui.send('removeSuggestion', { name = name })
  end
end)

RegisterNetEvent('siku_chat:client:sync', function(state)
  if type(state) ~= 'table' then
    return
  end

  Nui.send('sync', {
    state = {
      suggestions = type(state.suggestions) == 'table' and state.suggestions or {},
      messages = type(state.messages) == 'table' and state.messages or {},
    },
  })
end)

RegisterNetEvent('siku_chat:client:setStaffMode', function(enabled)
  Nui.send('setStaffMode', { enabled = enabled == true })

  if enabled == true then
    openChat()
  end
end)

exports('AddMessage', addMessage)
exports('Clear', clear)
exports('AddSuggestion', addSuggestion)
exports('RemoveSuggestion', removeSuggestion)
