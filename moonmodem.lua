--package.path = "/opt/moonmodem/?.lua;/opt/moonmodem/?/init.lua;" .. package.path

local mqtt = require("mosquitto")
local json = require("rapidjson")

local client = mqtt.new()

local modem = require("mmod.modem")
local pbook = require("mmod.phonebook")

local cmds = {}

local pb = pbook.open(".phonebook")

local m = modem(0, function (kind, ctx)
    if kind == "sms" then
        local notify = true

        local ninfo = pb[ctx.content.number]

        if ninfo then
            ctx.content.number = ninfo.name

            if ninfo.admin then
                local msg = ctx.content.text
                
                local cmd, args = msg:match("@([a-z]+)%(?([^)]*)%)?")

                if cmd then
                    if args then
                        local a = {}

                        for arg in args:gmatch("([^,]+),?") do
                            table.insert(a, arg)
                        end

                        args = a
                    end

                    local cfn = cmds[cmd]

                    if not cfn then
                        
                    else
                        cfn(table.unpack(args))
                        notify = false
                    end
                end
            end
        end

        if notify then
            client:publish("/modem/sms", json.encode(ctx), 2)
        end
    end
end)

local _EXIT = false

function cmds.zto(state)
    local verb = state == "true" and "start" or "stop"
    os.execute(string.format("systemctl %s zerotier-one.service", verb))
end

function cmds.net(state)
    local verb = state ~= "true" and "dis" or ""
    os.execute(string.format("nmcli device %sconnect cdc-wdm0", verb))
end

local _cConnect = false
client.ON_CONNECT = function()
        _cConnect = true
end

client.ON_MESSAGE = function(mid, topic, payload)
end

client:login_set("lua", "lua")

client:connect("localhost", 1883, 30)

repeat
    client:loop()
until _cConnect

while not _EXIT do
    m:sync()
    client:loop()

    local h = io.popen("sleep 5", "r")
    h:read("a")
    h:close()
end
