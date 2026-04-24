local Gamestate = { currentState = nil }

function Gamestate.switch(state, ...)
    Gamestate.currentState = state

    if state and state.enter then
        state:enter(...)
    end
end

function Gamestate.current()
    return Gamestate.currentState
end

function Gamestate.update(dt)
    local state = Gamestate.currentState

    if state and state.update then
        state:update(dt)
    end
end

function Gamestate.draw()
    local state = Gamestate.currentState

    if state and state.draw then
        state:draw()
    end
end

function Gamestate.keypressed(key)
    local state = Gamestate.currentState

    if state and state.keypressed then
        state:keypressed(key)
    end
end

function Gamestate.mousepressed(x, y, button)
    if Gamestate.currentState and Gamestate.currentState.mousepressed then
        Gamestate.currentState:mousepressed(x, y, button)
    end
end

return Gamestate