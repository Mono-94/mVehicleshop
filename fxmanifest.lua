fx_version 'cerulean'

game 'gta5'

name "mono_garage_v2"

description "M O N O _ G A R A G E _ V 2"

author "aka_mono & .rawpaper"

version "1.0.0"

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'shared/*.lua',
	'@ox_lib/init.lua',
	'@mVehicle/import.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',

}

files {
	'ui/*.html',
	'ui/*.css',
	'ui/*.js',
}

ui_page {
	'ui/index.html',
}

--provide 'esx_vehicleshop'