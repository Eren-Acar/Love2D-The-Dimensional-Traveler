local Gamestate = require("lib.hump.gamestate")

local Win = {}

function Win:enter(data)
    data = data or {}

    self.bg = love.graphics.newImage("assets/backgrounds/background.png")

    self.coins = data.coins or 0
    self.time = math.floor(data.time or 0)

    self:saveScore()
end

function Win:saveScore()
    local line = string.format("%d,%d", self.time, self.coins)

    love.filesystem.append("leaderboard.txt", line .. "\n")
end

function Win:formatTime(totalSeconds)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60

    return string.format("%02d:%02d", minutes, seconds)
end

function Win:draw()
    local screenW = love.graphics.getWidth()

    love.graphics.draw(self.bg, 0, 0)

    love.graphics.printf("YOU WIN", 0, 180, screenW, "center")
    love.graphics.printf("Time: " .. self:formatTime(self.time), 0, 240, screenW, "center")
    love.graphics.printf("Coins: " .. tostring(self.coins), 0, 280, screenW, "center")
    love.graphics.printf("Press M for Menu", 0, 360, screenW, "center")
end

function Win:keypressed(key)
    if key == "m" then
        Gamestate.switch(require("states.Menu"))
    end
end

return Win