local Gamestate = require("lib.hump.gamestate")
local Play = require("states.Play")

local Menu = {}

function Menu:enter()
    self.mode = "menu"
    self.selected = 1
    self.font = love.graphics.newFont("assets/bit.ttf", 36)
    self.bg = love.graphics.newImage("assets/backgrounds/background.png")

    self.buttons = {
        "New Game",
        "LeaderBoard",
        "Exit"
    }

    self.scores = {}

    self.selectSound = love.audio.newSource("assets/sfx/menu.wav", "static")
    self.selectSound:setVolume(0.6)
end

function Menu:loadScores()
    self.scores = {}

    if not love.filesystem.getInfo("leaderboard.txt") then
        return
    end

    for line in love.filesystem.lines("leaderboard.txt") do
        table.insert(self.scores, line)
    end
end

function Menu:draw()
    love.graphics.draw(self.bg, 0, 0)
    love.graphics.printf("THE DIMENSIONAL TRAVELER", 0, 120, love.graphics.getWidth(), "center")
    love.graphics.setFont(self.font)
    if self.mode == "menu" then
        for i, text in ipairs(self.buttons) do
            local y = 220 + i * 60

            if self.selected == i then
                love.graphics.printf("> " .. text .. " <", 0, y, love.graphics.getWidth(), "center")
            else
                love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
            end
        end

        love.graphics.printf("Use W/S and ENTER", 0, 600, love.graphics.getWidth(), "center")

    elseif self.mode == "leaderboard" then
        love.graphics.printf("LEADERBOARD", 0, 200, love.graphics.getWidth(), "center")

        if #self.scores == 0 then
            love.graphics.printf("No scores yet.", 0, 260, love.graphics.getWidth(), "center")
        else
            for i, score in ipairs(self.scores) do
                love.graphics.printf(score, 0, 240 + i * 35, love.graphics.getWidth(), "center")
            end
        end

        love.graphics.printf("Press ESC to return", 0, 520, love.graphics.getWidth(), "center")
    end
end

function Menu:keypressed(key)
    if self.mode == "leaderboard" then
        if key == "escape" then
            self.mode = "menu"
            self:playSelectSound()
        end
        return
    end

    if key == "w" or key == "up" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #self.buttons
        end
        self:playSelectSound()

    elseif key == "s" or key == "down" then
        self.selected = self.selected + 1
        if self.selected > #self.buttons then
            self.selected = 1
        end
        self:playSelectSound()

    elseif key == "return" or key == "kpenter" then
        self:playSelectSound()

        if self.selected == 1 then
            Gamestate.switch(Play, { level = 1 })

        elseif self.selected == 2 then
            self:loadScores()
            self.mode = "leaderboard"

        elseif self.selected == 3 then
            love.event.quit()
        end
    end
end

function Menu:playSelectSound()
    if self.selectSound then
        self.selectSound:stop()
        self.selectSound:play()
    end
end

return Menu