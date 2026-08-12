local STAFF_PERMISSION <const> = 'chat.staff.join'

local ROLE_RANKS <const> = {
  moderator = 'mod',
  dev = 'dev',
  admin = 'admin',
  owner = 'owner',
}

local staffCooldowns <const> = {}

ChatStaff = {}

---Resolves the active character id of a player, or nil when the player is not initialized.
---@param src number The player's server id.
---@return number? charId
local function getCharacterId(src)
  local character <const> = Siku.cache.getCurrentCharacter(src)

  if type(character) ~= 'table' or type(character.id) ~= 'number' then
    return nil
  end

  return character.id
end

---Checks whether a player may access the staff channel.
---@param src number The player's server id.
---@return boolean allowed
function ChatStaff.IsStaff(src)
  local charId <const> = getCharacterId(src)

  if not charId then
    return false
  end

  return Siku.permissions.hasPermission(charId, STAFF_PERMISSION)
end

---Returns the NUI rank key of a player's primary role, or nil.
---@param src number The player's server id.
---@return string? rank
local function getRank(src)
  local charId <const> = getCharacterId(src)

  if not charId then
    return nil
  end

  local role <const> = Siku.permissions.getPrimaryRole(charId)

  if type(role) ~= 'table' or type(role.name) ~= 'string' then
    return nil
  end

  return ROLE_RANKS[role.name]
end

---Checks the sender against the message cooldown, stamping the send time on success.
---@param src number The player's server id.
---@return boolean allowed Whether the sender may send a staff message now.
local function passesCooldown(src)
  if ChatConfig.messageCooldown <= 0 then
    return true
  end

  local time <const> = GetGameTimer()
  local lastSent <const> = staffCooldowns[src]

  if lastSent and time - lastSent < ChatConfig.messageCooldown then
    return false
  end

  staffCooldowns[src] = time

  return true
end

---Sends a staff message to every player allowed into the staff channel.
---@param message table The message in its NUI shape.
---@return nil
local function broadcastToStaff(message)
  for _, id in ipairs(GetPlayers()) do
    local target <const> = tonumber(id)

    if target and ChatStaff.IsStaff(target) then
      TriggerClientEvent('siku_chat:client:receiveStaffMessage', target, message)
    end
  end
end

Siku.RegisterCommand('staffchat', function(src)
  TriggerClientEvent('siku_chat:client:setStaffMode', src, true)
end, {
  description = T('chat_staffchat_description'),
  permission = STAFF_PERMISSION,
})

RegisterNetEvent('siku_chat:server:sendStaffMessage', function(content)
  local src <const> = source

  if type(content) ~= 'string' or not ChatStaff.IsStaff(src) then
    return
  end

  local trimmed <const> = content:match('^%s*(.-)%s*$')
  local length <const> = utf8.len(trimmed)

  if not length or length == 0 or length > ChatConfig.maxMessageLength then
    return
  end

  if not passesCooldown(src) then
    return
  end

  local author <const> = GetPlayerName(tostring(src))

  if not author then
    return
  end

  broadcastToStaff({
    type = 'player',
    channel = 'staff',
    author = ChatNormalize.Sanitize(author),
    rank = getRank(src),
    text = ChatNormalize.Sanitize(trimmed),
    timestamp = os.time() * 1000,
  })
end)

AddEventHandler('playerDropped', function()
  staffCooldowns[source] = nil
end)
