local Gamestate = require("lib.hump.gamestate")
local Play = require("states.Play")
local Menu = require("states.Menu")
local Settings = require("objects.Settings")

local Pause = {}

function Pause:enter()
    self.selected = 1

    self.buttons = {
        "Continue",
        "Settings",
        "Back to Menu"
    }

    self.settingsMode = false
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
        Settings:draw()    
    end
end

function Pause:keypressed(key)
    if self.settingsMode then
        local result = Settings:keypressed(key)

        if result == "back" then
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