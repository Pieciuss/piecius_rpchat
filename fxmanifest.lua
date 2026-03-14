fx_version 'cerulean'
game 'gta5'

name 'Piecius_rpchat'
author 'Piecius'
description 'RP Chat Commands - /me /do /twt /dw /globaldo /try /med + OOC + 3D Hints'
version '1.1.0'
lua54 'yes'

shared_scripts {
    'config.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/main.lua',
}

server_scripts {
    'bridge/server.lua',
    'server/main.lua',
}

ui_page 'html/hint.html'

files {
    'html/hint.html',
    'html/hint.css',
    'html/hint.js',
}

dependencies {
    'chat',
}