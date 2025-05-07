-- RandoGratzFrame.lua

local frameCreated = false
local messageEntries = {}

function CreateRandoGratzFrame()
    if frameCreated then return end
    frameCreated = true

    -- Main frame
    local frame = CreateFrame("Frame", "RandoGratzFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(800, 600)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    -- Checkbox
    local checkbox = CreateFrame("CheckButton", "AutoGratzCheckbox", frame, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
    checkbox:SetSize(24, 24)

    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    label:SetText("Enable AutoGratz")

    checkbox:SetChecked(RandoGratzDB.autoGratzEnabled)
    checkbox:SetScript("OnClick", function(self)
        RandoGratzDB.autoGratzEnabled = self:GetChecked()
        print("|cffFFD700[RandoGratz]|r AutoGratz is now " .. (RandoGratzDB.autoGratzEnabled and "|cff00ff00ENABLED|r" or "|cffff0000DISABLED|r"))
    end)

    -- Background
    local bgFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    bgFrame:SetSize(782, 565)
    bgFrame:SetPoint("TOPLEFT", 8, -28)

    local background = bgFrame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(bgFrame)
    background:SetTexture("Interface/AddOns/RandoGratz/IceniBackground.tga")

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOP", frame, "TOP", 0, -5)
    title:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    title:SetText("|cFFFFD700RandoGratz!|r")

    -- Scrollable message list
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(740, 500)
    scrollFrame:SetPoint("TOPLEFT", 10, -50)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
    contentFrame:SetSize(740, 500)
    scrollFrame:SetScrollChild(contentFrame)

    -- UpdateMessageList function (global)
    function UpdateMessageList()
        for _, entry in ipairs(messageEntries) do entry:Hide() end
        wipe(messageEntries)

        for i, msg in ipairs(RandoGratzDB.messages) do
            local indexText, bg, box, removeButton = CreateMessageEntry(i, msg, contentFrame)
            table.insert(messageEntries, indexText)
            table.insert(messageEntries, bg)
            table.insert(messageEntries, box)
            table.insert(messageEntries, removeButton)
        end

        local _, bg, box, addButton = CreateMessageEntry(nil, "", contentFrame)
        table.insert(messageEntries, bg)
        table.insert(messageEntries, box)
        table.insert(messageEntries, addButton)
    end

    -- Expose the frame globally
    _G["RandoGratzFrame"] = frame
end

-- Reusable entry creation (optional to move to RandoGratz.lua instead)
function CreateMessageEntry(index, text, parent)
    local yOffset = -((index and (index - 1) * 62 + 35 or (#RandoGratzDB.messages + 1) * 62 - 25))

    local indexText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    indexText:SetPoint("TOPLEFT", 10, yOffset)
    indexText:SetJustifyH("RIGHT")
    indexText:SetWidth(30)
    if index then indexText:SetText(index .. ":") end

    local bg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    bg:SetSize(600, 60)
    bg:SetPoint("TOPLEFT", indexText, "TOPRIGHT", 5, 0)
    bg:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    bg:SetBackdropColor(0, 0, 0, 0.8)

    local box = CreateFrame("EditBox", nil, bg)
    box:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    box:SetMultiLine(true)
    box:SetMaxLetters(255)
    box:SetJustifyH("LEFT")
    box:SetJustifyV("TOP")
    box:SetPoint("TOPLEFT", bg, "TOPLEFT", 10, -10)
    box:SetSize(580, 60)
    box:SetText(text or "")
    box:SetAutoFocus(false)
    box:Show()

    if index then
        box:EnableMouse(false)
        local remove = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        remove:SetSize(60, 30)
        remove:SetPoint("TOPLEFT", bg, "TOPRIGHT", 5, 0)
        remove:SetText("Remove")
        remove:SetScript("OnClick", function()
            table.remove(RandoGratzDB.messages, index)
            UpdateMessageList()
        end)
        return indexText, bg, box, remove
    else
        local add = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        add:SetSize(60, 30)
        add:SetPoint("TOPLEFT", bg, "TOPRIGHT", 5, 0)
        add:SetText("Add")
        add:SetScript("OnClick", function()
            local msg = box:GetText()
            if msg and msg ~= "" then
                table.insert(RandoGratzDB.messages, msg)
                box:SetText("")
                UpdateMessageList()
            end
        end)
        return nil, bg, box, add
    end
end
