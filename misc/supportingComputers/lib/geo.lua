-- geo.lua — Geolyzer helpers (annotated)
-- Purpose: tiny utilities for aiming the geolyzer, denoising readings,
-- and doing small area scans. Written for OpenComputers / OpenOS.
-- Coords are (x, z, y) where +y is up. All offsets are *relative to the robot/analyzer*.

local component = require("component")
local sides = require("sides")
local serialization = require("serialization")
local ok_gimp, gimpHelper = pcall(require, "gimpHelper") -- optional helper lib

local geo = {}

-- =============================
-- Config (spelling kept to avoid breaking other files)
-- How many samples to take per spot for simple noise suppression.
-- 1 = no suppression; 10 is a nice default.
local noiseCancelationFactor = 10

-- =============================
-- Internals / utilities
local geolyzer = assert(component and component.geolyzer, "No geolyzer component found")
local db = assert(component and component.database, "No database component found")

geo.west = {-1, 0, 0}
geo.north = {0, -1, 0}
geo.south = {0, 1, 0}
geo.east = {1, 0, 0}
geo.up = {0, 0, 1}
geo.down = {0, 0, -1}
geo.none = {0, 0, 0}

---@alias direction
---| "west"
---| "north"
---| "south"
---| "east"
---| "up"
---| "down"
---| "none"

---Scans a single block in a given direction/magnitude combination, averaging multiple samples to suppress noise.
---@param NSEWUD1 direction
---@param amount1 integer
---@param NSEWUD2 direction|nil
---@param amount2 integer|nil
---@param NSEWUD3 direction|nil
---@param amount3 integer|nil
---@return number geoResult averaged hardness value
function geo.scanSpot(NSEWUD1, amount1, NSEWUD2, amount2, NSEWUD3, amount3)
    NSEWUD2 = NSEWUD2 or "none"
    amount2 = amount2 or 0
    NSEWUD3 = NSEWUD3 or "none"
    amount3 = amount3 or 0

    local x = geo[NSEWUD1][1] * amount1 + geo[NSEWUD2][1] * amount2 + geo[NSEWUD3][1] * amount3
    local z = geo[NSEWUD1][2] * amount1 + geo[NSEWUD2][2] * amount2 + geo[NSEWUD3][2] * amount3
    local y = geo[NSEWUD1][3] * amount1 + geo[NSEWUD2][3] * amount2 + geo[NSEWUD3][3] * amount3

    local rawScan = {}
    for i = 1, noiseCancelationFactor do
        rawScan[i] = component.geolyzer.scan(x, z, y, 1, 1, 1)[1]
    end

    local mathStats = gimpHelper.mathStats(rawScan)
    local geoResult = mathStats(rawScan).max + mathStats(rawScan).min / 2
    return geoResult
end

---Samples the block directly adjacent in the given direction and stores its data in the database and optionally sends via tunnel.
---@param NSEWUD direction
---@return table blockInfo contains label, hardness, name, and metadata
function geo.sampleBlock(NSEWUD)
    local hardness = geolyzer.analyze(sides[NSEWUD]).hardness
    geolyzer.store(sides[NSEWUD], db.address, 1)

    if component.tunnel then
        component.tunnel.send("block library send", serialization.serialize({
            label = db.get(1).label,
            hardness = hardness,
            name = db.get(1).name,
            metadata = db.get(1).metadata
        }))
    end

    return {
        label = db.get(1).label,
        hardness = hardness,
        name = db.get(1).name,
        metadata = db.get(1).metadata
    }
end

---Performs a full cubic scan (-32..32 in each axis), with noise suppression, returning a nested table of averaged hardness values.
---@return table scanResult 3D table indexed as [x][z][y]
function geo.fullScan()
    local scanResult = {}
    for i = -32, 32 do
        scanResult[i] = {}
        for j = -32, 32 do
            scanResult[i][j] = {}
            for k = -32, 32 do
                local rawScan = {}
                for v = 1, noiseCancelationFactor do
                    rawScan[v] = geolyzer.scan(i, j, k, 1, 1, 1)[1]
                end
                local mathStats = gimpHelper.mathStats(rawScan)
                scanResult[i][j][k] = (mathStats.max + mathStats.min) / 2
            end
        end
    end
    return scanResult
end

---Converts absolute coordinate deltas into direction strings and magnitudes.
---@param x number
---@param z number
---@param y number
---@return direction directionX
---@return integer magnitudeX
---@return direction directionZ
---@return integer magnitudeZ
---@return direction directionY
---@return integer magnitudeY
function geo.convertToVector(x, z, y)
    local directionX = "none"
    local directionZ = "none"
    local directionY = "none"

    if x >= 1 then directionX = "east"
    elseif x <= -1 then directionX = "west" end

    if z >= 1 then directionZ = "south"
    elseif z <= -1 then directionZ = "north" end

    if y >= 1 then directionY = "up"
    elseif y <= -1 then directionY = "down" end

    local magnitudeX = math.abs(x)
    local magnitudeZ = math.abs(z)
    local magnitudeY = math.abs(y)

    return directionX, magnitudeX, directionZ, magnitudeZ, directionY, magnitudeY
end

return geo
