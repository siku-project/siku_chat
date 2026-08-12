local ALLOWED_PREFIXES <const> = { '?', ',', ';', '.', ':', '/', '=', '+', '%' }
local MAX_COMMAND_LENGTH <const> = 512

local isChatOpen = false
local passiveMode = PassiveConfig.mode

---Checks whether the given prefix belongs to the allowed set.
---@param prefix string
---@return boolean
local function isAllowedPrefix(prefix)
  for _, allowed in ipairs(ALLOWED_PREFIXES) do
    if allowed == prefix then
      return true
    end
  end

  return false
end

---Returns the configured command prefix, raising when it is missing or not allowed.
---@return string
local function getCommandPrefix()
  local prefix = ChatConfig.commandPrefix

  if type(prefix) ~= 'string' or not isAllowedPrefix(prefix) then
    error(
      ('siku_chat: commandPrefix %q is invalid — expected one of: %s'):format(
        tostring(prefix),
        table.concat(ALLOWED_PREFIXES, ' ')
      )
    )
  end

  return prefix
end

local COMMAND_PREFIX <const> = getCommandPrefix()

---Displays a message in the chat.
---@param data table The message data: content, and optionally type, author, icon, channel, metadata.
---@return boolean shown Whether the message was accepted.
local function addMessage(data)
  local message <const> = ChatNormalize.Message(data)

  if not message then
    return false
  end

  SendNUIMessage({
    action = 'siku_chat:nui:addMessage',
    message = message,
  })

  return true
end

---Clears every message from the chat.
---@return nil
local function clear()
  SendNUIMessage({ action = 'siku_chat:nui:clear' })
end

---Registers a command suggestion in the chat.
---@param data table The suggestion data: name, and optionally description, params, staff.
---@return boolean added Whether the suggestion was accepted.
local function addSuggestion(data)
  local suggestion <const> = ChatNormalize.Suggestion(data, COMMAND_PREFIX)

  if not suggestion then
    return false
  end

  SendNUIMessage({
    action = 'siku_chat:nui:addSuggestion',
    suggestion = suggestion,
  })

  return true
end

---Removes a command suggestion from the chat.
---@param name string The suggestion name, with or without the command prefix.
---@return boolean removed Whether the removal was accepted.
local function removeSuggestion(name)
  if type(name) ~= 'string' or #name == 0 then
    return false
  end

  SendNUIMessage({
    action = 'siku_chat:nui:removeSuggestion',
    name = ChatNormalize.StripPrefix(name, COMMAND_PREFIX),
  })

  return true
end

---Pushes the current chat configuration to the NUI.
---@return nil
local function sendConfig()
  SendNUIMessage({
    action = 'siku_chat:nui:setConfig',
    config = {
      commandPrefix = COMMAND_PREFIX,
      maxMessages = ChatConfig.maxMessages,
      maxMessageLength = ChatConfig.maxMessageLength,
      messageCooldown = ChatConfig.messageCooldown,
      allowMessages = ChatConfig.allowMessages,
      inputMode = ChatConfig.inputMode,
      passiveEnabled = passiveMode == 'dynamic',
      passiveDuration = PassiveConfig.duration,
      passiveMaxMessages = PassiveConfig.maxMessages,
      historyEnable = HistoryConfig.enable,
      historyMax = HistoryConfig.max,
    },
  })
end

---Loads the full translation table for the active language.
---@return table<string, string>
local function loadTranslations()
  local file <const> =
    LoadResourceFile(GetCurrentResourceName(), ('translations/%s.lua'):format(TranslationConfig.language))
  if not file then
    return {}
  end

  local fn <const> = load(file)
  if not fn then
    return {}
  end

  return fn() or {}
end

---Pushes the active language and its translations to the NUI.
---@return nil
local function sendLocale()
  SendNUIMessage({
    action = 'siku_chat:nui:setLocale',
    locale = {
      language = TranslationConfig.language,
      translations = loadTranslations(),
    },
  })
end

---Opens the chat and grants NUI focus on the next frame, so the key press
---that triggered the command never leaks into the freshly focused input.
---@return nil
local function openChat()
  if isChatOpen then
    return
  end

  isChatOpen = true

  CreateThread(function()
    Wait(0)
    SetNuiFocus(true, ChatConfig.inputMode == 'mouse')
    SendNUIMessage({ action = 'siku_chat:nui:open' })
  end)
end

---Toggles the player's passive overlay for the session.
---Only allowed when the server keeps the passive overlay dynamic.
---@return nil
local function togglePassive()
  if PassiveConfig.mode ~= 'dynamic' then
    return
  end

  passiveMode = passiveMode == 'dynamic' and 'hidden' or 'dynamic'
  sendConfig()

  local enabled <const> = passiveMode == 'dynamic'

  Siku.Notification({
    type = 'info',
    title = T('chat_title'),
    description = enabled and T('chat_passive_enabled') or T('chat_passive_disabled'),
    icon = enabled and 'mdi-message-outline' or 'mdi-message-off-outline',
    duration = 3000,
  })
end

RegisterCommand('+siku_chat', openChat, false)
RegisterCommand('-siku_chat', function() end, false)
RegisterKeyMapping('+siku_chat', 'Open chat', 'keyboard', KeybindsConfig.openKey)

RegisterCommand('+siku_chat_passive', togglePassive, false)
RegisterCommand('-siku_chat_passive', function() end, false)
RegisterKeyMapping('+siku_chat_passive', 'Toggle passive chat', 'keyboard', KeybindsConfig.passiveKey)

RegisterNUICallback('siku_chat:nui:ready', function(_, cb)
  sendLocale()
  sendConfig()
  TriggerServerEvent('siku_chat:server:ready')
  cb({})
end)

RegisterNUICallback('siku_chat:nui:close', function(_, cb)
  isChatOpen = false
  SetNuiFocus(false, false)
  cb({})
end)

RegisterNUICallback('siku_chat:nui:sendMessage', function(data, cb)
  if type(data) == 'table' and type(data.text) == 'string' then
    TriggerServerEvent('siku_chat:server:sendMessage', data.text)
  end

  cb({})
end)

RegisterNUICallback('siku_chat:nui:sendStaffMessage', function(data, cb)
  if type(data) == 'table' and type(data.text) == 'string' then
    TriggerServerEvent('siku_chat:server:sendStaffMessage', data.text)
  end

  cb({})
end)

RegisterNUICallback('siku_chat:nui:command', function(data, cb)
  if type(data) == 'table' and type(data.raw) == 'string' then
    local command <const> = ChatNormalize.Sanitize(data.raw)

    if #command > 0 and #command <= MAX_COMMAND_LENGTH then
      ExecuteCommand(command)
    end
  end

  cb({})
end)

RegisterNetEvent('siku_chat:client:receiveMessage', function(data)
  if type(data) ~= 'table' or type(data.content) ~= 'string' then
    return
  end

  SendNUIMessage({
    action = 'siku_chat:nui:addMessage',
    message = {
      type = 'player',
      channel = 'public',
      author = data.author,
      text = data.content,
      metadata = type(data.metadata) == 'table' and data.metadata or nil,
      timestamp = type(data.timestamp) == 'number' and data.timestamp or nil,
    },
  })
end)

RegisterNetEvent('siku_chat:client:setStaffMode', function(enabled)
  SendNUIMessage({
    action = 'siku_chat:nui:setStaffMode',
    enabled = enabled == true,
  })

  if enabled == true then
    openChat()
  end
end)

RegisterNetEvent('siku_chat:client:receiveStaffMessage', function(data)
  if type(data) ~= 'table' or type(data.text) ~= 'string' then
    return
  end

  SendNUIMessage({
    action = 'siku_chat:nui:addMessage',
    message = {
      type = 'player',
      channel = 'staff',
      author = type(data.author) == 'string' and data.author or nil,
      rank = type(data.rank) == 'string' and data.rank or nil,
      text = data.text,
      timestamp = type(data.timestamp) == 'number' and data.timestamp or nil,
    },
  })
end)

RegisterNetEvent('siku_chat:client:sync', function(state)
  if type(state) ~= 'table' then
    return
  end

  SendNUIMessage({
    action = 'siku_chat:nui:sync',
    state = {
      suggestions = type(state.suggestions) == 'table' and state.suggestions or {},
      messages = type(state.messages) == 'table' and state.messages or {},
    },
  })
end)

RegisterNetEvent('siku_chat:client:addMessage', addMessage)
RegisterNetEvent('siku_chat:client:clear', clear)
RegisterNetEvent('siku_chat:client:addSuggestion', addSuggestion)
RegisterNetEvent('siku_chat:client:removeSuggestion', removeSuggestion)

exports('AddMessage', addMessage)
exports('Clear', clear)
exports('AddSuggestion', addSuggestion)
exports('RemoveSuggestion', removeSuggestion)
