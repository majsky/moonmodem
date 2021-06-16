local pb = {}
local _pb = {}

function _pb.__index(t, k)
    if type(k) ~= "string" then
        return
    end
    
    if k:sub(1,1) == "+" then
        return rawget(t, k:sub(5))
    end
end

function pb.open(path)
    local h = assert(io.open(path, "r"))

    local book = {}
    for l in h:lines() do
        local num, name, grp = l:match("(%d+)=([^,]+),?(.*)")

        book[num] = {name = name, admin = grp == "admin"}
    end

    h:close()

    return setmetatable(book, _pb)
end

return pb
