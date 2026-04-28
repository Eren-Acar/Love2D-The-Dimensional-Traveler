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

function Audio:load()
    love.audio.setEffect("pause_muffle", {
        type = "equalizer",
        
        lowgain = 1.2,
        highgain = 0.2
    })
end

function Audio:setPausedMuffle(enabled)
    if not self.music then return end

    if enabled then
        self.music:setVolume(Settings.musicVolume * 0.2)
        self.sfxMultiplier = 0.3
    else
        self.music:setVolume(Settings.musicVolume)
        self.sfxMultiplier = 1
    end
end

return Audio