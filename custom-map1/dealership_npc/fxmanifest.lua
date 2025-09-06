fx_version 'cerulean'
game 'gta5'

description 'Standalone Dealership NPC Script'
author 'Randy Webb'
version '1.0.0'

-- Removed problematic resource_type declaration
-- resource_type 'gametype'
-- resource_type_extra '{"name": "DealershipNPC"}'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}
