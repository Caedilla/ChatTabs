local nibChatTabs = LibStub("AceAddon-3.0"):GetAddon("nibChatTabs")
local db

-- Options
local styles = {
	normal = "Normal",
	selected = "Selected",
	highlight = "Highlight",
	flash = "Flash"
}

local table_Outline = {
	"NONE",
	"OUTLINE",
	"THICKOUTLINE",
}

local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "nibChatTabs",
		childGroups = "tab",
		args = {
			font = {
				name = "Font",
				type = "group",
				childGroups = "tab",
				order = 10,
				args = {
					fontname = {
						type = "select",
						name = "Font Name",
						values = AceGUIWidgetLSMlists.font,
						get = function()
							return db.font.name
						end,
						set = function(info, value)
							db.font.name = value
							nibChatTabs:UpdateTabs()
						end,
						dialogControl='LSM30_Font',
						order = 10,
					},
					fontsize = {
						type = "range",
						name = "Font Size",
						min = 6, max = 36, step = 1,
						get = function(info) return db.font.size end,
						set = function(info, value)
							db.font.size = value
							nibChatTabs:UpdateTabs()
						end,
						order = 20,
					},
				},
			},
			textposition = {
				name = "Text Position",
				type = "group",
				order = 20,
				args = {
					note = {
						type = "description",
						name = "Note: Position changes won't take effect until you Log Out or Reload the UI.",
						order = 10,
					},
					normal = {
						name = "Regular Tabs",
						type = "group",
						inline = true,
						order = 20,
						args = {
							xoffset = {
								type = "range",
								name = "X Offset",
								min = -10, max = 10, step = 0.5,
								get = function(info) return db.textposition.normal.x end,
								set = function(info, value)
									db.textposition.normal.x = value
								end,
								order = 10,
							},
							yoffset = {
								type = "range",
								name = "Y Offset",
								min = -10, max = 10, step = 0.5,
								get = function(info) return db.textposition.normal.y end,
								set = function(info, value)
									db.textposition.normal.y = value
								end,
								order = 20,
							},
						},
					},
					combatlog = {
						name = "Combat Log Tab",
						type = "group",
						inline = true,
						order = 30,
						args = {
							xoffset = {
								type = "range",
								name = "X Offset",
								min = -10, max = 10, step = 0.5,
								get = function(info) return db.textposition.combatlog.x end,
								set = function(info, value)
									db.textposition.combatlog.x = value
								end,
								order = 10,
							},
							yoffset = {
								type = "range",
								name = "Y Offset",
								min = -10, max = 10, step = 0.5,
								get = function(info) return db.textposition.combatlog.y end,
								set = function(info, value)
									db.textposition.combatlog.y = value
								end,
								order = 20,
							},
						},
					},
				},
			},
			styles = {
				type = "group",
				name = "Tab Styles",
				childGroups = "tab",
				order = 30,
				args = {},
			},
			hide = {
				type = "group",
				name = "Hide Sections",
				order = 40,
				args = {
					tab = {
						name = "Tab",
						desc = "Hide the Tab.",
						type = "toggle",
						get = function(info) return db.hide.tab end,
						set = function(info, value) db.hide.tab = value; nibChatTabs:UpdateTabs(); end,
						order = 10,
					},
					highlight = {
						name = "Highlight",
						desc = "Hide the Tab's glow when it becomes highlighted (mouse over).",
						type = "toggle",
						get = function(info) return db.hide.highlight end,
						set = function(info, value) db.hide.highlight = value; nibChatTabs:UpdateTabs(); end,
						order = 20,
					},
					selected = {
						name = "Selected Glow",
						desc = "Hide the Tab's glow when it's selected.",
						type = "toggle",
						get = function(info) return db.hide.selected end,
						set = function(info, value) db.hide.selected = value; nibChatTabs:UpdateTabs(); end,
						order = 30,
					},
					flash = {
						name = "Flash",
						desc = "Hide the Tab's flash.",
						type = "toggle",
						get = function(info) return db.hide.flash end,
						set = function(info, value) db.hide.flash = value; nibChatTabs:UpdateTabs(); end,
						order = 40,
					},
				},
			},
			alphas = {
				type = "group",
				name = "Opacity",
				childGroups = "tab",
				order = 50,
				args = {
					tabs = {
						type = "group",
						name = "Chat Tabs",
						order = 10,
						args = {
							hidetabs = {
								name = "Hide Chat Tabs",
								desc = "Completely hide the Chat Tabs.",
								type = "toggle",
								get = function(info) return db.alphas.hidetabs end,
								set = function(info, value) db.alphas.hidetabs = value; nibChatTabs:UpdateTabs(); end,
								order = 10,
							},
							note = {
								name = "Note: To make Tabs visible again, you will need to reload the UI (type: /reload ui).",
								type = "description",
								order = 20,
							},
							sep1 = {
								name = " ",
								type = "description",
								order = 30,
							},
							nomousealpha = {
								type = "group",
								name = "No Mouse Alpha",
								inline = true,
								disabled = function()
									if db.alphas.hidetabs then return true else return false end 
								end,
								order = 40,
								args = {
									selected = {
										type = "range",
										name = "Selected",
										min = 0, max = 1, step = 0.05,
										isPercent = true,
										get = function(info) return db.alphas.nomousealpha.selected end,
										set = function(info, value) db.alphas.nomousealpha.selected = value; nibChatTabs:UpdateAlphas(); end,
										order = 10,
									},
									normal = {
										type = "range",
										name = "Normal",
										min = 0, max = 1, step = 0.05,
										isPercent = true,
										get = function(info) return db.alphas.nomousealpha.normal end,
										set = function(info, value) db.alphas.nomousealpha.normal = value; nibChatTabs:UpdateAlphas(); end,
										order = 20,
									},
									flash = {
										type = "range",
										name = "Flash",
										min = 0, max = 1, step = 0.05,
										isPercent = true,
										get = function(info) return db.alphas.nomousealpha.flash end,
										set = function(info, value) db.alphas.nomousealpha.flash = value; nibChatTabs:UpdateAlphas(); end,
										order = 30,
									},
								},
							},
							mouseoveralpha = {
								type = "group",
								name = "Mouse Over Alpha",
								inline = true,
								disabled = function()
									if db.alphas.hidetabs then return true else return false end 
								end,
								order = 50,
								args = {
									selected = {
										type = "range",
										name = "Selected",
										min = 0, max = 1, step = 0.05,
										isPercent = true,
										get = function(info) return db.alphas.mouseoveralpha.selected end,
										set = function(info, value) db.alphas.mouseoveralpha.selected = value; nibChatTabs:UpdateAlphas(); end,
										order = 10,
									},
									normal = {
										type = "range",
										name = "Normal",
										min = 0, max = 1, step = 0.05,
										isPercent = true,
										get = function(info) return db.alphas.mouseoveralpha.normal end,
										set = function(info, value) db.alphas.mouseoveralpha.normal = value; nibChatTabs:UpdateAlphas(); end,
										order = 20,
									},
									flash = {
										type = "range",
										name = "Flash",
										min = 0, max = 1, step = 0.05,
										isPercent = true,
										get = function(info) return db.alphas.mouseoveralpha.flash end,
										set = function(info, value) db.alphas.mouseoveralpha.flash = value; nibChatTabs:UpdateAlphas(); end,
										order = 30,
									},
								},
							},
						},
					},
					chatframe = {
						type = "group",
						name = "Chat Frame",
						order = 20,
						args = {
							selected = {
								type = "range",
								name = "Background Alpha",
								min = 0, max = 1, step = 0.05,
								isPercent = true,
								get = function(info) return db.alphas.chatframe end,
								set = function(info, value) db.alphas.chatframe = value; nibChatTabs:UpdateAlphas(); end,
								order = 10,
							},
						},
					},
					fadetimes = {
						type = "group",
						name = "Fade Times",
						order = 30,
						args = {
							fadein = {
								type = "group",
								name = "Fade In",
								inline = true,
								order = 10,
								args = {
									delay = {
										type = "range",
										name = "Delay",
										desc = "Time to wait until Chat Frame\\Tabs fade in (seconds).",
										min = 0, max = 4, step = 0.05,
										get = function(info) return db.alphas.fadetimes.fadein.delay end,
										set = function(info, value) db.alphas.fadetimes.fadein.delay = value; nibChatTabs:UpdateAlphas(); end,
										order = 10,
									},
									speed = {
										type = "range",
										name = "Speed",
										desc = "Speed at which Chat Frame\\Tabs fade in (seconds).",
										min = 0, max = 4, step = 0.05,
										get = function(info) return db.alphas.fadetimes.fadein.speed end,
										set = function(info, value) db.alphas.fadetimes.fadein.speed = value; nibChatTabs:UpdateAlphas(); end,
										order = 20,
									},
								},
							},
							fadeout = {
								type = "group",
								name = "Fade Out",
								inline = true,
								order = 20,
								args = {
									delay = {
										type = "range",
										name = "Delay",
										desc = "Time to wait until Chat Frame\\Tabs fade out (seconds).",
										min = 0, max = 4, step = 0.05,
										get = function(info) return db.alphas.fadetimes.fadeout.delay end,
										set = function(info, value) db.alphas.fadetimes.fadeout.delay = value; nibChatTabs:UpdateAlphas(); end,
										order = 10,
									},
									speed = {
										type = "range",
										name = "Speed",
										desc = "Speed at which Chat Frame\\Tabs fade out (seconds).",
										min = 0, max = 4, step = 0.05,
										get = function(info) return db.alphas.fadetimes.fadeout.speed end,
										set = function(info, value) db.alphas.fadetimes.fadeout.speed = value; nibChatTabs:UpdateAlphas(); end,
										order = 20,
									},
								},
							},
						},
					},
				},
			},
		},
	}
	end
	
	-- Styles
	local StyleOpts = {}
	local StyleOpts_OrderCnt = 10
	for k_s,v_s in pairs(styles) do		
		StyleOpts[v_s] = {
			type = "group",
			name = v_s,
			order = StyleOpts_OrderCnt,
			childGroups = "tab",
			args = {
				textcolor = {
					type = "group",
					name = "Text Color",
					order = 10,
					args = {
						color = {
							type = "color",
							name = "Normal color",
							hasAlpha = false,
							get = function(info,r,g,b)
								return db[k_s].colors.r, db[k_s].colors.g, db[k_s].colors.b
							end,
							set = function(info,r,g,b)
								db[k_s].colors.r = r
								db[k_s].colors.g = g
								db[k_s].colors.b = b
								nibChatTabs:UpdateTabs()
							end,
							disabled = function()
								if db[k_s].colors.class.enabled then return true else return false end 
							end,
							order = 10,
						},
						classcolor_area = {
							type = "group",
							name = "Class Color",
							inline = true,
							order = 20,
							args = {			
								useclasscolor = {
									name = "Use Class Color",
									type = "toggle",
									get = function(info) return db[k_s].colors.class.enabled end,
									set = function(info, value) db[k_s].colors.class.enabled = value; nibChatTabs:UpdateTabs(); end,
									order = 10,
								},											
								classshade = {
									name = "Shade",
									type = "range",
									desc = "Adjust how dark the Class Color will appear.",
									min = 0,
									max = 1,
									step = 0.05,
									isPercent = true,
									get = function(info) return db[k_s].colors.class.shade end,
									set = function(info, value) db[k_s].colors.class.shade = value; nibChatTabs:UpdateTabs(); end,
									disabled = function() if db[k_s].colors.class.enabled then return false else return true end end,
									order = 20,
								},
							},
						},
					},
				},
				fontstyle = {
					type = "group",
					name = "Font Style",
					order = 20,
					args = {
						shadow_area = {
							name = "Shadow",
							type = "group",
							inline = true,
							order = 10,
							args = {
								useshadow = {
									name = "Use Shadow",
									type = "toggle",
									get = function(info) return db[k_s].shadow.useshadow end,
									set = function(info, value) db[k_s].shadow.useshadow = value; nibChatTabs:UpdateTabs(); end,
									order = 10,							
								},
								offsets = {
									name = "Position",
									type = "group",
									inline = true,
									disabled = function() if db[k_s].shadow.useshadow then return false else return true end end,
									order = 20,
									args = {
										shadowx = {
											type = "range",
											name = "X Offset",
											min = -8,
											max = 8,
											step = 1,
											get = function(info) return db[k_s].shadow.position.x end,
											set = function(info, value) db[k_s].shadow.position.x = value; nibChatTabs:UpdateTabs(); end,
											order = 10,
										},
										shadowy = {
											type = "range",
											name = "Y Offset",
											min = -8,
											max = 8,
											step = 1,
											get = function(info) return db[k_s].shadow.position.y end,
											set = function(info, value) db[k_s].shadow.position.y = value; nibChatTabs:UpdateTabs(); end,
											order = 20,
										},
									},
								},
								color = {
									name = "Color",
									type = "color",
									hasAlpha = true,
									get = function(info,r,g,b,a)
										return db[k_s].shadow.color.r, db[k_s].shadow.color.g, db[k_s].shadow.color.b, db[k_s].shadow.color.a
									end,
									set = function(info,r,g,b,a)
										db[k_s].shadow.color.r = r
										db[k_s].shadow.color.g = g
										db[k_s].shadow.color.b = b
										db[k_s].shadow.color.a = a
										nibChatTabs:UpdateTabs()
									end,
									disabled = function() if db[k_s].shadow.useshadow then return false else return true end end,
									order = 30,
								},
							},
						},
						outline = {
							type = "group",
							name = "Outline",
							inline = true,
							order = 20,
							args = {
								style = {
									type = "select",
									name = "Style",
									values = table_Outline,
									get = function()
										for k,v in pairs(table_Outline) do
											if v == db[k_s].outline then return k end
										end
									end,
									set = function(info, value)
										db[k_s].outline = table_Outline[value]
										nibChatTabs:UpdateTabs()
									end,
									order = 10,
								},
							},
						},
					},
				},						
			},
		}
		StyleOpts_OrderCnt = StyleOpts_OrderCnt + 10;
	end
	for k, v in pairs(StyleOpts) do
		options.args.styles.args[k] = (type(v) == "function") and v() or v
	end
		
	return options
end

local intoptions = nil
local function GetIntOptions()
	if not intoptions then
		intoptions = {
			name = "nibChatTabs",
			handler = nibChatTabs,
			type = "group",
			args = {
				note = {
					type = "description",
					name = "You can access the nibChatTabs options by typing: /nibct",
					order = 10,
				},
				openoptions = {
					type = "execute",
					name = "Open config...",
					func = function() 
						nibChatTabs:OpenOptions()
					end,
					order = 20,
				},
			},
		}
	end
	return intoptions
end


function nibChatTabs:OpenOptions()
	if not options then nibChatTabs:SetUpOptions() end
	LibStub("AceConfigDialog-3.0"):Open("nibChatTabs")
end

function nibChatTabs:ChatCommand(input)
	nibChatTabs:OpenOptions()
end

function nibChatTabs:ConfigRefresh()
	db = self.db.profile
end

function nibChatTabs:SetUpInitialOptions()
	-- Chat Command
	self:RegisterChatCommand("nibchattabs", "ChatCommand")
	self:RegisterChatCommand("nibct", "ChatCommand")
	
	-- Interface panel options
	LibStub("AceConfig-3.0"):RegisterOptionsTable("nibChatTabs-Int", GetIntOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("nibChatTabs-Int", "nibChatTabs")
end

function nibChatTabs:SetUpOptions()
	db = self.db.profile
	
	-- Options Window
	GetOptions()
	
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	options.args.profiles.order = 10000
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("nibChatTabs", options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("nibChatTabs", 700, 550)
end