SF__ = SF__ or {}
-- Program
SF__.Program = SF__.Program or {}
function SF__.Program.Main(args)
    BJDebugMsg("Hello SharpForge")
end

function SF__.Program.__Init(self)
    self.__sf_type = SF__.Program
end

function SF__.Program.New()
    local self = setmetatable({}, { __index = SF__.Program })
    SF__.Program.__Init(self)
    return self
end
