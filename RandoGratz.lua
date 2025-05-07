-- Ace3 Configuration Setup
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local options = {
    name = "RandoGratz",
    type = "group",
    args = {
        openConfig = {
            type = "execute",
            name = "Open RandoGratz Config",
            func = function()
                SlashCmdList["OPENRANDOGRATZ"]()
            end,
        },
    },
}

-- Register in Blizzard options but disable auto UI
AceConfig:RegisterOptionsTable("RandoGratz", options)
--AceConfigDialog:AddToBlizOptions("RandoGratz", "RandoGratz (use /rgcfg)")

-- Saved variables
RandoGratzDB = RandoGratzDB or { messages = {"Default message 1", "Default message 2"} }
if RandoGratzDB.autoGratzEnabled == nil then
    RandoGratzDB.autoGratzEnabled = true
end

-- Cooldown for manual /rg
local lastManualGratzTime = 0
local manualCooldownDuration = 10

-- Send a random message
local function SendRandomMessage(channel)
    if #RandoGratzDB.messages > 0 then
        local message = RandoGratzDB.messages[math.random(#RandoGratzDB.messages)]
        SendChatMessage(message, channel)
    else
        print("RandoGratz: No messages available.")
    end
end

-- /rg command
SLASH_RANDOGRATZ1 = "/rg"
SlashCmdList["RANDOGRATZ"] = function(msg)
    local currentTime = GetTime()
    if currentTime - lastManualGratzTime < manualCooldownDuration then
        --print("|cffff0000[RandoGratz]|r Manual gratz is on cooldown. Please wait.")
        return
    end

    local channel = msg:lower()
    if channel == "guild" then
        SendRandomMessage("GUILD")
    elseif channel == "say" then
        SendRandomMessage("SAY")
    elseif channel == "party" then
        SendRandomMessage("PARTY")
    else
        print("Usage: /rg guild, /rg say, /rg party")
        return
    end

    lastManualGratzTime = currentTime
end

-- /rgcfg toggles the settings frame
SLASH_OPENRANDOGRATZ1 = "/rgcfg"
SlashCmdList["OPENRANDOGRATZ"] = function()
    CreateRandoGratzFrame()
    if RandoGratzFrame:IsShown() then
        RandoGratzFrame:Hide()
    else
        UpdateMessageList()
        RandoGratzFrame:Show()
    end
end

-- AutoGratz listener
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")

local lastGratzTime = 0
local cooldownDuration = 10

eventFrame:SetScript("OnEvent", function(_, event, _, sender)
    if event ~= "CHAT_MSG_GUILD_ACHIEVEMENT" or not RandoGratzDB.autoGratzEnabled then return end

    local currentTime = GetTime()
    if currentTime - lastGratzTime < cooldownDuration then
        --print("|cffff0000[DEBUG]|r AutoGratz is on cooldown! Skipping message.")
        return
    end
    lastGratzTime = currentTime

    local playerName = UnitName("player"):match("^(%S+)") or ""
    sender = sender:match("^(.-)-") or sender
    if sender == playerName then return end

    local delay = math.random(1, 5)
    C_Timer.After(delay, function()
        if #RandoGratzDB.messages > 0 then
            local msg = string.format(RandoGratzDB.messages[math.random(#RandoGratzDB.messages)], sender)
            SendChatMessage(msg, "GUILD")
        end
    end)
end)
