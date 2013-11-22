-- interface options menu

local function create_interface_options_dialog()
	local dlg, container
	local hailmsg, usescale, scaleslider
	local showtooltips, runtutorialagain, colorname, colorchatinput
	local showlogoffconfirmation, showsethomeconfirmation, showsellallconfirmation
	local scaleslider_lefttext, scaleslider_righttext
	local showstationbehindmenu, showlowpowerdialog
	local toggleTouchMode
	local showbarupdatenotification
	local showgroupkillnotification
	local hudsettings, chatcolorsettings
	local okbutton, applybutton, cancelbutton
	local apply, setup
	local donotsetup
	local si_unit
	local commod_sort
	local flashintensity

	local statechangefunc = function(self) applybutton.active = "YES" end

	-- used to refresh all the matrix/listbox/etc.. 
	-- used with number formats and sort order
	local function refresh_stuff()
		ProcessEvent("STATION_UPDATE_PRICE")
	end
	
	hudsettings = iup.stationbutton{title="HUD Settings",
		action=function()
			donotsetup = true
			HideDialog(dlg)
			ShowDialog(HUDInterfaceOptionsDialog, iup.CENTER, iup.CENTER)
		end}
	chatcolorsettings = iup.stationbutton{title="Chat Color Settings",
		action=function()
			donotsetup = true
			HideDialog(dlg)
			ShowDialog(ChatColorOptionsDialog, iup.CENTER, iup.CENTER)
		end}
	hailmsg = iup.text{value="Hail", expand="HORIZONTAL", action=statechangefunc}
	showtooltips = iup.stationtoggle{title="Show Tool Tips", value="ON", action=statechangefunc}
	showlogoffconfirmation = iup.stationtoggle{title="Show 'Log Off Confirmation' dialog", value="ON", action=statechangefunc}
	showsethomeconfirmation = iup.stationtoggle{title="Show 'Set Home Station Confirmation' dialog", value="ON", action=statechangefunc}
	showsellallconfirmation = iup.stationtoggle{title="Show 'Sell All Confirmation' dialog", value="ON", action=statechangefunc}
	showlowpowerdialog = iup.stationtoggle{title="Show 'Low Grid Power' dialog", value="ON", action=statechangefunc}
	colorname = iup.stationtoggle{title="Colorize Names in Chat Log", value="ON", action=statechangefunc}
	colorchatinput = iup.stationtoggle{title="Colorize Text in the Chat Input Box", value="ON", action=statechangefunc}
	commod_sort = iup.stationsublist{'Name', 'Price', 'Group>Name>Price', 'Group>Price>Name', DROPDOWN='YES', value=SortItems, action=statechangefunc, expand="HORIZONTAL"}
	si_unit = iup.stationsublist{'No Formatting (1234.5m)', 'Space/Comma (1 234,5m)', 'Comma/Decimal (1,234.5m)', DROPDOWN='YES', value=SI_unit, action=statechangefunc, expand="HORIZONTAL"}
	runtutorialagain = iup.stationtoggle{title="Run Tutorial On Next Station Dock", value="OFF", action=statechangefunc}
	flashintensity = iup.canvas{
		scrollbar="HORIZONTAL", size="200x", border="NO",
		expand="NO",
		xmin = 0, xmax=100, dx=10, posx=0,
		scroll_cb=statechangefunc,
	}
	usescale = iup.stationtoggle{title="Use Manual Font Scaling", value="OFF",
		action=function(self, newstate)
			if newstate==1 then
				scaleslider.active = "YES"
				scaleslider_lefttext.fgcolor = tabseltextcolor
				scaleslider_righttext.fgcolor = tabseltextcolor
			else
				scaleslider.active = "NO"
				scaleslider_lefttext.fgcolor = "192 192 192"
				scaleslider_righttext.fgcolor = "192 192 192"
			end
			statechangefunc()
		end}
	scaleslider_lefttext = iup.label{title="    0.5"}
	scaleslider_righttext = iup.label{title="1.5"}
	scaleslider = iup.canvas{
		scrollbar="HORIZONTAL", size="200x", border="NO",
		expand="NO",
		xmin = 50, xmax=150, dx=10, posx=0,
		scroll_cb=statechangefunc,
		active="NO",
	}
	showstationbehindmenu = iup.stationtoggle{title="Show Station in Menu", value="OFF", action=statechangefunc}
	if Platform == 'Android' then
		toggleTouchMode = iup.stationtoggle{title="Enable Touchscreen Mode", value="ON", action=statechangefunc}
	end
	showbarupdatenotification = iup.stationtoggle{title="Station Bar Activity Triggers Attention", value="OFF", action=statechangefunc}
	showgroupkillnotification = iup.stationtoggle{title="Show Group Kill/Death Notification", value="ON", action=statechangefunc}

	okbutton = iup.stationbutton{title="OK",
		action=function() apply() donotsetup = nil HideDialog(dlg) ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER) end}
	applybutton = iup.stationbutton{title="Apply", active="NO",
		action=function() apply() end}
	cancelbutton = iup.stationbutton{title="Cancel",
		action=function() donotsetup = nil HideDialog(dlg) ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER) end}

	if Platform == 'Android' then
		container = iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					iup.hbox{iup.label{title="Hail Message:", fgcolor=tabunseltextcolor}, hailmsg, alignment="ACENTER"},
					iup.hbox{iup.label{title="Sort Commodities/Ship Items by:", fgcolor=tabunseltextcolor}, commod_sort, alignment="ACENTER"},
					iup.hbox{iup.label{title="Number Formatting:", fgcolor=tabunseltextcolor}, si_unit, alignment="ACENTER"},
					iup.hbox{iup.label{title="Hit Flash Intensity:", fgcolor=tabunseltextcolor}, iup.fill{size=5}, iup.label{title="0"}, flashintensity, iup.label{title="100"}, alignment="ACENTER"},
					colorchatinput,
					colorname,
					showtooltips,
					runtutorialagain,
					iup.hbox{usescale, scaleslider_lefttext, scaleslider, scaleslider_righttext, alignment="ACENTER"},
					showstationbehindmenu,
					showbarupdatenotification,
					showgroupkillnotification,
					showlowpowerdialog,
					showlogoffconfirmation,
					showsethomeconfirmation,
					showsellallconfirmation,
					toggleTouchMode,
					iup.hbox{hudsettings, chatcolorsettings, gap=5},
					iup.fill{},
					iup.hbox{
						okbutton, applybutton, cancelbutton, iup.fill{}; gap="15"
					},
					gap=5,
				},
			},
		}
	else
		container = iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					iup.hbox{iup.label{title="Hail Message:", fgcolor=tabunseltextcolor}, hailmsg, alignment="ACENTER"},
					iup.hbox{iup.label{title="Sort Commodities/Ship Items by:", fgcolor=tabunseltextcolor}, commod_sort, alignment="ACENTER"},
					iup.hbox{iup.label{title="Number Formatting:", fgcolor=tabunseltextcolor}, si_unit, alignment="ACENTER"},
					iup.hbox{iup.label{title="Hit Flash Intensity:", fgcolor=tabunseltextcolor}, iup.fill{size=5}, iup.label{title="0"}, flashintensity, iup.label{title="100"}, alignment="ACENTER"},
					colorchatinput,
					colorname,
					showtooltips,
					runtutorialagain,
					iup.hbox{usescale, scaleslider_lefttext, scaleslider, scaleslider_righttext, alignment="ACENTER"},
					showstationbehindmenu,
					showbarupdatenotification,
					showgroupkillnotification,
					showlowpowerdialog,
					showlogoffconfirmation,
					showsethomeconfirmation,
					showsellallconfirmation,
					iup.hbox{hudsettings, chatcolorsettings, gap=5},
					iup.fill{},
					iup.hbox{
						okbutton, applybutton, cancelbutton, iup.fill{}; gap="15"
					},
					gap=5,
				},
			},
		}
	end

	apply = function()
		applybutton.active = "NO"

		local playername = GetPlayerName()
		local refresh = false
		if playername then
			gkini.WriteString(playername, "hailmsg", hailmsg.value)
			Game.SetCVar("hailmsg", hailmsg.value)
		end
		ColorChatInput = colorchatinput.value=="ON"
		ColorName = colorname.value=="ON"
		ShowTooltips = showtooltips.value=="ON"
		ShowLowGridPowerDialog = showlowpowerdialog.value=="ON"
		ShowLogoffDialog = showlogoffconfirmation.value=="ON"
		ShowSetHomeDialog = showsethomeconfirmation.value=="ON"
		ShowSellAllDialog = showsellallconfirmation.value=="ON"
		FlashIntensity = flashintensity.posx/100
		
		if Platform == 'Android' then
			local oldmode = gkinterface.IsTouchModeEnabled()
			gkinterface.EnableTouchMode(toggleTouchMode.value=="ON")
			if oldmode ~= gkinterface.IsTouchModeEnabled() then
			   HUD:Reload()
			   if IsConnected() then
				  SendInputDeviceInfo()
			   end
			end
		end

		if SortItems ~= commod_sort.value then
			SortItems = commod_sort.value
			gkini.WriteInt("Vendetta", "sort_by", SortItems)
			refresh = true
		end

		if SI_unit ~= si_unit.value then
			SI_unit = si_unit.value
			gkini.WriteInt("Vendetta", "si_unit", si_unit.value)
			-- refresh everything in and out of the station.
			refresh = true
		end

		if refresh then refresh_stuff() end
		
		gkini.WriteInt("Vendetta", "flashintensity", flashintensity.posx)
		gkini.WriteInt("Vendetta", "colorchatinput", ColorChatInput and 1 or 0)
		gkini.WriteInt("Vendetta", "colorname", ColorName and 1 or 0)
		gkini.WriteInt("Vendetta", "enableTouchMode", gkinterface.IsTouchModeEnabled() and 1 or 0)
		gkini.WriteInt("Vendetta", "showtooltips", ShowTooltips and 1 or 0)
		gkini.WriteInt("Vendetta", "showlowpowerdialog", ShowLowGridPowerDialog and 1 or 0)
		gkini.WriteInt("Vendetta", "showlogoffconfirmation", ShowLogoffDialog and 1 or 0)
		gkini.WriteInt("Vendetta", "showsethomeconfirmation", ShowSetHomeDialog and 1 or 0)
		gkini.WriteInt("Vendetta", "showsellallconfirmation", ShowSellAllDialog and 1 or 0)
		gkini.WriteInt("Vendetta", "showhelpstring", HUD.showhelpstring)
		ShowBarUpdateNotification = showbarupdatenotification.value=="ON"
		gkini.WriteInt("Vendetta", "showbarupdatenotification", ShowBarUpdateNotification and 1 or 0)
		ShowGroupKillNotification = showgroupkillnotification.value=="ON"
		gkini.WriteInt("Vendetta", "showgroupkillnotification", ShowGroupKillNotification and 1 or 0)
		if runtutorialagain.active == "YES" then
			if runtutorialagain.value=="ON" then
				ResetTutorial()
			else
				StopTutorial()
			end
		end

		local reseteverything = false
		local newusefontscaling = usescale.value=="ON" and true or false
		if UseFontScaling ~= newusefontscaling then
			UseFontScaling = newusefontscaling
			gkini.WriteInt("Vendetta", "usefontscaling", UseFontScaling and 1 or 0)
			reseteverything = true
		end
		local newfontscale = tonumber(scaleslider.posx)/100
		if FontScale ~= newfontscale then
			FontScale = newfontscale
			gkini.WriteInt("Vendetta", "fontscale", FontScale*100)
			reseteverything = true
		end

		local ShowStationInMenu = showstationbehindmenu.value=="ON" and 1 or 0
		Game.SetCVar("rRenderStationInMenu", ShowStationInMenu)
		if PlayerInStation() or not IsConnected() then
			gkinterface.Draw3DScene(ShowStationInMenu==1)
		end

		if reseteverything then
			HideDialog(dlg)
			ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER)
			ReloadInterface()
		end
	end

	setup = function()
		applybutton.active = "NO"

		if IsConnected() then
			hailmsg.value = Game.GetCVar("hailmsg") or "Hail"
			hailmsg.active = "YES"
		else
			hailmsg.value = "Log in to set the hail message for a character."
			hailmsg.active = "NO"
		end
		if Platform == 'Android' then
			toggleTouchMode.value = (gkinterface.IsTouchModeEnabled()) and "ON" or "OFF"
		end
		showtooltips.value = (ShowTooltips==true) and "ON" or "OFF"
		showlowpowerdialog.value = (ShowLowGridPowerDialog==true) and "ON" or "OFF"
		showlogoffconfirmation.value = (ShowLogoffDialog==true) and "ON" or "OFF"
		showsethomeconfirmation.value = (ShowSetHomeDialog==true) and "ON" or "OFF"
		showsellallconfirmation.value = (ShowSellAllDialog==true) and "ON" or "OFF"
		colorname.value = (ColorName==true) and "ON" or "OFF"
		colorchatinput.value = (ColorChatInput==true) and "ON" or "OFF"
		si_unit.value = SI_unit
		-- this can only be set if the user is logged in.
		local shouldruntutorial = ShouldTutorialRun()
		runtutorialagain.value = shouldruntutorial and "ON" or "OFF"
		runtutorialagain.active = (shouldruntutorial~=nil) and "ON" or "OFF"

		usescale.value = UseFontScaling and "ON" or "OFF"
		if UseFontScaling then
			scaleslider.active = "YES"
			scaleslider_lefttext.fgcolor = tabseltextcolor
			scaleslider_righttext.fgcolor = tabseltextcolor
		else
			scaleslider.active = "NO"
			scaleslider_lefttext.fgcolor = "192 192 192"
			scaleslider_righttext.fgcolor = "192 192 192"
		end
		scaleslider.posx = (FontScale or 1)*100
		flashintensity.posx = FlashIntensity*100

		showbarupdatenotification.value = ShowBarUpdateNotification and "ON" or "OFF"
		showgroupkillnotification.value = ShowGroupKillNotification and "ON" or "OFF"
		local ShowStationInMenu = Game.GetCVar("rRenderStationInMenu")
		showstationbehindmenu.value = (ShowStationInMenu==1) and "ON" or "OFF"
	end

	dlg = iup.dialog{
		container,
		bgcolor="0 0 0 0 *",
		border="NO",menubox="NO",resize="NO",
		size="%55x",
		defaultesc=cancelbutton,
	}

	function dlg:show_cb()
		if not donotsetup then
			setup()
		end
	end

	dlg:map()

	return dlg
end

local function create_hudinterface_options_dialog()
	local dlg, container
	local option1, option2, option3, option4, option5
	local option6, option7, option8, option9, option10
	local option11, option12, option13, option14, option15
	local option16, option17, option18, option19, option20, option21
	local option22
	local showhelpinhud, targetmode_2d, targetmode_3d, targetboxmode
	local show3000mnavpoint
	local okbutton, applybutton, cancelbutton
	local apply, setup

	local statechangefunc = function(self) applybutton.active = "YES" end

	option1 = iup.stationtoggle{title="Show Radar", value="OFF", action=statechangefunc}
	option2 = iup.stationtoggle{title="Show Crosshair", value="OFF", action=statechangefunc}
	option3 = iup.stationtoggle{title="Show Target Direction Indicator", value="OFF", action=statechangefunc}
	option4 = iup.stationtoggle{title="Show Target Leadoff Indicator", value="OFF", action=statechangefunc}
	option5 = iup.stationtoggle{title="Show Chat", value="OFF", action=statechangefunc}
	option6 = iup.stationtoggle{title="Show Distance Indicator", value="OFF", action=statechangefunc}
	option7 = iup.stationtoggle{title="Show Speed Indicator", value="OFF", action=statechangefunc}
	option8 = iup.stationtoggle{title="Show Energy Indicator", value="OFF", action=statechangefunc}
	option9 = iup.stationtoggle{title="Show Damage Direction Indicators", value="OFF", action=statechangefunc}
	option10 = iup.stationtoggle{title="Show Character Info", value="OFF", action=statechangefunc}
	option11 = iup.stationtoggle{title="Show Target Info", value="OFF", action=statechangefunc}
	option12 = iup.stationtoggle{title="Show Watched License", value="OFF", action=statechangefunc}
	option13 = iup.stationtoggle{title="Show Mission Timers", value="OFF", action=statechangefunc}
	option14 = iup.stationtoggle{title="Show Addon List", value="OFF", action=statechangefunc}
	option15 = iup.stationtoggle{title="Show Cargo List", value="OFF", action=statechangefunc}
	option16 = iup.stationtoggle{title="Show Group Info", value="OFF", action=statechangefunc}
	option17 = iup.stationtoggle{title="Show Flight-Assist Indicator", value="OFF", action=statechangefunc}
	option18 = iup.stationtoggle{title="Show Flight-Assist Notification Text", value="OFF", action=statechangefunc}
	option19 = iup.stationtoggle{title="Show Auto-Aim Indicator", value="OFF", action=statechangefunc}
	option20 = iup.stationtoggle{title="Show Auto-Aim Notification Text", value="OFF", action=statechangefunc}
	option21 = iup.stationtoggle{title="Show No-Fire-Zone (NFZ) Indicator", value="OFF", action=statechangefunc}
	option22 = iup.stationtoggle{title="Center HUD to 4:3 region of screen", value="OFF", action=statechangefunc}
	showhelpinhud = iup.stationtoggle{title="Show F1 msg in HUD", value="OFF", action=statechangefunc}
	targetmode_2d = iup.stationradio{title="2D Square", action=statechange}
	targetmode_3d = iup.stationradio{title="3D Box", action=statechange}
	targetboxmode = iup.radio{iup.vbox{targetmode_2d, targetmode_3d, margin="20x0"}, value=targetmode_2d}
	show3000mnavpoint = iup.stationtoggle{title="Show 3000m Navpoint", value="ON", action=statechangefunc}

	okbutton = iup.stationbutton{title="OK",
		action=function() apply() HideDialog(dlg) ShowDialog(InterfaceOptionsDialog, iup.CENTER, iup.CENTER) end}
	applybutton = iup.stationbutton{title="Apply", active="NO",
		action=function() apply() end}
	cancelbutton = iup.stationbutton{title="Cancel",
		action=function() HideDialog(dlg) ShowDialog(InterfaceOptionsDialog, iup.CENTER, iup.CENTER) end}

	container = iup.stationhighopacityframe{
		iup.stationhighopacityframebg{
			iup.vbox{
				iup.hbox{
				iup.vbox{
				option1,
				option2,
				option3,
				option4,
				option5,
				option6,
				option7,
				option8,
				option9,
				showhelpinhud,
				show3000mnavpoint,
				option22,
				gap=2,
				},
				iup.fill{},
				iup.vbox{
				option10,
				option11,
				option12,
				option13,
				option14,
				option15,
				option16,
				option17,
				option18,
				option19,
				option20,
				option21,
				gap=2,
				},
				},
				iup.label{title="HUD Target Selection Mode"},
				targetboxmode,
				iup.fill{},
				iup.hbox{
					okbutton, applybutton, cancelbutton, iup.fill{}; gap="15"
				},
				gap=5,
			},
		},
	}

	apply = function()
		applybutton.active = "NO"

		HUD.visibility.radar = option1.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDradar", HUD.visibility.radar=="YES" and 1 or 0)
		HUD.visibility.crosshair = option2.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDcrosshair", HUD.visibility.crosshair=="YES" and 1 or 0)
		HUD.visibility.targetdir = option3.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDtargetdir", HUD.visibility.targetdir=="YES" and 1 or 0)
		HUD.visibility.leadoff = option4.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDleadoff", HUD.visibility.leadoff=="YES" and 1 or 0)
		HUD.visibility.chat = option5.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDchat", HUD.visibility.chat=="YES" and 1 or 0)

		HUD.visibility.distance = option6.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDdistance", HUD.visibility.distance=="YES" and 1 or 0)
		HUD.visibility.speed = option7.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDspeed", HUD.visibility.speed=="YES" and 1 or 0)
		HUD.visibility.energy = option8.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDenergy", HUD.visibility.energy=="YES" and 1 or 0)
		HUD.visibility.damagedir = option9.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDdamagedir", HUD.visibility.damagedir=="YES" and 1 or 0)
		HUD.visibility.selfinfo = option10.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDselfinfo", HUD.visibility.selfinfo=="YES" and 1 or 0)

		HUD.visibility.targetinfo = option11.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDtargetinfo", HUD.visibility.targetinfo=="YES" and 1 or 0)
		HUD.visibility.license = option12.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDlicense", HUD.visibility.license=="YES" and 1 or 0)
		HUD.visibility.missiontimers = option13.value=="ON" and"YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDmissiontimers", HUD.visibility.missiontimers=="YES" and 1 or 0)
		HUD.visibility.addons = option14.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDaddons", HUD.visibility.addons=="YES" and 1 or 0)
		HUD.visibility.cargo = option15.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDcargo", HUD.visibility.cargo=="YES" and 1 or 0)

		HUD.visibility.groupinfo = option16.value=="ON" and "YES" or "NO"
		gkini.WriteInt("Vendetta", "HUDgroupinfo", HUD.visibility.groupinfo=="YES" and 1 or 0)

		HUD.visibility.fa_indicator = option17.value=="ON"
		gkini.WriteInt("Vendetta", "HUDflightassistindicator", HUD.visibility.fa_indicator and 1 or 0)

		HUD.visibility.fa_notification = option18.value=="ON"
		gkini.WriteInt("Vendetta", "HUDflightassistnotification", HUD.visibility.fa_notification and 1 or 0)

		HUD.visibility.aa_indicator = option19.value=="ON"
		gkini.WriteInt("Vendetta", "HUDautoaimindicator", HUD.visibility.aa_indicator and 1 or 0)

		HUD.visibility.aa_notification = option20.value=="ON"
		gkini.WriteInt("Vendetta", "HUDautoaimnotification", HUD.visibility.aa_notification and 1 or 0)

		HUD.visibility.nfz_indicator = option21.value=="ON"
		gkini.WriteInt("Vendetta", "HUDnfzindicator", HUD.visibility.nfz_indicator and 1 or 0)

		local oldHUDCentered = HUD.Centered
		HUD.Centered = option22.value=="ON"
		gkini.WriteInt("Vendetta", "HUDcentered", HUD.Centered and 1 or 0)

		HUD.showhelpstring = showhelpinhud.value=="ON" and 1 or 0

		local rTargetBoxMode = targetboxmode.value==targetmode_2d and 0 or 1
		Game.SetCVar("rTargetBoxMode", rTargetBoxMode)

		Show3000mNavpoint = show3000mnavpoint.value=="ON"
		gkini.WriteInt("Vendetta", "show3000mnavpoint", Show3000mNavpoint and 1 or 0)

		if oldHUDCentered ~= HUD.Centered then
			HUD:Reload()
		else
			HUD:setup_visible_elements()
		end
	end

	setup = function()
		applybutton.active = "NO"

		showhelpinhud.value = HUD.showhelpstring==1 and "ON" or "OFF"

		local rTargetBoxMode = Game.GetCVar("rTargetBoxMode")
		targetboxmode.value = (rTargetBoxMode==0) and targetmode_2d or targetmode_3d

		show3000mnavpoint.value = Show3000mNavpoint and "ON" or "OFF"

		option1.value = HUD.visibility.radar=="YES" and "ON" or "OFF"
		option2.value = HUD.visibility.crosshair=="YES" and "ON" or "OFF"
		option3.value = HUD.visibility.targetdir=="YES" and "ON" or "OFF"
		option4.value = HUD.visibility.leadoff=="YES" and "ON" or "OFF"
		option5.value = HUD.visibility.chat=="YES" and "ON" or "OFF"

		option6.value = HUD.visibility.distance=="YES" and "ON" or "OFF"
		option7.value = HUD.visibility.speed=="YES" and "ON" or "OFF"
		option8.value = HUD.visibility.energy=="YES" and "ON" or "OFF"
		option9.value = HUD.visibility.damagedir=="YES" and "ON" or "OFF"
		option10.value = HUD.visibility.selfinfo=="YES" and "ON" or "OFF"

		option11.value = HUD.visibility.targetinfo=="YES" and "ON" or "OFF"
		option12.value = HUD.visibility.license=="YES" and "ON" or "OFF"
		option13.value = HUD.visibility.missiontimers=="YES" and "ON" or "OFF"
		option14.value = HUD.visibility.addons=="YES" and "ON" or "OFF"
		option15.value = HUD.visibility.cargo=="YES" and "ON" or "OFF"
		option16.value = HUD.visibility.groupinfo=="YES" and "ON" or "OFF"
		option17.value = HUD.visibility.fa_indicator and "ON" or "OFF"
		option18.value = HUD.visibility.fa_notification and "ON" or "OFF"
		option19.value = HUD.visibility.aa_indicator and "ON" or "OFF"
		option20.value = HUD.visibility.aa_notification and "ON" or "OFF"
		option21.value = HUD.visibility.nfz_indicator and "ON" or "OFF"
		option22.value = HUD.Centered and "ON" or "OFF"
	end

	dlg = iup.dialog{
		container,
		bgcolor="0 0 0 0 *",
		border="NO",menubox="NO",resize="NO",
		size="%60x%60",
		defaultesc=cancelbutton,
	}

	function dlg:show_cb()
		setup()
	end

	dlg:map()

	return dlg
end

local function create_chatcolor_options_dialog()
	local dlg, container
	local colornames, colornames_rev, colornames_sort
	local listbox, sliders, previewtext
	local colorpicker
	local okbutton, applybutton, cancelbutton, resetbutton, defaultbutton
	local apply, setup
	local red_edit
	local grn_edit
	local blu_edit

	local xres = gkinterface.GetXResolution()
	local colorpickersize = (198*xres/800)..'x'..(66*xres/800)
	
	local function setcolor(color)
		local red, green, blue = color:match("^(%d+) (%d+) (%d+)")
		sliders.red.posx = tonumber(red)
		sliders.green.posx = tonumber(green)
		sliders.blue.posx = tonumber(blue)
		previewtext.fgcolor = color
		red_edit.value = red
		grn_edit.value = green
		blu_edit.value = blue
	end
	
	colorpicker = iup.zbox{
		iup.label{title="", image="images/ship_palette.tga", uv="0 0 1 1", size=colorpickersize, filter="POINT"},
		iup.canvas{
			button_cb=function(self, button, state, x, y, modifiers)
				if button == iup.LMBUTTON and state == 1 then
					x = x - tonumber(self.x)
					y = y - tonumber(self.y)
					x = 32*x/tonumber(self.w)
					y = 8*y/tonumber(self.h)
					local paletteindex = (math.floor(y)*32 + math.floor(x))
					setcolor(ShipPalette_string[paletteindex + 1])
					applybutton.active = "YES"
					resetbutton.active = "YES"
				end
			end
		},
		expand="NO",
		ALL="YES",
	}
	
	local function statechangefunc(self)
		applybutton.active = "YES"
		resetbutton.active = "YES"
		local red, green, blue = sliders.red.posx, sliders.green.posx, sliders.blue.posx
		local color = red.." "..green.." "..blue
		local hex_color = string.format("%.2x%.2x%.2x", red, green, blue)
		colornames[colornames_rev[filter_colorcodes(listbox[listbox.value])][1]][3] = hex_color
		setcolor(color)
	end
	
	colornames = { -- [1] is pretty name, [2] is config.ini name
		["CHAT_MSG_BUDDYNOTE"] = {"Buddy Note (Outgoing)", "buddynote"},
		["CHAT_MSG_INCOMINGBUDDYNOTE"] = {"Buddy Note (Incoming)", "incomingbuddynote"},
		["CHAT_MSG_PRIVATEOUTGOING"] = {"Private Message (Outgoing)", "msgoutgoing"},
		["CHAT_MSG_PRIVATE"] = {"Private Message (Incoming)", "msgincoming"},
		["CHAT_MSG_BARLIST"] = {"Bar List", "barlist"},
		["CHAT_MSG_BARENTER"] = {"Bar Enter", "barenter"},
		["CHAT_MSG_BARLEAVE"] = {"Bar Leave", "barleave"},
		["CHAT_MSG_BAR"] = {"Bar", "bar"},
		["CHAT_MSG_BAR1"] = {"Bar (Itani)", "bar1"},
		["CHAT_MSG_BAR2"] = {"Bar (Serco)", "bar2"},
		["CHAT_MSG_BAR3"] = {"Bar (UIT)", "bar3"},
		["CHAT_MSG_SECTOR"] = {"Sector", "sector"},
		["CHAT_MSG_MISSION"] = {"Mission", "mission"},
		["CHAT_MSG_GUILD"] = {"Guild", "guild"},
		["CHAT_MSG_GUIDE"] = {"Guide", "guide"},
		["CHAT_MSG_GROUP"] = {"Group", "group"},
		["CHAT_MSG_SYSTEM"] = {"System", "system"},
		["CHAT_MSG_SECTORD"] = {"Sector (Server)", "sd"},
		["CHAT_MSG_CHANNEL_ACTIVE"] = {"Channel (Active)", "activechannel"},
		["CHAT_MSG_CHANNEL"] = {"Channel (Inactive)", "inactivechannel"},
	}
	
	colornames_rev = {}
	colornames_sort = {expand="VERTICAL", value=1}
	
	for k,v in pairs(colornames) do
		colornames_rev[v[1]] = {k, v[2]}
		table.insert(colornames_sort, v[1])
	end
	
	table.sort(colornames_sort)
	local colornames_sort_rev = {}
	for i,v in ipairs(colornames_sort) do colornames_sort_rev[v] = i end
	
	listbox = iup.stationhighopacitysublist(colornames_sort)
	previewtext = iup.label{title="Sample Text", expand="HORIZONTAL"}
	
	sliders = {
		red = iup.canvas{
			scrollbar="HORIZONTAL", size="200x", border="NO",
			expand="NO",
			xmin = 0, xmax=255, dx=32, posx=1,
			scroll_cb=statechangefunc,
		},
		green = iup.canvas{
			scrollbar="HORIZONTAL", size="200x", border="NO",
			expand="NO",
			xmin = 0, xmax=255, dx=32, posx=2,
			scroll_cb=statechangefunc,
		},
		blue = iup.canvas{
			scrollbar="HORIZONTAL", size="200x", border="NO",
			expand="NO",
			xmin = 0, xmax=255, dx=32, posx=3,
			scroll_cb=statechangefunc,
		},
	}
	
	function listbox:action(s, i, v)
		if v == 1 then
			local chattype = colornames_rev[filter_colorcodes(s)][1]
			local color = colornames[chattype][3] or chatinfo[chattype][1]:gsub("\127", "")
			color = hextorgb(color)
			setcolor(color)
			resetbutton.active = colornames[chattype][3] and "YES" or "NO"
		end
	end
	
	okbutton = iup.stationbutton{title="OK",
		action=function() apply() HideDialog(dlg) ShowDialog(InterfaceOptionsDialog, iup.CENTER, iup.CENTER) end}
	applybutton = iup.stationbutton{title="Apply", active="NO",
		action=function() apply() end}
	cancelbutton = iup.stationbutton{title="Cancel",
		action=function() HideDialog(dlg) ShowDialog(InterfaceOptionsDialog, iup.CENTER, iup.CENTER) end}
	resetbutton = iup.stationbutton{title="Undo", active="NO", size=80,
		action=function(self)
			self.active="NO"
			local chattype = colornames_rev[filter_colorcodes(listbox[listbox.value])]
			local color = chatinfo[chattype[1]][1]:gsub(string.char(127), "")
			color = hextorgb(color)
			setcolor(color)
			colornames[chattype[1]][3] = nil
		end}
		
	local function default_accept()
		HideDialog(QuestionDialog)
		for k,v in pairs(colornames) do
			v[3] = chatinfo[k].default:gsub("\127", "")
		end
		apply()
	end
	defaultbutton = iup.stationbutton{title="Defaults",
		action=function()
			QuestionDialog:SetMessage("Are you sure you want to restore the chat colors to their default settings?",
				"Yes", default_accept,
				"No", function() HideDialog(QuestionDialog) end)
			ShowDialog(QuestionDialog)
		end}

	red_edit = iup.text{
		size = tostring(Font.Default*3),
		action = function(self, ch, after)
				local newnumber = tonumber(self.value)
				if ch == 13 then -- FIXME: this should be KEY_RETURN after we fix IUP/OnChar/OnKey/blah
					if newnumber then
						sliders.red.posx = newnumber
					else
						self.value = sliders.red.posx
					end
					statechangefunc()
					iup.SetFocus(grn_edit)
					return iup.IGNORE
				else
					if (self.value ~= "") and (not newnumber or newnumber > 255) then
						return iup.IGNORE
					end
				end
			end,
		killfocus_cb = function(self)
				local newnumber = tonumber(self.value)
				if newnumber then
					sliders.red.posx = newnumber
				else
					self.value = sliders.red.posx
				end
				statechangefunc()
			end,
		}
	grn_edit = iup.text{
		size = tostring(Font.Default*3),
		action = function(self, ch, after)
				local newnumber = tonumber(self.value)
				if ch == 13 then -- FIXME: this should be KEY_RETURN after we fix IUP/OnChar/OnKey/blah
					if newnumber then
						sliders.green.posx = newnumber
					else
						self.value = sliders.green.posx
					end
					statechangefunc()
					iup.SetFocus(blu_edit)
					return iup.IGNORE
				else
					if (self.value ~= "") and (not newnumber or newnumber > 255) then
						return iup.IGNORE
					end
				end
			end,
		killfocus_cb = function(self)
				local newnumber = tonumber(self.value)
				if newnumber then
					sliders.green.posx = newnumber
				else
					self.value = sliders.green.posx
				end
				statechangefunc()
			end,
		}
	blu_edit = iup.text{
		size = tostring(Font.Default*3),
		action = function(self, ch, after)
				local newnumber = tonumber(self.value)
				if ch == 13 then -- FIXME: this should be KEY_RETURN after we fix IUP/OnChar/OnKey/blah
					if newnumber then
						sliders.blue.posx = newnumber
					else
						self.value = sliders.blue.posx
					end
					statechangefunc()
					return iup.IGNORE
				else
					if (self.value ~= "") and (not newnumber or newnumber > 255) then
						return iup.IGNORE
					end
				end
			end,
		killfocus_cb = function(self)
				local newnumber = tonumber(self.value)
				if newnumber then
					sliders.blue.posx = newnumber
				else
					self.value = sliders.blue.posx
				end
				statechangefunc()
			end,
		}

	container = iup.stationhighopacityframe{
		iup.stationhighopacityframebg{
			iup.vbox{
				iup.hbox{
					iup.vbox{iup.label{title="Chat Type"}, listbox},
					iup.fill{},
					iup.vbox{
						iup.label{title="Chat Color"},
						iup.fill{size=2},
						iup.hbox{
							iup.label{title="Red:", fgcolor="255 0 0"},
							iup.fill{size=7},
							sliders.red,
							red_edit,
						},
						iup.hbox{
							iup.label{title="Green:", fgcolor="0 255 0"},
							iup.fill{size=7},
							sliders.green,
							grn_edit,
						},
						iup.hbox{
							iup.label{title="Blue:", fgcolor="0 0 255"},
							iup.fill{size=7},
							sliders.blue,
							blu_edit,
						},
						iup.fill{size=10},
						iup.hbox{
							iup.stationhighopacitysubframe{previewtext},
							iup.fill{},
							resetbutton,
							gap=5,
						},
						colorpicker,
						alignment="ARIGHT",
						gap=5,
					},
					gap=5,
				},
				iup.fill{},
				iup.hbox{okbutton, applybutton, cancelbutton, iup.fill{}, defaultbutton, gap=15},
				gap=5,
			},
		},
	}

	apply = function()
		applybutton.active = "NO"
		resetbutton.active = "NO"
		for k,v in pairs(colornames) do
			if v[3] then
				chatinfo[k][1] = string.char(127)..v[3]
				gkini.WriteString("colors", "chatcolors."..v[2], v[3])
				v[3] = nil
			end
			local name = chatinfo[k][1]..v[1]
			listbox[colornames_sort_rev[v[1]]] = name
			listbox:action(listbox[listbox.value], listbox.value, 1)
		end
	end

	setup = function()
		if resetbutton.active == "YES" then resetbutton:action() end
		applybutton.active = "NO"
		for k,v in pairs(colornames) do
			if v[3] then v[3] = nil end
			local name = chatinfo[k][1]..v[1]
			listbox[colornames_sort_rev[v[1]]] = name
		end
		
		listbox.value = 1
		listbox:action(listbox[1], 1, 1)
	end
	
	dlg = iup.dialog{
		container,
		bgcolor="0 0 0 0 *",
		border="NO",menubox="NO",resize="NO",
		size="x%55",
		defaultesc=cancelbutton,
	}

	function dlg:show_cb()
		setup()
	end
	
	dlg:map()

	return dlg
end




HUDInterfaceOptionsDialog = create_hudinterface_options_dialog()
ChatColorOptionsDialog = create_chatcolor_options_dialog()
InterfaceOptionsDialog = create_interface_options_dialog()
