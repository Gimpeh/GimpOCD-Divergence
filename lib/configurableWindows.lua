local widgetsAreUs = require("lib.widgetsAreUs")
local contextMenu = require("lib.contextMenu")
local modules = require("lib.modules.modules")
local component = require("component")
local event = require("event")


local glasses

local configurableWindows = {}

local horizontalSteps = 4
local verticalSteps = 9

--need to get glasses resolution


function configurableWindows.init(res)
        local xThresholds = {}
        local yThresholds = {}
        local grid = {}
        grid.elements = {}
        local div1 = res.x/2-91
        local div2 = res.x/2+91

        local step = div1 / horizontalSteps
        for i = 1, horizontalSteps do
            local line = widgetsAreUs.createBox(step*i, 0, 1, res.y, {0.1333, 0.1333, 0.1333}, 0.4)
            table.insert(grid, line)
            table.insert(xThresholds, step*i)
        end
        for i = 0, horizontalSteps do
            local line = widgetsAreUs.createBox(div2+step*i, 0, 1, res.y, {0.1333, 0.1333, 0.1333}, 0.4)
            table.insert(grid, line)
            table.insert(xThresholds, div2+step*i)
        end
        step = res.y / verticalSteps
        for i = 1, verticalSteps do
            local line = widgetsAreUs.createBox(0, step*i, res.x, 1, {0.1333, 0.1333, 0.1333}, 0.4)
            table.insert(grid, line)
            table.insert(yThresholds, step*i)
        end

end

return configurableWindows


--[[

function hudSetup.init(player)
    print("hudSetup - Line 18: Initializing HUD setup for player")
    local suc, err = pcall(function()
        local glasses_display = require("displays.glasses_display")
        component.glasses = glasses_display.getGlassesProxy(player)
        local xThresholds = {}
        local yThresholds = {}
        local res = glasses_display.getResolution(player)
        print("hudSetup - Line 28: Resolution fetched for player")
        local grid = {}
        grid.elements = {}
        local div1 = res.x/2-91
        local div2 = res.x/2+91

        print("hudSetup - Line 33: Checking if hudSetup.elements exists for player")
        if players[player].hudSetup.elements then
            hudSetup.remove(player)
            print("hudSetup - Line 35: Removed existing HUD setup for player")
        end

        print("hudSetup - Line 36: Initializing player table")
        if not players[player] then
            players[player] = {}
        end
        if not players[player].hudSetup then
            players[player].hudSetup = {}
        end
        if not players[player].hudSetup.elements then
            players[player].hudSetup.elements = {}
        end
        players[player].hudSetup = {}

        print("hudSetup - Line 42: Calculating step for horizontal grid lines")
        local step = div1 / horizontalSteps
        print("hudSetup - Line 46: Creating horizontal grid lines")
        for i = 1, horizontalSteps do
            local line = widgetsAreUs.createBox(step*i, 0, 1, res.y, {0.1333, 0.1333, 0.1333}, 0.4)
            table.insert(grid, line)
            table.insert(xThresholds, step*i)
            print("hudSetup - Line 49: Created horizontal grid line at position " .. step*i)
        end
        for i = 0, horizontalSteps do
            local line = widgetsAreUs.createBox(div2+step*i, 0, 1, res.y, {0.1333, 0.1333, 0.1333}, 0.4)
            table.insert(grid, line)
            table.insert(xThresholds, div2+step*i)
            print("hudSetup - Line 53: Created horizontal grid line at position " .. (div2+step*i))
        end
        step = res.y / verticalSteps
        print("hudSetup - Line 54: Creating vertical grid lines")
        for i = 1, verticalSteps do
            local line = widgetsAreUs.createBox(0, step*i, res.x, 1, {0.1333, 0.1333, 0.1333}, 0.4)
            table.insert(grid, line)
            table.insert(yThresholds, step*i)
            print("hudSetup - Line 57: Created vertical grid line at position " .. step*i)
        end

        print("hudSetup - Line 60: Surface grid created")

        players[player].hudSetup.xThresholds = xThresholds
        players[player].hudSetup.yThresholds = yThresholds
        players[player].hudSetup.elements = grid
        print("hudSetup - Line 64: HUD setup elements assigned to player")
    end)
    if not suc then print(err) end
end

function hudSetup.onClick(eventName, address, player, x, y, button)
    print("hudSetup - Line 66: onClick function called with eventName: " .. eventName .. ", player: " .. player .. ", x: " .. x .. ", y: " .. y .. ", button: " .. button)
    local suc, err = pcall(function()
        print("hudSetup - Line 68: Checking if selection window exists for player")
        if players[player].hudSetup.elements.window then
            players[player].hudSetup.elements.window.remove()
            players[player].hudSetup.elements.window = nil
            print("hudSetup - Line 71: Removed existing selection window for player")
        end
        if eventName == "hud_click" and button == 0 then
            print("hudSetup - Line 73: Checking if selectionWindow exists for player")
            if players[player].hudSetup.selectionWindow then
                players[player].hudSetup.selectionWindow.remove()
                players[player].hudSetup.selectionWindow = nil
                players[player].hudSetup.selection = nil
                print("hudSetup - Line 77: Removed existing selection window and selection for player")
            end
            players[player].hudSetup.selectionStart = {x=x, y=y}
            print("hudSetup - Line 80: Set selection start coordinates for player")
        end
    end)
    if not suc then print(err) end
    return true
end

function hudSetup.onClickRight()
    print("hudSetup - Line 84: onClickRight function called")
    local suc, err = pcall(function()
        return false
    end)
    if not suc then print(err) end
end

function hudSetup.onDrag(eventName, address, player, x, y, button)
    print("hudSetup - Line 89: onDrag function called with eventName: " .. eventName .. ", player: " .. player .. ", x: " .. x .. ", y: " .. y .. ", button: " .. button)
    local suc, err = pcall(function()
        print("hudSetup - Line 91: Drag event confirmed")
        if eventName == "hud_drag" then
            component.glasses = require("displays.glasses_display").getGlassesProxy(player)
            local selection --init in a usable context
            print("hudSetup - Line 94: Initializing selection coordinates")        
            --get the coordinates of the mouse during the drag
            if players[player].hudSetup.selection == nil then
                selection = {x=x, y=y}
                print("hudSetup - Line 98: No existing selection, initializing new selection")
            end
            --Init Grid Coordinates in a usable context
            print("hudSetup - Line 101: Initializing grid selection coordinates")
            local gridSelectionLeft = 0
            local gridSelectionRight = nil
            local gridSelectionTop = 0
            local gridSelectionBottom = nil
            --convert the x coordinates to grid coordinates
            for _, gridCoords in ipairs(players[player].hudSetup.xThresholds) do
                if gridCoords <= players[player].hudSetup.selectionStart.x then -- decide if grid line is on the left or right side of the selection
                    gridSelectionLeft = gridCoords
                else
                    break -- stop checking once we have our value
                end
            end
            print("hudSetup - Line 109: Converted x coordinates to grid coordinates, gridSelectionLeft: " .. tostring(gridSelectionLeft))
            for _, gridCoords in ipairs(players[player].hudSetup.xThresholds) do
                if gridCoords >= selection.x then
                    gridSelectionRight = gridCoords
                    break
                end
            end
            print("hudSetup - Line 114: Converted x coordinates to grid coordinates, gridSelectionRight: " .. tostring(gridSelectionRight))
            --convert the y coordinates to grid coordinates
            for _, gridCoords in ipairs(players[player].hudSetup.yThresholds) do
                if gridCoords <= players[player].hudSetup.selectionStart.y then -- decide if grid line is on the top or bottom side of the selection
                    gridSelectionTop = gridCoords
                else
                    break -- stop checking once we have our value
                end
            end
            print("hudSetup - Line 120: Converted y coordinates to grid coordinates, gridSelectionTop: " .. tostring(gridSelectionTop))
            for _, gridCoords in ipairs(players[player].hudSetup.yThresholds) do
                if gridCoords >= selection.y then
                    gridSelectionBottom = gridCoords
                    break
                end
            end
            print("hudSetup - Line 125: Converted y coordinates to grid coordinates, gridSelectionBottom: " .. tostring(gridSelectionBottom))
            -- Make or resize the selection window
            print("hudSetup - Line 127: Creating or resizing selection window")
            if not players[player].hudSetup.elements.window then
                players[player].hudSetup.elements.window = widgetsAreUs.createBox(gridSelectionLeft, gridSelectionTop, gridSelectionRight-gridSelectionLeft, 
                    gridSelectionBottom-gridSelectionTop, {0.537, 0.812, 0.941}, 0.5)
                print("hudSetup - Line 131: Created new selection window for player")
            elseif players[player].hudSetup.elements.window.x + players[player].hudSetup.elements.window.width < gridSelectionRight or
                players[player].hudSetup.elements.window.y + players[player].hudSetup.elements.window.height < gridSelectionBottom then
                players[player].hudSetup.elements.window.setSize(gridSelectionBottom-gridSelectionTop, gridSelectionRight-gridSelectionLeft)
                print("hudSetup - Line 135: Resized selection window for player")
            end

            if hasLoadedFunction then
                print("hudSetup - Line 139: hasLoadedFunction is true, skipping initialization")
                return
            else
                hasLoadedFunction = true
                print("hudSetup - Line 143: Initializing context menu functionality")
                local function spawnArgTable(player)
                    local args = {}
                    local i = 1
                    for k, v in pairs(players[player].modules.available) do
                        local tbl = {
                            text = k,
                            func = players[player].modules.available[k],
                            args = {player}
                        }
                        table.insert(args, tbl)
                        print("hudSetup - Line 150: Added module " .. k .. " to argument table")
                    end
                    return args
                end

                hudSetup.onClickRight = function(eventName, address, player, x, y, button)
                    component.glasses = require("displays.glasses_display").getGlassesProxy(player)
                    if eventName == "hud_click" and button == 1 then
                        print("hudSetup - Line 157: Right-click detected, initializing context menu")
                        contextMenu.init(x, y, player, spawnArgTable(player))
                    end
                end
            end
        end
    end)
    if not suc then print(err) end
end

function hudSetup.setVisible(visible, player)
    print("hudSetup - Line 167: setVisible function called for player with visibility: " .. tostring(visible))
    local suc, err = pcall(function()
        for index, element in pairs(players[player].hudSetup.elements) do
            element.setVisible(visible)
            print("hudSetup - Line 170: Set visibility for element " .. index .. " to " .. tostring(visible))
        end
    end)
    if not suc then print(err) end
end

function hudSetup.remove(player)
    print("hudSetup - Line 176: remove function called for player")
    local suc, err = pcall(function()
        if players[player].hudSetup.elements.window and players[player].hudSetup.elements.window.remove then
            players[player].hudSetup.elements.window.remove()
            players[player].hudSetup.elements.window = nil
            print("hudSetup - Line 179: Removed selection window for player")
        end
        for index, element in ipairs(players[player].hudSetup.elements) do
            element.remove()
            players[player].hudSetup.elements[index] = nil
            print("hudSetup - Line 179: Removed element " .. index .. " for player")
        end
        players[player].hudSetup.elements = nil
        players[player].hudSetup.onClickRight = function() return false end
        print("hudSetup - Line 183: Cleared HUD elements and reset onClickRight for player")
    end)
    if not suc then print(err) end
end

return hudSetup
]]