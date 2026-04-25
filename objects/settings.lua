local Settings = {}

Settings.musicVolume = 0.3
Settings.sfxVolume = 0.6
Settings.selected = 1

Settings.items = {
    "Music Volume",
    "SFX Volume",
    "Back"
}

function Settings:draw()
    love.graphics.printf("SETTINGS", 0, 200, love.graphics.getWidth(), "center")

    local texts = {
        "Music Volume: " .. math.floor(self.musicVolume * 100) .. "%",
        "SFX Volume: " .. math.floor(self.sfxVolume * 100) .. "%",
        "Back"
    }

    for i, text in ipairs(texts) do
        local y = 260 + i * 55

        if self.selected == i then
            text = "> " .. text .. " <"
        end

        love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
    end

    love.graphics.printf("W/S = Select | A/D = Change | ENTER = Choose", 0, 600, love.graphics.getWidth(), "center")
end

function Settings:apply()
    love.audio.setVolume(self.musicVolume)
end

function Settings:keypressed(key)
    if key == "w" or key == "up" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #self.items
        end
        return "move"

    elseif key == "s" or key == "down" then
        self.selected = self.selected + 1
        if self.selected > #self.items then
            self.selected = 1
        end
        return "move"

    elseif key == "a" or key == "left" then
        if self.selected == 1 then
            self.musicVolume = math.max(0, self.musicVolume - 0.1)
            self:apply()
        elseif self.selected == 2 then
            self.sfxVolume = math.max(0, self.sfxVolume - 0.1)
            self:apply()
        end
        return "change"

    elseif key == "d" or key == "right" then
        if self.selected == 1 then
            self.musicVolume = math.min(1, self.musicVolume + 0.1)
            self:apply()
        elseif self.selected == 2 then
            self.sfxVolume = math.min(1, self.sfxVolume + 0.1)
            self:apply()
        end
        return "change"

    elseif key == "return" then
        if self.selected == 3 then
            return "back"
        end

    elseif key == "escape" then
        return "back"
    end

    return nil
end

return Settings