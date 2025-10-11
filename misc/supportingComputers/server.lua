local component = require("component")
local serialization = require("serialization")

local server = {}
server.capacitors = {}
local capacitorControl = component.proxy("8103930b-8a69-44a4-bdae-d8ac9de62aae")
local powerPort = 100
component.modem.open(powerPort)


for k, v in component.list("ie_hv_capacitor") do
  table.insert(server.capacitors, component.proxy(k))
end

local function getTotalEnergy()
  local totalEnergy = 0
  for _, capacitor in ipairs(server.capacitors) do
    totalEnergy = totalEnergy + capacitor.getEnergyStored()
  end
  return totalEnergy
end

local function getMaxEnergy()
  local maxEnergy = 0
  for _, capacitor in ipairs(server.capacitors) do
    maxEnergy = maxEnergy + capacitor.getMaxEnergyStored()
  end
  return maxEnergy
end

while true do
    local stats = {}
    stats.totalEnergy = getTotalEnergy()
    stats.maxEnergy = getMaxEnergy()
    stats.energyPercentage = (stats.totalEnergy / stats.maxEnergy) * 100

    if stats.energyPercentage < 20 then
        capacitorControl.setOutput({0,0,0,0,0,0})
    elseif stats.energyPercentage > 80 then
        capacitorControl.setOutput({15,15,15,15,15,15})
    end

    component.modem.broadcast(powerPort, serialization.serialize(stats))
    os.sleep(10)
end

