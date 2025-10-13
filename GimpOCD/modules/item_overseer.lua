local pagedWindow = require("lib.pagedWindow")
local contextMenu = require("lib.contextMenu")
local widgetsAreUs = require("lib.widgetsAreUs")
local s = require("serialization")

local c = require("lib.gimpColors")
local component = require("component")
local sides = require("sides")

local item_overseer = {}

component.modem.open(102)

local function itemContextMenu(x, y, element)
    contextMenu.init(x, y, {
                    {text = "To Crusher", 
                    func = function() component.modem.broadcast(102, s.serialize({id="to_crusher",slotNum = element[2]})) end,
                    args = {}},
                    {text = "To Grinder", 
                    func = function() component.modem.broadcast(102, s.serialize({id="to_grinder", slotNum = element[2]})) end,
                    args = {}},
                    {text = "To Smeltery",
                    func = function() component.modem.broadcast(102, s.serialize({id="to_smeltery", slotNum = element[2]})) end,
                    args = {}},
                    {text = "To Furnace",
                    func = function() component.modem.broadcast(102, s.serialize({id="to_furnace", slotNum = element[2]})) end,
                    args = {}},
                    {text = "To Assembly Table",
                    func = function() component.modem.broadcast(102, s.serialize({id="to_assembly", slotNum = element[2]})) end,
                    args = {}}})
end
      
local function setOnClickForPagedItems()
    for index, element in pairs(item_overseer.itemWindow.currentlyDisplayed) do
        element.onClick = function(eventName, address, player, x, y, button)
            if eventName == "hud_click" and button == 0 then
                --do we even do anything on a left click???
                --like maybe allow changing to one of the transposer connected inventories to move back or wtvr)
            end
        end
    end
    for index, element in pairs(item_overseer.itemWindow.currentlyDisplayed) do
        element[1].onClickRight = function(eventName, address, player, x, y, button)
            itemContextMenu(x, y, element)
        end
    end                
end

local function getItemMethod(i)
    return component.transposer.getStackInSlot(sides.down, i)
end

function item_overseer.init(box)
    --init tables
    item_overseer.elements = {}
    item_overseer.elements.background = {}
    item_overseer.elements.background.box = box
    --set the boxes color to item_overseer scheme
    item_overseer.elements.background.box.setColor(c.item_overseerBackground)

    --get and set the windows area
    item_overseer.bounds = {}
    item_overseer.bounds.x1, item_overseer.bounds.y1 = item_overseer.elements.box.getPosition()
    item_overseer.bounds.y2, item_overseer.bounds.x2 = item_overseer.elements.box.getSize()

    -------create a window with pages of items
    item_overseer.itemWindow = pagedWindow.new(getItemMethod, 80, 34, item_overseer.bounds, 5, widgetsAreUs.itemBox)
    item_overseer.itemWindow:displayItems()
    setOnClickForPagedItems()


    ------------next and previous page buttons
    item_overseer.elements.nextButton = widgetsAreUs.button(
        item_overseer.bounds.x1-23,
        item_overseer.bounds.y1+(((item_overseer.bounds.y2-item_overseer.bounds.y1)/2)-20),
        "->")
    item_overseer.elements.nextButton.onClick = function(eventName, address, player, x, y, button)
        if eventName == "hud_click" and button == 0 and item_overseer.elements.nextButton.box.contains(x, y) then
            item_overseer.itemWindow:nextPage()
            setOnClickForPagedItems()
            return true
        end
    end
    --prev
    item_overseer.elements.prevButton = widgetsAreUs.button(
        item_overseer.bounds.x2+3,
        item_overseer.bounds.y1+(((item_overseer.bounds.y2-item_overseer.bounds.y1)/2)-20),
        "<-")
    item_overseer.elements.prevButton.onClick = function(eventName, address, player, x, y, button)
        if eventName == "hud_click" and button == 0 and item_overseer.elements.prevButton.box.contains(x, y) then
            item_overseer.itemWindow:prevPage()
            setOnClickForPagedItems()
            return true
        end
    end
end

item_overseer.setVisible = function(visible)
    for index, element in pairs(item_overseer.elements) do
        element.setVisible(visible)
    end
    for index, element in pairs(item_overseer.itemWindow.currentlyDisplayed) do
        element[1].setVisible(visible)
    end
end

item_overseer.remove = function()
    for k,v in pairs(item_overseer.elements) do
        v.remove()
    end
    item_overseer.elements = nil
    item_overseer.itemWindow:ClearDisplayedItems()
    item_overseer.itemWindow = nil
    item_overseer.bounds = nil
    item_overseer = {}
end

item_overseer.onClick = function(eventName, address, player, x, y, button)
    for index, element in pairs(item_overseer.elements) do
        if element.box.contains(x, y) and element.onClick then
            if item_overseer.elements.background == element then
                for key, pagedElement in ipairs(item_overseer.itemWindow.currentlyDisplayed) do
                    if pagedElement.box.contains(x, y) and pagedElement.onClick then
                        pagedElement.onClick(eventName, address, player, x, y, button)
                        return true
                    end
                end
            end
            element.onClick(eventName, address, player, x, y, button)
            return true
        end
    end
end

item_overseer.onClickRight = function(eventName, address, player, x, y, button)
    if item_overseer.elements.background.box.contains(x, y) then
        for index, element in pairs(item_overseer.elements) do
            if element.box.contains(x, y) and element.onClickRight and index ~= "background" then
                element.onClickRight(eventName, address, player, x, y, button)
                return true
            end
        end
    end
end



return item_overseer