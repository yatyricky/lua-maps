---Add v to k of tab, in place. tab will be mutated.
---@generic K
---@param tab table<K, number>
---@param k K
---@param v number
---@return number result
function table.addNum(tab, k, v)
    local r = tab[k]
    if r == nil then
        r = v
    else
        r = r + v
    end
    tab[k] = r
    return r
end

function table.any(tab)
    return next(tab) ~= nil
end

function table.getOrCreateTable(tab, key)
    local ret = tab[key]
    if not ret then
        ret = {}
        tab[key] = ret
    end
    return ret
end
