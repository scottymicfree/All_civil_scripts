fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Civil Disorder AI Framework'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'npc_gang_ai_client.lua'
}

server_scripts {
    'npc_gang_ai_server.lua'
}

dependencies {
    'interior_zone_manager'
}

lua54 'yes'
