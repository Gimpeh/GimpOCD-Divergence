local component = require("component")
local serialization = require("serialization")
local sides = require("sides")
local event = require("event")

local server = {}
server.capacitors = {}
local capacitorControl = component.proxy("8103930b-8a69-44a4-bdae-d8ac9de62aae")
local powerPort = 100
component.modem.open(powerPort)

------------------------------

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

local function sendPowerStats()
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
end

-----------------------------

local biodieselPort = 101
component.modem.open(biodieselPort)

local biodieselTransposer = component.proxy("3aad8060-033d-4ea4-b7c0-2188b1a27b03")

local function getBiodiesel()
  local stupidDoubleTable = biodieselTransposer.getFluidInTank(sides.south)
  return stupidDoubleTable[1]
end

local function sendBiodieselStats()
    component.modem.broadcast(biodieselPort, serialization.serialize(getBiodiesel()))
end
-----------------------------

local transposerPort = 102
component.open(transposerPort)

local transposers = {}
transposers.grinder = component.proxy("e1ba8c12-f234-48a9-b586-66eef4caccc2")
transposers.furnace = component.proxy("30a9db7e-8dfc-4f3b-b0a5-0b9a268894a2")
transposers.crusher = component.proxy("4462c095-5d68-4689-a36d-cc2819586193")
transposers.smeltery = component.proxy("c7a3f09b-a520-4d5e-8047-49cb30422974")
transposers.assembly = component.proxy("6db0a0de-897e-44fb-a03e-9e4cbd296ccf")

local function onModemMessage(eventName, address, address2, port, distance, message)
    if port == transposerPort then
        local command = serialization.unserialize(message)
        if command.id == "to_crusher" then
            transposers.crusher.transferItem(sides.down, sides.east, transposers.crusher.getStackInSlot(sides.south, command.slotNum).size, command.slotNum)
        elseif command.id == "to_grinder" then
            transposers.grinder.transferItem(sides.down,sides.east, transposers.grinder.getStackInSlot(command.slotNum).size, command.slotNum)
        elseif command.id == "to_smeltery" then
            transposers.smeltery.transferItem(sides.down,sides.north, transposers.smeltery.getStackInSlot(command.slotNum).size, command.slotNum)
        elseif command.id == "to_furnace" then
            transposers.furnace.transferItem(sides.down,sides.north, transposers.furnace.getStackInSlot(command.slotNum).size, command.slotNum)
        elseif command.id == "to_assembly" then
            transposers.assembly.transferItem(sides.down,sides.north, transposers.assembly.getStackInSlot(command.slotNum).size, command.slotNum)
        end
    end
end

event.listen("modem_message", onModemMessage)

--item_overseer.transposers.crusher.transferItem(sides.down, sides.east, item_overseer.transposers.crusher.getStackInSlot(element[2]).size, element[2])




-----------------------------
while true do
    sendPowerStats()
    sendBiodieselStats()
    os.sleep(10)
end

