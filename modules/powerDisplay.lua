local widgetsAreUs = require("lib.widgetsAreUs")
local c = require("gimpColors")
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
    widget.backgroundBox = widgetsAreUs.createBox(x, y, 203, 86, {0, 0, 0}, 0.8)
    widget.backgroundInterior = widgetsAreUs.createBox(x + 2, y + 2, 199, 82, {1, 1, 1}, 0.7)
    widget.header = widgetsAreUs.text(x+33,y+10,"Power Metrics", 2)
    widget.powerCurrentLabel = widgetsAreUs.text(x+9, y+40, "RF:", 2)
    widget.powerCurrent = widgetsAreUs.text(x+50, y+40, "Placeholder", 2)
    widget.powerBarBackground = widgetsAreUs.createBox(x+10, y+62, 180, 15, {0,0,0}, 0.7)
    widget.powerBar = widgetsAreUs.createBox(x+10, y+62, 0, 15, {1,1,0}, 0.7)
    widget.powerPercentage = widgetsAreUs.text(x+150, y+40, "xx%", 1.7)

    widget.setVisible = function(visible)
        widget.backgroundBox.setVisible(visible)
        widget.backgroundInterior.setVisible(visible)
        widget.header.setVisible(visible)
        widget.powerCurrentLabel.setVisible(visible)
        widget.powerCurrent.setVisible(visible)
        widget.powerBarBackground.setVisible(visible)
        widget.powerBar.setVisible(visible)
        widget.powerPercentage.setVisible(visible)
    end
    widget.remove = function()
        component.glasses.remove(widget.backgroundBox.getID())
        component.glasses.remove(widget.backgroundInterior.getID())
        component.glasses.remove(widget.header.getID())
        component.glasses.remove(widget.powerCurrentLabel.getID())
        component.glasses.remove(widget.powerCurrent.getID())
        component.glasses.remove(widget.powerBarBackground.getID())
        component.glasses.remove(widget.powerBar.getID())
        component.glasses.remove(widget.powerPercentage.getID())
    end
    widget.update = function(stats)
        widget.powerCurrent.setText(tostring(stats.totalEnergy))

        local percentage = math.floor(stats.energyPercentage)
        widget.powerPercentage.setText(tostring(percentage) .. "%")
        local size = math.floor((percentage / 100) * 180)
        widget.powerBar.setSize(15, size)
    end
    return widgetsAreUs.attachCoreFunctions(widget)
end

function powerDisplay.init()
    local suc, err = pcall(function(resX)
        local popUp = widgetsAreUs.popUp(resX -200, 1, 190, 100,
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