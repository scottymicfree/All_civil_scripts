fx_version 'cerulean'
game 'gta5'

description 'Standalone Civilian Job Script'
author 'Randy Webb'
version '1.0.0'

-- Removed the problematic resource_type declaration
-- resource_type 'gametype'
-- resource_type_extra '{"name": "CivilianJob"}'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}
