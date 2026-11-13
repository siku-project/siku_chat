local ALLOWED_PREFIXES <const> = { '?', ',', ';', '.', ':', '/', '=', '+', '%' }
local DEFAULT_PREFIX <const> = '/'
local ICON_PATTERN <const> = '^[%w_%-]+$'

local EXPORT_TYPES <const> = {
  system = true,
  info = true,
  success = true,
  warning = true,
  error = true,
}

local MESSAGE_TYPES <const> = {
  player = true,
  system = true,
  info = true,
  success = true,
  warning = true,
  error = true,
}

local CHANNELS <const> = {
  public = true,
  staff = true,
}

local allowedPrefixes <const> = {}

for _, prefix in ipairs(ALLOWED_PREFIXES) do
  allowedPrefixes[prefix] = true
end

ChatNormalize = {}

ChatNormalize.PUBLIC_CHANNEL = 'public'
ChatNormalize.STAFF_CHANNEL = 'staff'

---Resolves the command prefix to use, falling back to the default one when the configured value is not allowed.
---@param value any The configured prefix.
---@return string prefix The prefix to use.
---@return boolean valid Whether the configured value was kept.
function ChatNormalize.Prefix(value)
  if type(value) == 'string' and allowedPrefixes[value] then
    return value, true
  end

  return DEFAULT_PREFIX, false
end

---Lists the allowed command prefixes, for messages.
---@return string list
function ChatNormalize.AllowedPrefixes()
  return table.concat(ALLOWED_PREFIXES, ' ')
end

---Checks whether a value is a message type a resource may send through the exports.
---@param value any
---@return boolean valid
function ChatNormalize.IsExportType(value)
  return EXPORT_TYPES[value] == true
end

---Removes GTA color codes and control characters from a chat string.
---@param value string The raw content.
---@return string cleaned The sanitized content.
function ChatNormalize.Sanitize(value)
  local withoutColors <const> = value:gsub('%^%d', '')

  return (withoutColors:gsub('%c', ''))
end

---Trims the surrounding whitespace of a string.
---@param value string
---@return string trimmed
function ChatNormalize.Trim(value)
  return (value:match('^%s*(.-)%s*$'))
end

---Counts the characters of a string, nil when it is not valid UTF-8.
---@param value string
---@return number? length
function ChatNormalize.Length(value)
  return utf8.len(value)
end

---Normalizes a message payload into its interface shape, nil when it carries no text.
---Only the fields the interface shows are kept: nothing else ever reaches a client.
---@param data table The message data: content, and optionally type, channel, author, rank, icon, timestamp.
---@return table? message
function ChatNormalize.Message(data)
  if type(data) ~= 'table' or type(data.content) ~= 'string' or #data.content == 0 then
    return nil
  end

  return {
    type = MESSAGE_TYPES[data.type] and data.type or 'system',
    channel = CHANNELS[data.channel] and data.channel or ChatNormalize.PUBLIC_CHANNEL,
    author = type(data.author) == 'string' and data.author or nil,
    rank = type(data.rank) == 'string' and data.rank or nil,
    icon = type(data.icon) == 'string' and data.icon:match(ICON_PATTERN) ~= nil and data.icon or nil,
    timestamp = type(data.timestamp) == 'number' and data.timestamp or nil,
    text = data.content,
  }
end

---Strips the command prefix from a suggestion name when present.
---@param name string
---@param prefix string
---@return string stripped
function ChatNormalize.StripPrefix(name, prefix)
  if name:sub(1, #prefix) == prefix then
    return name:sub(#prefix + 1)
  end

  return name
end

---Normalizes a command suggestion payload into its interface shape, nil when it has no name.
---@param data table The suggestion data: name, and optionally description, params.
---@param prefix string The command prefix, stripped from the name when present.
---@return table? suggestion
function ChatNormalize.Suggestion(data, prefix)
  if type(data) ~= 'table' or type(data.name) ~= 'string' or #data.name == 0 then
    return nil
  end

  local name <const> = ChatNormalize.StripPrefix(data.name, prefix)

  if #name == 0 then
    return nil
  end

  local params <const> = {}

  if type(data.params) == 'table' then
    for _, param in ipairs(data.params) do
      if type(param) == 'table' and type(param.name) == 'string' then
        params[#params + 1] = {
          name = param.name,
          description = type(param.description) == 'string' and param.description or '',
          optional = param.optional == true,
        }
      end
    end
  end

  return {
    name = name,
    description = type(data.description) == 'string' and data.description or '',
    params = params,
  }
end
