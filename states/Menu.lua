local Gamestate = require("lib.hump.gamestate")
local Play = require("states.Play")
local Settings = require("objects.settings")

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

    self.settingsSelected = 1

    self.settingsButtons = {
        "Music Volume",
        "SFX Volume",
        "Back to Menu"
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
        love.graphics.printf("SETTINGS", 0, 200, love.graphics.getWidth(), "center")

        local items = {
            "Music Volume: " .. math.floor(Settings.musicVolume * 100) .. "%",
            "SFX Volume: " .. math.floor(Settings.sfxVolume * 100) .. "%",
            "Back to Menu"
        }

        for i, text in ipairs(items) do
            local y = 260 + i * 55

            if self.settingsSelected == i then
                love.graphics.printf("> " .. text .. " <", 0, y, love.graphics.getWidth(), "center")
            else
                love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
            end
        end

        love.graphics.printf("W/S = Select | A/D = Change | ENTER = Choose", 0, 600, love.graphics.getWidth(), "center")    
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
        if key == "w" or key == "up" then
            self.settingsSelected = self.settingsSelected - 1

            if self.settingsSelected < 1 then
                self.settingsSelected = #self.settingsButtons
            end

            self:playSelectSound()

        elseif key == "s" or key == "down" then
            self.settingsSelected = self.settingsSelected + 1

            if self.settingsSelected > #self.settingsButtons then
                self.settingsSelected = 1
            end

            self:playSelectSound()

        elseif key == "a" or key == "left" then
            if self.settingsSelected == 1 then
                Settings.musicVolume = math.max(0, Settings.musicVolume - 0.1)
            elseif self.settingsSelected == 2 then
                Settings.sfxVolume = math.max(0, Settings.sfxVolume - 0.1)
                self.selectSound:setVolume(Settings.sfxVolume)
            end

            self:playSelectSound()

        elseif key == "d" or key == "right" then
            if self.settingsSelected == 1 then
                Settings.musicVolume = math.min(1, Settings.musicVolume + 0.1)
            elseif self.settingsSelected == 2 then
                Settings.sfxVolume = math.min(1, Settings.sfxVolume + 0.1)
                self.selectSound:setVolume(Settings.sfxVolume)
            end

            self:playSelectSound()

        elseif key == "return" then
            if self.settingsSelected == 3 then
                self.mode = "menu"
            end

            self:playSelectSound()

        elseif key == "escape" then
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