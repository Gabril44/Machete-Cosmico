local Player = require("src.player")
local Alien = require("src.alien")
local Cow = require("src.cow")

local game = {
    state = "playing",
    aliens = {},
    cows = {},
    score = 0,
    message = "Protegé la chacra",
    messageTimer = 3,
    spawnTimer = 0,
}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    game.player = Player.new(640, 420)

    game.cows = {
        Cow.new(260, 220),
        Cow.new(980, 220),
        Cow.new(330, 540),
    }

    for i = 1, 4 do
        spawnAlien()
    end
end

function love.update(dt)
    if game.state ~= "playing" then return end

    game.player:update(dt)

    game.spawnTimer = game.spawnTimer - dt
    if game.spawnTimer <= 0 and #game.aliens < 6 then
        spawnAlien()
        game.spawnTimer = 2.5
    end

    for i = #game.aliens, 1, -1 do
        local alien = game.aliens[i]
        alien:update(dt, game.player, game.cows)

        if game.player:isAttackActive() and alien:isInsideAttack(game.player:getAttackBox()) then
            if not alien.wasHitThisSwing then
                alien:takeDamage(game.player.damage, game.player.x, game.player.y)
                alien.wasHitThisSwing = true
                game.player:addRage(10)
            end
        else
            alien.wasHitThisSwing = false
        end

        if alien.dead then
            table.remove(game.aliens, i)
            game.score = game.score + 100
        end
    end

    for _, cow in ipairs(game.cows) do
        cow:update(dt)
    end

    if game.messageTimer > 0 then
        game.messageTimer = game.messageTimer - dt
    end
end

function love.draw()
    drawFarm()

    for _, cow in ipairs(game.cows) do
        cow:draw()
    end

    for _, alien in ipairs(game.aliens) do
        alien:draw()
    end

    game.player:draw()
    drawHud()
end

function love.keypressed(key)
    if key == "space" then
        game.player:attack()
    elseif key == "lshift" then
        game.player:dash()
    elseif key == "f" then
        game.player:activateBerserk()
    elseif key == "r" then
        love.event.quit("restart")
    end
end

function spawnAlien()
    local side = love.math.random(4)
    local x, y

    if side == 1 then
        x, y = love.math.random(80, 1200), 70
    elseif side == 2 then
        x, y = 1210, love.math.random(90, 650)
    elseif side == 3 then
        x, y = love.math.random(80, 1200), 650
    else
        x, y = 70, love.math.random(90, 650)
    end

    table.insert(game.aliens, Alien.new(x, y))
end

function drawFarm()
    love.graphics.clear(0.08, 0.11, 0.08)

    love.graphics.setColor(0.16, 0.22, 0.12)
    love.graphics.rectangle("fill", 40, 70, 1200, 580, 16, 16)

    love.graphics.setColor(0.3, 0.21, 0.12)
    love.graphics.rectangle("fill", 460, 100, 360, 150, 10, 10)

    love.graphics.setColor(0.15, 0.35, 0.12)
    for y = 300, 610, 36 do
        for x = 110, 360, 42 do
            love.graphics.circle("fill", x, y, 8)
        end
    end

    love.graphics.setColor(0.8, 0.75, 0.5)
    love.graphics.print("HUERTA", 190, 270)
end

function drawHud()
    local p = game.player

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("MACHETE CÓSMICO - PROTOTIPO", 20, 18)
    love.graphics.print("WASD mover | ESPACIO machete | SHIFT dash | F berserk", 20, 42)
    love.graphics.print("Puntos: " .. game.score, 1080, 20)

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 20, 670, 250, 18)
    love.graphics.setColor(0.8, 0.15, 0.15)
    love.graphics.rectangle("fill", 20, 670, 250 * (p.hp / p.maxHp), 18)

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 290, 670, 250, 18)
    love.graphics.setColor(0.8, 0.45, 0.1)
    love.graphics.rectangle("fill", 290, 670, 250 * (p.rage / p.maxRage), 18)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("VIDA", 20, 646)
    love.graphics.print("FURIA", 290, 646)

    if game.messageTimer > 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(game.message, 0, 90, 1280, "center")
    end
end
