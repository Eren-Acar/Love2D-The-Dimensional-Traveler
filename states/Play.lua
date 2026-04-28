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
local DeadZone = require("objects.DeadZone")

local GameOver = require("states.GameOver")
local Win = require("states.Win")

local Play = {}

local function getPauseState()
    return require("states.Pause")
end

local function beginContact(a, b, collision)
    if Coin.beginContact(a, b, collision) then return end
    if Spike.beginContact(a, b, collision) then return end
    if DeadZone.beginContact(a, b, collision) then return end
    Enemy.beginContact(a, b, collision)
    Player:beginContact(a, b, collision)
end

local function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end

function Play:loadMusic()
    if self.music == nil then
        Audio:playMusic("assets/sfx/main_theme.wav")
    end
end

function Play:loadLevel(params)
    Enemy.loadAssets()
    Map:load(params.level)
    World:setCallbacks(beginContact, endContact)
end

function Play:loadPlayer(params)
    Player:load()
    Player.coins = params.coins or 0
end

function Play:loadUI()
    GUI:load()
    self.font = love.graphics.newFont("assets/bit.ttf", 16)
end

function Play:resetState(params)
    self.timer = params.time or 0
    self.paused = false
    self.gameEnded = false
end


function Play:enter(params)
    params = params or {}

    self:loadMusic()
    self:resetState(params)
    self:loadLevel(params)
    self:loadUI()
    self:loadPlayer(params)
end

function Play:updateTimer(dt)
    self.timer = self.timer + dt
    GUI.time = self.timer
end

function Play:updateWorld(dt)
    Audio:updateVolumes()
    World:update(dt)
end

function Play:updateEntities(dt)
    Player:update(dt)
    Enemy.checkBulletHits(Player.bullets)

    Boss.updateAll(dt)
    Coin.updateAll(dt)
    Spike.updateAll(dt)
    DeadZone.updateAll(dt)
    Enemy.updateAll(dt)
end

function Play:updateSystems(dt)
    GUI:update(dt)
    Camera:setPosition(Player.x, Player.y)
    Map:update()
end

function Play:goToGameOver()
    self.gameEnded = true

    Gamestate.switch(GameOver, {
        coins = Player.coins,
        level = Map.currentLevel,
        time = self.timer
    })
end

function Play:goToWin()
    Boss.defeated = false

    Gamestate.switch(Win, {
        coins = Player.coins,
        time = self.timer
    })
end

function Play:checkGameOver()
    if Player.dead and not self.gameEnded then
        self:goToGameOver()
        return true
    end

    return false
end

function Play:checkLevelCompleted()
    if Map.completed or Boss.defeated then
        self:goToWin()
        return true
    end

    return false
end

function Play:update(dt)
    if self.paused then
        return
    end

    self:updateTimer(dt)
    self:updateWorld(dt)
    self:updateEntities(dt)
    self:updateSystems(dt)

    if self:checkGameOver() then return end
    if self:checkLevelCompleted() then return end
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

function Play:drawTutorial()
    if Map.currentLevel == 1 then
        love.graphics.setFont(self.font)
        love.graphics.print(
            "A / D - Move   \nW - Jump   S - Crouch   \nRight Click - Shoot\nBEAT THE BOSS!!!",
            170,
            141.6
        )
    end
end

function Play:drawWorld()
    Map:draw()

    Camera:apply()

    self:drawTutorial()

    Player:draw()
    Enemy.drawAll()
    Boss.drawAll()
    Coin.drawAll()
    Spike.drawAll()

    Camera:clear()
end

function Play:drawPause()
    if not self.paused then
        return
    end

    local Pause = getPauseState()
    Pause:draw()
end

function Play:draw()
    self:drawWorld()
    GUI:draw()
    self:drawPause()
end

function Play:pauseGame()
    self.paused = true
    Audio:setPausedMuffle(true)

    local Pause = getPauseState()
    Pause:enter()
end

function Play:resumeGame()
    self.paused = false
    Audio:setPausedMuffle(false)
end

function Play:handlePausedInput(key)
    if key == "escape" then
        self:resumeGame()
        return
    end

    local Pause = getPauseState()
    Pause:keypressed(key, self)
end

function Play:keypressed(key)
    if self.paused then
        self:handlePausedInput(key)
        return
    end

    if key == "escape" then
        self:pauseGame()
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