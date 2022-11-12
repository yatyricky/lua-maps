local FrameTimer = require("Lib.FrameTimer")
local Time = require("Lib.Time")
require("Lib.CoroutineExt")
require("Lib.TableExt")
require("Lib.StringExt")
require("Lib.native")

local ipairs = ipairs

-- main logic

-- game machine

---@type SystemBase[]
local systems = {
    require("System.ItemSystem").new(),
    require("System.SpellSystem").new(),
    --require("System.MeleeGameSystem").new(),
    require("System.BuffSystem").new(),
    require("System.DamageSystem").new(),
    require("System.ProjectileSystem").new(),
    --require("System.MoverSystem").new(),
    require("System.ManagedAISystem").new(),

    require("System.InitAbilitiesSystem").new(),
}

for _, system in ipairs(systems) do
    system:Awake()
end

local group = CreateGroup()
GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
    local s, m = pcall(ExTriggerRegisterNewUnitExec, GetFilterUnit())
    if not s then
        print(m)
    end
end))
DestroyGroup(group)
group = nil

for _, system in ipairs(systems) do
    system:OnEnable()
end

local MathRound = MathRound

local game = FrameTimer.new(function(dt)
    local now = MathRound(Time.Time * 100) * 0.01
    for _, system in ipairs(systems) do
        system:Update(dt, now)
    end
end, 1, -1)
game:Start()
