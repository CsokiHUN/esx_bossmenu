fx_version("cerulean")
game("gta5")

client_scripts({
	"client.lua",
	"config.lua",
})
server_scripts({
	"@mysql-async/lib/MySQL.lua",
	"server.lua",
})
ui_page("html/index.html")

files({
	"html/*",
	"html/assets/*",
})

shared_script("@es_extended/imports.lua")
