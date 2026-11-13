local STAFF_PERMISSION <const> = 'chat.staff.join'

local ROLE_RANKS <const> = {
  moderator = 'mod',
  dev = 'dev',
  admin = 'admin',
  owner = 'owner',
}

ChatStaff = {}

---Whether a player may read and write the staff channel.
---@param src number The player's server id.
---@return boolean allowed
function ChatStaff.IsStaff(src)
  local characterId <const> = Siku.cache.getCurrentCharacterId(src)

  if not characterId then
    return false
  end

  return Siku.permissions.hasPermission(characterId, STAFF_PERMISSION) == true
end

---The rank badge of a player's primary role, nil when it has none the chat shows.
---@param src number The player's server id.
---@return string? rank
function ChatStaff.Rank(src)
  local characterId <const> = Siku.cache.getCurrentCharacterId(src)

  if not characterId then
    return nil
  end

  local role <const> = Siku.permissions.getPrimaryRole(characterId)

  if type(role) ~= 'table' or type(role.name) ~= 'string' then
    return nil
  end

  return ROLE_RANKS[role.name]
end

---Every connected player allowed into the staff channel.
---@return number[] recipients
function ChatStaff.Recipients()
  local recipients <const> = {}

  for _, id in ipairs(GetPlayers()) do
    local src <const> = tonumber(id)

    if src and ChatStaff.IsStaff(src) then
      recipients[#recipients + 1] = src
    end
  end

  return recipients
end

Siku.command.register('staffchat', function(src)
  TriggerClientEvent('siku_chat:client:setStaffMode', src, true)
end, {
  description = T('chat_staffchat_description'),
  permission = STAFF_PERMISSION,
})
