local FrameTimer = require("Lib.FrameTimer")
require("Lib.CoroutineExt")
require("Lib.ArrayExt")
require("Lib.TableExt")
require("Lib.native")

local ipairs = ipairs

-- main logic

-- game machine

---@type SystemBase[]
local systems = {
    require("System.ItemSystem").new(),
    require("System.SpellSystem").new(),
    require("System.MeleeGameSystem").new(),
    require("System.BuffSystem").new(),
    require("System.DamageSystem").new(),
    --require("System.AbilityEditorSystem").new(),

    require("System.InitAbilitiesSystem").new(),
}

for _, system in ipairs(systems) do
    system:Awake()
end

for _, system in ipairs(systems) do
    system:OnEnable()
end

local game = FrameTimer.new(function()
    for _, system in ipairs(systems) do
        system:Update(dt)
    end
end, 1, -1)
game:Start()
