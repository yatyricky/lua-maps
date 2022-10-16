local data = {}

local cls = setmetatable({}, {
    __index = function(t, k)
        return data[k]
    end,
    __newindex = function(t, k, v)
        if data[k] then
            Log("Error: duplicate ability name:", k)
        else
            data[k] = v
        end
    end
})

return cls
