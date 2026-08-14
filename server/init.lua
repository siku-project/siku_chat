local REQUIRED_CORE_VERSION <const> = '0.1.0'

local dependency <const> = Siku.CheckDependency('siku_core', REQUIRED_CORE_VERSION)

if not dependency.ok then
  Siku.print.throw(dependency.message)
end

Siku.print.success(('Linked to siku_core (%s)'):format(dependency.currentVersion))
Siku.VersionCheck('siku-project/siku_chat')
