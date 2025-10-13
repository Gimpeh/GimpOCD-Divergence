local contextMenu = {}
local widgetsAreUs = require("lib.widgetsAreUs")
local c = require("lib.gimpColors")
local component = require("component")

contextMenu.remove = nil

local choiceHeight = 10

---@param x2 x
---@param y2 y
---@param funcTable funcTable
---@param funcTable.text contextMenuOptionText
---@param funcTable.func onClick
---@param funcTable.args args for onClick
function contextMenu.init(x2, y2, funcTable)
    --[[
    funcTable = {
        [1] = {text = "text", func = function, args = {args}},
        [2] = {text = "text", func = function, args = {args}},
            and so on
    ]]
        local x = math.floor(x2)
        local y = math.floor(y2)

        if contextMenu and contextMenu.elements then
            contextMenu.remove()
        end

        if not contextMenu.elements then contextMenu.elements = {} end
        contextMenu.elements.backgroundBox = widgetsAreUs.createBox(x, y, 100, 1, c.contextMenuBackground, 0.3)

        local i = 0
        for index, args in ipairs(funcTable) do
            local text = widgetsAreUs.text(x + 1, y + 1 + (choiceHeight * i), args.text, 1.0, c.contextMenuPrimaryColour)
            table.insert(contextMenu.elements, text)
            if i > 0 then
                local divisor = widgetsAreUs.createBox(x, y + (choiceHeight * i) - 1, 100, 1, c.contextMenuBackground, 0.3)
                table.insert(contextMenu.elements, divisor)
            end
            i = i + 1
        end
        contextMenu.elements.backgroundBox.setSize(i * choiceHeight, 150)
        contextMenu.funcTable = funcTable
end

function contextMenu.onClick(eventName, address, player, x, y, button)
        if eventName == "hud_click" and button == 0 and contextMenu.elements.backgroundBox then
            if contextMenu.elements.backgroundBox.contains(x, y) then
                local choice = math.floor((y - contextMenu.elements.backgroundBox.y) / choiceHeight) + 1
                local func = contextMenu.funcTable[choice].func
                local args = contextMenu.funcTable[choice].args
                contextMenu.remove()
                if args and args[1] then func(table.unpack(args))
                else func() end
            end
            return true
        end
end

function contextMenu.onClickRight(eventName, address, player, x, y, button)
        if eventName == "hud_click" and button == 1 then
            contextMenu.remove()
            return true
        end
end

function contextMenu.remove()
    local suc, err = pcall(function()
        contextMenu.elements.backgroundBox.remove()
        contextMenu.elements.backgroundBox = nil
        for i = #contextMenu.elements, 1, -1 do
            if contextMenu.elements[i].remove then contextMenu.elements[i].remove()
            elseif contextMenu.elements.getID then component.glasses.removeObject(contextMenu.elements.getID())
            table.remove(contextMenu.elements, i) end
        end
        contextMenu.elements = nil
        contextMenu.funcTable = nil
        return true
    end)
    if not suc then print(tostring(err)) end
end

function contextMenu.setVisible(bool)
    for k, v in ipairs(contextMenu.elements) do
        v.setVisible(bool)
    end
end

return contextMenu