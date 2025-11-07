--[[
Yes I am aware of MVC. I am making a tactical decision not to employ it. Even though it is the correct design for this type of project.
]]

local event = require("event")
local contextMenu = require("GimpOCD-Divergence.lib.contextMenu")

local ui = {}

ui.init = function(dependencies)
    ui.inventoryManager = dependencies.inventoryManager
    ui.configurableWindows = dependencies.configurableWindows
    ui.powerDisplay = dependencies.powerDisplay

    ui.configurableWindows.init({x = dependencies.resolution.x, y = dependencies.resolution.y})
    ui.powerDisplay.init()
end

local onClick = function(eventName, address, player, x, y, button)
    if contextMenu.elements then
        if button == 0 then
            contextMenu.onClick(eventName, address, player, x, y, button)
        end
        contextMenu.remove()
    end
    if ui.inventoryManager and ui.inventoryManager.isActive() then
        if x >= ui.inventoryManager.x1 and x <= ui.inventoryManager.x2 and
           y >= ui.inventoryManager.y1 and y <= ui.inventoryManager.y2 then
            if button == 0 then
                ui.inventoryManager.onClick(eventName, address, player, x, y, button)
                return
            elseif button == 1 then
                ui.inventoryManager.onClickRight(eventName, address, player, x, y, button)
                return
            end
        end
    end
    if button == 0 and ui.configurableWindows and ui.configurableWindows.onClick then
        ui.configurableWindows.onClick(eventName, address, player, x, y, button)
        return
    elseif button == 1 and ui.configurableWindows and ui.configurableWindows.onClickRight then
        ui.configurableWindows.onClickRight(eventName, address, player, x, y, button)
        return
    end
end

local onDrag = function(eventName, address, player, x, y, button)
    if ui.configurableWindows and ui.configurableWindows.onDrag then
        if button ~= 0 then return end
        ui.configurableWindows.onDrag(eventName, address, player, x, y, button)
        return
    end
end

local hudOn = function()
    if ui.inventoryManager and ui.inventoryManager.isActive() then
        ui.inventoryManager.setVisible(true)
    end
    if ui.configurableWindows then
        ui.configurableWindows.setVisible(true)
    end
    ui.powerDisplay.setVisible(false)
end

local hudOff = function()
    if contextMenu.elements then
        contextMenu.remove()
    end
    if ui.inventoryManager and ui.inventoryManager.isActive() then
        ui.inventoryManager.setVisible(false)
    end
    if ui.configurableWindows then
        ui.configurableWindows.setVisible(false)
    end
    ui.powerDisplay.setVisible(true)
end

event.listen("hud_click", onClick)
event.listen("hud_drag", onDrag)
event.listen("overlay_opened", hudOn)
event.listen("overlay_closed", hudOff)

return ui