-- List globals here for Mikk's FindGlobals script
-- GLOBALS: type, InterfaceOptionsFrame_OpenToCategory, LibStub, SLASH_BARTENDER4_BUFFHIDER1, SLASH_BARTENDER4_BUFFHIDER2, SLASH_BARTENDER4_BUFFHIDER3

local addon, ns = ...

local DB

local function Get(info)
	local optionName, barNumber = info[#info], info[#info - 1]
	return DB.profile[barNumber][optionName]
end

local function Set(info, value)	
	local optionName, barNumber = info[#info], info[#info - 1]
	DB.profile[barNumber][optionName] = value
	
	ns.UpdateShownStates()
end

local function Aura_Set(info, value)
	if value:find("|Hspell", 1, true) then -- If the user links a spell, use the spell name as the value
		value = value:match("|Hspell:%d+|h%[(.+)%]|h")
	else -- Otherwise trim the input
		value = value:trim()
	end

	Set(info, value)
end

local options = {
	name = "Bartender4 Buff Hider",
	type = "group",
	args = {}
}

for barNumber = 1, 10 do
	options.args[tostring(barNumber)] = {
		name = ("Bar %d"):format(barNumber),
		order = barNumber,
		type = "group",
		args = {
			aura = {
				name = "Aura",
				desc = "The buff/debuff that controls this bar. Leave blank if you want to ignore this bar.",
				type = "input",
				dialogControl = "SpellEditBox",
				get = Get,
				set = Aura_Set
			},
			invert = {
				name = "Invert",
				desc = "If checked, inverts the logic of this bar so that it's shown when you don't have the aura and hidden when you do. If unchecked, the bar is shown when you have the aura and hidden when you don't.",
				type = "toggle",
				get = Get,
				set = Set
			},
		}
	}
end

local optionsFrame

-- Called during ADDON_LOADED when the SavedVariables have been loaded
function ns.InitOptions(db)
	DB = db
	
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(DB)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addon, options)
	optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addon, "Bartender4 Buff Hider")
end

local firstUse = true

SLASH_BARTENDER4_BUFFHIDER1, SLASH_BARTENDER4_BUFFHIDER2, SLASH_BARTENDER4_BUFFHIDER3 = "/bt4bh", "/bt4buffhider", "/bartender4buffhider"
SlashCmdList.BARTENDER4_BUFFHIDER = function(input, editBox)
	InterfaceOptionsFrame_OpenToCategory(optionsFrame)
	
	-- If this is the first use of the slash command,
	-- the first call of InterfaceOptionsFrame_OpenToCategory will only open the options frame.
	-- The second call will correctly navigate to the AddOn's category.
	if firstUse then
		InterfaceOptionsFrame_OpenToCategory(optionsFrame)
		firstUse = false
	end
end