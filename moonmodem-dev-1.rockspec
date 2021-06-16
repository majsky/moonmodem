package = "moonmodem"
version = "dev-1"
source = {
   url = "git://github.com/majsky/moonmodem"
}

description = {
   homepage = "https://github.com/majsky/moonmodem",
   license = "GNU"
}

dependencies = {
   "lua >= 5.1",
   "rapidjson",
   "lua-mosquitto"
}

build = {
   type = "builtin",
   modules = {
      moonmodem = "moonmodem.lua",
      ["mmod.phonebook"] = "mmod/phonebook.lua",
      ["mmod.modem"] = "mmod/modem/init.lua"
   }
}
