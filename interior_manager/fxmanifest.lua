fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Interior zone conflict resolver and manager'
version '1.0.0'

client_scripts {
    'client.lua'
}

exports {
    'RegisterInterior',
    'UpdateInterior',
    'RemoveInterior',
    'GetActiveInteriorAtPosition'
}