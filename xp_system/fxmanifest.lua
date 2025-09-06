fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Enhanced XP and leveling system'
version '1.0.0'

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

exports {
    'AddPlayerXP',
    'GetXPLeaderboard',
    'GetServerXPStats',
}
