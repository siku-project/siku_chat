local VALID_POINTS <const> = {
  beforeMessage = true,
  afterMessage = true,
}

local DEFAULT_PRIORITY <const> = 0

local hooks <const> = {
  beforeMessage = {},
  afterMessage = {},
}

local nextHookId = 1

ChatHooks = {}

---Checks whether the given hook point exists.
---@param point string
---@return boolean valid
local function isValidPoint(point)
  return type(point) == 'string' and VALID_POINTS[point] == true
end

---Inserts the entry keeping the list sorted by ascending priority.
---@param list table
---@param entry table
---@return nil
local function insertSorted(list, entry)
  for index = 1, #list do
    if entry.priority < list[index].priority then
      table.insert(list, index, entry)
      return
    end
  end

  list[#list + 1] = entry
end

---Applies the modifiable fields returned by a hook onto the context.
---@param ctx table
---@param result table
---@return nil
local function applyResult(ctx, result)
  if type(result.content) == 'string' then
    ctx.content = result.content
  end

  if type(result.author) == 'string' then
    ctx.author = result.author
  end

  if type(result.metadata) == 'table' then
    ctx.metadata = result.metadata
  end
end

---Removes every hook owned by the given resource.
---@param resourceName string
---@return nil
local function removeResourceHooks(resourceName)
  for _, list in pairs(hooks) do
    for index = #list, 1, -1 do
      if list[index].resource == resourceName then
        table.remove(list, index)
      end
    end
  end
end

---Registers a hook on the given point.
---A beforeMessage handler receives the message context and may return false to
---cancel the message, or a table with content/author/metadata to modify it.
---An afterMessage handler is observation only.
---@param point string The hook point, 'beforeMessage' or 'afterMessage'.
---@param handler function The handler invoked with the message context.
---@param options? table Optional settings, supports priority (number, lower runs first).
---@return number? id The hook id, or nil when the registration is invalid.
function ChatHooks.Register(point, handler, options)
  if not isValidPoint(point) then
    Siku.print.error(
      ('RegisterHook: invalid point %q — expected \'beforeMessage\' or \'afterMessage\''):format(tostring(point))
    )
    return nil
  end

  if type(handler) ~= 'function' then
    Siku.print.error('RegisterHook: handler must be a function')
    return nil
  end

  local priority = DEFAULT_PRIORITY

  if type(options) == 'table' and type(options.priority) == 'number' then
    priority = options.priority
  end

  local id <const> = nextHookId
  nextHookId = nextHookId + 1

  insertSorted(hooks[point], {
    id = id,
    handler = handler,
    priority = priority,
    resource = GetInvokingResource() or GetCurrentResourceName(),
  })

  return id
end

---Removes a hook by id.
---@param id number The id returned by ChatHooks.Register.
---@return boolean removed Whether a hook was found and removed.
function ChatHooks.Remove(id)
  if type(id) ~= 'number' then
    return false
  end

  for _, list in pairs(hooks) do
    for index = 1, #list do
      if list[index].id == id then
        table.remove(list, index)
        return true
      end
    end
  end

  return false
end

---Runs the beforeMessage chain on the given context.
---@param ctx table The message context (source, author, content, channel, type, metadata).
---@return table|false ctx The final context, or false when a hook cancelled the message.
function ChatHooks.RunBefore(ctx)
  for _, entry in ipairs(hooks.beforeMessage) do
    local ok <const>, result = pcall(entry.handler, ctx)

    if not ok then
      Siku.print.error(('beforeMessage hook from %q failed: %s'):format(entry.resource, tostring(result)))
    elseif result == false then
      return false
    elseif type(result) == 'table' then
      applyResult(ctx, result)
    end
  end

  return ctx
end

---Runs the afterMessage chain on the given context.
---@param ctx table The message context of a broadcasted message.
---@return nil
function ChatHooks.RunAfter(ctx)
  for _, entry in ipairs(hooks.afterMessage) do
    local ok <const>, err = pcall(entry.handler, ctx)

    if not ok then
      Siku.print.error(('afterMessage hook from %q failed: %s'):format(entry.resource, tostring(err)))
    end
  end
end

AddEventHandler('onResourceStop', function(resourceName)
  removeResourceHooks(resourceName)
end)

exports('RegisterHook', ChatHooks.Register)
exports('RemoveHook', ChatHooks.Remove)
