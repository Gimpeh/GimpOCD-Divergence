local inventoryManager

local modules = {modules = {
    ["Inventory Manager"] = function(x, y, width, height)
        inventoryManager.init(x, y, width, height)
    end}
}

modules.init = function(dependencies)
    inventoryManager = dependencies.inventoryManager
end

return modules