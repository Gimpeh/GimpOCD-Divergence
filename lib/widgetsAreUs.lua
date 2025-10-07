-- widgetsAreUs Library (Full Cleaned Version)
-- The module starts by loading the color, event, and component libraries from OpenComputers.
-- Each of these are required for HUD rendering and event handling.
-- All component.glasses, event, and API calls remain untouched.
-- This cleanup restores windowTitle, searchBar, itemBox, and dependencies.

local c = require("lib.gimp_colors")
local event = require("event")
local component = require("component")

local widgetsAreUs = {}

--------------------------------------------------
-- CORE FUNCTIONS
--------------------------------------------------

--- Ensures every widget or visual element conforms to a common interface.
-- Adds default behaviors like remove, visibility control, and click/drag placeholders.
-- @param obj table HUD element or collection of elements
-- @return table with attached standard widget methods
function widgetsAreUs.attachCoreFunctions(obj)
    if not obj.remove then
        if obj.getID then
            obj.remove = function()
                component.glasses.removeObject(obj.getID())
                obj = nil
            end
        elseif type(obj) == "table" then
            obj.remove = function()
                for k, v in pairs(obj) do
                    if type(v) == "table" and v.remove then
                        v.remove()
                        obj[k] = nil
                    elseif type(v) == "table" and v.getID then
                        component.glasses.removeObject(v.getID())
                        obj[k] = nil
                    end
                end
                obj = nil
            end
        end
    end

    if not obj.setVisible then
        obj.setVisible = function(visible)
            for _, v in pairs(obj) do
                if type(v) == "table" and v.setVisible then
                    v.setVisible(visible)
                end
            end
        end
    end

    obj.update       = obj.update       or function() end
    obj.onClick      = obj.onClick      or function() end
    obj.onClickRight = obj.onClickRight or function() end
    obj.onDrag       = obj.onDrag       or function() end
    obj.onDragRight  = obj.onDragRight  or function() end

    return obj
end

--------------------------------------------------
-- UTILITIES
--------------------------------------------------

--- Trims whitespace and control characters from a string.
-- Useful for sanitizing player text input.
-- @param s string The string to trim.
-- @return string Sanitized version of the string.
function widgetsAreUs.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1")):gsub("%c", "")
end

--- Converts large numbers into human-readable shorthand notation (e.g. 1500 -> 1.50k)
-- @param numberToConvert number The numeric value to format.
-- @return string Shorthand formatted string representation.
function widgetsAreUs.shorthandNumber(numberToConvert)
    local num = tonumber(numberToConvert)
    local units = {"", "k", "M", "B", "T", "Qua", "E", "Z", "Y"}
    local unitIndex = 1

    while num >= 1000 and unitIndex < #units do
        num = num / 1000
        unitIndex = unitIndex + 1
    end

    return string.format("%.2f%s", num, units[unitIndex])
end

--------------------------------------------------
-- BASE ELEMENTS
--------------------------------------------------

--- Creates a rectangular box HUD element using `component.glasses.addRect()`.
-- Stores positional metadata and adds a contains() method for hit detection.
-- @param x number X position of the box.
-- @param y number Y position of the box.
-- @param width number Width of the box.
-- @param height number Height of the box.
-- @param color table RGB color table {r, g, b}.
-- @param alpha number|nil Optional transparency level.
-- @return table HUD rectangle object with utility methods.
function widgetsAreUs.createBox(x, y, width, height, color, alpha)
    local box = component.glasses.addRect()
    box.setSize(height, width)
    local old_setSize = box.setSize

    box.setPosition(x, y)
    box.setColor(table.unpack(color))
    if alpha then box.setAlpha(alpha) end

    box.x, box.y, box.width, box.height = x, y, width, height
    box.x2, box.y2 = x + width, y + height

    box.setSize = function(height, width)
        old_setSize(height, width)
        box.x2 = box.x + width
        box.y2 = box.y + height
    end

    --- Checks if a given coordinate lies within the box bounds.
    -- @param px number X coordinate.
    -- @param py number Y coordinate.
    -- @return boolean True if within box area, false otherwise.
    function box.contains(px, py)
        return px >= box.x and px <= box.x2 and py >= box.y and py <= box.y2
    end

    return widgetsAreUs.attachCoreFunctions(box)
end

--- Creates a text label HUD element.
-- @param x number X position of the text.
-- @param y number Y position of the text.
-- @param text1 string The displayed text.
-- @param scale number Text scale factor.
-- @param color table|nil Optional RGB color table.
-- @return table HUD text object.
function widgetsAreUs.text(x, y, text1, scale, color)
    local text = component.glasses.addTextLabel()
    text.setPosition(x, y)
    text.setScale(scale)
    text.setText(text1)

    if color then text.setColor(table.unpack(color)) end
    return widgetsAreUs.attachCoreFunctions(text)
end

--------------------------------------------------
-- WIDGETS: WINDOW TITLE & SEARCH BAR
--------------------------------------------------

--- Creates a dark header title box with text for HUD windows.
-- @param x number X position.
-- @param y number Y position.
-- @param width number Width of title box.
-- @param text string Title text to display.
-- @return table Combined box and text HUD object.
function widgetsAreUs.windowTitle(x, y, width, text)
    local titleBox = widgetsAreUs.createBox(x, y, width, 20, c.black, 0.8)
    local title = widgetsAreUs.text(x + 10, y + 5, text, 1, c.white)
    return widgetsAreUs.attachCoreFunctions({ box = titleBox, text = title })
end

--- Creates a search bar widget with editable text label.
-- @param x number X position.
-- @param y number Y position.
-- @param length number Length of the search bar.
-- @return table Search bar HUD object with getText and setText.
function widgetsAreUs.searchBar(x, y, length)
    local box = widgetsAreUs.createBox(x, y, length, 20, c.objectinfo, 0.7)
    local text = widgetsAreUs.text(x + 3, y + 5, "Search", 1)

    return widgetsAreUs.attachCoreFunctions({
        box = box,
        text = text,
        getText = function()
            return text.getText()
        end,
        setText = function(newText)
            text.setText(newText)
        end
    })
end

--------------------------------------------------
-- WIDGET: ITEM BOX
--------------------------------------------------

--- Creates an item box HUD element that displays an item name, icon, and amount.
-- @param x number X position.
-- @param y number Y position.
-- @param itemStack table Item data table containing label, name, damage, and size.
-- @return table Complete HUD item box with update() for ME network sync.
function widgetsAreUs.itemBox(x, y, itemStack)
    local background = widgetsAreUs.createBox(x, y, 80, 34, c.object, 0.8)
    local name = widgetsAreUs.text(x + 2, y + 2, itemStack.label, 0.9)

    local icon = component.glasses.addItem()
    icon.setPosition(x, y + 6)

    if component.database then
        component.database.clear(1)
        component.database.set(1, itemStack.name, itemStack.damage, itemStack.tag)
        icon.setItem(component.database.address, 1)
    end

    local amount = widgetsAreUs.text(x + 30, y + 18, tostring(widgetsAreUs.shorthandNumber(itemStack.size)), 1)

    return widgetsAreUs.attachCoreFunctions({
        box = background,
        name = name,
        icon = icon,
        amount = amount,
        update = function()
            local updatedItemStack = component.me_interface.getItemsInNetwork({
                label = itemStack.label,
                name = itemStack.name,
                damage = itemStack.damage
            })[1]
            if updatedItemStack then
                amount.setText(tostring(updatedItemStack.size))
            end
        end
    })
end

--------------------------------------------------
-- RETURN MODULE
--------------------------------------------------

--- Exports the entire module as a table so it can be required elsewhere.
-- Each function inside becomes accessible through `require('widgetsAreUs')`.
return widgetsAreUs
