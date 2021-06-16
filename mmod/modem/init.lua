local json = require("rapidjson")

local class = require("mmod.class")


local modem = class()


function modem:init(id, handler)
    self.id = id
    self.handler = handler

    do
        local hnd = io.open("msgs.json", "r")

        if hnd then
            self.msgs = json.decode(hnd:read("a"))
            hnd:close()
        else
            self.msgs = {}
        end
    end
end

function modem:sync()
    for _, msgid in pairs(self:eval("--messaging-list-sms")["modem.messaging.sms"]) do
        local sms = self:eval("-s", msgid).sms
        self.handler("sms", sms)
        table.insert(self.msgs, sms)
        self:eval("--messaging-delete-sms", msgid)
    end


    local hnd = io.open("msgs.json", "w")
    hnd:write(json.encode(self.msgs))
    hnd:close()

end

function modem:eval(...)
    local cmd = {"mmcli", "-J", "-m", self.id, ...}

    cmd = table.concat(cmd, " ")

    local hnd = io.popen(cmd, "r")

    local txt = hnd:read("a")

    hnd:close()

    return json.decode(txt)
end
return modem
