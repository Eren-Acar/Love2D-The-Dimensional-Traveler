local Gamestate = require("lib.hump.gamestate")

local Player = require("objects.Player")
local Coin = require("objects.Coin")
local GUI = require("objects.Gui")
local Spike = require("objects.spike")
local Camera = require("objects.Camera")
local Enemy = require("objects.Enemy")
local Map = require("objects.Map")
local Boss = require("objects.Boss")
local Audio = require("objects.Audio")

local GameOver = require("states.GameOver")
local Win = require("states.Win")

local Play = {}

local function beginContact(a, b, collision)
    if Coin.beginContact(a, b, collision) then return end
    if Spike.beginContact(a, b, collision) then return end
    Enemy.beginContact(a, b, collision)
    Player:beginContact(a, b, collision)
end

local function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end

function Play:enter(params)
    params = params or {}

    if self.music == nil then
        Audio:playMusic("assets/sfx/Hydrogen.ogg")
    end

    self.timer = params.time or 0

    Enemy.loadAssets()
    Map:load(params.level)

    World:setCallbacks(beginContact, endContact)

    self.paused = false
    self.gameEnded = false

    GUI:load()
    Player:load()
    Player.coins = params.coins or 0
end

function Play:update(dt)
    if self.paused then
        return
    end

    self.timer = self.timer + dt
    GUI.time = self.timer

    Audio:updateVolumes()

    World:update(dt)

    Player:update(dt)
    Enemy.checkBulletHits(Player.bullets)
    Boss.updateAll(dt)

    Coin.updateAll(dt)
    Spike.updateAll(dt)

    Enemy.updateAll(dt)
    GUI:update(dt)
    Camera:setPosition(Player.x, Player.y)
    Map:update()

    if Player.dead and not self.gameEnded then
        self.gameEnded = true
        Gamestate.switch(GameOver, {
    coins = Player.coins,
    level = Map.currentLevel,
    time = self.timer
})
        return
    end

    if Map.completed or Boss.defeated then
        Boss.defeated = false

        Gamestate.switch(Win, {
            coins = Player.coins,
            time = self.timer
        })

        return
    end
end

function Play:drawParallax()
    local camX = Camera.x
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    local layers = self.currentBG
    local total = #layers

    local function drawLayer(img, speed)
        local scale = math.max(
            screenW / img:getWidth(),
            screenH / img:getHeight()
        )

        local imgW = img:getWidth() * scale
        local x = -(camX * speed) % imgW

        love.graphics.draw(img, x, 0, 0, scale, scale)
        love.graphics.draw(img, x - imgW, 0, 0, scale, scale)
        love.graphics.draw(img, x + imgW, 0, 0, scale, scale)
    end

    for i = 1, total do
        local speed = i / total
        drawLayer(layers[i], speed)
    end
end

function Play:draw()
    Map:draw()

    Camera:apply()
    Player:draw()
    Enemy.drawAll()
    Boss.drawAll()
    Coin.drawAll()
    Spike.drawAll()
    Camera:clear()

    GUI:draw()

    if self.paused then
        local Pause = require("states.Pause")
        Pause:draw()
    end
end

function Play:keypressed(key)
    if self.paused then
        local Pause = require("states.Pause")

        if key == "escape" then
            self.paused = false
            return
        end

        Pause:keypressed(key, self)
        return
    end

    if key == "escape" then
        self.paused = true

        local Pause = require("states.Pause")
        Pause:enter()
        return
    end

    Player:jump(key)
end

function Play:mousepressed(x, y, button)
    if self.paused then
        return
    end

    if button == 1 then 
        Player:shoot()
    end
end

return Play