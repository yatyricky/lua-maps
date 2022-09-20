local cls = class("Vector2")

function cls:ctor(x,y)
    self.x = x or 0
    self.y = y or 0
end

return cls
