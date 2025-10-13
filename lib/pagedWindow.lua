-- v.1.0.2
local pagedWindow = {}
pagedWindow.__index = pagedWindow

---@class windowOfPages
---@field displayItems fun(self: windowOfPages) @Clears and redraws the current page of items
---@field ClearDisplayedItems fun(self: windowOfPages) @Clears all currently displayed items
---@field nextPage fun(self: windowOfPages) @Advances to the next page, if there is one, and redraws the items
---@field prevPage fun(self: windowOfPages) @Goes back to the previous page
---@field items function|table @Either a method that takes an index and returns an object, or a table of objects
---@field itemWidth number @The width of each object widget
---@field itemHeight number @The height of each object widget
---@field padding number @The padding between each widget object
---@field renderItem function @A function that takes (x, y, object, ...) and returns a widget representing the object
---@field args table @An array of additional arguments to pass to the objectWidgetCreationFunction after the object (4th and >4th args)
---@field screenX1 number @The x1 coordinate of the window boundary
---@field screenY1 number @The y1 coordinate of the window boundary
---@field screenX2 number @The x2 coordinate of the window boundary
---@field screenY2 number @The y2 coordinate of the window boundary
---@field itemsPerRow number @The number of items that can fit in a single row
---@field itemsPerColumn number @The number of items that can fit in a single column
---@field itemsPerPage number @The number of items that can fit in a single page
---@field currentPage number @The current page number
---@field currentlyDisplayed table @An array of currently displayed widgets
---@field new fun(objectObtainerMethodOrObjectTable: function|table, objectWidgetWidth: number, objectWidgetHeight: number, windowBoundaries: table, paddingBetweenObjectWidgets: number, objectWidgetCreationFunction: function, creationFunctionArgsArray: table | nil): windowOfPages @Creates a new paged window

---@param objectObtainerMethodOrObjectTable function|table @Either a method that takes an index and returns an object, or a table of objects
---@param objectWidgetWidth number @The width of each object widget
---@param objectWidgetHeight number @The height of each object widget
---@param windowBoundaries table @A table with x1, y1, x2, y2 defining the area in which to display the widgets
---@param paddingBetweenObjectWidgets number @The padding between each widget object (default 5) 
---@param objectWidgetCreationFunction function @A function that takes (x, y, object, ...) and returns a widget representing the object
---@param creationFunctionArgsArray table | nil @An array of additional arguments to pass to the objectWidgetCreationFunction after the object (4th and >4th args) (default nil)   
---@return windowOfPages @A new arrangement of pages of whatever object type you specify. 
function pagedWindow.new(objectObtainerMethodOrObjectTable, objectWidgetWidth, objectWidgetHeight, windowBoundaries, paddingBetweenObjectWidgets, objectWidgetCreationFunction, creationFunctionArgsArray)
    local self = setmetatable({}, pagedWindow)
    self.items = objectObtainerMethodOrObjectTable
    self.itemWidth = objectWidgetWidth
    self.itemHeight = objectWidgetHeight
    self.padding = paddingBetweenObjectWidgets or 5
    self.renderItem = objectWidgetCreationFunction
    self.args = creationFunctionArgsArray or {}

    self.screenX1 = windowBoundaries.x1
    self.screenY1 = windowBoundaries.y1
    self.screenX2 = windowBoundaries.x2
    self.screenY2 = windowBoundaries.y2

    local availableWidth = self.screenX2 - self.screenX1
    local availableHeight = self.screenY2 - self.screenY1

    self.itemsPerRow = math.floor((availableWidth + self.padding) / (self.itemWidth + self.padding))
    self.itemsPerColumn = math.floor((availableHeight + self.padding) / (self.itemHeight + self.padding))
    self.itemsPerPage = self.itemsPerRow * self.itemsPerColumn

    if self.itemsPerPage < 1 then error("Window too small to display any items") end
    if self.itemsPerRow < 1 then error("Window too narrow to display any items") end
    if self.itemsPerColumn < 1 then error("Window too short to display any items") end

    self.currentPage = 1
    self.currentlyDisplayed = {}
    return self
end

function pagedWindow:clearDisplayedItems()
    for _, element2 in ipairs(self.currentlyDisplayed) do
        if element2[1].remove then
            element2[1].remove()
        end
    end
    self.currentlyDisplayed = {}
end

function pagedWindow:displayItems()
        self:clearDisplayedItems()

        local items = {}
        local startIndex
        local endIndex
        if type(self.items) == "function" then
            for i = ((self.currentPage * self.itemsPerPage)-self.itemsPerPage)+1, self.currentPage * self.itemsPerPage do
                local suc, err = pcall(function()
                    local item = self.items(i)
                    if not item then
                        table.insert(items, "nil nil nillie")
                    else
                        table.insert(items, item)
                    end
                end)
                if not suc then
                    break
                end
            end
            startIndex = 1
            endIndex = #items
        elseif type(self.items) == "table" then
            items = self.items
            startIndex = (self.currentPage - 1) * self.itemsPerPage + 1
            endIndex = math.min(self.currentPage * self.itemsPerPage, #self.items)
        end

        for i = startIndex, endIndex do
            local row = math.floor((i - startIndex) / self.itemsPerRow)
            local col = (i - startIndex) % self.itemsPerRow
            local x = self.screenX1 + col * (self.itemWidth + self.padding)
            local y = self.screenY1 + row * (self.itemHeight + self.padding)

            local item = items[i]
            local itemSlotNumber = self.itemsPerPage * (self.currentPage - 1) + i

            if item and item ~= "nil nil nillie" then
                local displayedItem = self.renderItem(x, y, item, table.unpack(self.args))
                table.insert(self.currentlyDisplayed, {displayedItem, itemSlotNumber})
            end
        end
end

function pagedWindow:nextPage()
    local totalPages
    if type(self.items) == "table" then
        totalPages = math.ceil(#self.items / self.itemsPerPage)
    elseif type(self.items) == "function" then
        local suc, err = pcall(function() return self.items((self.currentPage * self.itemsPerPage)+1) end)
        if suc then
            totalPages = self.currentPage + 1
        end
    else
        totalPages = 0
    end
                    
    if self.currentPage < totalPages then
        self.currentPage = self.currentPage + 1
        self:displayItems()
    end
end

function pagedWindow:prevPage()
    if self.currentPage > 1 then
        self.currentPage = self.currentPage - 1
        self:displayItems()
    end
end

return pagedWindow
