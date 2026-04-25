local UIMenu = {}

function UIMenu.new(items)
    return {
        items = items,
        selected = 1
    }
end

function UIMenu:moveUp()
    self.selected = self.selected - 1

    if self.selected < 1 then
        self.selected = #self.items
    end
end

function UIMenu:moveDown()
    self.selected = self.selected + 1

    if self.selected > #self.items then
        self.selected = 1
    end
end

function UIMenu:draw(startY, spacing)
    for i, item in ipairs(self.items) do
        local y = startY + i * spacing
        local text = item.text

        if self.selected == i then
            text = "> " .. text .. " <"
        end

        love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
    end
end

function UIMenu:keypressed(key)
    if key == "w" or key == "up" then
        self:moveUp()
        return "move"

    elseif key == "s" or key == "down" then
        self:moveDown()
        return "move"

    elseif key == "return" then
        return "select", self.items[self.selected]
    end

    return nil
end

return UIMenu