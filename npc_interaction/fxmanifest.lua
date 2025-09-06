fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'NPC interaction system for FiveM'
version '1.0.0'

client_scripts {
    'npc_interaction.lua'
}



exports {
    'RegisterNPC',
    'SpawnNPC',
    'DespawnNPC',
    'InteractWithNPC',
    'InteractWithNPCEntity',
    'bounty_mission',
    'job_wheel',
    'GetNPCType'
}
