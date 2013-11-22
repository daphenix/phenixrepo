dofile(IF_DIR.."if_pda_tab1.lua")
dofile(IF_DIR.."if_pda_tab2.lua")
dofile(IF_DIR.."if_pda_tab3.lua")
dofile(IF_DIR.."if_pda_tab4.lua")

function CreatePDATab1()
	PDAMissionsTab, PDAMissionNotesTab, PDAMissionAdvancementTab, PDAMissionLogTab, PDAMissionBoardTab, PDAMissionBoardTabInfoButton = CreateMissionsPDATab() PDAMissionsTab.tabtitle="Missions"   PDAMissionsTab.hotkey = iup.K_m
	PDAShipTab, PDAShipNavigationTab = CreateShipPDATab() PDAShipTab.tabtitle="Navigation"   PDAShipTab.hotkey = iup.K_n
	PDASensorTab, PDASensorNearbyTab = CreateSensorPDATab(false) PDASensorTab.tabtitle="Sensor Log"   PDASensorTab.hotkey = iup.K_e
	PDACommTab = CreateCommPDATab() PDACommTab.tabtitle="Comm"   PDACommTab.hotkey = iup.K_o
	PDACharacterTab, PDACharacterStatsTab, PDACharacterFactionTab, PDACharacterAccomTab = CreateCharacterPDATab() PDACharacterTab.tabtitle="Character"   PDACharacterTab.hotkey = iup.K_r
	PDAInventoryTab, PDAInventoryInventoryTab, PDAInventoryJettisonTab = CreateInventoryPDATab(false) PDAInventoryTab.tabtitle="Inventory"   PDAInventoryTab.hotkey = iup.K_i

	return iup.roottabtemplate{
		PDAMissionsTab,
		PDAShipTab,
		PDASensorTab,
		PDACommTab,
		PDACharacterTab,
		PDAInventoryTab,
		secondary = iup.hbox{size="%14x"},
	}
end

function CreatePDA()
	local curtab
	local update_secondary_info
	local missiontimer
	local update_mission_timers
	local isvisible = false

	PDATab1 = CreatePDATab1()
	PDATab1.tabtitle = "Your PDA"
	PDAChatArea = chatareatemplate2(false)
	PDATargetInfo = CreateTargetInfo()
	PDACurrentLocationInfo = iup.label{title="YOU ARE HERE", alignment="ACENTER", expand="HORIZONTAL", fgcolor=tabunseltextcolor, font=Font.H2}
	PDACloseButton = iup.stationbutton{title="Close", expand="HORIZONTAL",
			action=function(self)
				HideDialog(PDADialog)
				ShowDialog(HUD.dlg)
			end
		}

	PDASecondaryInfo = iup.label{
		size="1x1",
		expand="YES",
		fgcolor=tabunseltextcolor,
		font=Font.H6,
		title="Credits: 10,001,100",
	}
--[[
	PDASecondaryMissionTimer = iup.label{
		size="50x",
		expand="HORIZONTAL",
		fgcolor=tabunseltextcolor,
		font=Font.H6,
		title="Mission Timer:\n00:00:00",
	}
--]]

	local secondary = iup.vbox{
		iup.pdasubframe_nomargin{
			iup.hbox{
			iup.vbox{
				PDASecondaryInfo,
--				PDASecondaryMissionTimer,
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
				PDACloseButton,
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

	PDATabs = iup.pda_root_tabs{
			{expand="HORIZONTAL", spacer=true},
			PDATab1,
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
	curtab = PDATab1

	local gap = -(Font.H4*1.5 - 4)
	local twentypercent = gkinterface.GetYResolution()*.20

	PDADialog = iup.dialog{
		iup.vbox{
			iup.hbox{
				iup.pdarootframe{
					PDAChatArea,
					size="%74x%20",
					expand="NO",
				},
				iup.vbox{
					iup.pdarootframe{
						PDATargetInfo,
					},
					iup.pdarootframe{
						iup.vbox{
							iup.fill{},
							PDACurrentLocationInfo,
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
				PDATabs,
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
		defaultesc=PDACloseButton,
		fullscreen="YES",
		show_cb=function()
			isvisible = true
			curtab:OnShow()
			PDAChatArea:OnShow()
			PDATargetInfo:OnShow()
			update_secondary_info()
			update_mission_timers()

			PDACurrentLocationInfo.title = ShortLocationStr(GetCurrentSectorid() or 1)
		end,
		k_any=function(self, ch)
			local keycommand = gkinterface.GetCommandForKeyboardBind(ch)
			if curtab.k_any and curtab:k_any(ch) ~= iup.CONTINUE then
				return iup.CONTINUE
			elseif keycommand == "+TopList" then
				if PDATab1:GetTab() == PDASensorTab and PDASensorTab:GetTab() == PDASensorNearbyTab then
					HideDialog(PDADialog)
					ShowDialog(HUD.dlg)
					return iup.IGNORE
				else
					PDATab1:SetTab(PDASensorTab)
					PDASensorTab:SetTab(PDASensorNearbyTab)
					return iup.IGNORE
				end
			elseif keycommand == "nav" then
				if PDATab1:GetTab() == PDAShipTab and PDAShipTab:GetTab() == PDAShipNavigationTab then
					HideDialog(PDADialog)
					ShowDialog(HUD.dlg)
					return iup.IGNORE
				else
					PDATab1:SetTab(PDAShipTab)
					PDAShipTab:SetTab(PDAShipNavigationTab)
					return iup.IGNORE
				end
			elseif keycommand == "Jettison" then
				if PDATab1:GetTab() == PDAInventoryTab and PDAInventoryTab:GetTab() == PDAInventoryJettisonTab then
					HideDialog(PDADialog)
					ShowDialog(HUD.dlg)
					return iup.IGNORE
				else
					PDATab1:SetTab(PDAInventoryTab)
					PDAInventoryTab:SetTab(PDAInventoryJettisonTab)
					return iup.IGNORE
				end
			elseif keycommand == "missionchat" then
				local numactivemissions = GetNumActiveMissions()
				if (PDATab1:GetTab() == PDAMissionsTab) and (((PDAMissionsTab:GetTab() == PDAMissionLogTab) and (numactivemissions>0)) or ((PDAMissionsTab:GetTab() == PDAMissionBoardTab) and (numactivemissions==0))) then
					HideDialog(PDADialog)
					ShowDialog(HUD.dlg)
					return iup.IGNORE
				else
					PDATab1:SetTab(PDAMissionsTab)
					if numactivemissions > 0 then
						PDAMissionsTab:SetTab(PDAMissionLogTab)
						iup.SetFocus(PDAMissionLogTab)
					else
						PDAMissionsTab:SetTab(PDAMissionBoardTab)
						iup.SetFocus(PDAMissionBoardTab)
					end
					return iup.IGNORE
				end
			elseif keycommand == "CharInfo" then
				if PDATab1:GetTab() == PDACharacterTab and PDACharacterTab:GetTab() == PDACharacterStatsTab then
--				if PDATab1:GetTab() == PDACharacterTab then
					HideDialog(PDADialog)
					ShowDialog(HUD.dlg)
					return iup.IGNORE
				else
					PDATab1:SetTab(PDACharacterTab)
					PDACharacterTab:SetTab(PDACharacterStatsTab)
					return iup.IGNORE
				end
			elseif keycommand == "say_sector" then
				PDAChatArea:set_chatmode(2)
			elseif keycommand == "say_channel" then
				PDAChatArea:set_chatmode(3)
			elseif keycommand == "say_group" then
				PDAChatArea:set_chatmode(4)
			elseif keycommand == "say_guild" then
				PDAChatArea:set_chatmode(5)
			elseif keycommand == "say_system" then
				PDAChatArea:set_chatmode(6)
			end
			return iup.CONTINUE
		end,
	}

	function PDADialog:hide_cb()
		isvisible = false
		curtab:OnHide()
		PDAChatArea:OnHide()
		PDATargetInfo:OnHide()
		missiontimer:Kill()
	end
	function PDADialog:map_cb()
		RegisterEvent(self, "PLAYERLIST_TOGGLE")
		RegisterEvent(self, "NAVMENU_TOGGLE")
		RegisterEvent(self, "JETTISONMENU_TOGGLE")
		RegisterEvent(self, "CHAT_CANCELLED")
		RegisterEvent(self, "CHAT_MSG_SERVER_CHANNEL_ACTIVE")
		RegisterEvent(self, "MISSION_TIMER_STOP")
		RegisterEvent(self, "MISSION_TIMER_START")
		RegisterEvent(self, "MISSION_NOTIFICATION")
		RegisterEvent(self, "MISSION_REMOVED")
		RegisterEvent(self, "PLAYER_UPDATE_STATS")
		RegisterEvent(self, "INVENTORY_ADD")
		RegisterEvent(self, "INVENTORY_REMOVE")
		RegisterEvent(self, "INVENTORY_UPDATE")
		RegisterEvent(self, "PLAYER_HOME_CHANGED")
	end

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
		PDASecondaryInfo.title = string.format(
			"Credits: %sc\nCurrent Ship:\n%s\nCargo: %u/%u cu\nMass: %skg\nLicenses: %s/%s/%s/%s/%s\nHome: %s",
			comma_value(GetMoney()), shipname, curcargo, maxcargo, comma_value((math.floor(1000*shipmass+0.5))),
			lic1>0 and lic1 or "-",
			lic2>0 and lic2 or "-",
			lic3>0 and lic3 or "-",
			lic4>0 and lic4 or "-",
			lic5>0 and lic5 or "-",
			home
			)
		PDASecondaryInfo.size = "1x1"
	end

	missiontimer = Timer()
	update_mission_timers = function()
		local firsttimer = GetMissionTimers()
		if firsttimer and PDADialog.visible == "YES" then
			firsttimer = math.max(0, firsttimer)
			PDACurrentLocationInfo.title = "Mission Timer: "..format_time(firsttimer)
--			PDASecondaryMissionTimer.title = "Mission Timer: "..format_time(firsttimer)
			missiontimer:SetTimeout(50, function() update_mission_timers() end)
		else
--			PDASecondaryMissionTimer.title = ""
			PDACurrentLocationInfo.title = ShortLocationStr(GetCurrentSectorid() or 1)
			missiontimer:Kill()
		end
	end

	function PDADialog:OnEvent(eventname, ...)
		if eventname == "PLAYERLIST_TOGGLE" then
			if self.visible == "YES" and PDATab1:GetTab() == PDASensorTab and PDASensorTab:GetTab() == PDASensorNearbyTab then
				HideDialog(self)
				ShowDialog(HUD.dlg)
			elseif HUD.IsVisible then
				HideDialog(HUD.dlg)
				HideAllDialogs()
				PDATabs:SetTab(PDATab1)
				PDATab1:SetTab(PDASensorTab)
				PDASensorTab:SetTab(PDASensorNearbyTab)
				ShowDialog(self, 0,0)
				iup.SetFocus(PDASensorNearbyTab)
			end
		elseif eventname == "NAVMENU_TOGGLE" then
			if self.visible == "YES" and PDATab1:GetTab() == PDAShipTab and PDAShipTab:GetTab() == PDAShipNavigationTab then
				HideDialog(self)
				ShowDialog(HUD.dlg)
			elseif HUD.IsVisible then
				HideDialog(HUD.dlg)
				HideAllDialogs()
				PDATabs:SetTab(PDATab1)
				PDATab1:SetTab(PDAShipTab)
				PDAShipTab:SetTab(PDAShipNavigationTab)
				ShowDialog(self, 0,0)
				iup.SetFocus(PDAShipNavigationTab)
			end
		elseif eventname == "JETTISONMENU_TOGGLE" then
			if self.visible == "YES" and PDATab1:GetTab() == PDAInventoryTab and PDAInventoryTab:GetTab() == PDAInventoryJettisonTab then
				HideDialog(self)
				ShowDialog(HUD.dlg)
			elseif HUD.IsVisible then
				HideDialog(HUD.dlg)
				HideAllDialogs()
				PDATabs:SetTab(PDATab1)
				PDATab1:SetTab(PDAInventoryTab)
				PDAInventoryTab:SetTab(PDAInventoryJettisonTab)
				ShowDialog(self, 0,0)
				iup.SetFocus(PDAInventoryJettisonTab)
			end
		elseif eventname == "CHAT_CANCELLED" then
			if self.visible == "YES" then
				HideDialog(self)
				ShowDialog(HUD.dlg)
			end
		elseif eventname == "MISSION_REMOVED" then
--[[  need to fix some missions before this can be used
				PDATabs:SetTab(PDATab1)
				PDATab1:SetTab(PDAMissionsTab)
				PDAMissionsTab:SetTab(PDAMissionBoardTab)
--]]
		elseif eventname == "MISSION_NOTIFICATION" then
--			if self.visible == "YES" then
				-- todo: flash the tab text or something.
--			else
				PDATabs:SetTab(PDATab1)
				PDATab1:SetTab(PDAMissionsTab)
				PDAMissionsTab:SetTab(PDAMissionLogTab)
--			end
		elseif eventname == "CHAT_MSG_SERVER_CHANNEL_ACTIVE" then
			PDAChatArea:update_channeltitle()
		elseif eventname == "PLAYER_UPDATE_STATS" then
			local charid = ...
			if self.visible == "YES" and charid == GetCharacterID() then
				update_secondary_info(self)
			end
		elseif eventname == "INVENTORY_ADD" or 
				eventname == "INVENTORY_REMOVE" or 
				eventname == "INVENTORY_UPDATE" or
				eventname == "PLAYER_HOME_CHANGED" then
			if self.visible == "YES" then
				update_secondary_info()
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
		end
	end

	PDADialog:map()

	return PDADialog
end

CreatePDA()
