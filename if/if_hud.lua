local __iup_sa = iup.StoreAttribute  -- just to speed up the call a little because it's called so often.
local tableconcat = table.concat

HUD_SCALE = 640/tonumber(Game.GetCVar("rHUDxscale"))

if Platform == 'Android' then
	font_HUD_SCALE = HUD_SCALE * 1.5
else
	font_HUD_SCALE = HUD_SCALE
end

function calc_health_color(health, alpha, mode)
	if health < 0 then health = 0 end
	local g = (1.25*health);		-- Green fades out fast, and red fades in quick.
	local r = (8.0*(1.0 - health));
	if g > 1 then g = 1 end
	if r > 1 then r = 1 end
	return string.format("%d %d 0 %d %s", r*255,g*255, alpha or 255, mode or "*")
end

HUD = HUD or {
	visibility={
		radar = gkini.ReadInt("Vendetta", "HUDradar", 1)==1 and "YES" or "NO",
		crosshair = gkini.ReadInt("Vendetta", "HUDcrosshair", 1)==1 and "YES" or "NO",
		targetdir = gkini.ReadInt("Vendetta", "HUDtargetdir", 1)==1 and "YES" or "NO",
		leadoff = gkini.ReadInt("Vendetta", "HUDleadoff", 1)==1 and "YES" or "NO",
		chat = gkini.ReadInt("Vendetta", "HUDchat", 1)==1 and "YES" or "NO",
		distance = gkini.ReadInt("Vendetta", "HUDdistance", 1)==1 and "YES" or "NO",
		speed = gkini.ReadInt("Vendetta", "HUDspeed", 1)==1 and "YES" or "NO",
		energy = gkini.ReadInt("Vendetta", "HUDenergy", 1)==1 and "YES" or "NO",
		damagedir = gkini.ReadInt("Vendetta", "HUDdamagedir", 1)==1 and "YES" or "NO",
		selfinfo = gkini.ReadInt("Vendetta", "HUDselfinfo", 1)==1 and "YES" or "NO",
		groupinfo = gkini.ReadInt("Vendetta", "HUDgroupinfo", 1)==1 and "YES" or "NO",
		targetinfo = gkini.ReadInt("Vendetta", "HUDtargetinfo", 1)==1 and "YES" or "NO",
		license = gkini.ReadInt("Vendetta", "HUDlicense", 1)==1 and "YES" or "NO",
		missiontimers = gkini.ReadInt("Vendetta", "HUDmissiontimers", 1)==1 and "YES" or "NO",
		addons = gkini.ReadInt("Vendetta", "HUDaddons", 1)==1 and "YES" or "NO",
		cargo = gkini.ReadInt("Vendetta", "HUDcargo", 1)==1 and "YES" or "NO",
		fa_indicator = gkini.ReadInt("Vendetta", "HUDflightassistindicator", 1)==1,
		fa_notification = gkini.ReadInt("Vendetta", "HUDflightassistnotification", 1)==1,
		aa_indicator = gkini.ReadInt("Vendetta", "HUDautoaimindicator", 1)==1,
		aa_notification = gkini.ReadInt("Vendetta", "HUDautoaimnotification", 1)==1,
		nfz_indicator = gkini.ReadInt("Vendetta", "HUDnfzindicator", 1)==1,
	},
}

local _xres = gkinterface.GetXResolution()
local _yres = gkinterface.GetYResolution()
HUD.Centered = (_xres >= 1920) and ((_xres/_yres) >= 16/9)  -- if >= 1920 and widescreen
HUD.Centered = gkini.ReadInt("Vendetta", "HUDcentered", HUD.Centered and 1 or 0)==1

function HUDSize(x,y)
	if x then
--		if centerit and x then x = x * ((_yres*4/3)/_xres) end
--		local t = {(x and ('%'..math.floor(x*100))) or "", y and ('%'..math.floor(y*100))}
		if HUD.Centered then
			x = x * (_yres*4/3)
		else
			x = x * _xres
		end
	end
	local t = {(x and (math.floor(x))) or "", y and ('%'..math.floor(y*100))}
	return tableconcat(t, 'x')
end


dofile(IF_DIR.."if_hud_group.lua")
dofile(IF_DIR.."if_hud_selfinfo.lua")
dofile(IF_DIR.."if_hud_chat.lua")
dofile(IF_DIR.."if_hud_progress.lua")
dofile(IF_DIR.."if_hud_icons.lua")
dofile(IF_DIR.."if_hud_target.lua")
dofile(IF_DIR.."if_hud_missiontimer.lua")
dofile(IF_DIR.."if_hud_licensewatch.lua")
dofile(IF_DIR.."if_hud_touch.lua")

RegisterEvent(HUD, "TOUCH_PRESSED")
RegisterEvent(HUD, "TOUCH_RELEASED")
RegisterEvent(HUD, "HUD_SHOW")
RegisterEvent(HUD, "HUD_HIDE")
RegisterEvent(HUD, "HUD_TOGGLE")
RegisterEvent(HUD, "HUD_UPDATE")
RegisterEvent(HUD, "HUD_MODE_TOGGLE")
RegisterEvent(HUD, "SYSMENU_TOGGLE")
RegisterEvent(HUD, "HUD_INVENTORY_TOGGLE")
RegisterEvent(HUD, "PLAYER_HIT")
RegisterEvent(HUD, "PLAYER_LEFT_SECTOR")
RegisterEvent(HUD, "PLAYER_DIED")
RegisterEvent(HUD, "PLAYER_GOT_HIT")
RegisterEvent(HUD, "INVENTORY_ADD")
RegisterEvent(HUD, "INVENTORY_UPDATE")
RegisterEvent(HUD, "INVENTORY_REMOVE")
RegisterEvent(HUD, "SHIP_CHANGED")
RegisterEvent(HUD, "SHIP_UPDATED")
RegisterEvent(HUD, "FLIGHT_MODE_CHANGED")
RegisterEvent(HUD, "AUTOAIM_MODE_CHANGED")
RegisterEvent(HUD, "DESIRED_SPEED_CHANGED")
RegisterEvent(HUD, "WEAPON_GROUP_CHANGED")
RegisterEvent(HUD, "CHAT_CANCELLED")
RegisterEvent(HUD, "CHAT_DONE")
RegisterEvent(HUD, "CHANGE_ACTIVE_CHATTAB")
RegisterEvent(HUD, "SECTOR_CHANGED")
RegisterEvent(HUD, "SECTOR_ALIGNMENT_UPDATED")
RegisterEvent(HUD, "TARGET_CHANGED")
RegisterEvent(HUD, "WEAPON_PROGRESS_START")
RegisterEvent(HUD, "WEAPON_PROGRESS_STOP")
RegisterEvent(HUD, "TARGET_SCANNED")
RegisterEvent(HUD, "MSG_LOGOFF_TIMER")
RegisterEvent(HUD, "MSG_NOTIFICATION")
RegisterEvent(HUD, "PLAYER_STATS_UPDATED")
RegisterEvent(HUD, "PLAYER_UPDATE_STATS")
RegisterEvent(HUD, "PLAYER_UPDATE_SKILLS")
RegisterEvent(HUD, "GROUP_CREATED")
RegisterEvent(HUD, "GROUP_SELF_JOINED")
RegisterEvent(HUD, "GROUP_MEMBER_JOINED")
RegisterEvent(HUD, "GROUP_SELF_LEFT")
RegisterEvent(HUD, "GROUP_MEMBER_LEFT")
RegisterEvent(HUD, "GROUP_MEMBER_UPDATE")
RegisterEvent(HUD, "GROUP_OWNER_CHANGED")
RegisterEvent(HUD, "GROUP_MEMBER_HEALTH_UPDATE")
RegisterEvent(HUD, "GROUP_MEMBER_LOCATION_CHANGED")
RegisterEvent(HUD, "TARGET_HEALTH_UPDATE")
RegisterEvent(HUD, "ACTIVATE_CHAT_SAY")
RegisterEvent(HUD, "ACTIVATE_CHAT_CHANNEL")
RegisterEvent(HUD, "ACTIVATE_CHAT_SECTOR")
RegisterEvent(HUD, "ACTIVATE_CHAT_GROUP")
RegisterEvent(HUD, "ACTIVATE_CHAT_GUILD")
RegisterEvent(HUD, "ACTIVATE_CHAT_PRIVATE")
RegisterEvent(HUD, "ACTIVATE_CHAT_MISSION")
RegisterEvent(HUD, "ACTIVATE_CHAT_USER")
RegisterEvent(HUD, "MISSION_TIMER_STOP")
RegisterEvent(HUD, "MISSION_TIMER_START")
RegisterEvent(HUD, "CHAT_SCROLL_UP")
RegisterEvent(HUD, "CHAT_SCROLL_DOWN")
RegisterEvent(HUD, "rHUDxscale")
RegisterEvent(HUD, "PROXIMITY_ALERT")
RegisterEvent(HUD, "ENTER_ZONE_NFZ")
RegisterEvent(HUD, "LEAVE_ZONE_NFZ")
RegisterEvent(HUD, "CINEMATIC_START")
RegisterEvent(HUD, "HUD_SKIRMISH_OPEN")
RegisterEvent(HUD, "HUD_SKIRMISH_CLOSE")
RegisterEvent(HUD, "HUD_SKIRMISH_UPDATE")
RegisterEvent(HUD, "VOICECHAT_PLAYER_TALK_STATUS")
RegisterEvent(HUD, "VOICECHAT_PLAYER_LISTEN_STATUS")
RegisterEvent(HUD, "VOICECHAT_PLAYER_MUTE_STATUS")

RegisterEvent(HUD, "SHIP_SPAWNED")

function HUD:OnEvent(eventname, ...)
debugprint(eventname)
	if eventname == "HUD_SHOW" then
		local hudtype = ...
		HideAllDialogs()
		self.IsVisible = true
		self.hudtype = hudtype
		self:CreateAimTouchRegion(hudtype)
		if self.hudtype == "turret" then
			for k=1,6 do
				self.selfhealthparts[k].visible = "NO"
				self.selfhealthparts[k].size = "1x1"
			end
		else
			for k=1,6 do
				self.selfhealthparts[k].visible = "YES"
				self.selfhealthparts[k].size = "64x128"
			end
		end
		if self.showhelpstring == 1 then
			if self.hudtype == "turret" then
				self.help_text.title = "Press the Activate key to leave the turret"
			else
				self.help_text.title = "Press F1 for help"
			end
			FadeControl(self.help_text, 20, 20, 0)
		else
			self.help_text.alpha = 0
		end
		self:SetMode("all")
		ShowDialog(self.dlg)
	elseif eventname == "HUD_HIDE" then
		self:DestroyAimTouchRegion()
		self.IsVisible = false
--		HideDialog(self.dlg)
--		if self.help_text then
--			FadeStop(self.help_text)
--			self.help_text.alpha = 0
--		end
	elseif eventname == "CINEMATIC_START" then
		self:SetMode("chat")
		ShowDialog(self.dlg)
	elseif eventname == "HUD_TOGGLE" then
		if self.IsVisible then
			if self.hud_toggled_off then
				self:ShowHUD()
			else
				self:HideHUD()
			end
		end
	elseif eventname == "HUD_MODE_TOGGLE" then
		-- hud mode: group/single mode
		self:ToggleGroupList()
	elseif eventname == "SHIP_SPAWNED" then
		self:ShowChat()
	elseif eventname == "HUD_UPDATE" then
	elseif eventname == "TOUCH_PRESSED" then
		self:OnTouchPressed(...)
	elseif eventname == "TOUCH_RELEASED" then
		self:OnTouchReleased(...)
	elseif eventname == "SYSMENU_TOGGLE" and (self.IsVisible or self.dlg.visible == "YES") then
		if OptionsDialog then
			HideAllDialogs()
			OptionsDialog:SetMenuMode(2, self)
			ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER)
			HideDialog(HUD.dlg)
		else
			Logout(2)
		end
	elseif eventname == "PLAYER_HIT" then
		local t = gkmisc.GetGameTime()
		if (not self.lasthitsoundtime) or (t > self.lasthitsoundtime+150) then
			gksound.GKPlaySound("hit");
			self.lasthitsoundtime = t
		end
	elseif eventname == "PROXIMITY_ALERT" then
		gksound.GKPlaySound("prox.warning");
	elseif (eventname == "ENTER_ZONE_NFZ") or (eventname == "LEAVE_ZONE_NFZ") then
		if self.visibility.nfz_indicator then
			local nfz_alert_mode = Game.GetNFZMode()
			gksound.GKPlaySound(nfz_alert_mode and "nfz.warning.enter" or "nfz.warning.leave");
		end
		self:ChangeNFZMode()
	elseif eventname == "INVENTORY_ADD" or
		eventname == "INVENTORY_REMOVE" or
		eventname == "INVENTORY_UPDATE" then
		if self.IsVisible then
			self:UpdateCargoInfo()
		end
	elseif eventname == "SHIP_UPDATED" then
		if self.IsVisible then
			self:UpdateHealthInfo(true)
		end
	elseif eventname == "SHIP_CHANGED" then
		self:ChangeShipInfo()
	elseif eventname == "FLIGHT_MODE_CHANGED" then
		if self.visibility.fa_notification then
			if Game.GetFlightMode() then
				generalprint("Flight-Assist mode enabled.")
			else
				generalprint("Flight-Assist mode disabled.")
			end
		end
		self:ChangeFlightMode()
	elseif eventname == "AUTOAIM_MODE_CHANGED" then
		if self.visibility.aa_notification then
			if Game.GetCVar("autoaim")==1 then
				generalprint("Auto-Aim enabled.")
			else
				generalprint("Auto-Aim disabled.")
			end
		end
		self:UpdateAutoAimIndicator()
	elseif eventname == "DESIRED_SPEED_CHANGED" then
		if self.IsVisible then
			self.leftbar.altvalue = Game.GetDesiredSpeed()
		end
	elseif eventname == "WEAPON_GROUP_CHANGED" then
		self:SetWeaponGroupHighlights()
	elseif eventname == "PLAYER_GOT_HIT" then
		self.PLAYER_GOT_HIT_args = {...}
	elseif eventname == "CHAT_CANCELLED" or eventname == "CHAT_DONE" then
		self:cancel_chat()
	elseif eventname == "SECTOR_CHANGED" then
		if self.locationtext then
			self.locationtext.title = ShortLocationStr(GetCurrentSectorid())
			self.sectoralignmenttext.title = (FactionName[GetSectorAlignment()] or "").."  "..(FactionMonitorStr[GetSectorMonitoredStatus()] or "")
		end
		-- reset groupinfo
		self:ResetGroupList()
	elseif eventname == "SECTOR_ALIGNMENT_UPDATED" then
		self.sectoralignmenttext.title = (FactionName[GetSectorAlignment()] or "").."  "..(FactionMonitorStr[GetSectorMonitoredStatus()] or "")
	elseif eventname == "HUD_INVENTORY_TOGGLE" then
		self:ChangeAddonElement(not self.invclosed)
	elseif eventname == "TARGET_CHANGED" or eventname == "TARGET_HEALTH_UPDATE" then
		if eventname == "TARGET_CHANGED" then
			if self.scaninfo then self.scaninfo.title = "" end
		end
		self:UpdateTargetInfo()
	elseif eventname == "WEAPON_PROGRESS_START" then
		self:StartWeaponProgress(...)
	elseif eventname == "WEAPON_PROGRESS_STOP" then
		local weaponid = ...
		self:StopWeaponProgress(weaponid)
	elseif eventname == "TARGET_SCANNED" then
		local arg1 = ...
		if self.scaninfo and arg1 then self.scaninfo.title=arg1 end
	elseif eventname == "MSG_LOGOFF_TIMER" then
		if self.IsVisible then
			self.logoff_text.title = ...
			FadeControl(self.logoff_text, 3, 3, 0)
		end
	elseif eventname == "MSG_NOTIFICATION" then
		if self.IsVisible then
			self.notify_text.title = ...
			FadeControl(self.notify_text, 5, 4, 0)
		end
	elseif eventname == "PLAYER_UPDATE_STATS" then
		if self.selfcredits then
			self.selfcredits.title=" "..comma_value(GetMoney())
		end
		self:UpdateLicenseWatch()
	elseif (eventname == "PLAYER_STATS_UPDATED" or eventname == "PLAYER_UPDATE_SKILLS") then
		local charid = ...
		if charid == GetCharacterID() then
			self:UpdateLicenseWatch()
		end
	elseif eventname == "GROUP_CREATED" then
		self:DestroyGroupList()
		self:CreateGroupList()
		self:ShowGroupList()
	elseif eventname == "GROUP_SELF_JOINED" then
		self:DestroyGroupList()
		self:CreateGroupList()
		self:ShowGroupList()
	elseif eventname == "GROUP_MEMBER_JOINED" then
		self:UpdateGroupList()
	elseif eventname == "GROUP_SELF_LEFT" then
		self:DestroyGroupList()
		self:HideGroupList()
	elseif eventname == "GROUP_MEMBER_LEFT" then
		self:UpdateGroupList()
	elseif eventname == "GROUP_OWNER_CHANGED" then
		self:UpdateGroupOwner()
	elseif eventname == "GROUP_MEMBER_UPDATE" then
		local arg1 = ...
		self:UpdateGroupMemberInfo(arg1)
	elseif eventname == "PLAYER_LEFT_SECTOR" then
		local arg1 = ...
		self:UpdateGroupMemberHealth(arg1, -1)
	elseif eventname == "PLAYER_DIED" then
		local arg1 = ...
		self:UpdateGroupMemberHealth(arg1, -1)
	elseif eventname == "GROUP_MEMBER_LOCATION_CHANGED" then
		local arg1 = ...
		self:UpdateGroupMemberHealth(arg1, nil, nil)
	elseif eventname == "GROUP_MEMBER_HEALTH_UPDATE" then
		local arg1, arg2, arg3, arg4 = ...
		self:UpdateGroupMemberHealth(arg1, arg3, arg4)
	elseif eventname == "ACTIVATE_CHAT_PRIVATE" then
		local arg1 = ...
		local title = (arg1 or GetLastPrivateSpeaker())..":"
		self:ShowGeneralChatEdit(title, "PRIVATE")
	elseif eventname == "ACTIVATE_CHAT_SAY" then
		self:ShowGeneralChatEdit("Sector:", "SAY")
	elseif eventname == "ACTIVATE_CHAT_SECTOR" then
		self:ShowGeneralChatEdit("Sector:", "SECTOR")
	elseif eventname == "ACTIVATE_CHAT_CHANNEL" then
		self:ShowGeneralChatEdit("Channel:", "CHANNEL")
	elseif eventname == "ACTIVATE_CHAT_GROUP" then
		self:ShowGeneralChatEdit("Group:", "GROUP")
	elseif eventname == "ACTIVATE_CHAT_GUILD" then
		self:ShowGeneralChatEdit("Guild:", "GUILD")
	elseif eventname == "ACTIVATE_CHAT_MISSION" then
		if HUD.IsVisible then
			HideDialog(HUD.dlg)
			HideAllDialogs()
			PDATab1:SetTab(PDAMissionsTab)
			local numactivemissions = GetNumActiveMissions()
--			if numactivemissions == 0 then
--				PDAMissionsTab:SetTab(PDAMissionBoardTab)
--			else
				PDAMissionsTab:SetTab(PDAMissionLogTab)
--			end
			ShowDialog(PDADialog)
		end
	elseif eventname == "ACTIVATE_CHAT_USER" then
		local arg1 = ...
		self:ShowGeneralChatEdit(arg1, nil)
	elseif eventname == "MISSION_TIMER_STOP" then
		if self.IsVisible then
			self:UpdateMissionTimers(GetMissionTimers())
		end
	elseif eventname == "MISSION_TIMER_START" then
		if self.IsVisible then
			self:UpdateMissionTimers(GetMissionTimers())
		end
	elseif eventname == "HUD_SKIRMISH_OPEN" or eventname == "HUD_SKIRMISH_CLOSE" then
		self:UpdateSkirmishInfo(GetSkirmishInfo())
	elseif eventname == "HUD_SKIRMISH_UPDATE" then
		self:UpdateSkirmishInfo(GetSkirmishInfo())
	elseif eventname == "CHAT_SCROLL_UP" then
		if self.chatcontainer then
			self.chatcontainer.chattext.scroll = "PAGEUP"
		end
	elseif eventname == "CHAT_SCROLL_DOWN" then
		if self.chatcontainer then
			self.chatcontainer.chattext.scroll = "PAGEDOWN"
		end
	elseif eventname == "rHUDxscale" then
		HUD_SCALE = 640/tonumber(Game.GetCVar("rHUDxscale"))
		self.Reload()
	elseif eventname == "VOICECHAT_PLAYER_TALK_STATUS" then
		local charid, status = ...
		self:SetGroupMemberTalkStatus(charid, status)
	elseif eventname == "VOICECHAT_PLAYER_LISTEN_STATUS" then
		local charid, status = ...
		self:SetGroupMemberListenStatus(charid, status)
	elseif eventname == "VOICECHAT_PLAYER_MUTE_STATUS" then
		local charid, status = ...
		self:SetGroupMemberMuteStatus(charid, status)
	end
end

function HUD:UpdateCargoInfo()
	self:SetupAddons()
	self.selfmass.title=" "..comma_value((math.floor(1000*(GetActiveShipMass() or 0)+0.5))).."kg"
	self.selfcargo.title=string.format(" %u / %ucu", GetActiveShipCargoCount() or 0, GetActiveShipMaxCargo() or 0)
end

function HUD:Destroy()
	self:HideMissionIndicator()
	
	self:DestroyTouchLayer()

	FadeStop(self.help_text)
	FadeStop(self.hitby_text)
	FadeStop(self.blood_flash)
	FadeStop(self.logoff_text)
	FadeStop(self.notify_text)
	for k,v in ipairs(self.secondarychatarealines) do
		FadeStop(v)
	end
	for k,v in ipairs(self.selfhealthparts) do
		FadeStop(v)
	end
	for k,v in pairs(self.damage_direction) do
		FadeStop(v)
	end
	self.target = nil
	self.dlg:destroy()
	self.dlg = nil
end

function HUD:Make()
	local dlg
	if self.dlg then return end
	self.invclosed = true
	self.progressbars = {container=iup.vbox{gap="4"}, items={}}
	local xres = gkinterface.GetXResolution()*HUD_SCALE
	local yres = gkinterface.GetYResolution()*HUD_SCALE
	local aspect_correction = ((4/3)/(xres/yres))
	local radarsize = math.floor(xres*.225)
	local iconsize = math.floor(xres*.04)
	local destarrowsize = math.floor(xres*.03)
	local radarblipscale = xres/800
	radar.SetAimDirIconSize(32*radarblipscale)
	radar.SetAimDirIcon(IMAGE_DIR.."hud_new_aimdir.png")
	radar.SetAimDirIconColor(1,1,1,1,"&")
	radar.SetWormholeIconSize(32*radarblipscale)
	radar.SetNavDestinationArrowIconSize(16*radarblipscale)
	radarsize = radarsize.."x"..radarsize
	iconsize = iconsize.."x"..iconsize
	destarrowsize = destarrowsize.."x"..destarrowsize
	local leftradar = iup.radar{type="FRONT", blipscale=tostring(radarblipscale), image=IMAGE_DIR.."hud_radar_left.png", size=radarsize, bgcolor="255 255 255 255 &", expand="NO", active="NO"}
	local rightradar = iup.radar{type="BACK", blipscale=tostring(radarblipscale), image=IMAGE_DIR.."hud_radar_right.png", size=radarsize, bgcolor="255 255 255 255 &", expand="NO", active="NO"}
	local crosshair = iup.label{title="", image=IMAGE_DIR.."hud_new_crosshairs.png", size=iconsize, bgcolor="255 255 255 255 &"}
	local target_arrow = iup.radar{type="ARROW", image=IMAGE_DIR.."hud_triangle.png", size="150x150", bgcolor="255 255 255 255 &", expand="NO", active="NO"}
	local leadoff_arrow = iup.radar{type="LEADOFF", image=IMAGE_DIR.."hud_target.png", imageover=IMAGE_DIR.."hud_target_over.png", size=iconsize, bgcolor="255 255 255 255 &", expand="NO", active="NO"}
	local locationtext = iup.label{title="", alignment="ACENTER", expand="HORIZONTAL", fgcolor="14 153 202", font=Font.H4*font_HUD_SCALE}
	local sectoralignmenttext = iup.label{title="", alignment="ACENTER", expand="HORIZONTAL", fgcolor="14 153 202", font=Font.H4*font_HUD_SCALE}
	local distancetext = iup.label{title="0m", alignment="ACENTER", expand="HORIZONTAL", fgcolor="14 153 202", font=Font.H4*font_HUD_SCALE}
	local _distancebarsize = string.format("%fx%f", xres*.15*aspect_correction, yres*.05)
	local distancebar = iup.progressbar{type="HORIZONTAL",
		LOWERCOLOR="0 0 0 0 +",
		MIDDLEABOVECOLOR="255 255 255 255 &",
		MIDDLEBELOWCOLOR="255 255 255 255 &",
		UPPERCOLOR="0 0 0 0 +",
		MINVALUE=0,
		MAXVALUE=6000,
		mode="TRINARY",
		expand="NO",
		size=_distancebarsize,
		}
	local distance_texture = IMAGE_DIR.."hud_distance_progress.png"
	distancebar.lowertexture = distance_texture
	distancebar.middletexture = distance_texture
	distancebar.uppertexture = distance_texture
	local distancebaruv = string.format("%f %f %f 1", 4/128, 2/32, 124/128)
	distancebar.uv = distancebaruv
	local distance3000m = iup.label{title="",image=IMAGE_DIR.."hud_distance_activate.png",bgcolor="255 255 255 255 &", size=_distancebarsize, uv=distancebaruv}
	local distance_all = iup.zbox{iup.label{title="",image=IMAGE_DIR.."hud_distance_bg.png",bgcolor="255 255 255 255 &", size=_distancebarsize, uv=distancebaruv},distancebar,all="YES"}
	local jumpindicator = iup.zbox{
		distance_all, distance3000m, alignment="ACENTER", expand="NO", all="YES"}
	local nfzindicator = iup.label{title="---", size=_distancebarsize, wordwrap="NO", fgcolor = "212 32 32", font=Font.H4*font_HUD_SCALE, alignment='ACENTER'}
	self.nfzindicator = nfzindicator
	local distanceindicator = iup.vbox{
		nfzindicator,
		iup.fill{size="30"},
		distancetext,
		jumpindicator,
		iup.fill{size="30"},
		locationtext,
		iup.fill{size="30"},
		sectoralignmenttext,
		margin="0x0", expand="NO",
		gap="-15",
		alignment="ACENTER",
	}
	self.locationtext = locationtext
	self.sectoralignmenttext = sectoralignmenttext
	self.distancetext = distancetext

	local barsize = (xres*0.04*aspect_correction).."x"..(yres*0.2)

	local leftbar = iup.progressbar{expand="NO", size=barsize, type="VERTICAL", active="NO"}
	local powerbars_texture = IMAGE_DIR.."powerbar_left.png"
	leftbar.lowertexture = powerbars_texture
	leftbar.middleabovetexture = IMAGE_DIR.."powerbar_left_red.png"
	leftbar.middlebelowtexture = IMAGE_DIR.."powerbar_left_green.png"
	leftbar.uppertexture = powerbars_texture
	leftbar.minvalue = 0
	leftbar.maxvalue = 100
	leftbar.middleabovecolor = "255 255 255 255 &" -- if value > altvalue
	leftbar.middlebelowcolor = "255 255 255 255 &" -- if value < altvalue
	leftbar.lowercolor = "255 255 255 255 &"
	leftbar.uppercolor = "0 0 0 0 +"
	leftbar.uv = "0 0.03125 1 0.96875"
	leftbar.value = 0
	leftbar.altvalue = 0
	leftbar.mode = "TRINARY"

	local rightbar = iup.progressbar{expand="NO", size=barsize, type="VERTICAL", active="NO"}
	powerbars_texture = IMAGE_DIR.."powerbar_right.png"
	rightbar.lowertexture = powerbars_texture
	rightbar.middletexture = powerbars_texture
	rightbar.uppertexture = powerbars_texture
	rightbar.minvalue = 0
	rightbar.maxvalue = 100
	rightbar.lowercolor = "255 255 255 255 &"
	rightbar.uppercolor = "0 0 0 0 +"
	rightbar.uv = "0 0.03125 1 0.96875"
	rightbar.value = 0

	local lefttext = iup.label{title="2000 m/s", size="%7x", alignment="ACENTER", wordwrap="NO", font=Font.H4*font_HUD_SCALE}
	local leftflightassistindicator = iup.label{title="", size="%7x", wordwrap="NO", font=Font.H4*font_HUD_SCALE}
	local righttext = iup.label{title="100 %", size="%7x", alignment="ACENTER", wordwrap="NO", font=Font.H4*font_HUD_SCALE}
	local rightautoaimindicator = iup.label{title="", size="%7x", wordwrap="NO", font=Font.H4*font_HUD_SCALE}
	lefttext.fgcolor = "64 128 128"
	leftflightassistindicator.fgcolor = "64 128 128"
	righttext.fgcolor = "64 128 128"
	rightautoaimindicator.fgcolor = "64 128 128"

	local damage_left = iup.label{title="",image=IMAGE_DIR.."hud_damage_left.png",bgcolor="255 255 255 0 *", size=barsize, uv="0 0 1 0.9375"}
	local damage_right = iup.label{title="",image=IMAGE_DIR.."hud_damage_right.png",bgcolor="255 255 255 0 *", size=barsize, uv="0 0 1 0.9375"}
	local _topbottomsize = string.format("%fx%f", xres*.15*aspect_correction, yres*.05)
	local damage_top = iup.label{title="",image=IMAGE_DIR.."hud_damage_top.png",bgcolor="255 255 255 0 *", size=_topbottomsize, uv=string.format("%f %f %f 1", 4/128, 2/32, 124/128)}
	local damage_bottom = iup.label{title="",image=IMAGE_DIR.."hud_damage_bottom.png",bgcolor="255 255 255 0 *", size=_topbottomsize, uv=string.format("%f 0 %f %f", 4/128, 124/128, 30/32)}

	self.damage_direction = {
		nil,
		nil,
		damage_left,
		damage_right,
		damage_top,
		damage_bottom,
	}

	self.distancebar = distanceindicator
	self.speedbar = iup.vbox{
				leftflightassistindicator, -- here to make this symmetric
				iup.zbox{iup.label{title="",image=IMAGE_DIR.."powerbar_left_bg.png",size=barsize,uv = "0 0.03125 1 0.96875",bgcolor="255 255 255 255 &"},leftbar,all="YES"},
				lefttext,
				alignment="ACENTER",
			}
	self.energybar = iup.vbox{
				rightautoaimindicator, -- here to make this symmetric
				iup.zbox{iup.label{title="",image=IMAGE_DIR.."powerbar_right_bg.png",size=barsize,uv = "0 0.03125 1 0.96875",bgcolor="255 255 255 255 &"},rightbar,all="YES"},
				righttext,
				alignment="ACENTER",
			}
	local layer1 = iup.zbox{
		all="YES",
		iup.vbox{
			iup.fill{},
			iup.hbox{
				iup.fill{},
				self.speedbar,
				iup.fill{size=xres*.15*aspect_correction},
				self.energybar,
				iup.fill{},
				alignment="ACENTER",
			},
			iup.fill{},
			alignment="ACENTER",
		},
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{size="HALF"},
				iup.fill{size=yres*0.10},
				distanceindicator,
				iup.fill{},
				alignment="ACENTER",
			},
			iup.fill{},
			alignment="ACENTER",
		},
	}
	self.targetdirectionlayer = iup.vbox{
		iup.fill{},
		iup.hbox{iup.fill{}, target_arrow, iup.fill{}},
		iup.fill{},
	}
	self.crosshairlayer = iup.vbox{
		iup.fill{},
		iup.hbox{iup.fill{}, crosshair, iup.fill{}},
		iup.fill{},
	}

if gkinterface.IsTouchModeEnabled() then
	self.radarlayer = iup.vbox{
		iup.fill{},
		iup.hbox{leftradar, iup.fill{}, rightradar, margin = "138x97"},
	}
else
	self.radarlayer = iup.vbox{
		iup.fill{},
		iup.hbox{leftradar, iup.fill{}, rightradar, margin = "10x10"},
	}
end

	self.progressbarlayer = iup.hbox{
		iup.fill{},
		iup.vbox{iup.fill{size="%75"}, 
			self.progressbars.container,
			iup.fill{},
			alignment="ACENTER",
		},
		iup.fill{},
	}
	self.damagedirectionlayer = iup.zbox{
		all="YES",
		iup.vbox{
			iup.fill{},
			iup.hbox{
				iup.fill{},
				damage_left,
				iup.fill{size=xres*.20*aspect_correction},
				damage_right,
				iup.fill{},
				alignment="ACENTER",
			},
			iup.fill{},
			alignment="ACENTER",
		},
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				damage_top,
				iup.fill{size=yres*.24},
				damage_bottom,
				iup.fill{},
				alignment="ACENTER",
			},
			iup.fill{},
			alignment="ACENTER",
		},
	}
	
	self.touchdisplaylayer = HUD:CreateTouchLayer()
	
	self.logoff_text = iup.label{title="", font=Font.HUDNotification*font_HUD_SCALE, alignment="ACENTER", expand="HORIZONTAL"}
	self.hitby_text = iup.label{title="", font=Font.HUDNotification*font_HUD_SCALE, alignment="ACENTER", expand="HORIZONTAL"}
	self.notify_text = iup.label{title="", font=Font.HUDNotification*font_HUD_SCALE, fgcolor="40 180 240", alignment="ACENTER", expand="HORIZONTAL"}
	self.help_text = iup.label{title="Press F1 for Help", font=Font.HUDNotification*font_HUD_SCALE, fgcolor="255 255 0 0", alignment="ACENTER", expand="HORIZONTAL"}
	self.textnotificationlayer = iup.vbox{
		iup.fill{size="%60"},
		self.logoff_text,
		self.hitby_text,
		self.notify_text,
		self.help_text,
		iup.fill{},
		alignment="ACENTER",
		gap="16",
	}

	self:CreateChatArea()
	self:CreateTargetArea()
	self:CreateMissionTimerArea()
	self:CreateIconAreas()
	self:CreateSelfInfo()
	self:CreateGroupArea()
	self:CreateLicenseWatchArea()

	self.scaninfo = iup.label{title="", expand="YES", alignment="ARIGHT", font=Font.H4*font_HUD_SCALE}
	self.secondarychatarea = iup.vbox{expand="YES"}
	self.secondarychatarealines = {}
	self.blood_flash = iup.label{title="", image="", size="FULLxFULL", fgcolor="0 0 0 0 +", bgcolor="0 0 0 0 +"}
	self.BSinfo = {
		friendlylabel = iup.label{title="Tunguska: 1000", fgcolor = FactionColor_RGB[1], expand="HORIZONTAL", wordwrap="NO", font=Font.H4*font_HUD_SCALE},
		enemylabel = iup.label{title="Tunguska: 1000", fgcolor = FactionColor_RGB[2], expand="HORIZONTAL", wordwrap="NO", font=Font.H4*font_HUD_SCALE},
		friendlyprogress = iup.progressbar{expand="NO", size="100x2", type="HORIZONTAL", active="NO", minvalue=0, maxvalue=100, value = 100, lowercolor="0 0 255 255 &", uppercolor="0 0 0 0 +"},
		enemyprogress = iup.progressbar{expand="NO", size="100x2", type="HORIZONTAL", active="NO", minvalue=0, maxvalue=100, value = 100, lowercolor="255 0 0 255 &", uppercolor="0 0 0 0 +"},
	}
	self.layer3_other1 = 
		iup.hbox{
			iup.vbox{
				self.addonframe,
				iup.zbox{self.cargoframe,self.morecargoindicator,all='YES', alignment="NE"},
				self.missionupdateindicator,
				self.voteindicator,
				iup.vbox{
					self.BSinfo.friendlylabel,
					self.BSinfo.friendlyprogress,
					self.BSinfo.enemyprogress,
					self.BSinfo.enemylabel,
					expand="NO",
				},
				gap=4,
			},
			iup.zbox{
				self.scaninfo,
				self.secondarychatarea,
				all="YES",
				expand="YES",
				alignment="NW",
			},
			iup.zbox{
				self.selfinfoframe,
				self.groupinfoframe,
				expand="NO",
			}
		}
	self.layer3_other2 = 
			iup.vbox{
				self.targetframe,
				iup.zbox{
					self.licensewatchframe,
					self.missiontimerframe,
				},
				gap=4,
			}
	self.chatlayer = iup.vbox{
		iup.hbox{
			self.chatframe,
			self.layer3_other2,
			gap=4,
		},
		self.layer3_other1,
		gap=4,
		margin="4x4",
	}
	self.leadofflayer = iup.hbox{leadoff_arrow, iup.fill{}} -- just so leadoff doesn't resize
	self.pluginlayer = iup.zbox{iup.vbox{},all="YES",expand="YES"}
	self.cboxlayer = iup.cbox{self.restcargoframe,self.morecargoindicator2, size=HUDSize(1,1),active="NO"}
	self.layers = {
		layer1, self.targetdirectionlayer, self.crosshairlayer, self.radarlayer, self.progressbarlayer, self.damagedirectionlayer, self.touchdisplaylayer,
		self.textnotificationlayer,
		self.chatlayer, self.leadofflayer,
		self.pluginlayer,
--		self.blood_flash,
		self.cboxlayer,
		all="YES",
	}
--	local zbox = iup.zbox(self.layers)
local spacer = (gkinterface.GetXResolution() - (gkinterface.GetYResolution()*4/3))*.5
	local zbox = iup.zbox{iup.hbox{ iup.fill{size=self.Centered and spacer}, iup.zbox(self.layers), iup.fill{size=self.Centered and spacer} }, self.blood_flash, all="YES"}
--	local zbox = iup.zbox{iup.zbox(self.layers), self.blood_flash, all="YES"}

	dlg = iup.dialog{
		zbox,
		fullscreen="YES",
--		CENTERED="YES",
--		size=HUDSize(1,1),
		MAXBOX="NO",
		MINBOX="NO",
		MENUBOX="NO",
		
		bgcolor = "0 0 0 0 *",
		shrink="YES",
		resize="NO",
		border="NO",
		topmost="YES",
	}
	function dlg:getfocus_cb()
		gkinterface.HideMouse()
		Game.SetInputMode(1)
	end
	self.dlg = dlg
	self.leftbar = leftbar
	self.rightbar = rightbar
	self.lefttext = lefttext
	self.leftflightassistindicator = leftflightassistindicator
	self.righttext = righttext
	self.rightautoaimindicator = rightautoaimindicator
	self.jumpindicator = {distance_all=distance_all, distancebar=distancebar, distance3000m=distance3000m}
	self.leadoff_arrow = leadoff_arrow
	self.updatetimer = Timer()
	self.nummissiontimers = 0
	self.hud_toggled_off = false
	if self.group_list_visible == nil then
		self.group_list_visible = GetNumGroupMembers() > 0
	end

	dlg:map()
	
	self.restcargoframe.cx = tonumber(self.cargoframe.x) + tonumber(self.cargoframe.w)
	self.restcargoframe.cy = tonumber(self.cargoframe.y)
	self.morecargoindicator2.cx = tonumber(self.cargoframe.x) + tonumber(self.cargoframe.w)
	self.morecargoindicator2.cy = tonumber(self.cargoframe.y)
	self.cboxlayer.REFRESH = "YES"
	self.restcargoframe.visible = self.invclosed and "NO" or "YES"
	self.morecargoindicator2.visible = self.invclosed and "NO" or "YES"
	
	function dlg:show_cb()
		SetChatLogReceiver(HUD.chatcontainer)
		SetMissionLogReceiver(HUD.missionlogcontainer)

		HUD:Show()
		if HUD.currentshowmode == "chat" then
			HUD:HideMost()
		end
	end

	function dlg:hide_cb()
		HUD:HideMost()
		HUD:cancel_chat()
--		HUD.IsVisible = false
		HUD.hudtype = "ship"
		if HUD.help_text then
			FadeStop(HUD.help_text)
			HUD.help_text.alpha = 0
		end
	end
end

function HUD:setup_visible_elements()
	-- front/back radar
	self.radarlayer.visible = self.visibility.radar

	-- crosshair
	self.crosshairlayer.visible = self.visibility.crosshair

	-- target direction arrow
	self.targetdirectionlayer.visible = self.visibility.targetdir

	-- target leadoff indicator
	self.leadofflayer.visible = self.visibility.leadoff

	-- chat region
	self.chatframe.visible = self.visibility.chat

	-- distance from nearest large object indicator
	self.distancebar.visible = self.visibility.distance

	-- speed indicator
	self.speedbar.visible = self.visibility.speed

	-- energy indicator
	self.energybar.visible = self.visibility.energy

	-- damage direction
	self.damagedirectionlayer.visible = self.visibility.damagedir

	-- self info
	self.selfinfoframe.visible = self.visibility.selfinfo

	-- group info
	self.groupinfoframe.visible = self.visibility.groupinfo

	-- target info
	self.targetframe.visible = self.visibility.targetinfo

	-- watched license
	self.licensewatchframe.visible = self.visibility.license

	-- mission timer
	self.missiontimerframe.visible = self.visibility.missiontimers

	-- addon list
	self.addonframe.visible = self.visibility.addons

	-- cargo list
	self.cargoframe.visible = self.visibility.cargo
	self.morecargoindicator.visible = self.morethan4items and self.visibility.cargo or "NO"
	self.restcargoframe.visible = self.invclosed and "NO" or (self.morethan4items and self.visibility.cargo or "NO")
	self.morecargoindicator2.visible = self.invclosed and "NO" or (self.morethan4items and self.visibility.cargo or "NO")

	-- navpoint thingy
	if Show3000mNavpoint then
		radar.Show3000mNavpoint()
	else
		radar.Hide3000mNavpoint()
	end

	self:UpdateMissionTimers(GetMissionTimers())
	if self.group_list_visible then
		self:ShowGroupList()
	else
		self:HideGroupList()
	end
end

function HUD.update()
	local self = HUD
	local curtime = gkmisc.GetGameTime()
	local delta = gkmisc.DiffTime(self.prevtime, curtime)*0.001
	self.prevtime = curtime
	self:setspeed(GetActiveShipSpeed() or 0)
	local e1,e2 = GetActiveShipEnergy()
	self:setenergy(e1 or 0 ,e2 or 0)
	self:SetTargetDistance(GetTargetDistance())
	local parenthealth = GetParentHealth()
	if parenthealth then
		parenthealth = math.max(parenthealth, 0)
		__iup_sa(self.distancetext, "TITLE", string.format("Ship armor: %d%%", parenthealth))
		__iup_sa(self.jumpindicator.distance3000m, "VISIBLE", "NO")
		__iup_sa(self.jumpindicator.distance_all, "VISIBLE", "YES")
		__iup_sa(self.jumpindicator.distancebar, "VALUE", 60*parenthealth)
		__iup_sa(self.jumpindicator.distancebar, "ALTVALUE", 0)
	else
		local dist = radar.GetNearestObjectDistance()
		local minjumpdist = GetMinJumpDistance()
		if dist < 0 or dist >= minjumpdist then
			dist = minjumpdist
			__iup_sa(self.jumpindicator.distancebar, "VALUE", 6000)
			__iup_sa(self.jumpindicator.distancebar, "ALTVALUE", 0)
			if ((self.destarrow == 3) or (self.destarrow == 2)) and not self.continuecoursemsgprinted then
				__iup_sa(self.jumpindicator.distance3000m, "VISIBLE", "YES")
				__iup_sa(self.jumpindicator.distance_all, "VISIBLE", "NO")
				self.notify_text.title = "Press the Activate key to continue on your plotted course."
				FadeControl(self.notify_text, 3, 3, 0)
				self.continuecoursemsgprinted = true
			end
		else
			__iup_sa(self.jumpindicator.distance3000m, "VISIBLE", "NO")
			__iup_sa(self.jumpindicator.distance_all, "VISIBLE", "YES")
			__iup_sa(self.jumpindicator.distancebar, "VALUE", minjumpdist+dist)
			__iup_sa(self.jumpindicator.distancebar, "ALTVALUE", minjumpdist-dist)
			self.continuecoursemsgprinted = false
		end
		__iup_sa(self.distancetext, "TITLE", string.format("%dm", dist))
	end
	self:UpdateWeaponProgress(delta)
	self.updatetimer:SetTimeout(50)

	if self.nummissiontimers > 0 then
		self:UpdateMissionTimers(GetMissionTimers())
	end

	if self.PLAYER_GOT_HIT_args then
		local arg1, attackercharid, arg3, arg4 = self.PLAYER_GOT_HIT_args[1], self.PLAYER_GOT_HIT_args[2], self.PLAYER_GOT_HIT_args[3], self.PLAYER_GOT_HIT_args[4]
		self.PLAYER_GOT_HIT_args = nil
		local attackername = GetPlayerName(attackercharid)
		if attackername then
			local color
			if arg4 then
				color = "255 0 0"  -- being damaged = red
			else
				color = "0 255 0"  -- being healed = green
			end
			if attackercharid ~= GetCharacterID() then -- don't show self
				__iup_sa(self.hitby_text, "FGCOLOR", color)
				__iup_sa(self.hitby_text, "TITLE", attackername)
				FadeControl(self.hitby_text, 5, 4, 0)
			end
			__iup_sa(self.blood_flash, "BGCOLOR", color.." 0 +")
			__iup_sa(self.blood_flash, "VISIBLE", "YES")
			FadeControl(self.blood_flash, 0.5, FlashIntensity, 0)
		end
	end

end

function HUD:UpdateAutoAimIndicator()
	if not self.IsVisible then return end

	local autoaimOn = Game.GetCVar("autoaim")==1
	
	if autoaimOn then
		if self.visibility.aa_indicator then
			self.rightautoaimindicator.title = "A/A Mode"
		end
	else
		self.rightautoaimindicator.title = ""
	end
end

function HUD:ChangeFlightMode()
	if not self.IsVisible then return end
	if Game.GetFlightMode() then
		self.leftbar.altvalue = Game.GetDesiredSpeed()
		self.leftbar.mode = "TRINARY"
		if self.visibility.fa_indicator then
			self.leftflightassistindicator.title = "F/A Mode"
		end
	else
		self.leftbar.mode = "BINARY"
		self.leftflightassistindicator.title = ""
	end
end

function HUD:ChangeNFZMode()
	if not self.IsVisible then return end
	if Game.GetNFZMode() then
		if self.visibility.nfz_indicator then
			self.nfzindicator.title = "NFZ"
		end
	else
		self.nfzindicator.title = ""
	end
end


-- these functions are for HUD_TOGGLE. they don't kill off the HUD, they just stop it from rendering.
function HUD:ShowHUD()
	self.hud_toggled_off = false
	for _,v in ipairs(self.layers) do
		v.visible = "YES"
	end
	if self.visible then
		radar.ShowRadar()
	end
	self:setup_visible_elements()
end
function HUD:HideHUD()
	self.hud_toggled_off = true
	for _,v in ipairs(self.layers) do
		v.visible = "NO"
	end
	self.blood_flash.visible = "YES" -- this is in self.layers, so just reshow it.
	radar.HideRadar()
end
function HUD:UpdateHUDvisibility()
	if self.IsVisible then
		if self.hud_toggled_off then
			self:HideHUD()
		else
			self:ShowHUD()
		end
	elseif self.dlg.visible == "YES" then
		self:ShowChat()
	end
end


function HUD:Show()
	if not self.IsVisible then return end
	self.jumpindicator.distancebar.visible = "YES"
	self.jumpindicator.distance3000m.visible = "NO"
	self.jumpindicator.distance_all.visible = "YES"
	self.PLAYER_GOT_HIT_args = nil

	self:DestroyGroupList()
	self:CreateGroupList()
	if self.group_list_visible then
		self:ShowGroupList()
	else
		self:HideGroupList()
	end
	self:UpdateHealthInfo(false)
	self:UpdateLicenseWatch()
	self:UpdateCargoInfo()
	self:ChangeShipInfo()
	self.selfcredits.title=" "..comma_value(GetMoney())
	self.locationtext.title = ShortLocationStr(GetCurrentSectorid())
	self.sectoralignmenttext.title = (FactionName[GetSectorAlignment()] or "").."  "..(FactionMonitorStr[GetSectorMonitoredStatus()] or "")

	self.visible = "YES"
	self:ChangeFlightMode()
	self:ChangeNFZMode()
	self:UpdateAutoAimIndicator()
	self:UpdateTargetInfo()
	self.scaninfo.title = ""
	self:SetWeaponGroupHighlights()
	self:UpdateMissionTimers(GetMissionTimers())

	self:SetFlightPath(NavRoute.GetNextHop())
	self:UpdateSkirmishInfo(GetSkirmishInfo())

	self.prevtime = gkmisc.GetGameTime()
	local maxspeed = GetActiveShipMaxSpeed()
	if maxspeed then
		self.maxspeed = maxspeed
		self.leftbar.maxvalue = maxspeed
		self.updatetimer:SetTimeout(30, self.update)
		self.update()
	else
		self.maxspeed = 50
		self.leftbar.maxvalue = self.maxspeed
		self.leftbar.value = 0
		self.rightbar.value = 0
	end

	self:ShowEverything()
	self:UpdateHUDvisibility()
end

function HUD:ShowEverything()
	for _,v in ipairs(self.layers) do
		v.visible = "YES"
	end
	self.layer3_other1.visible = "YES"
	self.layer3_other2.visible = "YES"
end


function HUD:HideMost()
	self:DestroyGroupList()
	self.updatetimer:Kill()
	self.visible = false
	radar.HideRadar()
	-- hide all payers
	for _,v in ipairs(self.layers) do
		v.visible = "NO"
	end
	-- show main chat
	self.chatlayer.visible = "YES"
	-- but not other parts of chat.
	self.layer3_other1.visible = "NO"
	self.layer3_other2.visible = "NO"
end

function HUD:ShowChat()
	self:ShowEverything()
	self:HideMost()
end

function HUD:SetMode(mode)
	if self.currentshowmode ~= mode then
		self.currentshowmode = mode
		if self.dlg.visible == "YES" then
			if mode == "chat" then
				self:ShowChat()
			else
				self:Show()
			end
		end
	end
end

function HUD:setspeed(value)
	__iup_sa(self.lefttext, "TITLE", string.format("%d m/s", math.floor(value+0.5)))
	__iup_sa(self.leftbar, "VALUE", value)
	__iup_sa(self.leftbar, "ALTVALUE", Game.GetDesiredSpeed())
	if value < self.maxspeed then
		__iup_sa(self.lefttext, "FGCOLOR", "64 128 128")
	else
		__iup_sa(self.lefttext, "FGCOLOR", "128 255 255")
	end
--	self.leftbar.value = value
--	self.leftbar.altvalue = Game.GetDesiredSpeed()
--	self.lefttext.title = string.format("%d m/s", math.floor(value)) -- tostring(math.floor(value)).." m/s"
end

function HUD:setenergy(energy, percent)
	__iup_sa(self.righttext, "TITLE", tostring(math.floor(energy)))
	__iup_sa(self.rightbar, "VALUE", percent*100)
--	self.rightbar.value = percent*100
--	self.righttext.title = tostring(math.floor(energy))
end

function HUD:SetFlightPath(nexthopsector)
	local destarrow = 0
	if not Game.GetTurretObjectID() then
		if nexthopsector then
			local nexthopsystem = GetSystemID(nexthopsector)
			local currentsystem = GetCurrentSystemid()
			if nexthopsystem ~= currentsystem then
				destarrow = 1
			elseif IsStormPresent() and nexthopsector ~= GetCurrentSectorid() then
				destarrow = 2
			elseif nexthopsector ~= GetCurrentSectorid() then
				destarrow = 3
			end
		end
		self.continuecoursemsgprinted = false
	end
	self.destarrow = destarrow
	radar.SetDestArrows(destarrow)
end

function HUD:UpdateSkirmishInfo(value1, value2, range1, range2, title1, title2, color1, color2, isvisible, fac2otherobjective)
	if isvisible then
		self.BSinfo.friendlylabel.visible = "YES"
		self.BSinfo.enemylabel.visible = "YES"
		self.BSinfo.friendlyprogress.visible = "YES"
		if fac2otherobjective == "" then
			self.BSinfo.enemylabel.title = (title2 or "Bad Guys")..': '..value2
			self.BSinfo.enemyprogress.visible = "YES"
			self.BSinfo.enemyprogress.value = 100*value2/range2
			self.BSinfo.enemyprogress.lowercolor = color2
		else
			self.BSinfo.enemylabel.title = fac2otherobjective
			self.BSinfo.enemyprogress.visible = "NO"
		end			
		self.BSinfo.friendlylabel.title = (title1 or "Good Guys")..': '..value1
--		self.BSinfo.enemylabel.title = (title2 or "Bad Guys")..': '..value2
		self.BSinfo.friendlyprogress.value = 100*value1/range1

		self.BSinfo.friendlylabel.fgcolor = color1
		self.BSinfo.enemylabel.fgcolor = color2
		self.BSinfo.friendlyprogress.lowercolor = color1
	else
		self.BSinfo.friendlylabel.visible = "NO"
		self.BSinfo.enemylabel.visible = "NO"
		self.BSinfo.friendlyprogress.visible = "NO"
		self.BSinfo.enemyprogress.visible = "NO"
	end
end

function HUD.Reload()
	dofile(IF_DIR.."if_hud.lua")
end

-- reload code
if HUD.dlg then
	local visible = HUD.dlg.visible == "YES"
	if visible then
		HideDialog(HUD.dlg)
	end
	HUD:Destroy()
	HUD:Make()
	if visible then
		HUD:SetupAddons()
		ShowDialog(HUD.dlg, iup.CENTER, iup.CENTER)
		GeneralChatPanel:reset() -- make sure chat window is scrolled down all the way.
	end
else
	HUD:Make()
end
