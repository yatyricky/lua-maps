local FrameUpdate = require("Lib.EventCenter").FrameUpdate

local cls = class("FrameTimer")

function cls:ctor(func, count, loops)
    self.func = func
    self.count = count
    self.loops = loops

    self.frames = count
    self.running = false
end

function cls:Start()
    if self.running then
        print("zxcv running")
        return
    end

    if self.loops == 0 then
        print("zxcv loops == 0")
        return
    end

    self.running = true
    FrameUpdate:On(self, cls._update)
end

function cls:Stop()
    if not self.running then
        return
    end

    self.running = false
    FrameUpdate:Off(self, cls._update)
end

function cls:_update(dt)
    print("zxcv frame update")
    if not self.running then
        print("zxcv not running return")
        return
    end

    self.frames = self.frames - 1
    print("zxcv self.frames is ", self.frames)
    if self.frames <= 0 then
        print("zxcv self.frames <0  callback")
        if not cls.called then
            self.func()
            cls.called = true
        end
        

        if self.loops > 0 then
            self.loops = self.loops - 1
            print("zxcv loops is", self.loops)
            if self.loops == 0 then
                self:Stop()
                return
            end
        end
        self.frames = self.frames + self.count
    end
end

return cls
