dofile(IF_DIR.."if_capship_tab1.lua")
dofile(IF_DIR.."if_capship_tab2.lua")

function CreateCapShipPDATab()
	CapShipPDAMissionsTab, CapShipPDAMissionNotesTab, CapShipPDAMissionAdvancementTab, CapShipPDAMissionLogTab, CapShipPDAMissionBoardTab, CapShipPDAMissionBoardTabInfoButton = CreateMissionsPDATab() CapShipPDAMissionsTab.tabtitle="Missions"   CapShipPDAMissionsTab.hotkey = iup.K_m
	CapShipPDAShipTab, CapShipPDAShipNavigationTab = CreateShipPDATab(false) CapShipPDAShipTab.tabtitle="Navigation"   CapShipPDAShipTab.hotkey = iup.K_n
	CapShipPDASensorTab, CapShipPDASensorNearbyTab = CreateSensorPDATab(false) CapShipPDASensorTab.tabtitle="Sensor Log"   CapShipPDASensorTab.hotkey = iup.K_e
	CapShipPDACommTab = CreateCommPDATab() CapShipPDACommTab.tabtitle="Comm"   CapShipPDACommTab.hotkey = iup.K_o
	CapShipPDACharacterTab, CapShipPDACharacterStatsTab = CreateCharacterPDATab() CapShipPDACharacterTab.tabtitle="Character"   CapShipPDACharacterTab.hotkey = iup.K_r
	CapShipPDAInventoryTab, CapShipPDAInventoryInventoryTab, CapShipPDAInventoryJettisonTab = CreateInventoryPDATab(false) CapShipPDAInventoryTab.tabtitle="Inventory"   CapShipPDAInventoryTab.hotkey = iup.K_i

	return iup.roottabtemplate{
		CapShipPDAMissionsTab,
		CapShipPDAShipTab,
		CapShipPDASensorTab,
		CapShipPDACommTab,
		CapShipPDACharacterTab,
		CapShipPDAInventoryTab,
		secondary = iup.hbox{size="%14x"},
	}
end

function CreateCapShipFactionInfo()
	local container

--	CapShipFactionIcon = iup.label{title="Faction logo", wordwrap="YES", size="80x64", fgcolor=tabseltextcolor}
--	CapShipTypeIcon = iup.label{title="CapShip type logo", wordwrap="YES", size="80x64", fgcolor=tabseltextcolor}
	CapShipNameLabel = iup.label{title="", expand="HORIZONTAL", size="1x", wordwrap="NO", fgcolor=tabunseltextcolor}
	CapShipFactionLabel = iup.label{title="", expand="HORIZONTAL", size="1x", wordwrap="NO", fgcolor=tabunseltextcolor}
	container = iup.vbox{
--[[
		iup.hbox{
			iup.pdasubframe_nomargin{CapShipFactionIcon},
			iup.pdasubframe_nomargin{CapShipTypeIcon},
			gap="8",
		},
--]]
		CapShipNameLabel,
		CapShipFactionLabel,
	}

	function container:OnShow()
		CapShipNameLabel.title = "Welcome to "..tostring(GetStationName())
		local capshipfaction = tostring(FactionName[GetStationFaction()])
		CapShipFactionLabel.title = Article(capshipfaction).." ship"
--		CapShipFactionLabel.title = "a "..tostring(FactionName[GetStationFaction()]).." ship"
	end

	function container:OnHide()
	end

	return container
end

function CreateCapShipChatTab()
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
			CapShipTabs:SetTabTextColor(CapShipTacticalTab, GetStationLogReadState() and color or "255 0 0")
			CapShipTacticalTab:SetTabTextColor(CapShipChatTab, GetStationLogReadState() and color or "255 0 0")
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

	CapShipLog = capshiplog

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

function CreateCapShipTacticalTab()
	CapShipTurretTab = CreateCapShipTurretTab() CapShipTurretTab.tabtitle="Turrets"  CapShipTurretTab.hotkey = iup.K_r
	CapShipChatTab = CreateCapShipChatTab() CapShipChatTab.tabtitle = "Ship Com"  CapShipChatTab.hotkey = iup.K_h
	CapShipRepairTab = CreateCapShipRepairTab() CapShipRepairTab.tabtitle="Repair/Refill"  CapShipRepairTab.hotkey = iup.K_r

	return iup.roottabtemplate{
		CapShipTurretTab,
		CapShipRepairTab,
		CapShipChatTab,
		secondary = iup.hbox{size="%14x"},
	}
end

local curtab
local isvisible = false
local update_secondary_info
local missiontimer
local update_mission_timers

CapShipLaunchButton = iup.stationbutton{
			title="L A U N C H",
			tip="Launch into space",
			expand="HORIZONTAL",
			action=function(self)
				HideDialog(CapShipDialog)
				local launchfailure = RequestLaunch()
				if not launchfailure then
					NotificationDialog:SetMessage("Launching...")
					ShowDialog(NotificationDialog, iup.CENTER, iup.CENTER)
				else
					ShowDialog(CapShipDialog)
					if launchfailure == "noengine" then
						OpenAlarm("Unable to launch:", "You need an engine to launch.", "OK")
					elseif launchfailure == "nopowercell" then
						OpenAlarm("Unable to launch:", "You need a power cell to launch.", "OK")
					elseif launchfailure == "nogridpower" then
						OpenAlarm("Unable to launch:", "Your power cell does not have enough Grid Power\nto support the Grid Usage of the equipped addons.", "OK")
					elseif launchfailure == "noship" then
						OpenAlarm("Unable to launch:", "You need to select a ship to launch.", "OK")
					end
				end
			end,
		}
CapShipOptionsButton = iup.stationbutton{
			title="Options",
			tip="Config or logout",
			expand="HORIZONTAL",
			action=function(self)
				HideDialog(CapShipDialog)
				OptionsDialog:SetMenuMode(2, CapShipDialog)
				ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER)
			end,
		}
CapShipCurrentLocationInfo = iup.label{title="YOU ARE HERE", alignment="ACENTER", expand="HORIZONTAL", fgcolor=tabunseltextcolor, font=Font.H4}
CapShipSecondaryInfo = iup.label{
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
			CapShipSecondaryInfo,
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
			CapShipLaunchButton,
			CapShipOptionsButton,
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
	CapShipSecondaryInfo.title = string.format(
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
	CapShipSecondaryInfo.size = "1x1"
end

CapShipFactionInfo = CreateCapShipFactionInfo()
CapShipChatArea = chatareatemplate2(false)
CapShipTacticalTab = CreateCapShipTacticalTab() CapShipTacticalTab.tabtitle="Tactical" CapShipTacticalTab.hotkey = iup.K_c
CapShipTabPDA = CreateCapShipPDATab() CapShipTabPDA.tabtitle = "Your PDA"  CapShipTabPDA.hotkey = iup.K_y
CapShipTabs = iup.pda_root_tabs{
		{expand="HORIZONTAL", spacer=true},
		CapShipTacticalTab,
		{size=5, spacer=true},
		CapShipTabPDA,
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
curtab = CapShipTacticalTab

local gap = -(Font.H4*1.5 - 4)
local twentypercent = gkinterface.GetYResolution()*.20

CapShipDialog = iup.dialog{
		iup.vbox{
			iup.hbox{
				iup.pdarootframe{
					CapShipChatArea,
					size="%74x%20",
					expand="NO",
				},
				iup.vbox{
					iup.pdarootframe{
						CapShipFactionInfo,
					},
					iup.pdarootframe{
						iup.vbox{
							iup.fill{},
							CapShipCurrentLocationInfo,
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
				CapShipTabs,
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
		defaultesc=CapShipOptionsButton,
		fullscreen="YES",
	}

missiontimer = Timer()
update_mission_timers = function()
	local firsttimer = GetMissionTimers()
	if firsttimer and CapShipDialog.visible == "YES" then
		firsttimer = math.max(0, firsttimer)
		StationCurrentLocationInfo.title = "Mission Timer: "..format_time(firsttimer)
--		StationSecondaryMissionTimer.title = "Mission Timer: "..format_time(firsttimer)
		missiontimer:SetTimeout(50, function() update_mission_timers() end)
	else
--		StationSecondaryMissionTimer.title = ""
		CapShipCurrentLocationInfo.title = ShortLocationStr(GetCurrentSectorid() or 1)
		missiontimer:Kill()
	end
end

function CapShipDialog:k_any(c)
	local keycommand = gkinterface.GetCommandForKeyboardBind(c)
	if c == iup.K_1 then
		CapShipTabs:SetTab(CapShipTacticalTab)
	elseif c == iup.K_2 then
		CapShipTabs:SetTab(CapShipTabPDA)
	elseif keycommand == "say_sector" then
		CapShipChatArea:set_chatmode(2)
		return iup.CONTINUE
	elseif keycommand == "say_channel" then
		CapShipChatArea:set_chatmode(3)
		return iup.CONTINUE
	elseif keycommand == "say_group" then
		CapShipChatArea:set_chatmode(4)
		return iup.CONTINUE
	elseif keycommand == "say_guild" then
		CapShipChatArea:set_chatmode(5)
		return iup.CONTINUE
	elseif keycommand == "say_system" then
		CapShipChatArea:set_chatmode(6)
		return iup.CONTINUE
	else
		local curtab = CapShipTabs:GetTab()
		if curtab == CapShipTacticalTab then return CapShipTacticalTab:k_any(c)
		elseif curtab == CapShipTabPDA then return CapShipTabPDA:k_any(c)
		end
		return iup.CONTINUE
	end
end

function CapShipDialog:show_cb()
	isvisible = true
	curtab:OnShow()
	CapShipChatArea:OnShow()
	CapShipFactionInfo:OnShow()
	update_secondary_info()
	update_mission_timers()
	SetStationLogReceiver(CapShipLog)
end

function CapShipDialog:hide_cb()
	isvisible = false
	curtab:OnHide()
	CapShipChatArea:OnHide()
	CapShipFactionInfo:OnHide()
	missiontimer:Kill()
	SetStationLogReceiver(nil)
end

function CapShipDialog:map_cb()
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

function CapShipDialog:OnEvent(eventname, ...)
	if GetCurrentStationType() ~= 1 then return end
	if not HasActiveShip() then return end

	if eventname == "SHOW_STATION" then
		HideAllDialogs()
		HideDialog(HUD.dlg)
		CapShipCurrentLocationInfo.title = ShortLocationStr(GetCurrentSectorid() or 1)
		SetStationLogRead()
		gkinterface.Draw3DScene(Game.GetCVar("rRenderStationInMenu") == 1)
		ShowDialog(self)
	elseif eventname == "ENTERING_STATION" then
		gkinterface.Draw3DScene(Game.GetCVar("rRenderStationInMenu") == 1)
		HideDialog(ConnectingDialog)
		NotificationDialog:SetMessage("Entering "..tostring(GetStationName()).."...")
		ShowDialog(NotificationDialog, iup.CENTER, iup.CENTER)
		HUD:SetMode("chat")
	elseif eventname == "LEAVING_STATION" then
		gkinterface.Draw3DScene(true)
		missiontimer:Kill()
		HideDialog(self)
		-- set up the Tactical tab as default every time player enters capship.
		CapShipTabs:SetTab(CapShipTacticalTab)
		CapShipTacticalTab:SetTab(CapShipTurretTab)
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
			CapShipTabs:SetTab(CapShipTabPDA)
			CapShipTabPDA:SetTab(CapShipPDAMissionsTab)
			CapShipPDAMissionsTab:SetTab(CapShipPDAMissionBoardTab)
--]]
	elseif eventname == "MISSION_NOTIFICATION" then
--		if self.visible == "YES" then
			-- todo: flash the tab text or something.
--		else
			CapShipTabs:SetTab(CapShipTabPDA)
			CapShipTabPDA:SetTab(CapShipPDAMissionsTab)
			CapShipPDAMissionsTab:SetTab(CapShipPDAMissionLogTab)
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
		CapShipChatArea:update_channeltitle()
	elseif eventname == "TRANSACTION_FAILED" then
		local errorstring, errorid = ...
		print("capship error: "..tostring(errorstring))
		if errorid == 26 then -- 26 = failed to launch because your ship didn't have enough grid power.
			HideDialog(NotificationDialog)
			ShowDialog(CapShipDialog)
		end
	end
end

CapShipDialog:map()
