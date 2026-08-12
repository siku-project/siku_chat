local VALID_MESSAGE_TYPES <const> = {
  system = true,
  info = true,
  success = true,
  warning = true,
  error = true,
}

local VALID_CHANNELS <const> = {
  public = true,
  staff = true,
}

local ICON_PATTERN <const> = '^mdi%-[%w%-]+$'

ChatNormalize = {}

---Checks whether the given value is a valid public message type.
---@param value any
---@return boolean valid
function ChatNormalize.IsValidType(value)
  return VALID_MESSAGE_TYPES[value] == true
end

---Removes FiveM color codes and control characters from a chat string.
---@param value string The raw content.
---@return string cleaned The sanitized content.
function ChatNormalize.Sanitize(value)
  local withoutColors <const> = value:gsub('%^%d', '')

  return (withoutColors:gsub('%c', ''))
end

---Normalizes a public message payload into its NUI shape, returning nil when invalid.
---@param data table The message data: content, and optionally type, author, icon, channel, metadata, timestamp.
---@return table? message
function ChatNormalize.Message(data)
  if type(data) ~= 'table' or type(data.content) ~= 'string' or #data.content == 0 then
    return nil
  end

  return {
    type = VALID_MESSAGE_TYPES[data.type] and data.type or 'system',
    channel = VALID_CHANNELS[data.channel] and data.channel or 'public',
    author = type(data.author) == 'string' and data.author or nil,
    icon = type(data.icon) == 'string' and data.icon:match(ICON_PATTERN) ~= nil and data.icon or nil,
    metadata = type(data.metadata) == 'table' and data.metadata or nil,
    timestamp = type(data.timestamp) == 'number' and data.timestamp or nil,
    text = data.content,
  }
end

---Strips the given command prefix from a suggestion name when present.
---@param name string
---@param prefix string
---@return string stripped
function ChatNormalize.StripPrefix(name, prefix)
  if name:sub(1, #prefix) == prefix then
    return name:sub(#prefix + 1)
  end

  return name
end

---Normalizes a command suggestion payload into its NUI shape, returning nil when invalid.
---@param data table The suggestion data: name, and optionally description, params, staff.
---@param prefix string The configured command prefix, stripped from the name when present.
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
    staff = data.staff == true,
  }
end
