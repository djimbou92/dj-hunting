fx_version 'cerulean'
game 'gta5'

description 'Nopixel Hunting (Converted and improved by Djimbou - https://github.com/djimbou92'

client_scripts {
    'client/cl_main.lua',
    'client/cl_hunting.lua',
    'client/cl_sell.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
}

server_scripts {
    'server.lua'
}

files {
    'html/*'
}

ui_page 'html/index.html'

shared_scripts {
    'shared.lua'
}