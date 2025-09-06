fx_version 'cerulean'
game 'gta5'

name 'standalone-framework'
author 'Randy Webb'
description 'A standalone framework for FiveM resources'
version '1.0.0'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua',
    'server/staff.lua'
}

shared_scripts {
    'config.lua'
}

client_exports {
    'GetPlayerJob',
    'GetPlayerGang',
    'GetPlayerMoney',
    'GetPlayerBank',
    'GetPlayerXP',
    'GetPlayerLevel',
    'GetPlayerRank',
    'AddMoney',
    'RemoveMoney',
    'ShowNotification',
    'DoesWeaponExist'
}

server_exports {
    'GetPlayerJob',
    'SetPlayerJob',
    'GetPlayerGang',
    'SetPlayerGang',
    'AddMoney',
    'RemoveMoney',
    'AddXP',
    'GetPlayerValue',
    'GetPlayerRank',
    'SetPlayerRank',
    'IsPlayerAdmin',
    'GetStaffList',
    'DoesWeaponExist'
}
