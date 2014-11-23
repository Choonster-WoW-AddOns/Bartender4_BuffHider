-- List globals here for Mikk's FindGlobals script
-- GLOBALS: type, InterfaceOptionsFrame_OpenToCategory, LibStub, SLASH_BARTENDER4_BUFFHIDER1, SLASH_BARTENDER4_BUFFHIDER2, SLASH_BARTENDER4_BUFFHIDER3

local addon, ns = ...

local DB

local function Get(info)
	local optionName, barNumber = info[#info], info[#info - 1]
	return DB.profile[barNumber][optionName]
end

local function Set(info, value)
	if type(value) == "string" then
		value = value:trim()
	end
	
	local optionName, barNumber = info[#info], info[#info - 1]
	DB.profile[barNumber][optionName] = value
end

local options = {
	type = "group",
	args = {}
}

for barNumber = 1, 10 do
	options.args[tostring(barNumber)] = {
		name = ("Bar %d"):format(barNumber),
		type = "group",
		inline = true,
		args = {
			aura = {
				name = "Aura",
				desc = "The buff/debuff that controls this bar. Leave blank if you want to ignore this bar.",
				type = "input",
				get = Get,
				set = Set
			},
			invert = {
				name = "Invert",
				desc = "If checked, inverts the logic of this bar so that it's shown when you don't have the aura and hidden when you do. If unchecked, the bar is shown when you have the aura and hidden when you don't.",
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

SLASH_BARTENDER4_BUFFHIDER1, SLASH_BARTENDER4_BUFFHIDER2, SLASH_BARTENDER4_BUFFHIDER3 = "/bt4bh", "/bt4buffhider", "/bartender4buffhider"
SlashCmdList.BARTENDER4_BUFFHIDER = function(input, editBox)
	InterfaceOptionsFrame_OpenToCategory(optionsFrame)
end