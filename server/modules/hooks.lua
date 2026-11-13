local POINTS <const> = {
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

---@param resource string
---@return table entity
local function resourceEntity(resource)
  return { type = 'resource', id = resource, role = 'subject', label = resource }
end

---Inserts the entry keeping the list sorted by ascending priority.
---@param list table
---@param entry table
local function insertSorted(list, entry)
  for index = 1, #list do
    if entry.priority < list[index].priority then
      table.insert(list, index, entry)
      return
    end
  end

  list[#list + 1] = entry
end

---Applies the fields a hook may change onto the context.
---@param ctx table
---@param result table
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

---Registers a hook on a point.
---A beforeMessage handler receives the message context and may return false to
---cancel the message, or a table with content, author or metadata to change it.
---An afterMessage handler only observes. Both see the public and the staff channel.
---@param point string 'beforeMessage' or 'afterMessage'.
---@param handler function The handler, called with the message context.
---@param options? table Optional settings: priority (number, lower runs first).
---@return number? id The hook id, nil when the registration is refused.
function ChatHooks.Register(point, handler, options)
  local resource <const> = GetInvokingResource() or GetCurrentResourceName()

  if type(point) ~= 'string' or not POINTS[point] then
    Siku.log.warn('chat.hook_rejected', ('RegisterHook from %s: unknown point %s'):format(resource, tostring(point)), {
      resource = resource,
      point = tostring(point),
      reason = 'point_unknown',
    }, { entities = { resourceEntity(resource) } })
    return nil
  end

  if type(handler) ~= 'function' then
    Siku.log.warn('chat.hook_rejected', ('RegisterHook from %s on %s: the handler is not a function'):format(resource, point), {
      resource = resource,
      point = point,
      reason = 'handler_invalid',
      got = type(handler),
    }, { entities = { resourceEntity(resource) } })
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
    resource = resource,
  })

  return id
end

---Removes a hook by id.
---@param id number The id given by ChatHooks.Register.
---@return boolean removed Whether a hook was found.
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

---Runs the beforeMessage chain on a context.
---@param ctx table The message context: source, author, content, channel, type, metadata.
---@return table|false ctx The final context, or false when a hook cancelled the message.
function ChatHooks.RunBefore(ctx)
  for _, entry in ipairs(hooks.beforeMessage) do
    local ok <const>, result = pcall(entry.handler, ctx)

    if not ok then
      Siku.log.error('chat.hook_failed', ('beforeMessage hook from %s failed: %s'):format(entry.resource, tostring(result)), {
        resource = entry.resource,
        point = 'beforeMessage',
        channel = ctx.channel,
        error = tostring(result),
      }, { outcome = 'failure', entities = { resourceEntity(entry.resource) } })
    elseif result == false then
      return false
    elseif type(result) == 'table' then
      applyResult(ctx, result)
    end
  end

  return ctx
end

---Runs the afterMessage chain on the context of a delivered message.
---@param ctx table
function ChatHooks.RunAfter(ctx)
  for _, entry in ipairs(hooks.afterMessage) do
    local ok <const>, err = pcall(entry.handler, ctx)

    if not ok then
      Siku.log.error('chat.hook_failed', ('afterMessage hook from %s failed: %s'):format(entry.resource, tostring(err)), {
        resource = entry.resource,
        point = 'afterMessage',
        channel = ctx.channel,
        error = tostring(err),
      }, { outcome = 'failure', entities = { resourceEntity(entry.resource) } })
    end
  end
end

AddEventHandler('onResourceStop', function(resourceName)
  for _, list in pairs(hooks) do
    for index = #list, 1, -1 do
      if list[index].resource == resourceName then
        table.remove(list, index)
      end
    end
  end
end)

exports('RegisterHook', ChatHooks.Register)
exports('RemoveHook', ChatHooks.Remove)
