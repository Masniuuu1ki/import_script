fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Masniuuu1ki'

client_scripts {
    'client.lua',
    'config.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

server_scripts {
    'server.lua',
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
}

dependencies {
    'es_extended',
    'ox_lib',
}

ui_page 'web/index.html'

files {
	'web/index.html',
    'web/**.png',
	'web/**'
}