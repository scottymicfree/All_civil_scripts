fx_version 'cerulean'
game 'gta5'

name 'mechanic_garages'
author 'Randy Webb'
description 'Mechanic garage system for Civil Unrest RP'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'standalone-framework',
    'NativeUI'  -- Add NativeUI as a dependency
}
