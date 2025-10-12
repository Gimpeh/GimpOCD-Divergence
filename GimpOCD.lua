local event = require("event")
local widgetsAreUs = require("lib.widgetsAreUs")
local component = require("component")
local s = require("serialization")
local powerDisplay = require("modules.powerDisplay")

component.modem.open(100)
component.modem.open(101)


local initAlert = widgetsAreUs.notification(200, 100, "Take off your glasses and put them back on")
local _, _, playerName, xRes, yRes = event.pull("glasses_on")

powerDisplay.init(xRes)

local function onModemMessage(eventName, address, address2, port, distance, message)
    if port == 100 then
        local stats = s.unserialize(message)
        if stats then
            powerDisplay.update(stats)
        end
    elseif port == 101 then
        local stats = s.unserialize(message)
        if stats then
            powerDisplay.update(stats)
        end
    end
end

event.listen("modem_message", onModemMessage)