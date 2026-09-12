local Cow = {}
Cow.__index = Cow

function Cow.new(x, y)
    local self = setmetatable({}, Cow)
    self.x = x
    self.y = y
    self.abducted = false
    self.abductionTimer = 0
    return self
end

function Cow:beginAbduction()
    if not self.abducted then
        self.abducted = true
        self.abductionTimer = 2.5
    end
end

function Cow:update(dt)
    if self.abducted then
        self.abductionTimer = self.abductionTimer - dt
        self.y = self.y - 18 * dt
        if self.abductionTimer <= 0 then
            self.x = -999
            self.y = -999
        end
    end
end

function Cow:draw()
    if self.x < 0 then return end

    if self.abducted then
        love.graphics.setColor(0.45, 1, 0.65, 0.12)
        love.graphics.polygon("fill", self.x - 38, self.y + 60, self.x + 38, self.y + 60, self.x + 14, self.y - 70, self.x - 14, self.y - 70)
    end

    love.graphics.setColor(0.95, 0.95, 0.9)
    love.graphics.rectangle("fill", self.x - 18, self.y - 12, 36, 24, 8, 8)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.circle("fill", self.x - 8, self.y - 2, 5)
    love.graphics.circle("fill", self.x + 10, self.y + 5, 4)
end

return Cow
