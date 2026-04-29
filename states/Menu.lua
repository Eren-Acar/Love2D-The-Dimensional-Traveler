local Gamestate = require("lib.hump.gamestate")
local Play = require("states.Play")
local Settings = require("objects.Settings")
local Audio = require("objects.Audio")
local Camera = require("objects.Camera")

local Menu = {}

function Menu:enter()
    Camera.x = 0
    Camera.y = 0
    
    self.mode = "menu"
    self.selected = 1
    self.font = love.graphics.newFont("assets/bit.ttf", 36)
    self.backgroundLayers = {
        love.graphics.newImage("assets/backgrounds/menu_backgrounds/layer1.png"),
        love.graphics.newImage("assets/backgrounds/menu_backgrounds/layer2.png"),
        love.graphics.newImage("assets/backgrounds/menu_backgrounds/layer3.png")
    }

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

end

function Menu:drawParallax()
    love.graphics.origin()

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    for i, img in ipairs(self.backgroundLayers) do
        local scale = math.max(
            screenW / img:getWidth(),
            screenH / img:getHeight()
        )

        local imgW = img:getWidth() * scale
        local speed = i / #self.backgroundLayers

        local x = 0

        if Camera then
            x = -(Camera.x * speed) % imgW
        end

        love.graphics.draw(img, x, -175, 0, scale, scale)
        love.graphics.draw(img, x - imgW, 0, 0, scale, scale)
        love.graphics.draw(img, x + imgW, 0, 0, scale, scale)
    end
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
    self:drawParallax()

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
            local maxScores = math.min(5, #self.scores)

            for i = 1, maxScores do
                local score = self.scores[i]
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

        if result == "change" then
            Audio:updateVolumes()
        end

        if result then
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
    Audio:playSfx("assets/sfx/menu.wav")
end

return Menu