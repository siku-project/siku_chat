fx_version 'cerulean'
game 'gta5'

author 'Siku Studio'
description 'A modern, modular and high-performance chat system for the SIKU ecosystem. Built with clean architecture, seamless UI integration, scalability, and immersive roleplay communication in mind.'
version '2.0.1'

name 'siku_chat'

lua54 'yes'

shared_scripts {
  '@siku_core/init.lua',
  'config/*.lua',
  'shared/normalize.lua',
}

server_scripts {
  'server/init.lua',
  'server/modules/clock.lua',
  'server/modules/hooks.lua',
  'server/modules/suggestions.lua',
  'server/modules/staff.lua',
  'server/main.lua',
}

client_scripts {
  'client/siku_ui.lua',
  'client/nui.lua',
  'client/main.lua',
}

ui_page 'web/dist/index.html'

files {
  'translations/*.lua',
  'web/dist/**/*',
}

dependencies {
  'siku_core',
}
