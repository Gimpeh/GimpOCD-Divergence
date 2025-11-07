local c = require("GimpOCD-Divergence.lib.gimpColors")
local event = require("event")
local component = require("component")

local widgetsAreUs = {}

--------------------------------------------------
-- CORE FUNCTIONS
--------------------------------------------------

--- Ensures every widget or visual element conforms to a common interface.
-- Adds default behaviors like remove, visibility control, and click/drag placeholders.
---@param obj table HUD element or collection of elements
---@return table with attached standard widget methods
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

---@param s string @string to clean
---@return string @cleaned string
--- Trims whitespace and control characters from a string.
--- mainly used to clean up getText() results from widget text objects
function widgetsAreUs.trim(s)
    return s:gsub("%c", "")
end

--- Converts large numbers into human-readable shorthand notation (e.g. 1500 -> 1.50k)
---@param numberToConvert number|string @The numeric value to format.
---@return string  @formatted string representation of large numbers.
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


---@alias OneBasedNumber number


---@class color @RGB color table
---@field r OneBasedNumber @Red component (0-1).
---@field g OneBasedNumber @Green component (0-1).
---@field b OneBasedNumber @Blue component (0-1).

---@param color color|nil         @Optional RGB color table to flash to. Defaults to gimpColors.clicked.
---@param flashDuration number | nil @Optional duration in seconds to hold the flash color. Defaults to 0.2 seconds.
---@return nil
function widgetsAreUs.flash(widgetObject, color, flashDuration)
    color = color or c.clicked
    flashDuration = flashDuration or 0.2
    local r, g, b = widgetObject.getColor()
    local originalColor = {r, g, b}
    widgetObject.setColor(table.unpack(color))
    event.timer(flashDuration, function()
        widgetObject.setColor(table.unpack(originalColor))
    end)
end

--------------------------------------------------
-- BASE ELEMENTS
--------------------------------------------------

--- Creates a rectangular box HUD element using `component.glasses.addRect()`.
--- Creates its own box contains method (for click detection)

---@class box @OC Glasses widget object
---@field x number @Horizontal starting position of the box (from the left).
---@field y number @Vertical starting position of the box (from the top).
---@field width number @Width of the box.
---@field height number @Height of the box.
---@field x2 number @Horizontal ending position of the box (x + width).
---@field y2 number @Vertical ending position of the box (y + height).
---@field setSize fun(height: number, width: number): boolean @Changes the size of
---@field contains fun(px: number, py: number): boolean @Checks if a given set of x y coordinates lie within the box bounds.
---@field remove fun() @Removes the box from the HUD.
---@field setVisible fun(visible: boolean) @Sets the box visibility on or off.
---@field update fun() @Placeholder update function.
---@field onClick fun() @Placeholder click handler.
---@field onClickRight fun() @Placeholder right-click handler.
---@field onDrag fun() @Placeholder drag handler.
---@field onDragRight fun() @Placeholder right-drag handler.
---@field getID fun() @Returns the unique ID of the box object.
---@field setPosition fun(x: number, y: number) @Sets the left and top starting positions of the box.
---@field setColor fun(r: number, g: number, b: number) @Sets the RGB color of the box (1 based).

---@param x number @Horizontal position of the box.
---@param y number @Vertical position of the box.
---@param width number @Width of the box.
---@param height number @Height of the box.
---@param color table @0 Based RGB color table {r, g, b}.
---@param alpha number|nil @Optional transparency level (0-1).
---@return box @rectangle widget object with utility methods.
function widgetsAreUs.createBox(x, y, width, height, color, alpha)
    local box = component.glasses.addRect()
    box.setSize(height, width)
    local old_setSize = box.setSize

    box.setPosition(x, y)
    box.setColor(table.unpack(color))
    if alpha then box.setAlpha(alpha) end

    box.x, box.y, box.width, box.height = x, y, width, height
    box.x2, box.y2 = x + width, y + height

    ---Changes the size of the box and updates boundary properties.
    ---@param height number @New height of the box.
    ---@param width number @New width of the box.
    ---@return boolean @True if size was set successfully.
    box.setSize = function(height, width)
        old_setSize(height, width)
        box.x2, box.y2 = box.x + width, box.y + height
        return true
    end

    --- Checks if a given coordinate lies within the box bounds.
    ---@param px number @X coordinate (fed straight from the hud_click event preferably).
    ---@param py number @Y coordinate (fed straight from the hud_click event preferably).
    ---@return boolean @True if within box area, false otherwise.
    function box.contains(px, py)
        return px >= box.x and px <= box.x2 and py >= box.y and py <= box.y2
    end

    return widgetsAreUs.attachCoreFunctions(box)
end

--- Creates a text label HUD element.
---@param x number @Horizontal position of the text.
---@param y number @Vertical position of the text.
---@param text1 string @The displayed text.
---@param scale number @Text size.
---@param color color|nil Optional RGB color table.
---@return table @HUD text object.
function widgetsAreUs.text(x, y, text1, scale, color)
    local text = component.glasses.addTextLabel()
    text.setPosition(x, y)
    text.setScale(scale)
    text.setText(text1)

    if color then text.setColor(table.unpack(color)) end
    return widgetsAreUs.attachCoreFunctions(text)
end

------------------Widget Pieces------------------
---@param x number @horizontal position on players screen
---@param y number @vertical position on players screen
---@param width number @width of the text box
---@param height number @height of the text box
---@param color table @0 based rgb color table
---@param alpha number @0-1 transparency level  
---@param text string @text to display in the box
---@param textScale number @text scale factor
---@param xOffset number @x offset for text position WITHIN the box boundaries (padding basically)
---@param yOffset number @y offset for text position WITHIN the box boundaries (padding basically)
---@return table @full widget object instance with its own methods and metadata
function widgetsAreUs.textBox(x, y, width, height, color, alpha, text, textScale, xOffset, yOffset)
    local element = {}
    local box = widgetsAreUs.createBox(x, y, width, height, color, alpha)
    local text = widgetsAreUs.text(x + (xOffset or 5), y + (yOffset or 5), text, textScale or 1.5)

    return widgetsAreUs.attachCoreFunctions({box = box, text = text})
end

--- Creates a dark header title box with text for HUD windows.
---@param x number @Horizontal position.
---@param y number @Vertical position.
---@param width number @Width of title box.
---@param text string @Title text to display.
---@return table @Combined box and text HUD object.
function widgetsAreUs.windowTitle(x, y, width, text)
    local titleBox = widgetsAreUs.createBox(x, y, width, 20, c.black, 0.8)
    local title = widgetsAreUs.text(x + 10, y + 5, text, 1, c.white)
    return widgetsAreUs.attachCoreFunctions({ box = titleBox, text = title })
end

--- Creates a search bar widget with editable text label.
---@param x number @Horizontal position.
---@param y number @Vertical position.
---@param length number @Horizontal Size of the search bar. (width)
---@return table @Search bar HUD object with getText and setText.
function widgetsAreUs.searchBar(x, y, length)
    local box = widgetsAreUs.createBox(x, y, length, 20, c.objectinfo, 0.7)
    local text = widgetsAreUs.text(x + 3, y + 5, "Search", 1)
    local getText = function()
        return text.getText()
    end
    local setText = function(newText)
        text.setText(newText)
    end
    local onClick = function()
        while true do
            local eventName, address, player, char, dunno = event.pull("hud_keyboard")
            if char == 13 then
                break
            elseif char == 8 then
                local currentText = widgetsAreUs.trim(text.getText())
                setText(currentText:sub(1, -2))
            else
                local letter = string.char(char)
                local currentText = widgetsAreUs.trim(text.getText())
                setText(currentText .. letter)
            end
        end
    end

    return widgetsAreUs.attachCoreFunctions({
        box = box,
        text = text,
        getText = getText,
        setText = setText,
        onClick = onClick
    })
end

function widgetsAreUs.button(x, y, buttonSymbol)
    local button = {}
    button.box = widgetsAreUs.createBox(x, y, 20, 20, c.navbutton, 0.8)
    button.text = widgetsAreUs.text(x + 6, y + 3, buttonSymbol, 1.5, c.white)
    return widgetsAreUs.attachCoreFunctions(button)
end

--------------complete Widgets---------------------

------Object Widgets-------

--- Creates a item box HUD element that displays an item name, icon, and amount.
---@param x number @Horizontal position.
---@param y number @Vertical position.
---@param itemStack table @Item data table containing label, name, damage, and size.
---@return table @Complete HUD item box with update() for ME network sync (Or Modular Systems sync).
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
        itemStack = itemStack,
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


---------Pop-Ups-------

---@param x number @Horizontal position on screen.
---@param y number @Vertical position on screen.
---@param text string @Text to display in the notification.
---@param duration number|nil @Optional duration in seconds before auto-dismissal. If nil, requires click to dismiss.
---@return table @Notification HUD object that optionally auto-removes after duration or on click.
function widgetsAreUs.notification(x, y, text, duration)
    duration = duration or nil
    local notification = {}
    notification.box = widgetsAreUs.createBox(x, y, 300, 30, c.beige, 0.5)
    notification.text = widgetsAreUs.text(x + 3, y + 8, text, 1.2)

    notification.remove = function()
        component.glasses.removeObject(notification.box.getID())
        component.glasses.removeObject(notification.text.getID())
    end

    if duration then
        event.timer(duration, function()
            notification.remove()
        end)
    end

    notification.box.onClick = function(eventName, address, player, x1, y1, button)
        notification.remove()
    end

    return widgetsAreUs.attachCoreFunctions(notification)
end

---@param x number @Horizontal position on screen.
---@param y number @Vertical position on screen.
---@param width number @Width of the pop-up box.
---@param height number @Height of the pop-up box.
---@param line1 string @First line of text.
---@param line2 string|nil @Optional second line of text.
---@param line3 string|nil @Optional third line of text.
---@param line4 string|nil @Optional fourth line of text.
---@param line5 string|nil @Optional fifth line of text.
---@param line6 string|nil @Optional sixth line of text.
---@return table @Pop-up HUD object with multiple lines of text and a remove() method.
function widgetsAreUs.popUp(x, y, width, height, line1, line2, line3, line4, line5, line6)
    local widget = {}
    widget.box = widgetsAreUs.createBox(x, y, width, height, c.beige, 0.5)
    widget.text1 = widgetsAreUs.text(x + 3, y + 3, line1, 1.2)
    widget.text2 = nil
    widget.text3 = nil
    widget.text4 = nil
    widget.text5 = nil
    widget.text6 = nil

    if line2 then widget.text2 = widgetsAreUs.text(x + 3, y + 18, line2, 1.2) end
    if line3 then widget.text3 = widgetsAreUs.text(x + 3, y + 33, line3, 1.2) end
    if line4 then widget.text4 = widgetsAreUs.text(x + 3, y + 48, line4, 1.2) end
    if line5 then widget.text5 = widgetsAreUs.text(x + 3, y + 63, line5, 1.2) end
    if line6 then widget.text6 = widgetsAreUs.text(x + 3, y + 78, line6, 1.2) end

    widget.remove = function()
        component.glasses.removeObject(widget.box.getID())
        component.glasses.removeObject(widget.text1.getID())
        if widget.text2 then component.glasses.removeObject(widget.text2.getID()) end
        if widget.text3 then component.glasses.removeObject(widget.text3.getID()) end
        if widget.text4 then component.glasses.removeObject(widget.text4.getID()) end
        if widget.text5 then component.glasses.removeObject(widget.text5.getID()) end
        if widget.text6 then component.glasses.removeObject(widget.text6.getID()) end
    end
    widget.onClick = function(eventName, address, player, x1, y1, button)
        widget.remove()
    end
    return widgetsAreUs.attachCoreFunctions(widget)
end

return widgetsAreUs
