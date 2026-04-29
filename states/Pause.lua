local Gamestate = require("lib.hump.gamestate")
local Play = require("states.Play")
local Menu = require("states.Menu")
local Settings = require("objects.Settings")
local Audio = require("objects.Audio")
local Camera = require("objects.Camera")

local Pause = {}

function Pause:enter()
    self.backgroundLayers = {
        love.graphics.newImage("assets/backgrounds/menu_backgrounds/layer1.png"),
        love.graphics.newImage("assets/backgrounds/menu_backgrounds/layer2.png"),
        love.graphics.newImage("assets/backgrounds/menu_backgrounds/layer3.png")
    }
    self.selected = 1

    self.buttons = {
        "Continue",
        "Settings",
        "Back to Menu"
    }

    self.settingsMode = false
end

function Pause:drawParallax()
    love.graphics.origin()

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    local yOffset = -175

    for i, img in ipairs(self.backgroundLayers) do
        local scale = math.max(
            screenW / img:getWidth(),
            screenH / img:getHeight()
        )

        local imgW = img:getWidth() * scale
        local speed = i / #self.backgroundLayers

        local cameraX = 0
        if Camera and Camera.x then
            cameraX = Camera.x
        end

        local x = -(cameraX * speed) % imgW

        love.graphics.draw(img, x - imgW, yOffset, 0, scale, scale)
        love.graphics.draw(img, x, yOffset, 0, scale, scale)
        love.graphics.draw(img, x + imgW, yOffset, 0, scale, scale)
    end
end

function Pause:draw()
    self:drawParallax()

    love.graphics.printf("PAUSED", 0, 140, love.graphics.getWidth(), "center")

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

function Pause:keypressed(key, play)
    if self.settingsMode then
        local result = Settings:keypressed(key)

        if result == "change" then
            Audio:updateVolumes()
        elseif result == "back" then
            self.settingsMode = false
        end

        return
    end

    if key == "w" or key == "up" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #self.buttons
        end
        Audio:playSfx("assets/sfx/menu.wav")

    elseif key == "s" or key == "down" then
        self.selected = self.selected + 1
        if self.selected > #self.buttons then
            self.selected = 1
        end
        Audio:playSfx("assets/sfx/menu.wav")

    elseif key == "return" then
        Audio:playSfx("assets/sfx/menu.wav")

        if self.selected == 1 then
            play.paused = false

        elseif self.selected == 2 then
            self.settingsMode = true

        elseif self.selected == 3 then
            Gamestate.switch(Menu)
        end
    end
end

return Pause