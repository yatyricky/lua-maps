function math.fuzzyEquals(a, b, precision)
    precision = precision or 0.000001
    return (a == b) or math.abs(a - b) < precision
end

---@param t real ratio 0-1
---@param c1 real
---@param c2 real
---@param c3 real
---@return real
function math.bezier3(t, c1, c2, c3)
    local t1 = 1 - t
    return c1 * t1 * t1  + c2 * 2 * t1 * t  + c3 * t * t
end

math.clamp = function(value, min, max)
    return math.min(math.max(min, value), max)
end

math.clamp01 = function(value)
    return math.clamp(value, 0, 1)
end

math.atan2 = Atan2
