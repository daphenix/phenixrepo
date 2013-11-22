InterfaceManager = InterfaceManager or {}

IF_DIR = "if/"
IMAGE_DIR = gkini.ReadString("Vendetta", "skin", "images/station/")
UseFontScaling = gkini.ReadInt("Vendetta", "usefontscaling", 0) == 1
FontScale = gkini.ReadInt("Vendetta", "fontscale", 100) / 100
ShowTooltips = gkini.ReadInt("Vendetta", "showtooltips", 1) == 1
ShowLowGridPowerDialog = gkini.ReadInt("Vendetta", "showlowpowerdialog", 1) == 1
ColorChatInput = gkini.ReadInt("Vendetta", "colorchatinput", 0) == 1
ColorName = gkini.ReadInt("Vendetta", "colorname", 1) == 1
SortItems = gkini.ReadInt("Vendetta", "sort_by", 4)
SI_unit = gkini.ReadInt("Vendetta", "si_unit", 3)
ShowBarUpdateNotification = gkini.ReadInt("Vendetta", "showbarupdatenotification", 1) == 1
ShowGroupKillNotification = gkini.ReadInt("Vendetta", "showgroupkillnotification", 1) == 1
Show3000mNavpoint = gkini.ReadInt("Vendetta", "show3000mnavpoint", 1) == 1
ShowLogoffDialog = gkini.ReadInt("Vendetta", "showlogoffconfirmation", 1) == 1
ShowSetHomeDialog = gkini.ReadInt("Vendetta", "showsethomeconfirmation", 1) == 1
ShowSellAllDialog = gkini.ReadInt("Vendetta", "showsellallconfirmation", 1) == 1
FlashIntensity = gkini.ReadInt("Vendetta", "flashintensity", 100)/100
SensorSort = gkini.ReadInt("Vendetta", "sensorsort", 4)
if Platform == 'Android' then
	gkinterface.EnableTouchMode(gkini.ReadInt("Vendetta", "enableTouchMode", 1) == 1)
end
local framelimit = gkini.ReadInt("Vendetta", "maxframerate", (Platform == 'Android') and 40 or 120)
Game.SetMaxFramerate(framelimit)

DEFAULT_LICENSE_WATCH = 2
ignore_time = {} -- global table of ignored users and the duration to ignore them.

tabseltextcolor = "1 241 255"
tabunseltextcolor = "0 185 199"

ListColors = { -- matrix and listbox alternating colors
	Alpha=gkini.ReadInt("listcolors", "alpha", 255),
	SelectedAlpha=gkini.ReadInt("listcolors", "selectedalpha", 255),
	[0]=gkini.ReadString("listcolors", "even", "30 55 78"),
	[1]=gkini.ReadString("listcolors", "odd", "42 74 96"),
	[2]=gkini.ReadString("listcolors", "selected", "55 90 110"),
	Numbers = {[0]={}, {}, {}},
}
for i=0,2 do
	for number in ListColors[i]:gmatch("%d+") do table.insert(ListColors.Numbers[i], tonumber(number)) end
	ListColors.Numbers[i][4] = i == 2 and ListColors.SelectedAlpha or ListColors.Alpha
end


local FadeControls = {}

function FadeLookup(control)
	return FadeControls[control] -- local i=1 while FadeControls[i] do if FadeControls[i].control == control then return FadeControls[i] end i=i+1 end
end

local __iup_sa = iup.StoreAttribute  -- just to speed up the call a little because it's called often.
local mathfloor = math.floor

function FadeControl(control, timetofade, startalpha, endalpha, endfunc, ...)
	local _fadeinfo = FadeControls[control] -- FadeLookup(control)
	local fadeinfo = _fadeinfo or {}
	fadeinfo.timetofade = timetofade
	fadeinfo.startalpha = startalpha
	fadeinfo.endalpha = endalpha
	fadeinfo.endfunc = endfunc
	fadeinfo.endfuncargs = {...}
	fadeinfo.counter = 0
	fadeinfo.control = control

	__iup_sa(control, "ALPHA", math.floor(startalpha*255))
--	control.alpha = math.floor(startalpha*255)
	if not _fadeinfo then
		FadeControls[control] = fadeinfo -- table.insert(FadeControls, fadeinfo)
	end
end

function FadeStop(control)
	FadeControls[control] = nil -- local i=1 while FadeControls[i] do if FadeControls[i].control == control then table.remove(FadeControls, i) return end i=i+1 end
end

function UpdateFade(delta)
	local fadeinfo, alpha, control
--	local i = 1
--	while FadeControls[i] do
	for control, fadeinfo in pairs(FadeControls) do
--		fadeinfo = FadeControls[i]
--		control = fadeinfo.control
		if not fadeinfo.counter then fadeinfo.counter = 0 end
		fadeinfo.counter = fadeinfo.counter + delta

		if fadeinfo.counter < fadeinfo.timetofade then
			alpha = fadeinfo.startalpha + (fadeinfo.endalpha-fadeinfo.startalpha)*(fadeinfo.counter/fadeinfo.timetofade)
			control.alpha = math.floor(alpha*255)
		else
			control.alpha = math.floor(fadeinfo.endalpha*255)
			FadeControls[control] = nil -- table.remove(FadeControls, i) i = i - 1
			if fadeinfo.endfunc then
				fadeinfo.endfunc(unpack(fadeinfo.endfuncargs))
			end
		end
--		i=i+1
	end
end


FactionColor_RGB = {
	[0] = "212 212 212", -- Unaligned
	"96 128 255", -- itani
	"255 32 32", -- serco
	"192 192 0", -- uit
	"255 255 255", -- tpg
	"255 255 255", -- biocom
	"255 255 255", -- valent
	"255 255 255", -- orion
	"255 255 255", -- axia
	"128 128 128", -- kraz (corvus)
	"255 255 255", -- Tunguska
	"255 255 255", -- Aeolus
	"255 255 255", -- Ineubis
	"255 255 255", -- Xang Xi
}


dofile(IF_DIR.."if_fontsize.lua")
dofile(IF_DIR.."if_templates.lua")
dofile(IF_DIR.."if_tags.lua")
dofile(IF_DIR.."if_virtualkeyboard.lua")
dofile(IF_DIR.."if_portconfig_template.lua")
dofile(IF_DIR.."if_chatareatemplate.lua")
dofile(IF_DIR.."if_navmaptemplate.lua")
dofile(IF_DIR.."if_tooltip.lua")
dofile(IF_DIR.."if_accom_template.lua")
dofile(IF_DIR.."if_faction_template.lua")
dofile(IF_DIR.."if_chatlog.lua")
dofile(IF_DIR.."if_charselect.lua")
dofile(IF_DIR.."if_charcreate.lua")
dofile(IF_DIR.."if_connecting.lua")
dofile(IF_DIR.."if_hud.lua")
dofile(IF_DIR.."if_info.lua")
dofile(IF_DIR.."if_login.lua")
dofile(IF_DIR.."if_options.lua")
dofile(IF_DIR.."if_stationhelp.lua")
dofile(IF_DIR.."if_buybackmenu.lua")
dofile(IF_DIR.."if_jettison.lua")
dofile(IF_DIR.."if_objectinfo.lua")
dofile(IF_DIR.."if_news.lua")
dofile(IF_DIR.."if_mission.lua")
dofile(IF_DIR.."if_3dview.lua")
dofile(IF_DIR.."if_help.lua")
dofile(IF_DIR.."if_accominfo.lua")
dofile(IF_DIR.."if_target_info.lua")
dofile(IF_DIR.."if_newstation_tabs.lua")  -- linked to from if_newstation.lua
dofile(IF_DIR.."if_pda.lua") -- main PDA Tabs
dofile(IF_DIR.."if_newstation.lua") -- station specific tabs, commerce/ship
dofile(IF_DIR.."if_capship.lua")
dofile(IF_DIR.."if_capshipshipless.lua")
dofile(IF_DIR.."if_mandatory.lua") -- tutorials
dofile(IF_DIR.."if_voicechatoptions.lua")
dofile(IF_DIR.."if_storagerental.lua")
dofile(IF_DIR.."if_sellitemdlg.lua")
dofile(IF_DIR.."if_ownerkeydlg.lua")
dofile(IF_DIR.."if_newspostdlg.lua")
dofile(IF_DIR.."if_demomanager.lua")
--dofile(IF_DIR.."if_radiksbrowser.lua")

local LoginDialog = CreateLoginDialog()
local FirstTimeDialog
if Platform == "Android" then
	FirstTimeDialog = CreateFirstTimeAndroidModeDialog(LoginDialog)
else
	FirstTimeDialog = CreateFirstTimeNewAccountDialog(LoginDialog)
end
CreditsDialog = CreateCreditsDialog(LoginDialog)
LoginHelpDialog = CreateLoginHelpDialog(LoginDialog)
CharSelectDialog = CreateCharSelectMenu(LoginDialog)

local opendialogs = {}

function HideDialog(dlg)
	if dlg == HUD then dlg = HUD.dlg end
	for k,_ in pairs(opendialogs) do
		if k == dlg then -- this is because the direct reference may not be the same but the ihandles would be.
						-- possibly due to using what iup.GetDialog() returns, for example.
			dlg:hide()
			opendialogs[k] = nil
			return
		end
	end
end

function ShowDialog(dlg, x, y)
	if dlg == HUD then dlg = HUD.dlg end
	opendialogs[dlg] = debug.traceback("Showing dialog")
	if x then
		dlg:showxy(x, y)
	else
		dlg:show()
	end
end

function PopupDialog(dlg, x, y)
	if dlg == HUD then dlg = HUD.dlg end
	opendialogs[dlg] = debug.traceback("Popping up dialog")
	dlg:popup(x, y)
	opendialogs[dlg] = nil
end

function HideAllDialogs()
	for dlg,_ in pairs(opendialogs) do
		if dlg ~= HUD.dlg then
			if not dlg.hide then
				debug.logerror(dlg)
			end
			dlg:hide()
			opendialogs[dlg] = nil
		end
	end
end

function InterfaceManager:Startup()
	local startDialog

	Game.EnableInput()

	local firsttime = gkini.ReadInt("Vendetta", "firsttime", 1) == 1  -- this is set when the login dialog is shown.
	-- show the 'first time' dialog.
	-- this will ask if they have an account.
	-- if they don't, then it will open a web browser to the new account page.
	if (Subplatform == 'Atom') then
		if firsttime then
			startDialog = FirstTimeDialog
		else
			startDialog = LoginDialog
		end
	elseif (Platform == "Android") then
		if firsttime then
			startDialog = FirstTimeDialog
		else
			startDialog = LoginDialog
		end
	else
		startDialog = LoginDialog
	end
	ShowDialog(startDialog)
	
	-- start menu music on non-androids because android version starts it when the game starts up.
	if Platform ~= 'Android' then
		gksound.GKPlayMusic("music/menu.ogg", true)
	end
	
	-- set up mouse skins
	gkinterface.SetMouseCursorIndexImage(0, IMAGE_DIR.."int_mouse_pointer.png", 0, 0)
	gkinterface.SetMouseCursorIndexImage(1, IMAGE_DIR.."int_mouse_pointer_no.png", 0.25, 0.25)
	gkinterface.SetMouseCursorIndexImage(2, IMAGE_DIR.."int_mouse_pointer_copy.png", 0, 0)
	gkinterface.SetMouseCursorIndexImage(3, IMAGE_DIR.."int_mouse_pointer.png", 0, 0)
	gkinterface.SetMouseCursorIndexImage(4, IMAGE_DIR.."int_mouse_pointer.png", 0, 0)
	
	-- set up radar navpoints skins
	radar.SetHUDIcon(0, IMAGE_DIR.."hud_wormhole_reticle.png")
	radar.SetHUDIcon(1, IMAGE_DIR.."hud_storm_reticle.png")
	radar.SetHUDIcon(2, IMAGE_DIR.."hud_waypoint_reticle.png")
end

function InterfaceManager:OnEvent(eventname, ...)
	if eventname == "START" then
		self:Startup()
	elseif eventname == "QUIT" then
		HUD:Destroy()
	elseif eventname == "PLAYER_ENTERED_GAME" then
		LoadChannels()
		HUD.showhelpstring = gkini.ReadInt("Vendetta", "showhelpstring", 1)
		HUD:SetLicenseWatch(gkini.ReadInt(GetUserName(), "watchedlicense", DEFAULT_LICENSE_WATCH))
		LoadShipPresets()
		NavRoute.SetFullRoute(LoadNavpath(nil))  -- load navpath from ini file


		-- s = string from LoadSystemNotes, system = ID number
		local function unspickle2(s, system) 
			if not s then return nil end 
			local f = loadstring("return {"..s.."}") 
			if not f then 
				-- conditions that triggers this, corrupt data, faulty data handling via plugin, user messing with functions, etc.
				-- if we have errors of any form dump it into the error= table 
				-- and write it to the file
				-- save errors so data is not lost, user can edit the file to retrieve it				
				SaveSystemNotes(spickle({error=s}) ,system)
				purchaseprint("Errors encountered in System Notes for "..SystemNames[system])
				return {error=s}
			end 
			local success, retval = pcall(f)
			return success and retval or nil
		end
		
		-- read values for SystemNotes table
		for x = 1,#SystemNames do
			SystemNotes[x] = unspickle2(LoadSystemNotes(x),x) or {}
			SystemNotes[x].name = SystemNotes[x].name or ''
		end
		-- end read values for SystemNote table

	elseif eventname == "PLAYER_LOGGED_OUT" then
		local arg1 = ...
		if lcd then lcd.ShowLogo() end
		if GetPlayerName() then
			SaveNavpath(NavRoute.GetCurrentRoute(), nil)
		end
		HideAllDialogs()
		HUD.IsVisible = false
		HideDialog(HUD.dlg)
		LoginDialog.close_cinematic()
		if arg1 then
			ConnectingDialog:SetMessage(arg1, "OK", function() HideDialog(ConnectingDialog) ShowDialog(LoginDialog) end)
			ShowDialog(ConnectingDialog, iup.CENTER, iup.CENTER)
		else
			ShowDialog(LoginDialog)
		end
	elseif eventname == "CINEMATIC_START" then
		HideAllDialogs()
	elseif eventname == "PLAYER_STATS_UPDATED" or eventname == "PLAYER_UPDATE_SKILLS" then
		if lcd then
			for i=1,5 do
				local cur, max = GetSkillLevel(i)
				local curlicense = GetLicenseLevel(i)
				local min = GetLicenseRequirement(curlicense)
				lcd.SetLevel(i-1, curlicense, 0, math.max(max-min, 0), math.max(cur-min, 0))
			end
		end
	elseif eventname == "NAVROUTE_SAVE" then
		local arg1 = ...
		SaveNavpath(NavRoute.GetCurrentRoute(), ...)
	elseif (eventname == "NAVROUTE_ADD") or (eventname == "NAVROUTE_CHANGED") or (eventname == "NAVROUTE_UNDOLAST") then
		local nexthop = NavRoute.GetNextHop()
		Game.SetJumpDest(nexthop)
		HUD:SetFlightPath(nexthop)
	elseif eventname == "SECTOR_CHANGED" then
		local arg1 = ...
		if NavRoute.GetCurrentRoute() then SaveNavpath(NavRoute.GetCurrentRoute(), nil) end
		sectorprint("You are entering "..ShortLocationStr(arg1))
		local nexthop = NavRoute.GetNextHop()
		Game.SetJumpDest(nexthop)
		HUD:SetFlightPath(nexthop)
	elseif eventname == "SHIP_UPDATED" then
		local gridpower, gridusage = GetActiveShipGridPowerAndUsage()
		if (gridpower > 0) and (gridpower < gridusage) then
			if ShowLowGridPowerDialog then
				ShowDialog(LowGridPowerDialog, iup.CENTER, iup.CENTER)
			end
		end
	elseif eventname == "PLAYER_RECEIVED_NEW_ACCOMPLISHMENTS" then
		local arg1, arg2 = ...
		local gotnewaccomplishment = nil
		for accomtype,accomlevel in pairs(arg2) do
			gotnewaccomplishment = gotnewaccomplishment or {}
			local accomname = GetAccomplishmentName(accomtype,accomlevel) or "a medal"
			table.insert(gotnewaccomplishment, tostring(accomname))
		end

		if gotnewaccomplishment and gotnewaccomplishment[1] then
			local msg = "You have earned "..table.concat(gotnewaccomplishment, ", ")..'!  See "Accomplishments" under "Character" in your PDA.'
			ProcessEvent("CHAT_MSG_PRINT", {msg=msg})
			ProcessEvent("CHAT_MSG_SECTORD_MISSION", {msg=msg, missionid=0})
		end
	elseif (eventname == "GROUP_MEMBER_DIED") or (eventname == "GROUP_MEMBER_KILLED") then
		if ShowGroupKillNotification == true then
			local victimcharid, killercharid, sectorid, weaponname, damagetype = ...
			local deathmsg = GeneratePlayerDiedMessage(GetPlayerName(victimcharid), GetPlayerName(killercharid), damagetype)
			if deathmsg then ProcessEvent("CHAT_MSG_GROUP_NOTIFICATION", {msg=deathmsg, location=sectorid}) end
		end
	elseif eventname == "GROUP_SELF_INVITED" then
		local args = {...}
		InterfaceManager.mostrecentinvite = args[1] or 'n/a'
	elseif eventname == "FORGIVENESS_DIALOG" then
		local killercharid = ...
		if killercharid > 0 then
			AskForgivenessDialog:SetMessage("\nYou were killed by "..GetPlayerName(killercharid).."\n\n  "..GetPlayerName(killercharid).." will get a reputation penalty  \nfor killing you, unless you Forgive them.\n\nForgive kill?\n", "Yes", nil, "No", nil)
			ShowDialog(AskForgivenessDialog, iup.CENTER, iup.CENTER)
		else
			HideDialog(AskForgivenessDialog)
		end
	elseif eventname == "ASSIGNOWNERKEY_DIALOG" then
		AssignOwnerKeyDialog.keytransactionid = ...
		ShowDialog(AssignOwnerKeyDialog, iup.CENTER, iup.CENTER)
	elseif eventname == "KEYINFO_DIALOG" then
		KeyInfoDialog.keyindex = ...
		ShowDialog(KeyInfoDialog, iup.CENTER, iup.CENTER)
	end
end

RegisterEvent(InterfaceManager, "CINEMATIC_START")
RegisterEvent(InterfaceManager, "START")
RegisterEvent(InterfaceManager, "TERMINATE")
RegisterEvent(InterfaceManager, "PLAYER_ENTERED_GAME")
RegisterEvent(InterfaceManager, "PLAYER_LOGGED_OUT")
RegisterEvent(InterfaceManager, "PLAYER_STATS_UPDATED")
RegisterEvent(InterfaceManager, "PLAYER_UPDATE_SKILLS")
RegisterEvent(InterfaceManager, "NAVROUTE_SAVE")
RegisterEvent(InterfaceManager, "NAVROUTE_ADD")
RegisterEvent(InterfaceManager, "NAVROUTE_CHANGED")
RegisterEvent(InterfaceManager, "NAVROUTE_UNDOLAST")
RegisterEvent(InterfaceManager, "SECTOR_CHANGED")
RegisterEvent(InterfaceManager, "PLAYER_RECEIVED_NEW_ACCOMPLISHMENTS")
RegisterEvent(InterfaceManager, "GROUP_MEMBER_DIED")
RegisterEvent(InterfaceManager, "GROUP_MEMBER_KILLED")
RegisterEvent(InterfaceManager, "SHIP_UPDATED")
RegisterEvent(InterfaceManager, "GROUP_SELF_INVITED")
RegisterEvent(InterfaceManager, "FORGIVENESS_DIALOG")
RegisterEvent(InterfaceManager, "ASSIGNOWNERKEY_DIALOG")
RegisterEvent(InterfaceManager, "KEYINFO_DIALOG")




function GetFriendlyStatus(charid)
	if charid == GetCharacterID() then return 3 end  -- you are friendly to yourself
	if IsEnemy(charid) then return 0 end
	local theirfaction = GetPlayerFaction(charid) or 0
	local myfaction = GetPlayerFaction() or 0
	if (theirfaction == 0) or (myfaction == 0) then return 0 end

	local val = 0
	if (GetPlayerFactionStanding(myfaction, charid) or FactionStanding.Neutral) > FactionStanding.Hate then val = val + 1 end
	if (GetPlayerFactionStanding(theirfaction) or FactionStanding.Neutral) > FactionStanding.Hate then val = val + 1 end
	if (GetPlayerFactionStanding("sector", charid) or FactionStanding.Neutral) > FactionStanding.Hate then val = val + 1 end
	return val
end



function OnIdle(delta)
	UpdateFade(delta)
end


-- function comma_value()
-- args = number to format.
-- return a comma value for numers
-- handles - . and any unit.
-- SI_unit = 1  then comma_value("-100000.54 kg") returns "-100000.54 kg"
-- SI_unit = 2 then comma_value("-100000.54 kg") returns "-100 000,54 kg"
-- SI_unit = 3 then  comma_value("-100000.54 kg") returns "-100,000.54 kg"
-- failure with improper formats returns the passed value unchanged.
function comma_value(amount)

  -- hanlde nil 
  if not amount then return amount end

  local substrings = {}
  local SI_UNIT = {}
  local result
  
  local neg = false
  local rest = false
  local value = false
  local decimal = false
  local units = false

  -- table for the unit values.
  SI_unit = tonumber(SI_unit)
  if SI_unit == 1 then 
    return amount
  elseif SI_unit == 2 then  -- metric format, space and ,
    SI_UNIT = {' ',','} 
  elseif SI_unit == 3 then  -- imperial format, comma and .
    SI_UNIT = {',','.'}
  else  -- error condition.
    return amount 
  end

  neg,rest,value,decimal,units = string.match(amount,'(.-)(%d+)(%.*)(%d*)(%D*)')

  if not tonumber(rest) then -- error condition, rather than yield errors return the passed value
    return amount 
  end
  
  --strip 3 units at a time into a table
  while #rest > 2 do
    local restlen = #rest
    table.insert(substrings, 1, string.sub(rest, restlen-2))
    rest = string.sub(rest, 1, restlen-3)
  end
    
  -- sprinkle with either ' ' or ',' depending on SI_unit
  if #rest > 0 then table.insert(substrings, 1, rest) end
  for i,v in ipairs(substrings) do
    result = result and (result..SI_UNIT[1]..v) or v
  end

  -- format the new number, add si_values and units if any
  if value == '.' then result = result..SI_UNIT[2]..decimal end
  if neg == '-' then result = '-'..result end
  if units then result = result..units end

  -- return the human readable number with extras
  return result
end -- end comma_value()
