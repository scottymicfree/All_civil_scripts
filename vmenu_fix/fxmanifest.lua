fx_version 'cerulean'
game 'gta5'

name 'vmenu_fix'
author 'Randy Webb'
description 'Fixes repeating vMenu prompts'
version '1.0.0'

client_script 'client.lua'

-- Make sure this loads after vMenu
dependencies {
    'vMenu'
}
