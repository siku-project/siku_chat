local REQUIRED_CORE_VERSION <const> = '1.7.1'

local dependency <const> = Siku.version.checkDependency('siku_core', REQUIRED_CORE_VERSION)

if not dependency.ok then
  error(dependency.message)
end

Siku.version.checkRelease('siku-project/siku_chat')

local prefix <const>, valid <const> = ChatNormalize.Prefix(ChatConfig.commandPrefix)

if not valid then
  Siku.log.warn('chat.prefix_invalid', ('commandPrefix %s is not allowed, the chat uses %s'):format(tostring(ChatConfig.commandPrefix), prefix), {
    configured = tostring(ChatConfig.commandPrefix),
    fallback = prefix,
    allowed = ChatNormalize.AllowedPrefixes(),
    reason = 'not_allowed',
  }, { entities = { { type = 'resource', id = Siku.name, role = 'subject', label = Siku.name } } })
end

ChatPrefix = prefix
