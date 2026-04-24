local Gamestate = require("lib.hump.gamestate")

local Player = require("objects.player")
local Coin = require("objects.coin")
local GUI = require("objects.gui")
local Spike = require("objects.spike")
local Camera = require("objects.camera")
local Enemy = require("objects.enemy")
local Map = require("objects.map")
local Boss = require("objects.boss")

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
        self.music = love.audio.newSource("assets/sfx/Hydrogen.ogg", "stream")
        self.music:setLooping(true)
        self.music:setVolume(0.3)
        self.music:play()
    end

    self.timer = 0

    self.bg_sets = {
    level1 = {
        love.graphics.newImage("assets/backgrounds/forest/BACKGROUND.png"),
        love.graphics.newImage("assets/backgrounds/forest/WOODS - First.png"),
        love.graphics.newImage("assets/backgrounds/forest/WOODS - Second.png"),
        love.graphics.newImage("assets/backgrounds/forest/VINES - Second.png"),
        love.graphics.newImage("assets/backgrounds/forest/WOODS - Third.png"),
        love.graphics.newImage("assets/backgrounds/forest/WOODS - Fourth.png"),
        love.graphics.newImage("assets/backgrounds/forest/BUSH - BACKGROUND.png")
    },

    level2 = {
        love.graphics.newImage("assets/backgrounds/cave/cave7.png"),
        love.graphics.newImage("assets/backgrounds/cave/cave0.png"),
        love.graphics.newImage("assets/backgrounds/cave/cave1.png"),
        love.graphics.newImage("assets/backgrounds/cave/cave2.png"),
        love.graphics.newImage("assets/backgrounds/cave/cave3.png"),
        love.graphics.newImage("assets/backgrounds/cave/cave4.png"),
        love.graphics.newImage("assets/backgrounds/cave/cave5.png"),
        love.graphics.newImage("assets/backgrounds/cave/cave6.png"),
        
    }
}

    if Map.currentLevel == 1 then
        self.currentBG = self.bg_sets.level1
    else
        self.currentBG = self.bg_sets.level2
    end

    Enemy.loadAssets()
    Map:load(params.level)

    World:setCallbacks(beginContact, endContact)

    self.paused = false
    self.gameEnded = false

    GUI:load()
    Player:load()
end

function Play:update(dt)
    if self.paused then
        return
    end

    if self.paused then
        return
    end

    self.timer = self.timer + dt
    GUI.time = self.timer

    World:update(dt)

    Player:update(dt)
    Enemy.checkBulletHits(Player.bullets)
    Boss.updateAll(dt)

    Coin.updateAll(dt)
    Spike.updateAll(dt)

    Enemy.updateAll(dt)
    GUI:update(dt)
    Camera:setPosition(Player.x, 0)
    Map:update()

    local newLevel = Map.currentLevel == 1 and self.bg_sets.level1 or self.bg_sets.level2

    if self.currentBG ~= newLevel then
        self.currentBG = newLevel
    end

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
    self:drawParallax()

    Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

    Camera:apply()
    Player:draw()
    Enemy.drawAll()
    Boss.drawAll()
    Coin.drawAll()
    Spike.drawAll()

    Camera:clear()

    GUI:draw()

    if self.paused then
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("PAUSED", 0, 220, love.graphics.getWidth(), "center")
        love.graphics.printf("Press ESC to continue", 0, 260, love.graphics.getWidth(), "center")
    end
end

function Play:keypressed(key)
    if key == "escape" then
        self.paused = not self.paused
        return
    end

    if self.paused then
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