-- An EditBox widget with an icon for spells.
-- Reuses an AceGUI EditBox widget and uses icon code taken from the Label widget

-- List globals here for Mikk's FindGlobals script
-- GLOBALS: pairs, hooksecurefunc, CreateFrame, GetSpellTexture, UIParent

local Type, Version = "SpellEditBox", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

-----------------------
-------- Hooks --------
-----------------------

local function Frame_SetPoint(frame, ...)
	frame.obj:FixStrata()
end

-----------------------
------- Scripts -------
-----------------------
local function Frame_OnShow(frame)
	frame.obj:FixStrata()
end

local function EditBox_OnTextChanged(frame)
	local spellEditBox = frame.spellEditBox
	
	local spellName = spellEditBox:GetText()
	spellName = spellName and spellName:trim()
	
	spellEditBox:SetIcon(GetSpellTexture(spellName))
end

local function EditBox_OnEnterPressed(editbox, name, value)
	editbox.editbox.spellEditBox:Fire("OnEnterPressed", value)
end

-----------------------
------- Methods -------
-----------------------

local methods = {
	["OnAcquire"] = function(self)
		self.editbox.frame:Show()
		self.editbox:OnAcquire()
		
		self:SetIconSize(26)
		self:SetWidth(200)
		self:SetText()
		self:SetIcon(nil)
	end,
	
	["OnRelease"] = function(self)
		self.editbox.frame:Hide()
		self.editbox:OnRelease()
	end,
	
	["OnHeightSet"] = function(self, height)
		self.editbox:SetHeight(height)
		self:SetIconSize(height)
	end,
	
	["OnWidthSet"] = function(self, width)
		self.editbox:SetWidth(width - (self.icon:GetWidth() + 5))
	end,
	
	["FixStrata"] = function(self)
		local frame, editboxFrame = self.frame, self.editbox.frame
		editboxFrame:SetFrameStrata(frame:GetFrameStrata())
		editboxFrame:SetFrameLevel(frame:GetFrameLevel() + 1)
	end,
	
	["SetDisabled"] = function(self, disabled)
		self.editbox:SetDisabled(disabled)
	end,
	
	["SetText"] = function(self, text)
		self.editbox:SetText(text)
	end,
	
	["GetText"] = function(self, text)
		return self.editbox:GetText()
	end,
	
	["SetLabel"] = function(self, text)
		self.editbox:SetLabel(text)
		self:SetHeight((text and text ~= "") and 44 or 26)
	end,
	
	["DisableButton"] = function(self, disabled)
		self.editbox:DisableButton(disabled)
	end,
	
	["SetMaxLetters"] = function (self, num)
		self.editbox:SetMaxLetters(num)
	end,
	
	["ClearFocus"] = function(self)
		self.editbox:ClearFocus()
	end,

	["SetFocus"] = function(self)
		self.editbox:SetFocus()
	end,

	["SetIcon"] = function(self, path)
		self.icon:SetTexture(path or DEFAULT_ICON)
	end,
	
	["SetIconSize"] = function(self, size)
		self.icon:SetWidth(size)
		self.icon:SetHeight(size)
	end,
}

-----------------------
----- Constructor -----
-----------------------

local function Constructor()
	local num  = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", "AceGUI-3.0SpellEditBox" .. num, UIParent)
	frame:SetHeight(26)
	frame:Hide()
	
	frame:SetScript("OnShow", Frame_OnShow)
	hooksecurefunc(frame, "SetPoint", Frame_SetPoint)
	
	local editbox = AceGUI:Create("EditBox")
	editbox:SetParent(frame)
	
	editbox.editbox:HookScript("OnTextChanged", EditBox_OnTextChanged)
	editbox:SetCallback("OnEnterPressed", EditBox_OnEnterPressed)

	local icon = frame:CreateTexture(nil, "BACKGROUND")
	icon:SetSize(26, 26)
	icon:SetPoint("LEFT")
	
	editbox:SetPoint("LEFT", icon, "RIGHT", 5, 0)
	
	local widget = {
		alignoffset = 30,
		type = Type,
		frame = frame,
		editbox = editbox,
		icon = icon
	}
	
	for method, func in pairs(methods) do
		widget[method] = func
	end
	
	editbox.editbox.spellEditBox = widget
	
	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
