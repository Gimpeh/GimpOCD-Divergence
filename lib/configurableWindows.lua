local widgetsAreUs = require("lib.widgetsAreUs")
local contextMenu = require("lib.contextMenu")
local modules = require("lib.modules.modules")
local component = require("component")
local event = require("event")

local configurableWindows = {}

local horizontalSteps = 4
local verticalSteps = 9
local xThresholds = {}
local yThresholds = {}


--need to get glasses resolution


function configurableWindows.init(res)
        configurableWindows.elements = {}
        configurableWindows.elements.grid = {}
        xThresholds = {}
        yThresholds = {}

        local div1 = res.x/2-91
        local div2 = res.x/2+91

        local step = div1 / horizontalSteps
        for i = 1, horizontalSteps do
            local line = widgetsAreUs.createBox(step*i, 0, 1, res.y, {0.1333, 0.1333, 0.1333}, 0.4)
            table.insert(configurableWindows.elements.grid, line)
            table.insert(xThresholds, step*i)
        end
        for i = 0, horizontalSteps do
            local line = widgetsAreUs.createBox(div2+step*i, 0, 1, res.y, {0.1333, 0.1333, 0.1333}, 0.4)
            table.insert(configurableWindows.elements.grid, line)
            table.insert(xThresholds, div2+step*i)
        end
        step = res.y / verticalSteps
        for i = 1, verticalSteps do
            local line = widgetsAreUs.createBox(0, step*i, res.x, 1, {0.1333, 0.1333, 0.1333}, 0.4)
            table.insert(configurableWindows.elements.grid, line)
            table.insert(yThresholds, step*i)
        end
end

function configurableWindows.onClick(eventName, address, player, x, y, button)
    if eventName == "hud_click" then
        if configurableWindows.selectionWindow then
            configurableWindows.selectionWindow.remove()
            configurableWindows.selectionWindow = nil
            configurableWindows.selectionEnd = nil
        end
        if button == 0 then 
            configurableWindows.selectionStart = {x=x, y=y}
            return true
        end
    end
end

function configurableWindows.onClickRight(eventName, address, player, x, y, button)
    if eventName ~= "hud_click" or button ~= 1 then return false end
    if configurableWindows.selectionWindow and configurableWindows.selectionWindow.contains(x, y) then
        local function menuArgTable()
            local argTable = {}
            for k, mod in pairs(modules) do
                local tbl = {
                    text = k,
                    func = modules[k],
                    args = {}
                }
                table.insert(argTable, tbl)
            end
            return argTable
        end

        if configurableWindows.selectionWindow and configurableWindows.selectionWindow.contains(x, y) then
        contextMenu.init(x, y, menuArgTable())
        end
    else
        if configurableWindows.selectionWindow then
            configurableWindows.selectionWindow.remove()
            configurableWindows.selectionWindow = nil
            configurableWindows.selectionEnd = nil
        end
    end
end

function configurableWindows.onDrag(eventName, address, player, x, y, button)
    --- Normalize two points so dragging in any direction is supported.
    --- Returns leftX/rightX/topY/bottomY in screen coordinates.
    ---@param startPoint table @{x:number, y:number}
    ---@param endPoint table   @{x:number, y:number}
    ---@return table           @{leftX:number, rightX:number, topY:number, bottomY:number}
    local function getNormalizedCorners(startPoint, endPoint)
        return {
            leftX   = math.min(startPoint.x, endPoint.x),
            rightX  = math.max(startPoint.x, endPoint.x),
            topY    = math.min(startPoint.y, endPoint.y),
            bottomY = math.max(startPoint.y, endPoint.y),
        }
    end
    --- Snap a value DOWN to the nearest threshold <= value.
    --- thresholds must be an ascending array of numbers.
    ---@param thresholds number[] @Ascending grid lines (e.g., xThresholds or yThresholds)
    ---@param value number        @Screen coordinate to snap
    ---@return number             @Snapped coordinate (never nil; returns 0 if none found)
    local function snapToLowerThreshold(thresholds, value)
        local lastAtOrBelow = 0
        for i = 1, #thresholds do
            if thresholds[i] <= value then
                lastAtOrBelow = thresholds[i]
            else
                break
            end
        end
        return lastAtOrBelow
    end
    --- Snap a value UP to the nearest threshold >= value.
    --- thresholds must be an ascending array of numbers.
    ---@param thresholds number[] @Ascending grid lines (e.g., xThresholds or yThresholds)
    ---@param value number        @Screen coordinate to snap
    ---@return number             @Snapped coordinate (falls back to the largest threshold)
    local function snapToUpperThreshold(thresholds, value)
        for i = 1, #thresholds do
            if thresholds[i] >= value then
                return thresholds[i]
            end
        end
        return thresholds[#thresholds]
    end

    if eventName == "hud_drag" then
        if not configurableWindows.selectionStart then configurableWindows.selectionStart = {x=x, y=y} end
        configurableWindows.selectionEnd = {x=x, y=y}

        local corners = getNormalizedCorners(
            configurableWindows.selectionStart,
            configurableWindows.selectionEnd
        )

        local snappedLeftX   = snapToLowerThreshold(xThresholds, corners.leftX)
        local snappedRightX  = snapToUpperThreshold(xThresholds, corners.rightX)
        local snappedTopY    = snapToLowerThreshold(yThresholds, corners.topY)
        local snappedBottomY = snapToUpperThreshold(yThresholds, corners.bottomY)

        local widthPixels  = math.max(1, snappedRightX  - snappedLeftX)
        local heightPixels = math.max(1, snappedBottomY - snappedTopY)

        if not configurableWindows.selectionWindow then
            configurableWindows.selectionWindow =
            widgetsAreUs.createBox(snappedLeftX, snappedTopY, widthPixels, heightPixels, {0.537,0.812,0.941}, 0.5)
        else
            if configurableWindows.selectionWindow.setPosition then
                configurableWindows.selectionWindow.setPosition(snappedLeftX, snappedTopY)
            end
            configurableWindows.selectionWindow.setSize(heightPixels, widthPixels)
        end
    end
end

configurableWindows.remove = function()
    if configurableWindows.selectionWindow then
        configurableWindows.selectionWindow.remove()
        configurableWindows.selectionWindow = nil
        configurableWindows.selectionEnd = nil
    end
    if configurableWindows.elements and configurableWindows.elements.grid then
        for k, v in pairs(configurableWindows.elements.grid) do
            v.remove()
        end
        configurableWindows.elements.grid = nil
        configurableWindows.elements = nil
        configurableWindows = {}
    end
end

configurableWindows.setVisible = function(visible)
    if configurableWindows.elements and configurableWindows.elements.grid then
        for k, v in pairs(configurableWindows.elements.grid) do
            v.setVisible(visible)
        end
    end
    if configurableWindows.selectionWindow then
        configurableWindows.selectionWindow.setVisible(visible)
    end
end

return configurableWindows