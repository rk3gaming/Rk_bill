fx_version 'cerulean'
game 'gta5'

author 'rkfrmda3'
description 'Billing Script for Okok Banking'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    'server/server.lua'
}

dependency 'es_extended'
