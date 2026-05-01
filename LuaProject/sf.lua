SF__ = SF__ or {}
-- Program
SF__.Program = SF__.Program or {}
function SF__.Program.Main(args)
    BJDebugMsg("Hello SharpForge")
    local unit = CreateUnit(Player(0), FourCC("hfoo"), 0, 0, 0)
    BJDebugMsg(GetUnitName(unit))
    BJDebugMsg(GetPlayerName(GetOwningPlayer(unit)))
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
