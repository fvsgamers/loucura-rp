fx_version 'cerulean'
game 'gta5'

author 'fvsgamers'
description 'Evento Global Purga - Qbox Edition'
version '3.0.0'
lua54 'yes'

-- Garante que o servidor possui o Qbox e ox_lib ativos
dependencies {
    'qbx_core',
    'ox_lib'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}
