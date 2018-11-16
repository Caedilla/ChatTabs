local nibChatTabs = LibStub("AceAddon-3.0"):NewAddon("nibChatTabs", "AceConsole-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local db

local defaults = {
	profile = {
		font = {
			name = "Friz Quadrata TT",
			size = 12,
		},
		textposition = {
			normal = {x = 0, y = 0},
			combatlog = {x = 0, y = 1},
		},
		hide = {
			tab = true,
			highlight = true,
			selected = true,
			flash = true,
		},
		alphas = {
			chatframe = 0,
			hidetabs = false,
			nomousealpha = {
				selected = 0,
				normal = 0,
				flash = 1,
			},
			mouseoveralpha = {
				selected = 1,
				normal = .75,
				flash = 1,
			},
			fadetimes = {
				fadein = {
					delay = 0.2,
					speed = 0.15,
				},
				fadeout = {
					delay = 1,
					speed = 2,
				},
			},
		},
		normal = {
			outline = "NONE",
			shadow = {
				useshadow = true,
				color = {r = 0, g = 0, b = 0, a = 1},
				position = {x = 1, y = -1},
			},
			colors = {
				class = {
					enabled = false,
					shade = 0.50,
				},
				r = 0.50, g = 0.50, b = 0.50,
			},
		},
		selected = {
			outline = "NONE",
			shadow = {
				useshadow = true,
				color = {r = 0, g = 0, b = 0, a = 1},
				position = {x = 1, y = -1},
			},
			colors = {
				class = {
					enabled = false,
					shade = .9,
				},
				r = .9, g = .9, b = .9,
			},
		},
		highlight = {
			outline = "NONE",
			shadow = {
				useshadow = true,
				color = {r = 0, g = 0, b = 0, a = 1},
				position = {x = 1, y = -1},
			},
			colors = {
				class = {
					enabled = false,
					shade = 1,
				},
				r = 1, g = 1, b = 1,
			},
		},
		flash = {
			outline = "NONE",
			shadow = {
				useshadow = true,
				color = {r = 0, g = 0, b = 0, a = 1},
				position = {x = 1, y = -1},
			},
			colors = {
				class = {
					enabled = false,
					shade = 1,
				},
				r = 1, g = 1, b = 0.1,
			},
		},
	},
}

local TabTextMoved = {}
local UClass, UClassColors

-- LSM Retrieval
local function RetrieveFont(font)
	font = LSM:Fetch("font", font)
	if font == nil then font = GameFontNormalSmall:GetFont() end
	return font
end

-- Tab Style update
local TStyleColors = {}
local TShadow = {
	colors = {},
	position = {x = 0, y = 0},
}
local function UpdateTabStyle(self, style)
	-- Retrieve FontString of tab
	if self.GetFontString then
		self = self:GetFontString()
	else
		self = self:GetParent():GetFontString()
	end
	
	
	local R_Frame = self:GetName()
	R_Frame = R_Frame:gsub("TabText","")
	R_Frame = R_Frame:gsub("ChatFrame","R_ChatTabText")
	R_Frame = _G[R_Frame]
	

	if db[style].colors.class.enabled then
		local shade = db[style].colors.class.shade
		TStyleColors = {UClassColors.r * shade, UClassColors.g * shade, UClassColors.b * shade}
	else
		TStyleColors = {db[style].colors.r, db[style].colors.g, db[style].colors.b}
	end
	
	-- Shadow
	TShadow.position.x, TShadow.position.y = db[style].shadow.position.x, db[style].shadow.position.y
	if db[style].shadow.useshadow then
		TShadow.colors = {db[style].shadow.color.r, db[style].shadow.color.g, db[style].shadow.color.b, db[style].shadow.color.a}
	else
		TShadow.colors = {0, 0, 0, 0}
	end
	
	-- Set new colors
	local font = RetrieveFont(db.font.name)
	self:SetFont(font, db.font.size, db[style].outline)
	self:SetTextColor(unpack(TStyleColors))
	self:SetShadowColor(unpack(TShadow.colors))
	self:SetShadowOffset(TShadow.position.x, TShadow.position.y)
	
	R_Frame:SetFont(font, db.font.size, db[style].outline)
	R_Frame:SetTextColor(unpack(TStyleColors))
	R_Frame:SetShadowColor(unpack(TShadow.colors))
	R_Frame:SetShadowOffset(TShadow.position.x, TShadow.position.y)
	
end

local function UpdateMine()
	for i = 1, 10 do
		UIFrameFadeRemoveFrame(_G["R_ChatTabText"..i])
		_G["R_ChatTabText"..i]:SetAlpha(_G["ChatFrame"..i.."Tab"].noMouseAlpha)
		UIFrameFadeOut(_G["R_ChatTabText"..i], CHAT_FRAME_FADE_OUT_TIME, _G["ChatFrame"..i.."Tab"]:GetAlpha(), _G["ChatFrame"..i.."Tab"].noMouseAlpha);
	end
end

local function UpdateMineEnter(self)
	for i = 1, 10 do
		UIFrameFadeRemoveFrame(_G["R_ChatTabText"..i])
		_G["R_ChatTabText"..i]:SetAlpha(1)
		UIFrameFadeIn(_G["R_ChatTabText"..i], CHAT_FRAME_FADE_TIME, _G["ChatFrame"..i.."Tab"]:GetAlpha(), 1);
	end
end

local function UpdateMineLeave(self)
	for i = 1, 10 do
		UIFrameFadeRemoveFrame(_G["R_ChatTabText"..i])
		_G["R_ChatTabText"..i]:SetAlpha(_G["ChatFrame"..i.."Tab"].noMouseAlpha)
		UIFrameFadeOut(_G["R_ChatTabText"..i], CHAT_FRAME_FADE_OUT_TIME, _G["ChatFrame"..i.."Tab"]:GetAlpha(), _G["ChatFrame"..i.."Tab"].noMouseAlpha);
	end
end

-- Chat Tab mouse-events
local function ChatTab_OnLeave(self)
	UpdateMineLeave(self)
	nibChatTabs:UpdateTabs(false)
end

local function ChatTab_OnEnter(self)
	nibChatTabs:UpdateTabs(false)
	UpdateTabStyle(self, "highlight")
	UpdateMineEnter(self)
end

local function ChatTabFlash_OnHide(self)
	UpdateTabStyle(self, "normal")
end

local function ChatTabFlash_OnShow(self)
	UpdateTabStyle(self, "flash")
	if db.hide.flash then UIFrameFlashStop(self.glow) end
end

local function Chat_SizeChanged(self,width,height)
	nibChatTabs:UpdateTabs(false)
end

-- Tab update
function nibChatTabs:UpdateTabs(SimpleUpdate)
	local chat, tab, flash, text
	local maxTabs = ChatFrame11Tab and 11 or NUM_CHAT_WINDOWS
	for i = 1, maxTabs do
		chat = _G["ChatFrame"..i]
		tab = _G["ChatFrame"..i.."Tab"]
		flash = _G["ChatFrame"..i.."TabFlash"]
		text = _G["ChatFrame"..i.."TabText"]
		ChatTab = _G["R_ChatTab"..i]
		TabText = _G["R_ChatTabText"..i]
		_G["ChatFrame"..i.."TabText"]:Hide()
		
		if not SimpleUpdate then
			if db.alphas.hidetabs then
				-- Hide Tabs completely
				tab:Hide()
				tab:SetScript("OnShow", function(self) self:Hide() end)
			else
				-- Hide/Show regular Chat Tab textures
				if db.hide.tab then
					_G["ChatFrame"..i.."TabLeft"]:Hide()
					_G["ChatFrame"..i.."TabMiddle"]:Hide()
					_G["ChatFrame"..i.."TabRight"]:Hide()
				else
					_G["ChatFrame"..i.."TabLeft"]:Show()
					_G["ChatFrame"..i.."TabMiddle"]:Show()
					_G["ChatFrame"..i.."TabRight"]:Show()
				end
				if db.hide.highlight then
					_G["ChatFrame"..i.."TabHighlightLeft"]:Hide()
					_G["ChatFrame"..i.."TabHighlightMiddle"]:Hide()
					_G["ChatFrame"..i.."TabHighlightRight"]:Hide()
				else
					_G["ChatFrame"..i.."TabHighlightLeft"]:Show()
					_G["ChatFrame"..i.."TabHighlightMiddle"]:Show()
					_G["ChatFrame"..i.."TabHighlightRight"]:Show()
				end
				if i == 1 then
					tab:SetWidth(35)
					tab:SetHeight(15)
				elseif i == 2 then
					tab:SetWidth(51)
					tab:SetHeight(15)
				elseif i == 3 then
					tab:SetWidth(45)
					tab:SetHeight(15)
				elseif i == 4 then
					tab:SetWidth(86)
					tab:SetHeight(15)
				elseif i == 5 then
					tab:SetWidth(45)
					tab:SetHeight(15)
				end

				-- Hook Tab
				tab:SetScript("OnEnter", ChatTab_OnEnter)
				tab:SetScript("OnLeave", ChatTab_OnLeave)
			end			
		end
		
		-- Update Selected
		_G["ChatFrame"..i.."TabSelectedLeft"]:Hide()
		_G["ChatFrame"..i.."TabSelectedMiddle"]:Hide()
		_G["ChatFrame"..i.."TabSelectedRight"]:Hide()		
		if ( not db.hide.selected and chat == SELECTED_CHAT_FRAME ) then
			if db.hide.tab then
				-- Quickly Show then Hide the tab to update the Selected textures coordinates
				_G["ChatFrame"..i.."TabLeft"]:Show()
				_G["ChatFrame"..i.."TabMiddle"]:Show()
				_G["ChatFrame"..i.."TabRight"]:Show()
				
				_G["ChatFrame"..i.."TabLeft"]:Hide()
				_G["ChatFrame"..i.."TabMiddle"]:Hide()
				_G["ChatFrame"..i.."TabRight"]:Hide()
			end
			
			_G["ChatFrame"..i.."TabSelectedLeft"]:Show()
			_G["ChatFrame"..i.."TabSelectedMiddle"]:Show()
			_G["ChatFrame"..i.."TabSelectedRight"]:Show()
		end

		-- Update Tab Appearance
		if chat == SELECTED_CHAT_FRAME then
			UpdateTabStyle(tab, "selected")
		elseif tab.alerting then
			UpdateTabStyle(tab, "flash")
		else
			UpdateTabStyle(tab, "normal")
		end
	end
end


-- Alpha update
function nibChatTabs:UpdateAlphas()
	-- Set alphas
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = db.alphas.nomousealpha.selected
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = db.alphas.nomousealpha.normal
	CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = db.alphas.nomousealpha.flash
	
	CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = db.alphas.mouseoveralpha.selected
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = db.alphas.mouseoveralpha.normal
	CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = db.alphas.mouseoveralpha.flash
	
	CHAT_TAB_SHOW_DELAY = db.alphas.fadetimes.fadein.delay
	CHAT_TAB_HIDE_DELAY = db.alphas.fadetimes.fadeout.delay
	CHAT_FRAME_FADE_TIME = db.alphas.fadetimes.fadein.speed
	CHAT_FRAME_FADE_OUT_TIME = db.alphas.fadetimes.fadeout.speed
	
	hooksecurefunc("FCFTab_UpdateAlpha", UpdateMine)	
	for i = 1, 10 do
		FCFTab_UpdateAlpha(_G["ChatFrame"..i])
	end
	
	DEFAULT_CHATFRAME_ALPHA = db.alphas.chatframe
end





-- Chat Window creation
local function NewChatWindow()
	nibChatTabs:UpdateTabs(false)
end

-- Hook FCF
local function HookFCF()
	-- Tab Click
	local Orig_FCF_Tab_OnClick = FCF_Tab_OnClick
	FCF_Tab_OnClick = function(...)
		-- Click the Tab
		Orig_FCF_Tab_OnClick(...)
		-- Update Tabs
		nibChatTabs:UpdateTabs(true)
	end

	-- New Window
	hooksecurefunc("FCF_OpenNewWindow", NewChatWindow)
	
	-- Window Close
	hooksecurefunc("FCF_Close", function(self, fallback)
		local frame = fallback or self
		UIParent.Hide(_G[frame:GetName().."Tab"])
		FCF_Tab_OnClick(_G["ChatFrame1Tab"], "LeftButton")
	end)
	
	-- Flash
	-- Start
	hooksecurefunc("FCF_StartAlertFlash", function(chatFrame)
		ChatTabFlash_OnShow(_G[chatFrame:GetName().."Tab"])
	end)
	-- Stop
	hooksecurefunc("FCF_StopAlertFlash", function(chatFrame)
		ChatTabFlash_OnHide(_G[chatFrame:GetName().."Tab"])
	end)
	
	-- New UpdateColors function, stop it!
	FCFTab_UpdateColors = function(...) end
end

----
local function ClassColorsUpdate()
	UClassColors = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[UClass] or RAID_CLASS_COLORS[UClass]
	nibChatTabs:UpdateTabs(true)
end

function nibChatTabs:PET_BATTLE_OPENING_START()
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:ZONE_CHANGED()
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:ZONE_CHANGED_NEW_AREA()
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:CHANNEL_LEFT()
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:CHANNEL_UI_UPDATE()
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:CHAT_MSG_CHANNEL_NOTICE()
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:UPDATE_ALL_UI_WIDGETS()
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:AREA_POIS_UPDATED()
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:FOG_OF_WAR_UPDATED()
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:PLAYER_LOGIN()
	UClass = select(2, UnitClass("player"))
	UClassColors = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[UClass] or RAID_CLASS_COLORS[UClass]

	nibChatTabs:UpdateTabs(false)
	nibChatTabs:UpdateAlphas()
	GENERAL_CHAT_DOCK.overflowButton:SetAlpha(CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA)
	HookFCF()
	
	if CUSTOM_CLASS_COLORS then
		CUSTOM_CLASS_COLORS:RegisterCallback(ClassColorsUpdate)
	end
	ChatFrame5Tab:HookScript("OnSizeChanged",Chat_SizeChanged)
	nibChatTabs:UpdateTabs(false)
end

function nibChatTabs:ProfChange()
	db = self.db.profile
	nibChatTabs:ConfigRefresh()
	nibChatTabs:Refresh()
end

function nibChatTabs:Refresh()
	nibChatTabs:UpdateTabs(false)
	nibChatTabs:UpdateAlphas()
end

function nibChatTabs:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("nibChatTabsDB", defaults, "Default")
	
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfChange")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfChange")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfChange")
	
	nibChatTabs:SetUpInitialOptions()
	
	db = self.db.profile
	
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PET_BATTLE_OPENING_START")
end