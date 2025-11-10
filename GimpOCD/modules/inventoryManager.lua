local widgetsAreUs = require("GimpOCD-Divergence.lib.widgetsAreUs")
local contextMenu = require("GimpOCD-Divergence.lib.contextMenu")
local pagedWindow = require("GimpOCD-Divergence.lib.pagedWindow")
local component = require("component")
local sides = require("sides")
local s = require("serialization")
local c = require("GimpOCD-Divergence.lib.gimpColors")

local widget
local inventoryManager = {}
component.modem.open(110)

local function getItems(slot)
    print("Getting item in slot:", slot)
    local itemStack = component.inventory_controller.getStackInSlot(sides.east, slot)
    print("Retrieved item:", s.serialize(itemStack))
    return itemStack
end

local startSlot = 1
local function getFilteredItems(partialLabel)
    local items = {}
    for slot = startSlot, component.inventory_controller.getInventorySize(sides.east) do
        local itemStack = component.inventory_controller.getStackInSlot(sides.east, slot)
        if itemStack and itemStack.label and itemStack.label:lower():find(partialLabel:lower()) then
            print("Found matching item:", s.serialize(itemStack), "getFilteredItems")
            table.insert(items, {itemStack, slot})
            if #items > 40 then return items end
        end
    end
    print("returning items", #items)
    return items
end


local function assignItemBoxClicks(displayed)
    for _, boxData in ipairs(displayed) do
        local widget, slot = boxData[1], boxData[2]
        widget.onClickRight = function(x, y)
            contextMenu.init(x, y, {
                {
                    text = "To Furnace",
                    func = function()
                        widget.remove()
                        component.modem.broadcast(110, "toFurnace", slot)
                    end
                },
                {
                    text = "To Crusher",
                    func = function()
                        widget.remove()
                        component.modem.broadcast(110, "toCrusher", slot)
                    end
                },
                {
                    text = "To Smeltery",
                    func = function()
                        widget.remove()
                        component.modem.broadcast(110, "toSmeltery", slot)
                    end
                },
                {
                    text = "To Grinder",
                    func = function()
                        widget.remove()
                        component.modem.broadcast(110, "toGrinder", slot)
                    end
                },
                {
                    text = "To Assembly",
                    func = function()
                        widget.remove()
                        component.modem.broadcast(110, "toAssembly", slot)
                    end
                }
            })
        end
    end
end

---@param x number Horizontal position
---@param y number Vertical position
---@param width number Width of the auto crafter widget
---@param height number Height of the auto crafter widget
inventoryManager.init = function(x, y, width, height)
    inventoryManager.x1 = x
    inventoryManager.y1 = y
    inventoryManager.x2 = x + width
    inventoryManager.y2 = y + height
    widget = {}
    widget.box = widgetsAreUs.createBox(x, y, width, height, {0,0,0}, 0.6)
    widget.window = pagedWindow.new(getItems, 80, 34, {x1=x,y1=y+25, x2=x+width, y2=y+height-25}, 8, widgetsAreUs.itemBox)
    widget.window:displayItems()
    assignItemBoxClicks(widget.window.currentlyDisplayed)

    widget.upButton = widgetsAreUs.button(x+15,y,"^")
    widget.upButton.onClick = function()
        print("Up button clicked")
        widgetsAreUs.flash(widget.upButton.box, c.yellow, 0.3)
        widget.window:prevPage()
        assignItemBoxClicks(widget.window.currentlyDisplayed)
    end
    widget.downButton = widgetsAreUs.button(x+(width/2) - 10,y+height-20, "v" )
    widget.downButton.onClick = function()
        print("Down button clicked")
        widgetsAreUs.flash(widget.downButton.box, c.yellow, 0.3)
        print("flashed")
        widget.window:nextPage()
        print("next page called")
        assignItemBoxClicks(widget.window.currentlyDisplayed)
        print("assigned click functions to currentlyDisplayed")
    end

    widget.searchBar = widgetsAreUs.searchBar(x+40, y, 40)
    local funcHolder = widget.searchBar.onClick
    widget.searchBar.onClick = function()
        startSlot = 1
        funcHolder()
       
        if widget.window then
            widget.window:clearDisplayedItems()
            widget.window = nil
        end
        print("Cleared Displayed Items (Search Bar)")
        widget.window = pagedWindow.new(getFilteredItems(widgetsAreUs.trim(widget.searchBar.getText())), 80, 34, {x1=x,y1=y+25, x2=x+width, y2=y+height-25}, 8, widgetsAreUs.itemBox)
        widget.window:displayItems()
        print("Displayed Items (Search Bar)")
        assignItemBoxClicks(widget.window.currentlyDisplayed)

        local funcHolder2 = widget.upButton.onClick
        widget.upButton.onClick = function()
            startSlot = startSlot - widget.window.itemsPerPage
            if startSlot < 1 then startSlot = 1 end 
            funcHolder2() 
        end
        local funcHolder3 = widget.downButton.onClick
        widget.downButton.onClick = function()
            startSlot = startSlot + widget.window.itemsPerPage
            if startSlot > component.inventory_controller.getInventorySize() then startSlot = 1 end
            funcHolder3()
        end
    end
end

inventoryManager.onClickRight = function(eventName, address, player, x, y, button)
    if button ~= 1 or not widget then return end
    for _, boxData in ipairs(widget.window.currentlyDisplayed) do
        local boxWidget = boxData[1]
        if boxWidget.box.contains(x, y) and boxWidget.onClickRight then
            boxWidget.onClickRight(x, y)
        end
    end
end

inventoryManager.onClick = function(eventName, address, player, x, y, button)
    if button ~= 0 or not widget then return end
    if widget.upButton.box.contains(x, y) then
        widget.upButton.onClick()
    elseif widget.downButton.box.contains(x, y) then
        widget.downButton.onClick()
    elseif widget.searchBar.box.contains(x, y) then
        widget.searchBar.onClick()
    else
        for _, boxData in ipairs(widget.window.currentlyDisplayed) do
            local boxWidget = boxData[1]
            if boxWidget.box.contains(x, y) and boxWidget.onClick then
                boxWidget.onClick()
            end
        end
    end
end

inventoryManager.remove = function()
    if not widget then return end
    component.glasses.removeObject(widget.box.getID())
    widget.window:clearDisplayedItems()
    widget.upButton.remove()
    widget.downButton.remove()
    widget.searchBar.remove()
    widget = nil
end

inventoryManager.setVisible = function(visible)
    if not widget then return end
    widget.box.setVisible(visible)
    widget.upButton.setVisible(visible)
    widget.downButton.setVisible(visible)
    widget.searchBar.setVisible(visible)
    for _, boxData in ipairs(widget.window.currentlyDisplayed) do
        local boxWidget = boxData[1]
        boxWidget.setVisible(visible)
    end
end

inventoryManager.isActive = function()
    return widget ~= nil
end

return inventoryManager