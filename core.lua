-- List globals here for Mikk's FindGlobals script
-- GLOBALS: pairs, InCombatLockdown, AuraUtil, LibStub, Bartender4_BuffHider_DB

local addon, ns = ...

----------
-- Core --
----------

--@alpha@--
local function debugprint(message, ...)	
	print(message:format(...))
end
--@end-alpha@--

--[===[@non-alpha@
local function debugprint()
end
--@end-non-alpha@]===]

local DB
local BarRegistry = Bartender4.Bar.barregistry

local PendingShownStates = {}

-- Show or hide the specified bar
local function SetShown(barNumber, state)
	local bar = BarRegistry[barNumber]
	
	debugprint("SetShown bar %d: bar = %s, state = %s, in combat = %s", barNumber, bar and bar:GetName() or "", tostring(state), tostring(InCombatLockdown()))
	
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
		local aura = options.aura
		if aura and aura ~= "" then
			local state = not not AuraUtil.FindAuraByName(aura, "player") -- Coerce state to a boolean
			
			debugprint("Updating bar %d: Aura = %s, arua exists = %s, invert = %s", barNumber, aura, tostring(state), tostring(options.invert))
			
			if options.invert then
				state = not state
			end
			
			SetShown(barNumber, state)
		end
	end
end

ns.UpdateShownStates = UpdateShownStates

-- Perform any pending shown state changes
local function DoPendingStateChanges()
	debugprint("DoPendingStateChanges!")
	
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
		ns.InitOptions(DB)
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
