---@class Pill
local cls = class("Pill")

---@param p1 Vector2
---@param p2 Vector2
---@param r real
function cls:ctor(p1, p2, r)
    self.p1 = p1
    self.p2 = p2
    self.r = r
end

---胶囊碰撞
---@param c1 Pill
---@param c2 Pill
---@return boolean
function cls.PillPill(c1, c2)
    local _caps = { c1, c2 }
    local rs = (c1.r + c2.r) * (c1.r + c2.r)
    for i = 1, 2 do
        local ii = i + 1
        if ii == 3 then
            ii = 1
        end
        local _vw = _caps[ii].p2 - _caps[ii].p1
        local vws2 = _vw:MagnitudeSqr()
        local _ps = { _caps[i].p1, _caps[i].p2 }
        for _, p in ipairs(_ps) do
            local t = math.clamp01(Vector2.Dot(p - _caps[ii].p1, _vw) / vws2)
            local _proj = _vw * t + _caps[ii].p1
            local dist = (_proj - p):MagnitudeSqr()
            if dist <= rs then
                return true
            end
        end
    end
    local _v1 = c1.p2 - c1.p1
    local _v2 = c2.p2 - c2.p1
    local _vw = c2.p1 - c1.p1
    local d = Vector2.Cross(_v1, _v2)
    local v = Vector2.Cross(_vw, _v1) / d
    local n = Vector2.Cross(_vw, _v2) / d
    if n >= 0 and n <= 1 and v >= 0 and v <= 1 then
        return true
    end
    return false
end

---@param capsule Pill
---@param circle Circle
function cls.PillCircle(capsule, circle)
    local rs = (capsule.r + circle.r) * (capsule.r + circle.r)
    local _vw = capsule.p2 - capsule.p1
    local vws2 = _vw:MagnitudeSqr()
    local t = math.clamp01(Vector2.Dot(circle.center - capsule.p1, _vw) / vws2)
    local _proj = _vw * t + capsule.p1
    if (_proj - circle.center):MagnitudeSqr() <= rs then
        return true
    else
        return false
    end
end

return cls
