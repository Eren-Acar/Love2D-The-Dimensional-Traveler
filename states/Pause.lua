local Gamestate = require("lib.hump.gamestate")
local Play = require("states.Play")

local Pause = {}

function Pause:draw()
    love.graphics.printf("PAUSED", 0, 220, love.graphics.getWidth(), "center")
    love.graphics.printf("Press ESC to continue", 0, 260, love.graphics.getWidth(), "center")
end

function Pause:keypressed(key)
    if key == "escape" then
        Gamestate.switch(Play)
    end
end

return Pause