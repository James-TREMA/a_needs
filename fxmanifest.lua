fx_version 'cerulean'
game 'gta5'

author 'Protocol87'
description 'Système de faim et soif - NUI Svelte'
version '2.0.0'

lua54 'yes'

ui_page 'ui/dist/index.html'

-- Configuration partagée (client + serveur)
shared_scripts {
    'Config/config.lua'
}

-- Scripts client (ordre important)
client_scripts {
    'client/functions.lua',
    'client/events.lua',
    'client/threads.lua'
}

-- Scripts serveur (ordre important)
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/database.lua',
    'server/events.lua',
    'server/threads.lua',
    'server/exports.lua'
}

-- Fichiers UI
files {
    'ui/dist/index.html',
    'ui/dist/assets/*.js',
    'ui/dist/assets/*.css'
}

-- Dépendances requises
dependencies {
    'es_extended',
    'oxmysql'
    -- ox_inventory (optionnel, pour l'intégration items)
}