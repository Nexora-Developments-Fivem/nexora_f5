fx_version 'cerulean'
game 'gta5'

author 'Tarek.dev - Nexora Developments'
description 'Nexora F5 Menu - Multi-Framework'
version '1.0.0'

lua54 'yes'

ui_page 'link/index.html'

files {
    'stream/commonmenu.ytd',
    'stream/RageUI.ytd',
    'link/index.html',
    'link/link.js'
}

shared_scripts {
    'config/framework.lua',
    'config/config.lua',
    'config/config-2.lua',
    'config/translations.lua'
}

client_scripts {
    "libs/RageUI/RMenu.lua",
    "libs/RageUI/menu/RageUI.lua",
    "libs/RageUI/menu/Menu.lua",
    "libs/RageUI/menu/MenuController.lua",
    "libs/RageUI/components/*.lua",
    "libs/RageUI/menu/elements/*.lua",
    "libs/RageUI/menu/items/*.lua",
    "libs/RageUI/menu/panels/*.lua",
    "libs/RageUI/menu/windows/*.lua",
    'bridge/framework.lua',
    'client/hud.lua',
    'client/radio.lua',
    'client/cinematic.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

version_scripts {
    'server/version_checker.lua'
}

dependencies {
    'oxmysql'
}
