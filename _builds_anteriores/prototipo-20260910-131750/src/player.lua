local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.radius = 20
    self.speed = 240
    self.baseSpeed = 240
    self.facingX = 1
    self.facingY = 0
    self.hp = 100
    self.maxHp = 100
    self.rage = 0
    self.maxRage = 100
    self.damage = 1

    self.attackTimer = 0
    self.attackDuration = 0.18
    self.attackCooldown = 0

    self.dashTimer = 0
    self.dashCooldown = 0

    self.berserk = false
    self.berserkTimer = 0
    return self
end

function Player:update(dt)
    self.attackTimer = math.max(0, self.attackTimer - dt)
    self.attackCooldown = math.max(0, self.attackCooldown - dt)
    self.dashTimer = math.max(0, self.dashTimer - dt)
    self.dashCooldown = math.max(0, self.dashCooldown - dt)

    if self.berserk then
        self.berserkTimer = self.berserkTimer - dt
        if self.berserkTimer <= 0 then
            self.berserk = false
            self.damage = 1
            self.speed = self.baseSpeed
        end
    end

    local dx, dy = 0, 0
    if love.keyboard.isDown("a") then dx = dx - 1 end
    if love.keyboard.isDown("d") then dx = dx + 1 end
    if love.keyboard.isDown("w") then dy = dy - 1 end
    if love.keyboard.isDown("s") then dy = dy + 1 end

    if dx ~= 0 or dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx, dy = dx / len, dy / len
        self.facingX, self.facingY = dx, dy
    end

    local currentSpeed = self.speed
    if self.dashTimer > 0 then currentSpeed = 620 end

    self.x = math.max(55, math.min(1225, self.x + dx * currentSpeed * dt))
    self.y = math.max(85, math.min(635, self.y + dy * currentSpeed * dt))
end

function Player:attack()
    if self.attackCooldown <= 0 then
        self.attackTimer = self.attackDuration
        self.attackCooldown = self.berserk and 0.15 or 0.28
    end
end

function Player:dash()
    if self.dashCooldown <= 0 then
        self.dashTimer = 0.12
        self.dashCooldown = 0.8
    end
end

function Player:addRage(amount)
    if self.berserk then return end
    self.rage = math.min(self.maxRage, self.rage + amount)
end

function Player:activateBerserk()
    if self.rage >= self.maxRage and not self.berserk then
        self.berserk = true
        self.berserkTimer = 5
        self.rage = 0
        self.damage = 2
        self.speed = 300
    end
end

function Player:isAttackActive()
    return self.attackTimer > 0
end

function Player:getAttackBox()
    local reach = 58
    local size = 54
    return {
        x = self.x + self.facingX * reach - size / 2,
        y = self.y + self.facingY * reach - size / 2,
        w = size,
        h = size,
    }
end

function Player:draw()
    if self.berserk then
        love.graphics.setColor(1, 0.35, 0.1)
    else
        love.graphics.setColor(0.85, 0.72, 0.42)
    end
    love.graphics.circle("fill", self.x, self.y, self.radius)

    love.graphics.setColor(0.35, 0.2, 0.08)
    love.graphics.rectangle("fill", self.x - 23, self.y - 26, 46, 7)

    love.graphics.setColor(0.85, 0.85, 0.9)
    love.graphics.setLineWidth(5)
    love.graphics.line(
        self.x + self.facingX * 20,
        self.y + self.facingY * 20,
        self.x + self.facingX * 50,
        self.y + self.facingY * 50
    )

    if self:isAttackActive() then
        local box = self:getAttackBox()
        love.graphics.setColor(1, 1, 1, 0.15)
        love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    end
end

return Player
