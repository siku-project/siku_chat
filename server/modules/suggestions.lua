local globalSuggestions <const> = {}
local playerSuggestions <const> = {}

ChatSuggestions = {}

---Returns the per-player registry for the given source, creating it when needed.
---@param src number
---@return table<string, table> registry
local function getPlayerRegistry(src)
  local registry = playerSuggestions[src]

  if not registry then
    registry = {}
    playerSuggestions[src] = registry
  end

  return registry
end

---Registers a suggestion for one player or everyone and syncs the clients.
---@param target number The player's server id, or -1 for everyone.
---@param data table The suggestion data: name, and optionally description, params, staff.
---@return boolean added Whether the suggestion was accepted and dispatched.
function ChatSuggestions.Add(target, data)
  local suggestion <const> = ChatNormalize.Suggestion(data, ChatConfig.commandPrefix)

  if not suggestion then
    return false
  end

  local entry <const> = {
    suggestion = suggestion,
    resource = GetInvokingResource() or GetCurrentResourceName(),
  }

  if target == -1 then
    globalSuggestions[suggestion.name] = entry
  else
    getPlayerRegistry(target)[suggestion.name] = entry
  end

  TriggerClientEvent('siku_chat:client:addSuggestion', target, suggestion)

  return true
end

---Removes a suggestion for one player or everyone and syncs the clients.
---@param target number The player's server id, or -1 for everyone.
---@param name string The suggestion name, with or without the command prefix.
---@return boolean removed Whether the removal was dispatched.
function ChatSuggestions.Remove(target, name)
  local stripped <const> = ChatNormalize.StripPrefix(name, ChatConfig.commandPrefix)

  if target == -1 then
    globalSuggestions[stripped] = nil

    for _, registry in pairs(playerSuggestions) do
      registry[stripped] = nil
    end
  elseif playerSuggestions[target] then
    playerSuggestions[target][stripped] = nil
  end

  TriggerClientEvent('siku_chat:client:removeSuggestion', target, stripped)

  return true
end

---Collects every suggestion visible to the given player, global first.
---@param src number The player's server id.
---@return table[] suggestions
function ChatSuggestions.Collect(src)
  local list <const> = {}

  for _, entry in pairs(globalSuggestions) do
    list[#list + 1] = entry.suggestion
  end

  local registry <const> = playerSuggestions[src]

  if registry then
    for _, entry in pairs(registry) do
      list[#list + 1] = entry.suggestion
    end
  end

  return list
end

---Removes every suggestion owned by the given resource and syncs the clients.
---@param resourceName string
---@return nil
local function removeResourceSuggestions(resourceName)
  for name, entry in pairs(globalSuggestions) do
    if entry.resource == resourceName then
      globalSuggestions[name] = nil
      TriggerClientEvent('siku_chat:client:removeSuggestion', -1, name)
    end
  end

  for src, registry in pairs(playerSuggestions) do
    for name, entry in pairs(registry) do
      if entry.resource == resourceName then
        registry[name] = nil
        TriggerClientEvent('siku_chat:client:removeSuggestion', src, name)
      end
    end
  end
end

AddEventHandler('onResourceStop', function(resourceName)
  if resourceName == GetCurrentResourceName() then
    return
  end

  removeResourceSuggestions(resourceName)
end)

AddEventHandler('playerDropped', function()
  playerSuggestions[source] = nil
end)
