local ipairs = ipairs
local t_insert = table.insert
local m_floor = math.floor
local m_random = math.random
local m_clamp = math.clamp

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
    if key == nil then
        print(GetStackTrace())
    end
    local ret = tab[key]
    if not ret then
        ret = {}
        tab[key] = ret
    end
    return ret
end

---@generic T
---@param tab T[]
---@param n integer count
---@return T[]
function table.sample(tab, n)
    local result = {}
    local c = 0
    for _, item in ipairs(tab) do
        c = c + 1
        if #result < n then
            t_insert(result, item)
        else
            local s = m_floor(m_random() * c)
            if s < n then
                result[s + 1] = item
            end
        end
    end
    return result
end

---@generic T
---@param tab T[]
---@param item T
function table.removeItem(tab, item)
    local c = #tab
    local i = 1
    local d = 0
    local removed = false
    while i <= c do
        local it = tab[i]
        if it == item then
            d = d + 1
            removed = true
        else
            if d > 0 then
                tab[i - d] = it
            end
        end
        i = i + 1
    end
    for j = 0, d - 1 do
        tab[c - j] = nil
    end
    return removed
end

---@generic V
---@param t V[]
---@param func fun(i: integer, v: V): boolean
---@return V, integer
function table.iFind(t, func)
    for i, v in ipairs(t) do
        if func(i, v) == true then
            return v, i
        end
    end
    return nil, nil
end

---@generic T
---@param tab T[]
---@param from number Optional One-based index at which to begin extraction.
---@param to number Optional One-based index before which to end extraction.
---@return T[]
function table.slice(tab, from, to)
    from = from and m_clamp(from, 1, #tab + 1) or 1
    to = to and m_clamp(to, 1, #tab) or #tab
    local result = {}
    for i = from, to, 1 do
        if tab[i] then
            t_insert(result, tab[i])
        end
    end
    return result
end

---@generic K, V
---@param source table<K, V> | V[]
---@param copy table<K, V> | V[]
---@return table<K, V> | V[]
function table.shallow(source, copy)
    copy = copy or {}
    for k, v in pairs(source) do
        copy[k] = v
    end
    return copy
end

---@generic T
---@param t T[]
---@return T
function table.iGetRandom(t)
    return t[m_random(#t)]
end

---@generic T
---@param t T[]
---@param func fun(elem: T): boolean
---@return T[]
function table.iWhere(t, func)
    local tab = {}
    for _, v in ipairs(t) do
        if func(v) then
            t_insert(tab, v)
        end
    end
    return tab
end

---@generic V
---@param tab V[]
---@param filter fun(item: V): boolean
---@return V[] removed items
function table.iFilterInPlace(tab, filter)
    local ret = {}
    local c = #tab
    local i = 1
    local d = 0
    while i <= c do
        local it = tab[i]
        if filter(it) then
            if d > 0 then
                tab[i - d] = it
            end
        else
            t_insert(ret, it)
            d = d + 1
        end
        i = i + 1
    end
    for j = 0, d - 1 do
        tab[c - j] = nil
    end
    return ret
end

function table.iRemoveOneRight(tab, item)
    for i = #tab, 1, -1 do
        if tab[i] == item then
            table.remove(tab, i)
            return true
        end
    end
    return false
end

function table.iRemoveOneLeft(tab, item)
    for i = 1, #tab do
        if tab[i] == item then
            table.remove(tab, i)
            return true
        end
    end
    return false
end
