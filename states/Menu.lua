local Gamestate = require("lib.hump.gamestate")
local Play = require("states.Play")
local Settings = require("objects.Settings")

local Menu = {}

function Menu:enter()
    self.mode = "menu"
    self.selected = 1
    self.font = love.graphics.newFont("assets/bit.ttf", 36)
    self.bg = love.graphics.newImage("assets/backgrounds/background.png")

    self.buttons = {
        "New Game",
        "LeaderBoard",
        "Settings",
        "Exit"
    }

    self.scores = {}
    self.leaderboardSelected = 1

    self.leaderboardButtons = {
        "Reset Leaderboard",
        "Back to Menu"
    }

    self.selectSound = love.audio.newSource("assets/sfx/menu.wav", "static")
    self.selectSound:setVolume(0.6)
end

function Menu:loadScores()
    self.scores = {}

    if not love.filesystem.getInfo("leaderboard.txt") then
        return
    end

    for line in love.filesystem.lines("leaderboard.txt") do
        local time, coins = line:match("(%d+),(%d+)")

        if time and coins then
            table.insert(self.scores, {
                time = tonumber(time),
                coins = tonumber(coins)
            })
        end
    end

    table.sort(self.scores, function(a, b)
        if a.time == b.time then
            return a.coins > b.coins
        end

        return a.time < b.time
    end)
end

function Menu:draw()
    love.graphics.draw(self.bg, 0, 0)

    love.graphics.setFont(self.font)
    love.graphics.printf("THE DIMENSIONAL TRAVELER", 0, 120, love.graphics.getWidth(), "center")
    
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
                local minutes = math.floor(score.time / 60)
                local seconds = score.time % 60

                local text = string.format(
                    "%d) Time: %02d:%02d | Coins: %d",
                    i,
                    minutes,
                    seconds,
                    score.coins
                )

                love.graphics.printf(text, 0, 240 + i * 35, love.graphics.getWidth(), "center")
            end
        end

        for i, text in ipairs(self.leaderboardButtons) do
            local y = 500 + i * 45
            local displayText = text

            if self.leaderboardSelected == i then
                displayText = "> " .. text .. " <"
            end

            love.graphics.printf(displayText, 0, y, love.graphics.getWidth(), "center")
        end
    
    elseif self.mode == "settings" then
        Settings:draw()
    end
end

function Menu:keypressed(key)
    if self.mode == "leaderboard" then
        if key == "w" or key == "up" then
            self.leaderboardSelected = self.leaderboardSelected - 1

            if self.leaderboardSelected < 1 then
                self.leaderboardSelected = #self.leaderboardButtons
            end

            self:playSelectSound()

        elseif key == "s" or key == "down" then
            self.leaderboardSelected = self.leaderboardSelected + 1

            if self.leaderboardSelected > #self.leaderboardButtons then
                self.leaderboardSelected = 1
            end

            self:playSelectSound()

        elseif key == "return" then
            self:playSelectSound()

            if self.leaderboardSelected == 1 then
                love.filesystem.remove("leaderboard.txt")
                self.scores = {}

            elseif self.leaderboardSelected == 2 then
                self.mode = "menu"
            end

        elseif key == "escape" then
            self.mode = "menu"
            self:playSelectSound()
        end

        return
    end

    if self.mode == "settings" then
        local result = Settings:keypressed(key)

        if result == "back" then
            self.mode = "menu"
        end

        if result then
            self.selectSound:setVolume(Settings.sfxVolume)
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

    elseif key == "return" then
        self:playSelectSound()

        if self.selected == 1 then
            Gamestate.switch(Play, { level = 1 })

        elseif self.selected == 2 then
            self:loadScores()
            self.mode = "leaderboard"

        elseif self.selected == 3 then
            self.mode = "settings"
        
        elseif self.selected == 4 then
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