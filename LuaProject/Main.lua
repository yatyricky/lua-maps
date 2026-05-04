SF__ = SF__ or {}
function SF__.ListNew__(items)
    return { items = items or {}, version = 0 }
end

function SF__.ListCount__(list)
    return #list.items
end

function SF__.ListGet__(list, index)
    return list.items[index + 1]
end

function SF__.ListSet__(list, index, value)
    list.items[index + 1] = value
    list.version = list.version + 1
end

function SF__.ListAdd__(list, value)
    table.insert(list.items, value)
    list.version = list.version + 1
end

function SF__.ListIterate__(list)
    local version = list.version
    local i = 0
    return function()
        if list.version ~= version then error("collection was modified during iteration") end
        i = i + 1
        local value = list.items[i]
        if value ~= nil then return i, value end
    end
end

function SF__.ListSort__(list, less)
    local compare = less or function(a, b) return a < b end
    local items = list.items
    for i = 2, #items do
        local value = items[i]
        local j = i - 1
        while j >= 1 and compare(value, items[j]) do
            items[j + 1] = items[j]
            j = j - 1
        end
        items[j + 1] = value
    end
    list.version = list.version + 1
    return list
end

-- Program
SF__.Program = SF__.Program or {}
function SF__.Program.Main(args)
    CLI = {}
    local Time = require("Lib.Time")
    local FrameTimer = require("Lib.FrameTimer")
    require("Lib.CoroutineExt")
    require("Lib.TableExt")
    require("Lib.StringExt")
    require("Lib.native")
    local systems = SF__.ListNew__({})
    SF__.ListAdd__(systems, require("System.ItemSystem").new())
    SF__.ListAdd__(systems, require("System.SpellSystem").new())
    SF__.ListAdd__(systems, require("System.BuffSystem").new())
    SF__.ListAdd__(systems, require("System.DamageSystem").new())
    SF__.ListAdd__(systems, require("System.ProjectileSystem").new())
    SF__.ListAdd__(systems, require("System.InitAbilitiesSystem").new())
    SF__.ListAdd__(systems, require("System.BuffDisplaySystem").new())
    SF__.ListAdd__(systems, require("System.AIDebugSystem").new())
    SF__.ListAdd__(systems, require("System.TwistedMeadowsSystem").new())
    SF__.ListAdd__(systems, require("System.MeleeGameSystem").new())
    do
        local collection = systems
        for i, system in SF__.ListIterate__(collection) do
            system:Awake()
        end
    end
    local group = CreateGroup()
    GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
        ExTriggerRegisterNewUnitExec(GetFilterUnit())
        return false
    end))
    DestroyGroup(group)
    do
        local collection1 = systems
        for i2, system1 in SF__.ListIterate__(collection1) do
            system1:OnEnable()
        end
    end
    local game = FrameTimer.new(function(dt)
        local now = (MathRound((Time.Time * 100)) * 0.009999999776482582)
        do
            local collection3 = systems
            for i4, system2 in SF__.ListIterate__(collection3) do
                system2:Update(dt, now)
            end
        end
    end, 1, (-1))
    game:Start()
end

function SF__.Program.__Init(self)
    self.__sf_type = SF__.Program
end

function SF__.Program.New()
    local self = setmetatable({}, { __index = SF__.Program })
    SF__.Program.__Init(self)
    return self
end

SF__.Program.Main()
