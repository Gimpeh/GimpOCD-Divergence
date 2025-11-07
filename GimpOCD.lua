local widgetsAreUs = require("GimpOCD-Divergence.lib.widgetsAreUs")
local event = require("event")
local powerDisplay = require("GimpOCD-Divergence.GimpOCD.powerDisplay")
local configurableWindows = require("GimpOCD-Divergence.lib.configurableWindows")
local inventoryManager = require("GimpOCD-Divergence.GimpOCD.modules.inventoryManager")
local modules = require("GimpOCD-Divergence.GimpOCD.modules.modules")
local ui = require("GimpOCD-Divergence.GimpOCD.ui")
local component = require("component")

component.glasses.removeAll()


local resPull = widgetsAreUs.popUp(200, 250, 150, 100, "Remove and Replace Glasses", "take them off", "and put them back on")
local _, _, name, xRes, yRes = event.pull("glasses_on")
resPull.remove()

modules.init({
    inventoryManager = inventoryManager
})

ui.init({
    inventoryManager = inventoryManager,
    configurableWindows = configurableWindows,
    powerDisplay = powerDisplay,
    resolution = {x = xRes, y = yRes}
})

while true do
    os.sleep(10)
end