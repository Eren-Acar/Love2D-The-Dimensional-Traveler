local Gamestate = require("lib.hump.gamestate")
local Play = require("states.Play")
local Menu = require("states.Menu")

local Pause = {}

function Pause:enter()
    self.selected = 1

    self.buttons = {
        "Continue",
        "Settings",
        "Back to Menu"
    }

    self.settingsMode = false
    self.settingsSelected = 1

    self.musicVolume = self.musicVolume or 0.3
    self.sfxVolume = self.sfxVolume or 0.6
end

function Pause:draw()
    love.graphics.printf("PAUSED", 0, 180, love.graphics.getWidth(), "center")

    if not self.settingsMode then
        for i, text in ipairs(self.buttons) do
            local y = 240 + i * 50

            if self.selected == i then
                love.graphics.printf("> " .. text .. " <", 0, y, love.graphics.getWidth(), "center")
            else
                love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
            end
        end

        love.graphics.printf("W/S = Select | ENTER = Choose", 0, 560, love.graphics.getWidth(), "center")
    else
        love.graphics.printf("SETTINGS", 0, 240, love.graphics.getWidth(), "center")

        local items = {
            "Music Volume: " .. math.floor(self.musicVolume * 100) .. "%",
            "SFX Volume: " .. math.floor(self.sfxVolume * 100) .. "%",
            "Back"
        }

        for i, text in ipairs(items) do
            local y = 290 + i * 45

            if self.settingsSelected == i then
                love.graphics.printf("> " .. text .. " <", 0, y, love.graphics.getWidth(), "center")
            else
                love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
            end
        end

        love.graphics.printf("A/D = Change | ENTER = Choose", 0, 560, love.graphics.getWidth(), "center")
    end
end

function Pause:keypressed(key)
    if self.settingsMode then
        if key == "w" or key == "up" then
            self.settingsSelected = self.settingsSelected - 1
            if self.settingsSelected < 1 then
                self.settingsSelected = 3
            end

        elseif key == "s" or key == "down" then
            self.settingsSelected = self.settingsSelected + 1
            if self.settingsSelected > 3 then
                self.settingsSelected = 1
            end

        elseif key == "a" or key == "left" then
            if self.settingsSelected == 1 then
                self.musicVolume = math.max(0, self.musicVolume - 0.1)
            elseif self.settingsSelected == 2 then
                self.sfxVolume = math.max(0, self.sfxVolume - 0.1)
            end

        elseif key == "d" or key == "right" then
            if self.settingsSelected == 1 then
                self.musicVolume = math.min(1, self.musicVolume + 0.1)
            elseif self.settingsSelected == 2 then
                self.sfxVolume = math.min(1, self.sfxVolume + 0.1)
            end

        elseif key == "return" then
            if self.settingsSelected == 3 then
                self.settingsMode = false
            end

        elseif key == "escape" then
            self.settingsMode = false
        end

        return
    end

    if key == "w" or key == "up" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #self.buttons
        end

    elseif key == "s" or key == "down" then
        self.selected = self.selected + 1
        if self.selected > #self.buttons then
            self.selected = 1
        end

    elseif key == "return" then
        if self.selected == 1 then
            Gamestate.switch(Play)

        elseif self.selected == 2 then
            self.settingsMode = true

        elseif self.selected == 3 then
            Gamestate.switch(Menu)
        end

    elseif key == "escape" then
        Gamestate.switch(Play)
    end
end

return Pause