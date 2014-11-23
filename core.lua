-- List globals here for Mikk's FindGlobals script
-- GLOBALS: pairs, InCombatLockdown, UnitAura, LibStub, Bartender4_BuffHider_DB

local addon, ns = ...

----------
-- Core --
----------

local DB
local BarRegistry = Bartender4.Bar.barregistry

local PendingShownStates = {}

-- Show or hide the specified bar
local function SetShown(barNumber, state)
	local bar = BarRegistry[barNumber]
	if not bar then return end
	
	if InCombatLockdown() then -- If we're in combat, save the shown state and show/hide the bar as required when we leave combat
		PendingShownStates[barNumber] = state
	else
		bar:SetShown(state)
	end
end

-- Update the shown state of all bars
local function UpdateShownStates()
	for barNumber, options in pairs(DB.profile) do
		local state = not not UnitAura("player", options.aura) -- Coerce state to a boolean
		
		if options.invert then
			state = not state
		end
		
		SetShown(barNumber, state)
	end
end

-- Perform any pending shown state changes
local function DoPendingStateChanges()
	for barNumber, state in pairs(PendingShownStates) do
		SetShown(barNumber, state)
		PendingShownStates[barNumber] = nil
	end
end

------------
-- Events --
------------

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterUnitEvent("UNIT_AURA", "player")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

local dbDefaults = {
	profile = {}
}

for barNumber = 1, 10 do
	dbDefaults.profile[tostring(barNumber)] = {
		invert = false,
		spell = ""
	}
end

function f:ADDON_LOADED(name)
	if name == addon then
		DB = LibStub("AceDB-3.0"):New("Bartender4_BuffHider_DB", dbDefaults)
		ns.InitOptions()
	end
end

function f:PLAYER_ENTERING_WORLD()
	UpdateShownStates()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD") -- Only update the shown states when the player first logs in
end

function f:UNIT_AURA(unit)
	UpdateShownStates()
end

function f:PLAYER_REGEN_ENABLED()
	DoPendingStateChanges()
end
