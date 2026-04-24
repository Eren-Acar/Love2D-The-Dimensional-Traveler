local Gamestate = require("lib.hump.gamestate")


local Win = {}

function Win:enter(data)
    self.bg = love.graphics.newImage("assets/backgrounds/background.png")
    data = data or {}

    self.coins = data.coins or 0
    self.time = data.time or 0
    self.total = math.floor(self.time) - self.coins

    self:saveScore()
end

function Win:saveScore()
    local totalSeconds = math.floor(self.time)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60

    local line = string.format(
        "Time: %02d:%02d | Coins: %d | Total: %d",
        minutes,
        seconds,
        self.coins,
        self.total
    )

    -- it stores on C:\Users\Eren Acar\AppData\Roaming\LOVE\DimensionalTraveler\
    love.filesystem.append("leaderboard.txt", line .. "\n")
end

function Win:draw()
    love.graphics.draw(self.bg, 0, 0)
    local totalSeconds = math.floor(self.time)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60

    love.graphics.printf("YOU WIN", 0, 180, love.graphics.getWidth(), "center")
    love.graphics.printf(string.format("Time: %02d:%02d", minutes, seconds), 0, 240, love.graphics.getWidth(), "center")
    love.graphics.printf("Coins: " .. tostring(self.coins), 0, 280, love.graphics.getWidth(), "center")
    love.graphics.printf("Total: " .. tostring(self.total), 0, 320, love.graphics.getWidth(), "center")
    love.graphics.printf("Press M for Menu", 0, 400, love.graphics.getWidth(), "center")
end

function Win:keypressed(key)
    if key == "m" then
        Gamestate.switch(require("states.Menu"))
    end
end

return Win