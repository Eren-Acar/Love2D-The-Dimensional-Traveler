local Gamestate = require("lib.hump.gamestate")

local GameOver = {}

function GameOver:enter(data)
    data = data or {}

    self.bg = love.graphics.newImage("assets/backgrounds/background.png")

    self.coins = data.coins or 0
    self.level = data.level or 1
    self.time = data.time or 0
end

function GameOver:draw()
    love.graphics.draw(self.bg, 0, 0)
    love.graphics.printf("GAME OVER", 0, 200, love.graphics.getWidth(), "center")
    love.graphics.printf("Coins: " .. tostring(self.coins), 0, 240, love.graphics.getWidth(), "center")
    love.graphics.printf("Level: " .. tostring(self.level), 0, 280, love.graphics.getWidth(), "center")
    love.graphics.printf("Time: " .. tostring(math.floor(self.time)), 0, 320, love.graphics.getWidth(), "center")
    love.graphics.printf("R = Restart | M = Menu", 0, 360, love.graphics.getWidth(), "center")
end

function GameOver:keypressed(key)
    if key == "r" then
        local Play = require("states.Play")

        local restartTime = 0
        local restartCoins = 0

        if self.level == 2 then
            restartTime = self.time
        end

        Gamestate.switch(Play, {
            level = self.level,
            time = restartTime,
            coins = restartCoins
        })

    elseif key == "m" then
        local Menu = require("states.Menu")
        Gamestate.switch(Menu)
    end
end

return GameOver