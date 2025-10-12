local widgetsAreUs = require("lib.widgetsAreUs")
local c = require("lib.gimpColors")
local event = require("event")
local s = require("serialization")
local component = require("component")

local powerDisplay = {}
powerDisplay.onClick = nil
powerDisplay.onClickRight = nil
powerDisplay.setVisible = nil
powerDisplay.remove = nil
powerDisplay.onModemMessage = nil

local function widget(x, y)
    local widget = {}
    widget.backgroundBox = widgetsAreUs.createBox(x+30, y, 203, 86, {0, 0, 0}, 0.8)
    widget.backgroundInterior = widgetsAreUs.createBox(x + 32, y + 2, 199, 82, {1, 1, 1}, 0.7)
    widget.header = widgetsAreUs.text(x+63,y+10,"Power Metrics", 2)
    widget.powerCurrentLabel = widgetsAreUs.text(x+39, y+40, "RF:", 2)
    widget.powerCurrent = widgetsAreUs.text(x+80, y+40, "Placeholder", 2)
    widget.powerBarBackground = widgetsAreUs.createBox(x+40, y+62, 180, 15, {0,0,0}, 0.7)
    widget.powerBar = widgetsAreUs.createBox(x+40, y+62, 0, 15, {0,1,0}, 0.7)
    widget.powerPercentage = widgetsAreUs.text(x+180, y+40, "xx%", 1.7)
    widget.dieselBarBackground = widgetsAreUs.createBox(x, y, 25, 86, {0,0,0,}, 0.8)
    widget.dieselBar = widgetsAreUs.createBox(x, y, 25, 0, {1,1,0}, 0.7)
    widget.dieselPercent = widgetsAreUs.text(x+3, y+40, "xx%", 1.7)

    widget.setVisible = function(visible)
        widget.backgroundBox.setVisible(visible)
        widget.backgroundInterior.setVisible(visible)
        widget.header.setVisible(visible)
        widget.powerCurrentLabel.setVisible(visible)
        widget.powerCurrent.setVisible(visible)
        widget.powerBarBackground.setVisible(visible)
        widget.powerBar.setVisible(visible)
        widget.powerPercentage.setVisible(visible)
        widget.dieselBarBackground.setVisible(visible)
        widget.dieselBar.setVisible(visible)
        widget.dieselPercent.setVisible(visible)
    end
    widget.remove = function()
        component.glasses.removeObject(widget.backgroundBox.getID())
        component.glasses.removeObject(widget.backgroundInterior.getID())
        component.glasses.removeObject(widget.header.getID())
        component.glasses.removeObject(widget.powerCurrentLabel.getID())
        component.glasses.removeObject(widget.powerCurrent.getID())
        component.glasses.removeObject(widget.powerBarBackground.getID())
        component.glasses.removeObject(widget.powerBar.getID())
        component.glasses.removeObject(widget.powerPercentage.getID())
        component.glasses.removeObject(widget.dieselBarBackground.getID())
        component.glasses.removeObject(widget.dieselBar.getID())
        component.glasses.removeObject(widget.dieselPercent.getID())
    end
    widget.update = function(stats)
        if stats.totalEnergy then
            widget.powerCurrent.setText(tostring(stats.totalEnergy))

            local percentage = math.floor(stats.energyPercentage)
            widget.powerPercentage.setText(tostring(percentage) .. "%")
            local size = math.floor((percentage / 100) * 180)
            widget.powerBar.setSize(15, size)
        elseif stats.name then
            local percentage = math.floor((stats.amount / stats.capacity) * 100)
            widget.dieselPercent.setText(tostring(percentage) .. "%")
            local size = math.floor((percentage / 100) * 86)
            widget.dieselBar.setSize(size, 25)
        end
    end
    return widgetsAreUs.attachCoreFunctions(widget)
end

function powerDisplay.init(resX)
    local suc, err = pcall(function()
        local popUp = widgetsAreUs.popUp(400, 250, 190, 100,
            "Left Click to Set Position",
            "Right Click to Set Position from ends",
            "Middle Click to Accept"
        )

        while true do
            local _, _, _, x, y, button = event.pull("hud_click")
            if button == 0 then
                if powerDisplay.widget then
                    powerDisplay.widget.remove()
                end
                powerDisplay.widget = widget(x, y)
            end
            if button == 1 then
                if powerDisplay.widget then
                    powerDisplay.widget.remove()
                end
                powerDisplay.widget = widget(x-203,y-86)
            end
            if button == 2 then
                popUp.remove()
                break
            end
        end
    end)
    if not suc then print("Error initializing power display: " .. err) end
end

powerDisplay.update = function(stats)
    if powerDisplay.widget then
        powerDisplay.widget.update(stats)
    end
end

powerDisplay.setVisible = function(visible)
    if powerDisplay.widget then
        powerDisplay.widget.setVisible(visible)
    end
end

return powerDisplay