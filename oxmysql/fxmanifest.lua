fx_version 'cerulean'
game 'gta5'

name 'oxmysql'
author 'Overextended'
description 'MySQL resource for FiveM'
version '2.7.3'

server_only 'yes'
server_script 'dist/build.js'

dependencies {
    '/server:5848',
    '/onesync',
}

provide 'mysql-async'

lua54 'yes'
use_experimental_fxv2_oal 'yes'
