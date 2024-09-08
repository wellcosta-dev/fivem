fx_version 'cerulean'
game 'gta5'

author 'WELLCOSTA'
description 'WELLCOSTA PP SYSTEM'
version '1.0.0'

-- Client and server scripts
client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

-- HTML, CSS, and JS for NUI
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'es_extended'
}
