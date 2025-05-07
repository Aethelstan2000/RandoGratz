-- RandoGratzMinimap.lua

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("RandoGratz", {
    type = "data source",
    text = "RandoGratz",
    icon = "Interface\\AddOns\\RandoGratz\\minimapicon.tga", -- Choose any icon

    -- Left-click to toggle the options frame
    OnClick = function(self, button)
        if button == "LeftButton" then
            SlashCmdList["OPENRANDOGRATZ"]()
        end
    end,

    OnTooltipShow = function(tooltip)
        tooltip:AddLine("RandoGratz")
        tooltip:AddLine("Left-click to open settings", 1, 1, 1)
    end,
})

-- Create the minimap icon when saved variables are ready
local icon = LibStub("LibDBIcon-1.0")

-- Ensure DB structure exists
RandoGratzDB = RandoGratzDB or {}
RandoGratzDB.minimap = RandoGratzDB.minimap or {}

icon:Register("RandoGratz", LDB, RandoGratzDB.minimap)
