local EventCenter = require("Lib.EventCenter")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = FourCC("Arej"),
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            for _ = 1, 12 do
                coroutine.wait(1)
                if not ExIsUnitDead(data.target) then
                    EventCenter.Heal:Emit({
                        caster = data.caster,
                        target = data.target,
                        amount = 33.333,
                    })
                else
                    break
                end
            end
        end)
    end
})
