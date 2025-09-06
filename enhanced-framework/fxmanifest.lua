fx_version 'cerulean'
game 'gta5'

author 'Randy Webb'
description 'Enhanced FiveM Server Resources Integration'
version '1.0.0'

-- Use this directive for dependencies
shared_script '@ox_lib/init.lua' -- ox_lib is required for ox_inventory and is best practice
client_script '@NativeUI/NativeUI.lua'

client_scripts {
    'dpad_access_enhanced.lua',
    'npc_logic_enhanced.lua',
    'zone_manager_enhanced.lua'
}

server_scripts {
    'mission_system_enhanced.lua'
}

-- You DO NOT need to declare exports or server_exports for Lua scripts.
-- The exports() function in the code handles it automatically.
-- Remove the exports and server_exports sections from all your manifests.
