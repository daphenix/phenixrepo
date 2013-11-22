function CreateCapShipShiplessPDATab()
	CapShipShiplessPDAMissionsTab, CapShipShiplessPDAMissionNotesTab, CapShipShiplessPDAMissionAdvancementTab, CapShipShiplessPDAMissionLogTab, CapShipShiplessPDAMissionBoardTab, CapShipShiplessPDAMissionBoardTabInfoButton = CreateMissionsPDATab() CapShipShiplessPDAMissionsTab.tabtitle="Missions"   CapShipShiplessPDAMissionsTab.hotkey = iup.K_m
	CapShipShiplessPDAShipTab, CapShipShiplessPDAShipNavigationTab = CreateShipPDATab(false) CapShipShiplessPDAShipTab.tabtitle="Navigation"   CapShipShiplessPDAShipTab.hotkey = iup.K_n
	CapShipShiplessPDASensorTab, CapShipShiplessPDASensorNearbyTab = CreateSensorPDATab(false) CapShipShiplessPDASensorTab.tabtitle="Sensor Log"   CapShipShiplessPDASensorTab.hotkey = iup.K_e
	CapShipShiplessPDACommTab = CreateCommPDATab() CapShipShiplessPDACommTab.tabtitle="Comm"   CapShipShiplessPDACommTab.hotkey = iup.K_o
	CapShipShiplessPDACharacterTab, CapShipShiplessPDACharacterStatsTab = CreateCharacterPDATab() CapShipShiplessPDACharacterTab.tabtitle="Character"   CapShipShiplessPDACharacterTab.hotkey = iup.K_r
	CapShipShiplessPDAInventoryTab, CapShipShiplessPDAInventoryInventoryTab, CapShipShiplessPDAInventoryJettisonTab = CreateInventoryPDATab(false) CapShipShiplessPDAInventoryTab.tabtitle="Inventory"   CapShipShiplessPDAInventoryTab.hotkey = iup.K_i

	return iup.roottabtemplate{
		CapShipShiplessPDAMissionsTab,
		CapShipShiplessPDAShipTab,
		CapShipShiplessPDASensorTab,
		CapShipShiplessPDACommTab,
		CapShipShiplessPDACharacterTab,
		CapShipShiplessPDAInventoryTab,
		secondary = iup.hbox{size="%14x"},
	}
end

function CreateCapShipShiplessFactionInfo()
	local container

--	CapShipShiplessFactionIcon = iup.label{title="Faction logo", wordwrap="YES", size="80x64", fgcolor=tabseltextcolor}
--	CapShipShiplessTypeIcon = iup.label{title="CapShipShipless type logo", wordwrap="YES", size="80x64", fgcolor=tabseltextcolor}
	CapShipShiplessNameLabel = iup.label{title="", expand="HORIZONTAL", size="1x", wordwrap="NO", fgcolor=tabunseltextcolor}
	CapShipShiplessFactionLabel = iup.label{title="", expand="HORIZONTAL", size="1x", wordwrap="NO", fgcolor=tabunseltextcolor}
	container = iup.vbox{
--[[
		iup.hbox{
			iup.pdasubframe_nomargin{CapShipShiplessFactionIcon},
			iup.pdasubframe_nomargin{CapShipShiplessTypeIcon},
			gap="8",
		},
--]]
		CapShipShiplessNameLabel,
		CapShipShiplessFactionLabel,
	}

	function container:OnShow()
		CapShipShiplessNameLabel.title = "Welcome to "..tostring(GetStationName())
		local capshipfaction = tostring(FactionName[GetStationFaction()])
		CapShipShiplessFactionLabel.title = Article(capshipfaction).." ship"
--		CapShipShiplessFactionLabel.title = "a "..tostring(FactionName[GetStationFaction()]).." ship"
	end

	function container:OnHide()
	end

	return container
end

function CreateCapShipShiplessChatTab()
	local isvisible = false
	local capshiplog
	local function logupdated()
		local color
		if isvisible then
			SetStationLogRead()
			color = tabseltextcolor
		else
			color = tabunseltextcolor
		end
		if ShowBarUpdateNotification then
			CapShipShiplessTabs:SetTabTextColor(CapShipShiplessTacticalTab, GetStationLogReadState() and color or "255 0 0")
			CapShipShiplessTacticalTab:SetTabTextColor(CapShipShiplessChatTab, GetStationLogReadState() and color or "255 0 0")
		end
	end

	capshiplog = ChatLogTemplate("45 120 158 0 *", "100 0 0 178 *", logupdated, IMAGE_DIR.."commerce_tab_bgcolor.png", true)
	capshiplog.chattext.indent = "YES"
	capshiplog.chattext.border = "NO"
	capshiplog.chattext.boxcolor = "45 120 158 128"
	capshiplog.chattext.bgcolor = "45 120 158 128 *"
	capshiplog.chattext.active = "YES"
	capshiplog.chattext.expand = "YES"
	capshiplog.chatentry.active = "YES"
	capshiplog.chatentry.wanttab = "YES"
	capshiplog.chatentry.visible = "YES"
	capshiplog.chatentry.border = "YES"
	capshiplog.chatentry.bgcolor = "49 90 110 128 *"
	capshiplog.chatentry.bordercolor = "70 94 106"
	capshiplog.chatentry.type = "STATION"

	CapShipShiplessLog = capshiplog

	local container = iup.vbox{iup.pdarootframebg{capshiplog.vbox}}

	function container:OnShow()
		isvisible = true
		SetStationLogRead()
		logupdated()
		iup.SetFocus(capshiplog.chatentry)
	end

	function container:OnHide()
		isvisible = false
	end

	function container:OnEvent(eventname, ...)
	end

	return container
end

function CreateCapShipShiplessTacticalTab()
	CapShipShiplessTurretTab = CreateCapShipTurretTab() CapShipShiplessTurretTab.tabtitle="Turrets"  CapShipShiplessTurretTab.hotkey = iup.K_r
	CapShipShiplessChatTab = CreateCapShipShiplessChatTab() CapShipShiplessChatTab.tabtitle = "Ship Com"  CapShipShiplessChatTab.hotkey = iup.K_h

	return iup.roottabtemplate{
		CapShipShiplessTurretTab,
		CapShipShiplessChatTab,
		secondary = iup.hbox{size="%14x"},
	}
end

local curtab
local isvisible = false
local update_secondary_info
local missiontimer
local update_mission_timers

CapShipShiplessLeaveButton = iup.stationbutton{
			title="L e a v e",
			tip="Leave the ship",
			expand="HORIZONTAL",
			action=function(self)
				QuestionDialog:SetMessage("Are you sure you want to leave the ship?\nYou will be sent back to your home station.",
					"Yes", function() Gunner.Leave() HideDialog(QuestionDialog) end,
					"No", function() HideDialog(QuestionDialog) end,
					"ACENTER")
				ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
			end,
		}
CapShipShiplessOptionsButton = iup.stationbutton{
			title="Options",
			tip="Config or logout",
			expand="HORIZONTAL",
			action=function(self)
				HideDialog(CapShipShiplessDialog)
				OptionsDialog:SetMenuMode(2, CapShipShiplessDialog)
				ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER)
			end,
		}
CapShipShiplessCurrentLocationInfo = iup.label{title="YOU ARE HERE", alignment="ACENTER", expand="HORIZONTAL", fgcolor=tabunseltextcolor, font=Font.H4}
CapShipShiplessSecondaryInfo = iup.label{
	size="1x1",
	expand="YES",
	fgcolor=tabunseltextcolor,
	font=Font.H6,
	title="Credits: 10,001,100",
--	tip="Credits\nCurrent Ship\nCargo\nMass\nLicenses",
}
local secondary = iup.vbox{
	iup.pdasubframe_nomargin{
		iup.hbox{
		iup.vbox{
			CapShipShiplessSecondaryInfo,
			margin="5x5",
			size="x%18",
		},
		expand="NO",
		size="%13x",
		},
		expand="NO",
	},
	iup.pdasubframe_nomargin{
		iup.hbox{
		iup.vbox{
			CapShipShiplessLeaveButton,
			CapShipShiplessOptionsButton,
			gap=8,
			margin="5x5",
			alignment="ACENTER",
		},
		expand="NO",
		size="%13x",
		},
		expand="NO",
	},
	gap=5,
}
update_secondary_info = function()
	local curcargo, maxcargo, shipname, shipmass
	shipname = GetActiveShipName()
	if not shipname then
		curcargo = 0
		maxcargo = 0
		shipmass = 0
		shipname = "No active ship"
	else
		curcargo = GetActiveShipCargoCount() or 0
		maxcargo = GetActiveShipMaxCargo() or 0
		shipmass = GetActiveShipMass() or 0
	end
	local lic1 = GetLicenseLevel(1)
	local lic2 = GetLicenseLevel(2)
	local lic3 = GetLicenseLevel(3)
	local lic4 = GetLicenseLevel(4)
	local lic5 = GetLicenseLevel(5)
	local home = ShortLocationStr(GetHomeStation())
	CapShipShiplessSecondaryInfo.title = string.format(
		"Credits: %sc\nCurrent Ship:\n%s\nCargo: %u/%u cu\nMass: %skg\nLicenses: %s/%s/%s/%s/%s\nHome: %s",
--		"%uc\n%s\n%u/%u cu\n%ukg\n%s/%s/%s/%s/%s",
		comma_value(GetMoney()), shipname, curcargo, maxcargo, comma_value((math.floor(1000*shipmass+0.5))),
		lic1>0 and lic1 or "-",
		lic2>0 and lic2 or "-",
		lic3>0 and lic3 or "-",
		lic4>0 and lic4 or "-",
		lic5>0 and lic5 or "-",
		home
		)
	CapShipShiplessSecondaryInfo.size = "1x1"
end

CapShipShiplessFactionInfo = CreateCapShipShiplessFactionInfo()
CapShipShiplessChatArea = chatareatemplate2(false)
CapShipShiplessTacticalTab = CreateCapShipShiplessTacticalTab() CapShipShiplessTacticalTab.tabtitle="Tactical" CapShipShiplessTacticalTab.hotkey = iup.K_c
CapShipShiplessTabPDA = CreateCapShipShiplessPDATab() CapShipShiplessTabPDA.tabtitle = "Your PDA"  CapShipShiplessTabPDA.hotkey = iup.K_y
CapShipShiplessTabs = iup.pda_root_tabs{
		{expand="HORIZONTAL", spacer=true},
		CapShipShiplessTacticalTab,
		{size=5, spacer=true},
		CapShipShiplessTabPDA,
		{size="%25", spacer=true},
		seltextcolor=tabseltextcolor,
		unseltextcolor=tabunseltextcolor,
		tabchange_cb = function(self, newtab, oldtab)
			curtab = newtab
			if isvisible then
				oldtab:OnHide()
				newtab:OnShow()
			end
		end,
	}
curtab = CapShipShiplessTacticalTab

local gap = -(Font.H4*1.5 - 4)
local twentypercent = gkinterface.GetYResolution()*.20

CapShipShiplessDialog = iup.dialog{
		iup.vbox{
			iup.hbox{
				iup.pdarootframe{
					CapShipShiplessChatArea,
					size="%74x%20",
					expand="NO",
				},
				iup.vbox{
					iup.pdarootframe{
						CapShipShiplessFactionInfo,
					},
					iup.pdarootframe{
						iup.vbox{
							iup.fill{},
							CapShipShiplessCurrentLocationInfo,
							iup.fill{},
						}
					},
					gap="4",
					size="%24x"..twentypercent - gap,
					expand="HORIZONTAL"
				},
				gap="4",
			},
			iup.zbox{
				CapShipShiplessTabs,
				iup.hbox{
					secondary,
					margin="5x5",
				},
				all="YES",
				alignment = "SE",
			},
			gap = gap+4,
			margin = "4x4",
		},
		bgcolor = "0 0 0 0 +",
		border="NO",
		resize="NO",
		menubox="NO",
		defaultesc=CapShipShiplessOptionsButton,
		fullscreen="YES",
	}

missiontimer = Timer()
update_mission_timers = function()
	local firsttimer = GetMissionTimers()
	if firsttimer and CapShipShiplessDialog.visible == "YES" then
		firsttimer = math.max(0, firsttimer)
		StationCurrentLocationInfo.title = "Mission Timer: "..format_time(firsttimer)
--		StationSecondaryMissionTimer.title = "Mission Timer: "..format_time(firsttimer)
		missiontimer:SetTimeout(50, function() update_mission_timers() end)
	else
--		StationSecondaryMissionTimer.title = ""
		CapShipShiplessCurrentLocationInfo.title = ShortLocationStr(GetCurrentSectorid() or 1)
		missiontimer:Kill()
	end
end

function CapShipShiplessDialog:k_any(c)
	local keycommand = gkinterface.GetCommandForKeyboardBind(c)
	if c == iup.K_1 then
		CapShipShiplessTabs:SetTab(CapShipShiplessTacticalTab)
	elseif c == iup.K_2 then
		CapShipShiplessTabs:SetTab(CapShipShiplessTabPDA)
	elseif keycommand == "say_sector" then
		CapShipShiplessChatArea:set_chatmode(2)
		return iup.CONTINUE
	elseif keycommand == "say_channel" then
		CapShipShiplessChatArea:set_chatmode(3)
		return iup.CONTINUE
	elseif keycommand == "say_group" then
		CapShipShiplessChatArea:set_chatmode(4)
		return iup.CONTINUE
	elseif keycommand == "say_guild" then
		CapShipShiplessChatArea:set_chatmode(5)
		return iup.CONTINUE
	elseif keycommand == "say_system" then
		CapShipShiplessChatArea:set_chatmode(6)
		return iup.CONTINUE
	else
		local curtab = CapShipShiplessTabs:GetTab()
		if curtab == CapShipShiplessTacticalTab then return CapShipShiplessTacticalTab:k_any(c)
		elseif curtab == CapShipShiplessTabPDA then return CapShipShiplessTabPDA:k_any(c)
		end
		return iup.CONTINUE
	end
end

function CapShipShiplessDialog:show_cb()
	isvisible = true
	curtab:OnShow()
	CapShipShiplessChatArea:OnShow()
	CapShipShiplessFactionInfo:OnShow()
	update_secondary_info()
	update_mission_timers()
	SetStationLogReceiver(CapShipShiplessLog)
end

function CapShipShiplessDialog:hide_cb()
	isvisible = false
	curtab:OnHide()
	CapShipShiplessChatArea:OnHide()
	CapShipShiplessFactionInfo:OnHide()
	missiontimer:Kill()
	SetStationLogReceiver(nil)
end

function CapShipShiplessDialog:map_cb()
	RegisterEvent(self, "SHOW_STATION")
	RegisterEvent(self, "ENTERING_STATION")
	RegisterEvent(self, "LEAVING_STATION")
	RegisterEvent(self, "SECTOR_CHANGED")
	RegisterEvent(self, "TRANSACTION_COMPLETED")
	RegisterEvent(self, "TRANSACTION_FAILED")
	RegisterEvent(self, "PLAYER_UPDATE_STATS")
	RegisterEvent(self, "STATION_UPDATE_PRICE")
	RegisterEvent(self, "CHAT_CANCELLED")
	RegisterEvent(self, "CHAT_MSG_SERVER_CHANNEL_ACTIVE")
	RegisterEvent(self, "INVENTORY_ADD")
	RegisterEvent(self, "INVENTORY_REMOVE")
	RegisterEvent(self, "INVENTORY_UPDATE")
	RegisterEvent(self, "MISSION_NOTIFICATION")
	RegisterEvent(self, "MISSION_REMOVED")
	RegisterEvent(self, "PLAYER_HOME_CHANGED")

	RegisterEvent(self, "GROUP_CREATED")
	RegisterEvent(self, "GROUP_SELF_JOINED")
	RegisterEvent(self, "GROUP_SELF_LEFT")
end

function CapShipShiplessDialog:OnEvent(eventname, ...)
	if GetCurrentStationType() ~= 1 then return end
	if HasActiveShip() then return end

	if eventname == "SHOW_STATION" then
		HideAllDialogs()
		HideDialog(HUD.dlg)
		CapShipShiplessCurrentLocationInfo.title = ShortLocationStr(GetCurrentSectorid() or 1)
		SetStationLogRead()
		gkinterface.Draw3DScene(Game.GetCVar("rRenderStationInMenu") == 1)
		ShowDialog(self)
	elseif eventname == "ENTERING_STATION" then
		gkinterface.Draw3DScene(Game.GetCVar("rRenderStationInMenu") == 1)
		HideDialog(ConnectingDialog)
		NotificationDialog:SetMessage("Entering "..tostring(GetStationName()).."'s ship...")
		ShowDialog(NotificationDialog, iup.CENTER, iup.CENTER)
		HUD:SetMode("chat")
	elseif eventname == "LEAVING_STATION" then
		gkinterface.Draw3DScene(true)
		missiontimer:Kill()
		HideDialog(self)
		-- set up the Tactical tab as default every time player enters capship.
		CapShipShiplessTabs:SetTab(CapShipShiplessTacticalTab)
		CapShipShiplessTacticalTab:SetTab(CapShipShiplessTurretTab)
		HUD:SetMode("chat")
		ShowDialog(HUD.dlg)
	elseif eventname == "TRANSACTION_COMPLETED" or
			eventname == "INVENTORY_ADD" or 
			eventname == "INVENTORY_REMOVE" or 
			eventname == "INVENTORY_UPDATE" or
			eventname == "PLAYER_HOME_CHANGED" then
		if self.visible == "YES" then
			update_secondary_info()
		end
	elseif eventname == "PLAYER_UPDATE_STATS" then
		local charid = ...
		if self.visible == "YES" and charid == GetCharacterID() then
			update_secondary_info()
		end
	elseif eventname == "MISSION_REMOVED" then
--[[  need to fix some missions before this can be used
			CapShipShiplessTabs:SetTab(CapShipShiplessTabPDA)
			CapShipShiplessTabPDA:SetTab(CapShipShiplessPDAMissionsTab)
			CapShipShiplessPDAMissionsTab:SetTab(CapShipShiplessPDAMissionBoardTab)
--]]
	elseif eventname == "MISSION_NOTIFICATION" then
--		if self.visible == "YES" then
			-- todo: flash the tab text or something.
--		else
			CapShipShiplessTabs:SetTab(CapShipShiplessTabPDA)
			CapShipShiplessTabPDA:SetTab(CapShipShiplessPDAMissionsTab)
			CapShipShiplessPDAMissionsTab:SetTab(CapShipShiplessPDAMissionLogTab)
--		end
	elseif eventname == "GROUP_CREATED" or
			eventname == "GROUP_SELF_JOINED" or
			eventname == "GROUP_SELF_LEFT" then
		RequestMissionList()
	elseif eventname == "SECTOR_CHANGED" then
		HideDialog(self)
	elseif eventname == "CHAT_CANCELLED" then
		if self.visible == "YES" then
			iup.SetFocus(self)
		end
	elseif eventname == "MISSION_TIMER_STOP" then
		if self.visible == "YES" then
			update_mission_timers()
			iup.Refresh(self)
		end
	elseif eventname == "MISSION_TIMER_START" then
		if self.visible == "YES" then
			update_mission_timers()
			iup.Refresh(self)
		end
	elseif eventname == "CHAT_MSG_SERVER_CHANNEL_ACTIVE" then
		CapShipShiplessChatArea:update_channeltitle()
	elseif eventname == "TRANSACTION_FAILED" then
		local errorstring, errorid = ...
		print("capship error: "..tostring(errorstring))
		if errorid == 26 then -- 26 = failed to launch because your ship didn't have enough grid power.
			HideDialog(NotificationDialog)
			ShowDialog(CapShipShiplessDialog)
		end
	end
end

CapShipShiplessDialog:map()
