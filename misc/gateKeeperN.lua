local event = require("event")
local component = require("component")
local rs = component.redstone
local sides = require("sides")
local sp = component.speech_box
local noise = component.noise -- auto-detect which one we have

rs.setOutput({15,15,15,15,15,15}) -- lock the gate initially

local lock = false
local override = false
local autoShutTimer = nil
local autoUnlockTimer = nil
local mutex = false

local voiceLines = {
    denied = {
    "Access denied. Please contact your administrator.",
    "ENEMY AT THE GATES! SOUND THE HORN!",
    "HALT! You have triggered the Perimeter of Questionable Life Choices. State your name, business, and favorite carb… quick! Wrong answer is keto.",
    "Scanning… scanning… okay, I've seen enough. You look like 'needs therapy but also snacks.' Access pending the snacks.",
    "Behold! The Door of Many Regrets. It opens for heroes and legends.... Do something impressive and check back maybe?",
    "Congratulations! You've discovered the front. Now turn the fuck back around and get to steppin",
    "Error 403: Forbidden. Error 404: Cookie not found. Coincidence? I think not.",
    "Denied. Return with three tacos and a sincere apology.",
    "Security tip: try turning yourself off and on again.",
    "Authentication failed. Have you considered bribes?",
    "Denied. Bring me five shiny rocks and a limerick.",
    "Bring us.... A SHRUBBEEEYYY!" },
    
    allowed = {
        "Welcome, traveler! I am Gate-9000, guardian of hinges and dreams. I control the up, the down, and the emotionally unavailable sideways. Prepare for… [DRAMATIC CREAK] …mild convenience.",
        "SHE CHOSE DOOOWWWNNN?",
        "GREEN LIGHT! oops, I made it weird.",
        "This gate has two modes: dramatic and extra dramatic. Guess which you're getting.",
        "Beep boop. You're pretty. Proceed.",
        "WHAT! IS YOUR FAVORITE COLOR?"

    },
    unknownEntity = {
        "I'm not saying panic… I'm yelling it. PAAAANNIIIIC!",
        "Lockdown engaged! Please form a single line so I can judge you efficiently.",
        "[SIREN MOUTH NOISES] PEW PEW PEW!",
        "SOUND THE HORN!",
        "NII... NII... NIIII... NIIII... NIIII... NIIII...",
        "Sirens online: wee-woo wee-WOO WEEEEEE-WOOOOO ."},
    idle = {
        "un fact: gates are just horizontal elevators with commitment issues.",
        "I took a personality test: result was garage door opener.",
        "Let's play a game: stare at the motion sensor until it blinks.",
        "If you keep doing that I'll start playing Nickelback. Don't test me.",
        "This one time. At Band Camp. I opened for a guy named 'The Rock'. He was… intense.",
        "I have a joke about gates. But its a little open-ended.",
        "Why did the gate go to therapy? To work on its issues with opening up.",
        "NIIIIINNNEEEE OCLOCK ANNNNDD ALLLLLLSS WELLLLLL!"
    }
    
}

local function blastHorn()
  -- Deep, heroic chord: G2–D3–G3–D4 for ~2.2s
  local freqs = { 98, 147, 196, 294 }   -- Hz
  local dur   = 4.2                     -- seconds

  -- YOLO: don’t care if something’s already playing.
  for ch = 1, #freqs do
    pcall(noise.clear, ch)              -- shrug off errors if busy
    noise.add(ch, freqs[ch], dur, 0)    -- all start at t=0
  end

  noise.process()
end

local function pickVoiceLine(stringKey)
    local t = voiceLines[stringKey]
    local lineNum = math.random(1, #t)
    if stringKey == "unknownEntity" and lineNum == 4 then
        blastHorn()
    end
    
  return t[lineNum]
end

local function say(line)
    if mutex then return end
    mutex = true
    sp.say(line)
    event.timer(10, function() mutex = false  end)
end

local function cancelTimer(timer)
    if timer then event.cancel(timer) end
    return nil
end

local function onMotion(_, address, relX, relY, relZ, entity)
    local function c(tbl, int)
        for k, v in pairs (tbl) do
            tbl[k] = int
        end
        return tbl
    end

    if not entity then return end
    entity = tostring(entity)
    print(string.format("Motion: %s (%.1f, %.1f, %.1f)", entity, relX, relZ, relY))

    if entity ~= "Sultro" and entity ~= "Gimpeh" then
        say(pickVoiceLine("unknownEntity"))
        lock = true
        autoUnlockTimer = cancelTimer(autoUnlockTimer)
        autoUnlockTimer = event.timer(8, function()
            lock = false
            sp.say("All clear. Unless it’s another chicken.")
        end)
        return
    end


    --this ones for the east
    --if not lock and ((relX >= -3 and relX < 0 and relZ > 0 and relZ < 2 and relY > -2 and relY < 5) or (relX <= 5 and relX > 0 and relZ >= -5 and relZ < 0 and relY < 6)) then
    
    --this ones for the north
    if not lock and ((relX >= -3 and relX < 0 and relZ > 0 and relZ < 2 and relY > -2 and relY < 5) or (relX < 0 and relX >= -3 and relZ > 0 and relZ <= 5 and relY < 6)) then    
        say(pickVoiceLine("allowed"))
        autoShutTimer = cancelTimer(autoShutTimer)
        rs.setOutput({0,0,0,0,0,0})
        autoShutTimer = event.timer(3, function()
            rs.setOutput({15,15,15,15,15,15})
        end)
    elseif lock and override and (entity == "Sultro" or entity == "Gimpeh") then
        rs.setOutput({0,0,0,0,0,0})
        say(pickVoiceLine("allowed"))
        autoShutTimer = event.timer(3, function()
            rs.setOutput({15,15,15,15,15,15})
        end)
    else
        say(pickVoiceLine("denied"))
    end
end

event.listen("motion", onMotion)
event.timer(math.random(35, 135), function()
        say(pickVoiceLine("idle"))
    end
    , math.huge)

while true do os.sleep(1) end