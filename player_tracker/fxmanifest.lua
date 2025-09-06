fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Enhanced player tracking system for GPS, kills, deaths, XP, and vehicles'
version '1.0.0'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

exports {
    'GetPlayerData',
    'GetPlayerGPS',
    'GetPlayerKills',
    'GetPlayerDeaths',
    'GetPlayerXP',
    'GetPlayerLevel',
    'GetPlayerVehicles'
}