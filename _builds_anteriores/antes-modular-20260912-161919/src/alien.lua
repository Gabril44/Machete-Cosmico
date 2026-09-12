local Alien = {}
Alien.__index = Alien

function Alien.new(x, y)
    local self = setmetatable({}, Alien)
    self.x = x
    self.y = y
    self.radius = 17
    self.speed = love.math.random(70, 105)
    self.hp = 2
    self.dead = false
    self.knockX = 0
    self.knockY = 0
    self.wasHitThisSwing = false
    return self
end

function Alien:update(dt, player, cows)
    if self.dead then return end

    local target = player
    local closestDist = math.huge

    for _, cow in ipairs(cows) do
        if not cow.abducted then
            local dx, dy = cow.x - self.x, cow.y - self.y
            local d = dx * dx + dy * dy
            if d < closestDist then
                closestDist = d
                target = cow
            end
        end
    end

    local dx, dy = target.x - self.x, target.y - self.y
    local len = math.sqrt(dx * dx + dy * dy)

    if len > 0 then
        dx, dy = dx / len, dy / len
        self.x = self.x + dx * self.speed * dt + self.knockX * dt
        self.y = self.y + dy * self.speed * dt + self.knockY * dt
    end

    self.knockX = self.knockX * math.max(0, 1 - 7 * dt)
    self.knockY = self.knockY * math.max(0, 1 - 7 * dt)

    if target.abducted ~= nil and len < 28 then
        target:beginAbduction()
    end
end

function Alien:takeDamage(amount, sourceX, sourceY)
    self.hp = self.hp - amount

    local dx, dy = self.x - sourceX, self.y - sourceY
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        self.knockX = (dx / len) * 300
        self.knockY = (dy / len) * 300
    end

    if self.hp <= 0 then
        self.dead = true
    end
end

function Alien:isInsideAttack(box)
    return self.x + self.radius > box.x
        and self.x - self.radius < box.x + box.w
        and self.y + self.radius > box.y
        and self.y - self.radius < box.y + box.h
end

function Alien:draw()
    love.graphics.setColor(0.55, 0.9, 0.55)
    love.graphics.circle("fill", self.x, self.y, self.radius)

    love.graphics.setColor(0.08, 0.1, 0.08)
    love.graphics.ellipse("fill", self.x - 6, self.y - 3, 4, 7)
    love.graphics.ellipse("fill", self.x + 6, self.y - 3, 4, 7)
end

return Alien
