-- The name of the buff/debuff to show/hide the bar based on.
local AURA_NAME = "Dark Intent"

-- The number of the bar to show/hide.
local BAR_NUMBER = 6

-- If true, the bar will be shown when the aura is not present. If false, the bar will be shown when the aura is present.
local INVERT = true

-------------------
-- END OF CONFIG --
-------------------
-- Do not change anything below here

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

f:RegisterUnitEvent("UNIT_AURA", "player")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

local bar
local PendingShownState = nil

local function SetShown(state)
	bar = bar or Bartender4.Bar.barregistry[tostring(BAR_NUMBER)]
	if not bar then return end
	
	state = not not state -- Coerce state to a boolean
	
	if InCombatLockdown() then -- If we're in combat, save the shown state and show/hide the bar as required when we leave combat
		PendingShownState = state
	else
		bar:SetShown(state)
	end
end

function f:UNIT_AURA(unit)
	local state = UnitAura("player", AURA_NAME)
	
	if INVERT then
		state = not state
	end
	
	SetShown(state)
end

function f:PLAYER_REGEN_ENABLED()
	if PendingShownState ~= nil then -- The shown state changed in combat, show/hide the bar now that we're not in combat any more
		SetShown(PendingShownState)
		PendingShownState = nil
	end
end
