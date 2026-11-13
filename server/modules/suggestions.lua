local CORE_RESOURCE <const> = 'siku_core'
local EVERYONE <const> = -1

local globalSuggestions <const> = {}
local playerSuggestions <const> = {}
local pendingRefresh <const> = {}

ChatSuggestions = {}

---@param src number
---@return table<string, table> entries
local function entriesOf(src)
  local entries = playerSuggestions[src]

  if not entries then
    entries = {}
    playerSuggestions[src] = entries
  end

  return entries
end

---@param target number
---@param suggestion table
local function push(target, suggestion)
  TriggerClientEvent('siku_chat:client:addSuggestion', target, suggestion)
end

---@param target number
---@param name string
local function drop(target, name)
  TriggerClientEvent('siku_chat:client:removeSuggestion', target, name)
end

---Whether two suggestions would show the same thing.
---@param left table
---@param right table
---@return boolean same
local function same(left, right)
  return json.encode(left) == json.encode(right)
end

---Rebuilds what the core allows a player: suggestions they lost the permission for
---are removed, new ones are added, the global ones the core already registered are skipped.
---@param src number The player's server id.
function ChatSuggestions.RefreshCore(src)
  local entries <const> = entriesOf(src)
  local allowed <const> = {}

  for _, data in ipairs(Siku.command.getSuggestions(src)) do
    local suggestion <const> = ChatNormalize.Suggestion(data, ChatPrefix)

    if suggestion then
      local global <const> = globalSuggestions[suggestion.name]

      if not (global and global.resource == CORE_RESOURCE) then
        allowed[suggestion.name] = suggestion
      end
    end
  end

  for name, entry in pairs(entries) do
    if entry.resource == CORE_RESOURCE and not allowed[name] then
      entries[name] = nil
      drop(src, name)
    end
  end

  for name, suggestion in pairs(allowed) do
    local entry <const> = entries[name]

    if not entry then
      entries[name] = { suggestion = suggestion, resource = CORE_RESOURCE }
      push(src, suggestion)
    elseif entry.resource == CORE_RESOURCE and not same(entry.suggestion, suggestion) then
      entry.suggestion = suggestion
      push(src, suggestion)
    end
  end
end

---Rebuilds the core suggestions of a player once the current burst of pushes is over.
---@param src number The player's server id.
local function scheduleCoreRefresh(src)
  if pendingRefresh[src] then
    return
  end

  pendingRefresh[src] = true

  SetTimeout(0, function()
    pendingRefresh[src] = nil

    if GetPlayerName(tostring(src)) then
      ChatSuggestions.RefreshCore(src)
    end
  end)
end

---Registers a suggestion for one player or everyone and tells the clients.
---A per-player push from the core is a sign its allowed set changed: the whole set is
---rebuilt instead, so a lost permission takes its suggestions away.
---@param target number The player's server id, or -1 for everyone.
---@param data table The suggestion data: name, and optionally description, params.
---@param resource string The resource that owns the suggestion.
---@return boolean added Whether the suggestion was accepted.
function ChatSuggestions.Add(target, data, resource)
  local suggestion <const> = ChatNormalize.Suggestion(data, ChatPrefix)

  if not suggestion then
    return false
  end

  if resource == CORE_RESOURCE and target ~= EVERYONE then
    scheduleCoreRefresh(target)
    return true
  end

  local entry <const> = { suggestion = suggestion, resource = resource }

  if target == EVERYONE then
    globalSuggestions[suggestion.name] = entry
  else
    entriesOf(target)[suggestion.name] = entry
  end

  push(target, suggestion)

  return true
end

---Removes a suggestion for one player or everyone and tells the clients.
---@param target number The player's server id, or -1 for everyone.
---@param name string The suggestion name, with or without the command prefix.
---@return boolean removed Whether the removal was sent.
function ChatSuggestions.Remove(target, name)
  local stripped <const> = ChatNormalize.StripPrefix(name, ChatPrefix)

  if #stripped == 0 then
    return false
  end

  if target == EVERYONE then
    globalSuggestions[stripped] = nil

    for _, entries in pairs(playerSuggestions) do
      entries[stripped] = nil
    end
  elseif playerSuggestions[target] then
    playerSuggestions[target][stripped] = nil
  end

  drop(target, stripped)

  return true
end

---Every suggestion a player sees, the global ones first.
---@param src number The player's server id.
---@return table[] suggestions
function ChatSuggestions.Collect(src)
  local list <const> = {}

  for _, entry in pairs(globalSuggestions) do
    list[#list + 1] = entry.suggestion
  end

  local entries <const> = playerSuggestions[src]

  if entries then
    for _, entry in pairs(entries) do
      list[#list + 1] = entry.suggestion
    end
  end

  return list
end

AddEventHandler('onResourceStop', function(resourceName)
  if resourceName == GetCurrentResourceName() then
    return
  end

  for name, entry in pairs(globalSuggestions) do
    if entry.resource == resourceName then
      globalSuggestions[name] = nil
      drop(EVERYONE, name)
    end
  end

  for src, entries in pairs(playerSuggestions) do
    for name, entry in pairs(entries) do
      if entry.resource == resourceName then
        entries[name] = nil
        drop(src, name)
      end
    end
  end
end)

AddEventHandler('siku:server:releaseCharacterInstance', function(sessionId)
  if type(sessionId) == 'number' then
    scheduleCoreRefresh(sessionId)
  end
end)

AddEventHandler('playerDropped', function()
  playerSuggestions[source] = nil
  pendingRefresh[source] = nil
end)
