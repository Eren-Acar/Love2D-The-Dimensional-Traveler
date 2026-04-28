local Gamestate = require("lib.hump.gamestate")

local Menu = require("states.Menu")
local Audio = require("objects.Audio")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Audio:load()
    Gamestate.switch(Menu)
end

function love.update(dt)
    Gamestate.update(dt)
end

function love.draw()
    Gamestate.draw()
end

function love.keypressed(key)
    Gamestate.keypressed(key)
end

function love.mousepressed(x, y, button)
    Gamestate.mousepressed(x, y, button)
end