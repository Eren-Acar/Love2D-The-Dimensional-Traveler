local Settings = require("objects.Settings")

local Audio = {}

Audio.music = nil

function Audio:playMusic(path)
    if not self.music then
        self.music = love.audio.newSource(path, "stream")
        self.music:setLooping(true)
        self.music:play()
    end

    self.music:setVolume(Settings.musicVolume)
end

function Audio:updateVolumes()
    if self.music then
        self.music:setVolume(Settings.musicVolume)
    end
end

function Audio:playSfx(path)
    local sfx = love.audio.newSource(path, "static")
    sfx:setVolume(Settings.sfxVolume)
    sfx:play()
end

return Audio