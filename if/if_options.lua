dofile(IF_DIR.."if_options_interface.lua")

local scrollbar_width = Font.Default

local inputoptionsdlg
local cursubdlg

function getwidth(button)
--	local _,_,width, height = string.find(button.size, "^(.*)x(.*)$")

--	local s = button.size
	return tonumber(button.w)
end

function getheight(button)
--	local _,_,width, height = string.find(button.size, "^(.*)x(.*)$")

--	local s = button.size
	return tonumber(button.h)
end

local function populateoptions(options)
	local list = {}
	local vbox = iup.vbox{gap="2"}
	if options then
		for k,v in ipairs(options) do

			local theControl
						
			if v[1] then
				v.dropdown="YES"
				v.size="200x"
				v.visible_items=16
				theControl = iup.stationsubsublist(v)
			else
				v.size="200x"
--				v.expand='HORIZONTAL'
				v.nc=4
				theControl = iup.text(v)
			end

			if v.name == "Renormalize Normalmaps At Loadtime" then
				function theControl:action(text, index, selection)
					if (index == 2) and (selection == 1) then
						-- Warning: This setting may dramatically increase sector load times.
						-- Turing on 'Preload All Resources on Startup' in Graphics Options will lower sector load times.
						-- Are you sure you want to do this?
						-- [Yes] [No]
						QuestionDialog:SetMessage("Warning: This setting may dramatically\nincrease sector load times.\n\n(Note: Turing on 'Preload All Resources on Startup'\nin Graphics Options will lower sector load times\nbut increase startup time.)\n\nAre you sure you want to do this?\n",
							"Yes", function() HideDialog(QuestionDialog) end,
							"No", function() theControl.value = 1 HideDialog(QuestionDialog) end)
						ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
					end
				end
			end
			table.insert(list, theControl)
			vbox:append(iup.hbox{iup.label{title=v.name, alignment="ARIGHT", expand="HORIZONTAL"},iup.fill{},theControl,alignment="ACENTER", gap=2})
		end
	end
	return vbox, list
end

local function setoptions(options, list)
	for k,v in ipairs(options) do
		list[k].value = v.value
	end
end

local function applyoptions(list, apply_cb, initial_data)
	local data = initial_data or {}
	for k,v in ipairs(list) do
		table.insert(data, tonumber(v.value))
	end
	apply_cb(data)
end


local function changevideodriver(getname, setname, driverlabel, dialogtitle)
	local dlg
	local blah = {gkinterface[getname]()}
	local cur = blah[(#blah)]
	table.remove(blah)
	blah.dropdown = "YES"
	blah.value = cur
	local list = iup.stationsubsublist(blah)
	local ok_pressed = false
	local okbutton = iup.stationbutton{title="OK",
		action=function()
			gkinterface[setname](blah[tonumber(list.value)])
			HideDialog(dlg)
			dlg:destroy()
			HideDialog(cursubdlg)
			cursubdlg = nil
			ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER)
		end}
	local cancelbutton = iup.stationbutton{title="Cancel", action=function()
		HideDialog(dlg)
		dlg:destroy()
		ShowDialog(cursubdlg, iup.CENTER, iup.CENTER)
	end}

	dlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					iup.label{title=dialogtitle, font=Font.H3},
					iup.fill{size=1},
					iup.hbox{
						iup.label{title=driverlabel},
						list,
						gap=5,
						alignment="ACENTER",
					},
					iup.hbox{
						iup.fill{},
						okbutton,
						cancelbutton,
						gap=5,
					},
					gap=5,
					alignment="ACENTER",
				},
			},
		},
		defaultesc = cancelbutton,
		border="NO", resize="NO", menubox="NO", bgcolor="0 0 0 0 +",
	}
	function dlg:hide_cb()
		ShowDialog(cursubdlg, iup.CENTER, iup.CENTER)
	end
	function dlg:close_cb()
		self:destroy()
		ShowDialog(cursubdlg, iup.CENTER, iup.CENTER)
	end

	ShowDialog(dlg, iup.CENTER, iup.CENTER)

	return dlg
end

local function displayoptions(title, options_func, apply_cb, isvideo, isaudio)
	local retval, dlg, driverdlg
	local vbox, list = populateoptions(options_func())
	local reset_fov_hud_toggle
	if isvideo then
		-- do 'custom' autochange
		local f = function(self, text, index, state)
			if self.oldaction then self:oldaction(text, index, state) end
			list[1].value = 1
		end
		for k,v in ipairs(list) do
			v.oldaction = v.action
			v.action = f
		end
		list[1].action = nil
	end
	local okbutton = iup.stationbutton{title="OK", action=function()
		local reset_fov_hud
		if reset_fov_hud_toggle then
			reset_fov_hud = reset_fov_hud_toggle.value=="ON"
			gkini.WriteInt("Vendetta", "reset_fov_hud", reset_fov_hud and 1 or 0)
		end
		applyoptions(list, apply_cb, {reset_fov_hud=reset_fov_hud})
		HideDialog(dlg)
		dlg:destroy()
		cursubdlg = nil
		ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER)
	end}
	local applybutton = iup.stationbutton{title="Apply", action=function()
		applyoptions(list, apply_cb)
		local options = options_func()
		setoptions(options, list)
	end}
	local cancelbutton = iup.stationbutton{title="Cancel", action=function()
		HideDialog(dlg)
		dlg:destroy()
		cursubdlg = nil
		ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER)
	end}
	local changebutton
	if isvideo or isaudio then
		changebutton = iup.stationbutton{title="Change driver...",
			action=function()
				local okpressed
				HideDialog(dlg)
				if isaudio then
					driverdlg = changevideodriver("GetAudioDrivers", "SetAudioDriver", "Audio Driver", "Change Audio Driver")
				else
					driverdlg = changevideodriver("GetVideoDrivers", "SetVideoDriver", "Video Driver", "Change Video Driver")
				end
			end
			}
		vbox:append(changebutton)
	end
	if isvideo then
		local flag = gkini.ReadInt("Vendetta", "reset_fov_hud", 1) == 1 and "ON" or "OFF"
		reset_fov_hud_toggle = iup.stationtoggle{title="Reset FOV and HUD Size on Resolution Change",
			value=flag
			}
		vbox:append(reset_fov_hud_toggle)
	end
	vbox:append(iup.fill{})
	vbox:append(iup.hbox{iup.fill{},okbutton,applybutton,cancelbutton})
	dlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					iup.label{title=title, font=Font.H3},
					vbox,
					gap=10, alignment="ACENTER",
				},
			},
		},
		border="NO", resize="NO", menubox="NO", bgcolor="0 0 0 0 +",
		defaultesc=cancelbutton,
		close_cb = cancelbutton.action
	}
	function dlg:hide_cb()
		if driverdlg then
			HideDialog(driverdlg)
			driverdlg = nil
		end
	end
	function dlg:show_cb()
		driverdlg = nil
	end
	ShowDialog(dlg)
	return dlg
end

command_pretty_names = {
	["+TurnLeft"] = 	"Turn Left",
	["+TurnRight"] = 	"Turn Right",
	["+TurnUp"] = 		"Turn Up",
	["+TurnDown"] = 	"Turn Down",
	["+StrafeLeft"] = 	"Strafe Left",
	["+StrafeRight"] = "Strafe Right",
	["+StrafeUp"] = 	"Strafe Up",
	["+StrafeDown"] = 	"Strafe Down",
	["+RotateCW"] = 	"Rotate CW",
	["+RotateCCW"] = 	"Rotate CCW",
	["+Accelerate"] = 	"Accelerate",
	["+Decelerate"] = 	"Decelerate",
	["+Turbo"] = 		"Turbo",
	["+Brakes"] = 		"Brakes",
	["+Shoot2"] = 		"Fire Primary Weapons",
	["+Shoot1"] = 		"Fire Secondary Weapons",
	["+Shoot3"] = 		"Fire Tertiary Weapons",
	["Weapon1"] = 		"Select Group 1 weapons",
	["Weapon2"] = 		"Select Group 2 weapons",
	["Missile1"] = 	"Select Group 3 weapons",
	["Missile2"] = 	"Select Group 4 weapons",
	["Missile3"] = 	"Select Group 5 weapons",
	["Mine1"] = 		"Select Group 6 weapons",
	--["Mine2"] = 		"Select Group 7 weapons",	--This doesn't seem to exist.
	["RadarNext"] = 	"Select Next",
	["RadarPrev"] = 	"Select Previous",
	["RadarNextFront"] = "Select Next In Front",
	["RadarPrevFront"] = "Select Previous In Front",
	["RadarNextFrontEnemy"] = "Select Enemy in Front",
	["RadarPrevFrontEnemy"] = "Select Prev Enemy in Front",
	["RadarNextNearestPowerup"] = "Select Next Cargo",
	["RadarPrevNearestPowerup"] = "Select Previous Cargo",
	["RadarNextNearestEnemy"] = "Select Nearest Enemy",
	["RadarHitBy"] = 	"Select Last Hostile",
	["RadarNone"] = 	"Unselect Target",
	["+TopList"] = 	"Show Sector List",
	["ConsoleToggle"] = "Toggle Console",
	["ViewToggle"] = 	"Toggle View",
	["CameraToggle"] = "Toggle Camera",
	["HudToggle"] = 	"Toggle HUD",
	["allhudtoggle"] = "Toggle HUD and Chat",
	["HudMode"] = 	"Toggle HUD Group Mode",
	["Activate"] = 	"Activate",
	["FlyModeToggle"] = "Toggle Flight-Assist",
	["MLookToggle"] = "Toggle Mouse-Look",
	["Jettison"] = "Jettison Cargo",
	["ToggleInventory"] = "Toggle Inventory Display",
	["missionchat"] = "Mission Log",
	["Say_Channel"] = "Chat To Active Channel",
	["Say_Group"] = "Chat To Group Members",
	["Say_Guild"] = "Chat To Guild Members",
	["Say_Sector"] = "Chat To Sector",
	["Say_Help"] = "Chat To Help Channel",
	["scrollback"] = "Scroll Chat Back",
	["scrollforward"] = "Scroll Chat Forward",
	["ToggleHostiles"] = "Toggle Radar Hostiles",
	["ToggleFriendlies"] = "Toggle Radar Friendlies",
	["ToggleWormholes"] = "Toggle Radar Wormholes",
	["ToggleObjects"] = "Toggle Radar Objects",
	["ToggleStations"] = "Toggle Radar Stations",
	["ToggleCargo"] = "Toggle Radar Cargo",
	["ToggleMissiles"] = "Toggle Radar Missiles",
	["ShowAll"] = "Show Radar All",
	["explode"] = "Self Destruct",
	["Dump"] = "Screen Dump",
	["nav"] = "Show Navigation Menu",
	["charinfo"] = "Show Character Information",
	["toggleautoaim"] = "Toggle Auto-Aim",
	["hudscale"] = "Scale HUD",
	["hail"] = "Hail Targeted Ship",
	["+ptt"] = "Voice Chat Push To Talk",
}

local commandlist = {
	{"+TurnLeft"},
	{"+TurnRight"},
	{"+TurnUp"},
	{"+TurnDown"},
	{"+StrafeLeft"},
	{"+StrafeRight"},
	{"+StrafeUp"},
	{"+StrafeDown"},
	{"+RotateCW"},
	{"+RotateCCW"},
	{"+Accelerate"},
	{"+Decelerate"},
	{"+Turbo"},
	{"+Brakes"},
	{"+Shoot2"},
	{"+Shoot1"},
	{"+Shoot3"},
	{"Weapon1"},
	{"Weapon2"},
	{"Missile1"},
	{"Missile2"},
	{"Missile3"},
	{"Mine1"},
	--{"Mine2"},	--Again, appears to be no such thing.
	{"RadarNext"},
	{"RadarPrev"},
	{"RadarNextFront"},
	{"RadarPrevFront"},
	{"RadarNextFrontEnemy"},
	{"RadarPrevFrontEnemy"},
	{"RadarNextNearestPowerup"},
	{"RadarPrevNearestPowerup"},
	{"RadarNextNearestEnemy"},
	{"RadarHitBy"},
	{"RadarNone"},
	{"+TopList"},
	{"ConsoleToggle"},
	{"ViewToggle"},
	{"CameraToggle"},
	{"HudToggle"},
	{"allhudtoggle"},
	{"HudMode"},
	{"Activate"},
	{"FlyModeToggle"},
	{"MLookToggle"},
	{"Jettison"},
	{"ToggleInventory"},
	{"missionchat"},
	{"Say_Channel"},
	{"Say_Group"},
	{"Say_Guild"},
	{"Say_Sector"},
	{"Say_Help"},
	{"scrollback"},
	{"scrollforward"},
	{"ToggleHostiles"},
	{"ToggleFriendlies"},
	{"ToggleWormholes"},
	{"ToggleObjects"},
	{"ToggleStations"},
	{"ToggleCargo"},
	{"ToggleMissiles"},
	{"ShowAll"},
	{"explode"},
	{"Dump"},
	{"nav"},
	{"charinfo"},
	{"toggleautoaim"},
	{"hudscale"},
	{"hail"},
	{"+ptt"},
}
local commandlist_reverse = {}
for k,v in ipairs(commandlist) do
	commandlist_reverse[v[1]] = k
end

local joystick_cmds = {
	-- cmd name = visual name
	["NONE"] = "none",
	["Turn"] = "Turn",
	["Pitch"] = "Pitch",
	["Roll"] = "Roll",
	["Throttle"] = "Throttle",
	["Accel"] = "Accelerate",
	["StrafeLR"] = "Strafe Left/Right",
	["StrafeUD"] = "Strafe Up/Down",
}
local joycmdlist2 = {
	-- cmd name = index
	["NONE"] = 1,
	["Turn"] = 2,
	["Pitch"] = 3,
	["Roll"] = 4,
	["Throttle"] = 5,
	["Accel"] = 6,
	["StrafeLR"] = 7,
	["StrafeUD"] = 8,
}
local joycmdlist3 = {
	-- index = cmd name
	"NONE",
	"Turn",
	"Pitch",
	"Roll",
	"Throttle",
	"Accel",
	"StrafeLR",
	"StrafeUD",
}
local joycmdlist = {
	"none",
	"Turn",
	"Pitch",
	"Roll",
	"Throttle",
	"Accelerate",
	"Strafe Left/Right",
	"Strafe Up/Down",
	
	dropdown="YES",
	expand="NO",
}

local joystickchanges = {}

local function joystickcalibratetemplate()
	local dlg
	local joyindex, axisindex
	local leftdead, rightdead, leftsat, rightsat, center
	local automode
	
	local axisname = iup.label{title="", size="80", alignment="ACENTER", expand="NO"}
	local calibratedvalue = iup.canvas{
		scrollbar="HORIZONTAL", size="200x", border="NO", expand="NO",
		xmin = -1000, xmax=1000, dx=50, posx=0,
		xstyle=1,
		}
	local rawvalue = iup.joystick{
		size="200x24", border="NO", expand="NO",
		leftdead=-90, rightdead=-10,
		leftsat=10, rightsat=90,
		center=0,
		action=function(self, mode, value)
			if mode == 1 then
				joystick.SetJoystickSingleAxisSaturation(joyindex, axisindex, value, self.rightsat)
			elseif mode == 2 then
				joystick.SetJoystickSingleAxisDeadZone(joyindex, axisindex, value, self.rightdead)
			elseif mode == 3 then
				joystick.SetJoystickSingleAxisDeadZone(joyindex, axisindex, self.leftdead, value)
			elseif mode == 4 then
				joystick.SetJoystickSingleAxisSaturation(joyindex, axisindex, self.leftsat, value)
			elseif mode == 5 then
				joystick.SetJoystickSingleAxisCenter(joyindex, axisindex, value)
			end
		end
		}
	local b1 = iup.stationbutton{title="Set Center", expand="HORIZONTAL",
		action=function()
			rawvalue.center = joystick.GetJoystickSingleAxisRawValue(joyindex, axisindex)
		end}
	local b2 = iup.stationbutton{title="Reset", expand="HORIZONTAL", 
		action=function()
			center = joystick.GetJoystickSingleAxisRawValue(joyindex, axisindex)
			leftdead = (center-100)
			rightdead = (center+100)
			leftsat = leftdead
			rightsat = rightdead
			automode = true
			
			joystick.SetJoystickSingleAxisDeadZone(joyindex, axisindex, leftdead, rightdead)
			joystick.SetJoystickSingleAxisSaturation(joyindex, axisindex, leftsat, rightsat)
			joystick.SetJoystickSingleAxisCenter(joyindex, axisindex, center)
			rawvalue.leftdead = leftdead
			rawvalue.rightdead = rightdead
			rawvalue.leftsat = leftsat
			rawvalue.rightsat = rightsat
			rawvalue.center = center
		end}

	local entry = iup.hbox{
			axisname,
			iup.vbox{
				iup.hbox{iup.label{title="Raw: ",alignment="ARIGHT",expand="HORIZONTAL"},rawvalue, alignment="ACENTER"},
				iup.hbox{iup.label{title="Calibrated: ",alignment="ARIGHT",expand="HORIZONTAL"},calibratedvalue, alignment="ACENTER"},
				margin="0x0"},
			iup.vbox{b1,b2, margin="0x0"},
			alignment="ACENTER",
			gap=5,
			margin="0x10",
		}
	local okbutton = iup.stationbutton{title="OK", action=function() return iup.CLOSE end}
	local cancelbutton = iup.stationbutton{title="Cancel",
		action=function()
			joystick.SetJoystickSingleAxisDeadZone(joyindex, axisindex, leftdead, rightdead)
			joystick.SetJoystickSingleAxisSaturation(joyindex, axisindex, leftsat, rightsat)
			joystick.SetJoystickSingleAxisCenter(joyindex, axisindex, center)
			return iup.CLOSE
		end}

	dlg = iup.dialog{
		iup.stationhighopacityframe{
		iup.stationhighopacityframebg{
			iup.vbox{
				entry,
				iup.hbox{iup.fill{}, okbutton, iup.fill{}, cancelbutton, iup.fill{}}
			}
		},
		},
		border="NO",menubox="NO",resize="NO",
		bgcolor="0 0 0 0 +",
		fullscreen="NO",
		defaultesc=cancelbutton,
	}
	
	local function setup(joyinfo, a_index)
		automode = false
		joyindex = joyinfo.index
		axisindex = a_index
		leftdead, rightdead, leftsat, rightsat, center = joystick.GetJoystickSingleAxisSettings(joyindex, axisindex)
		rawvalue.leftdead = leftdead
		rawvalue.rightdead = rightdead
		rawvalue.leftsat = leftsat
		rawvalue.rightsat = rightsat
		rawvalue.center = center
		axisname.title=joyinfo.AxisNames[axisindex]
	end
	local function update(joyinfo)
		local raw_value = joystick.GetJoystickSingleAxisRawValue(joyindex, axisindex)
		rawvalue.rawvalue = raw_value
		calibratedvalue.posx = joyinfo[axisindex]
		if automode then
			if raw_value < leftsat then leftsat = raw_value rawvalue.leftsat = leftsat end
			if raw_value > rightsat then rightsat = raw_value rawvalue.rightsat = rightsat end
			joystick.SetJoystickSingleAxisSaturation(joyindex, axisindex, leftsat, rightsat)
		end
	end

	return {dialog=dlg, axisname=axis, calibratedvalue=calibratedvalue,
		rawvalue=rawvalue, centerbutton=b1, resetbutton=b2,
		okbutton=okbutton, cancelbutton=cancelbutton,
		setup=setup, update=update}
end

local JoystickCalibrationDialog = joystickcalibratetemplate()

local function makesubdlg(joyinfo, bindinfo, invertinfo, axis, change_cb)
	local axisname = iup.label{title=joyinfo.AxisNames[axis], size="120", alignment="ACENTER", expand="NO"}
	local cmds = iup.list(joycmdlist)
	cmds.value=joycmdlist2[bindinfo[axis] or "NONE"]
	local invert = iup.stationtoggle{title="Invert", expand="NO", value=invertinfo[axis] and "ON" or "OFF"}
	local val = iup.canvas{
		scrollbar="HORIZONTAL", size="150x", border="NO", expand="NO",
		xmin = -1000, xmax=1000, dx=100, posx=0,
		xstyle=1,
		}

	local calibratebutton
	if Platform ~= "Windows" then
--	if Platform == "MacOS" then
		calibratebutton = iup.stationbutton{title="Calibrate", expand="HORIZONTAL", 
			action = function()
				HideDialog(inputoptionsdlg)
				JoystickCalibrationDialog.setup(joyinfo, axis)
				
				PopupDialog(JoystickCalibrationDialog.dialog, iup.CENTER, iup.CENTER)
				ShowDialog(inputoptionsdlg)
			end
		}
	end

	local entry = iup.hbox{
			axisname,
			cmds,
			invert,
			val,
			calibratebutton,
			alignment="ACENTER",
			gap=5,
			margin="0x10",
		}
	local subdlg = iup.dialog{
		entry,
		border="NO",menubox="NO",resize="NO",
		bgcolor="0 0 0 0 +",
		fullscreen="NO",
	}

	function invert:action(newstate)
		joystickchanges[joyinfo.index][axis].invert = newstate
		change_cb()
	end
	function cmds:action(text, index, state)
		joystickchanges[joyinfo.index][axis].cmdindex = index
		change_cb()
	end

	return {subdlg, val, axis}
end

local function makeaxisdialog(axis, itemlist, bindinfo, joyinfo, invertinfo, change_cb)
	if joyinfo.AxisNames[axis] then
		local subdlg = makesubdlg(joyinfo, bindinfo, invertinfo, axis, change_cb)
		table.insert(itemlist, subdlg)
		joystickchanges[joyinfo.index][axis] = {}
	end
end

local function collateitems(listbox, itemlist)
	local size, curmaxsize
	for index,subdlg in ipairs(itemlist) do
		subdlg[1]:map()
		size = subdlg[1].size
		if (not curmaxsize) or curmaxsize < size then curmaxsize = size end
	end

	for index,subdlg in ipairs(itemlist) do
		subdlg[1].size = curmaxsize
		iup.Append(listbox, subdlg[1])
	end
	listbox:map()
end

local function clearlist(listctl, itemlist)
	listctl[1] = nil
	for k,v in ipairs(itemlist) do
		v[1]:destroy()
		itemlist[k] = nil
	end
end

local function setuplist(listctl, itemlist, bindinfo, joyinfo, invertinfo, change_cb)
	-- first, clear out and free old list
	clearlist(listctl, itemlist)

	-- second, get axes and make subdialogs
	if joyinfo then
		for k,v in ipairs(joyinfo.AxisNames) do
			makeaxisdialog(k, itemlist, bindinfo, joyinfo, invertinfo, change_cb)
		end
	end

	-- third, add subdlgs to listcontrol
	collateitems(listctl, itemlist)
	listctl[1] = 1
end



local function updateaxes(itemlist, joyinfo)
	for k,v in ipairs(itemlist) do
		local axis = tonumber(v[3])
		local value = joyinfo[axis]
		v[2].posx = value
	end
	if JoystickCalibrationDialog.dialog.visible == "YES" then
		JoystickCalibrationDialog.update(joyinfo)
	end
end

local function inputoptions()
	local dlg, inputtab, keyboardtab, mousetab, joysticktab, tabs
	local okbutton, applybutton, cancelbutton, defaultsbutton, helpbutton
	local km, kj, fam, inputmode
	local mousesensitivity, xinvert, yinvert
	local enableaccel, accelsensitivity, accelxinvert, accelyinvert, accelzinvert, centeranglesetting
	local keyreceiver
	local joylist, joyaxeslist, joyscanbutton
	local keybinds
	local keyboardconfig

	local statechange = function(self) applybutton.active = "YES" end
	local keychanges = {}

	km = iup.stationradio{title="Keyboard/Mouse", action=statechange}
	if Platform == 'Android' then
		kj = iup.stationradio{title="Keyboard/Accelerometer", action=statechange}
	else
		kj = iup.stationradio{title="Keyboard/Joystick", action=statechange}
	end
	fam = iup.stationtoggle{title="Enable Flight-Assist Mode", value="OFF", action=statechange}
	inputmode = iup.radio{iup.vbox{km, kj, margin="20x0"}, value=km}
	inputtab = iup.vbox{
		iup.label{title="Preferred Input Configuration"},
		inputmode,
		fam,
	}
	
	local numcommands = (#commandlist)
	keyreceiver = iup.canvas{border="NO", size="1x1", expand="NO"}
	keyboardtab = iup.matrix{numcol=2, numlin=numcommands,
		numcol_visible=2, numlin_visible=14,
		resizematrix="YES",
		expand="YES",
	}
	keyboardtab.alignment1 = "ARIGHT"
	keyboardtab.alignment2 = "ALEFT"
	for k=1,numcommands do
		keyboardtab:setcell(k, 1, command_pretty_names[commandlist[k][1]].." ")
		commandlist[k].keys = nil
		keyboardtab:setcell(k, 2, " (none)")
		keyboardtab["BGCOLOR"..k..":*"] = "0 0 0 0 +"
	end
	local editmode = nil
	local joystickbuttonpoller = Timer()
	function keyboardtab:enteritem_cb(lin, col)
		self["BGCOLOR"..lin..":*"] = "0 0 0 0 +"
		editmode = lin
		self['FGCOLOR'..lin..':*'] = "255 0 0"
		iup.SetCapture(keyreceiver)
		iup.SetFocus(keyreceiver)
		keyreceiver:StartJoyPoll()
	end
	function keyboardtab:leaveitem_cb(lin, col)
		self["FGCOLOR"..lin..":*"] = "255 255 255"
	end
	function keyboardtab:mousemove_cb(lin, col)
		if self.curline and self.curline ~= lin then self["FGCOLOR"..self.curline..":*"] = "255 255 255" end
		self.curline = tonumber(lin)
		self["FGCOLOR"..lin..":*"] = "255 255 0"
	end
	function keyboardtab:edition_cb(lin, col, mode)
		return iup.IGNORE
	end
	function keyreceiver:button_cb(button, state, x, y, status)
		if bitlib.band(button, iup.MBUTTONDBLCLICK) == iup.MBUTTONDBLCLICK then
			return
		elseif editmode then
			if state == 1 then
				keyboardtab:AddCode(button + 536870912)
				keyboardtab:DoneEdit()
			else
				-- this is a hack to handle how canvas
				-- handles mousebuttons.
				-- canvas automatically sets capture when mouse button
				-- is pressed and releases capture when mouse button is
				-- released. we don't want to lose capture so we have to
				-- recapture it.
				iup.SetCapture(self)
			end
		end
	end
	function keyreceiver:k_any(keycode)
		if editmode then
			if keycode ~= iup.K_ESC then
				keyboardtab:AddCode(keycode + 268435456)
			end
			keyboardtab:DoneEdit()
		elseif keycode == iup.K_BS then
			keyboardtab[keyboardtab.curline..':2'] = " (none)"
			keyboardtab["BGCOLOR"..keyboardtab.curline..":*"] = "0 0 0 0 +"
			commandlist[tonumber(keyboardtab.curline)].keys = {}
			statechange()
		end
		return iup.IGNORE
	end
	function keyreceiver:StartJoyPoll()
		joystickbuttonpoller:SetTimeout(10, function() keyreceiver:joypoll() end)
	end
	function keyreceiver:checkjoyinfo(newinfo)
		local direction
		if newinfo then
			local hasX45
			if string.find(newinfo.Name, "Saitek X45") or string.find(newinfo.Name, "Saitek X52") then
				hasX45 = true
			end
			for k,v in ipairs(newinfo.Buttons) do
				if v ~= 0 and not (hasX45 and (k==9 or k==10 or k==11 or k==13)) then
					return k-1
				end
			end
			for k,v in ipairs(newinfo.POV) do
				if v == 0 then
					direction = 108
				elseif v == 90 then
					direction = 109
				elseif v == 180 then
					direction = 110
				elseif v == 270 then
					direction = 111
				end
				if direction then
					return (k-1)*256 + direction
				end
			end
		end
	end
	function keyreceiver:joypoll()
		local curinfo, retval
		local i=0
		while true do
			curinfo = joystick.GetJoystickData(i)
			if not curinfo then break end
			retval = self:checkjoyinfo(curinfo)
			if retval then
				retval = retval + i*4096
				keyboardtab:AddCode(retval + 1073741824)
				keyboardtab:DoneEdit()
				return
			end
			i=i+1
		end
		joystickbuttonpoller:SetTimeout(10)
	end
	function keyboardtab:AddCode(code)
		local name = gkinterface.GetNameForInputCode(code)
		local oldindex
		if name then
			local curline = tonumber(self.curline)
			local curcmd = commandlist[curline]
			local oldcmd = keybinds[name]
			local function changekey()
			-- see if key is already bound to this cmd
			for k,v in ipairs(curcmd.keys) do if v==name then return end end
			table.insert(curcmd.keys, name)
				self:setcell(curline, 2, " "..table.concat(curcmd.keys, " "))
			local blah = keychanges[curcmd[1]] or {}
			keychanges[curcmd[1]] = blah
			table.insert(blah, code)

			-- see if this key was bound to anything else and update it
			if oldcmd and oldcmd ~= curcmd[1] then
				-- remove from old cmd's list
				if oldindex then
					local keys = commandlist[oldindex].keys
					for k,v in ipairs(keys) do
						if v == name then
							table.remove(keys, k)
							break
						end
					end
					if (#keys) == 0 then
							self:setcell(oldindex, 2, " (none)")
					else
							self:setcell(oldindex, 2, " "..table.concat(keys, " "))
					end
						self["BGCOLOR"..oldindex..":*"] = "0 0 0 0 +"
				end
				
				-- remove from changed list
				local changes = keychanges[oldcmd]
				if changes then
					for k,v in ipairs(changes) do
						if v == code then
							table.remove(changes, k)
							break
						end
					end
				end
			end
			-- save what cmd this key is set to
			keybinds[name] = curcmd[1]
				statechange()
			end
			
			if oldcmd and oldcmd ~= curcmd[1] then
				oldindex = commandlist_reverse[oldcmd]
				if oldindex then
					QuestionDialog:SetMessage("\""..name.."\" is already used for "..command_pretty_names[oldcmd]..". Do you wish to overwrite this?",
						"Yes", function() changekey() return iup.CLOSE end,
						"No", function() return iup.CLOSE end) 
					iup.ReleaseCapture(keyreceiver)
					PopupDialog(QuestionDialog, iup.CENTER, iup.CENTER)
				end
			else
				changekey()
				iup.ReleaseCapture(keyreceiver)
			end
		end
	end
	function keyboardtab:DoneEdit()
		if editmode then
			joystickbuttonpoller:Kill()
			iup.ReleaseCapture(keyreceiver)
			iup.SetFocus(dlg)
			self['FGCOLOR'..self.curline..':*'] = "255 255 255"
			self["BGCOLOR"..self.curline..":*"] = "0 0 0 0 +"
			editmode = nil
		end
	end
	keyboardconfig = iup.stationmainframebg{
		iup.vbox{keyboardtab, alignment="ACENTER"},
		tabtitle="Keyboard",
	}

	mousesensitivity = iup.canvas{
		scrollbar="HORIZONTAL", size="200x", border="NO",
		expand="NO",
		xmin = 1, xmax=20, dx=1, posx=0, linex=1,
		scroll_cb=statechange,
		}
	xinvert = iup.stationtoggle{title="Invert", value="OFF", action=statechange}
	yinvert = iup.stationtoggle{title="Invert", value="OFF", action=statechange}
	mousetab = iup.vbox{
		iup.hbox{iup.label{title="Sensitivity:  "}, iup.label{title="(slower)"},mousesensitivity,iup.label{title="(faster)"}, alignment="ACENTER"},
		iup.label{title="X Axis"}, iup.hbox{xinvert, margin="20x0"},
		iup.label{title="Y Axis"}, iup.hbox{yinvert, margin="20x0"}}

	local joylisttimer = Timer()
	local joysticktimer_cb
	joylist = iup.stationsubsublist{dropdown="YES", expand="HORIZONTAL"}
	joyaxeslist = iup.stationsubsublist{expand="YES", control="YES", size="614x"}
	local itemlist = {}
	function joylist:action(text, index, state)
		if state == 1 then
			iup.SetFocus(dlg) -- do this because setuplist may destroy the currently
			-- focused control and iup doesn't get notified about it.
			local bindinfo = joystick.GetJoystickAxisBind(index-1)
			local joyinfo = joystick.GetJoystickData(index-1)
			local invertinfo = joystick.GetJoystickAxisInvert(index-1)
			setuplist(joyaxeslist, itemlist, bindinfo, joyinfo, invertinfo, statechange)
		end
	end
	local function joysetup()
		joystickchanges = {}
		joylist[1] = nil
		local i=0
		while true do
			local joyinfo = joystick.GetJoystickData(i)
			if not joyinfo then break end
			joystickchanges[i] = {}
			joyinfo.index = i
			joylist[i+1] = "JOY"..i..": "..joyinfo.Name
			i=i+1
		end
		joylist[i+1] = nil
		joylist.value = 1
		joylist:action(nil, 1, 1)
		joylisttimer:SetTimeout(30, joysticktimer_cb)
	end
	joyscanbutton = iup.stationbutton{title="Scan for joysticks",
		action=function()
			joystick.ScanForJoysticks()
			joysetup()
		end
	}

	if Platform == 'Android' then
		-- accelerometer/sensor settings
		accelsensitivity = iup.canvas{
			scrollbar="HORIZONTAL", size="200x", border="NO",
			expand="NO",
			xmin = 0, xmax=200, dx=40, posx=0, linex=1,
			scroll_cb=statechange,
			}
		enableaccel = iup.stationtoggle{title="Enable Accelerometer", value="OFF", action=statechange}
		accelxinvert = iup.stationtoggle{title="Invert", value="OFF", action=statechange}
		accelyinvert = iup.stationtoggle{title="Invert", value="OFF", action=statechange}
		accelzinvert = iup.stationtoggle{title="Invert", value="OFF", action=statechange}
		centeranglesetting = iup.stationsubsublist{dropdown="YES", value="1", action=statechange}
		acceltab = iup.vbox{
			enableaccel,
			iup.hbox{iup.label{title="Sensitivity:  "}, iup.label{title="(slower)"},accelsensitivity,iup.label{title="(faster)"}, alignment="ACENTER"},
			iup.label{title="X Axis"}, iup.hbox{accelxinvert, margin="20x0"},
			iup.label{title="Y Axis"}, iup.hbox{accelyinvert, margin="20x0"},
			iup.label{title="Z Axis"}, iup.hbox{accelzinvert, margin="20x0"},
			iup.label{title="Default Orientation"}, iup.hbox{centeranglesetting, margin="20x0"}}
	else
		joysticktab = iup.vbox{iup.label{title="Select joystick to configure: "}, joylist, joyaxeslist, iup.hbox{iup.fill{}, joyscanbutton}}
		joysticktimer_cb = function()
				if joysticktab.visible == "YES" then
					local joyinfo = joystick.GetJoystickData(tonumber(joylist.value)-1)
					if joyinfo then updateaxes(itemlist, joyinfo) end
				end
				joylisttimer:SetTimeout(30)
			end
	end

	if joysticktab then
		tabs = iup.root_tabs{
			iup.stationmainframebg{iup.vbox{inputtab, iup.fill{}, iup.hbox{iup.fill{}}}, tabtitle="Input"},
			keyboardconfig,
			iup.stationmainframebg{iup.vbox{iup.hbox{mousetab, iup.fill{}}, iup.fill{}}, tabtitle="Mouse"},
			iup.stationmainframebg{joysticktab, tabtitle="Joystick"},
			seltextcolor=tabseltextcolor, unseltextcolor=tabunseltextcolor,
			font=Font.H2,
			tabchange_cb = function(self, newtab, oldtab)
				helpbutton.active = newtab == keyboardconfig and "YES" or "NO"
			end,
		}
	else
		tabs = iup.root_tabs{
			iup.stationmainframebg{iup.vbox{inputtab, iup.fill{}, iup.hbox{iup.fill{}}}, tabtitle="Input"},
			keyboardconfig,
--			iup.stationmainframebg{iup.vbox{iup.hbox{mousetab, iup.fill{}}, iup.fill{}}, tabtitle="Mouse"},
			iup.stationmainframebg{iup.vbox{iup.hbox{acceltab, iup.fill{}}, iup.fill{}}, tabtitle="Accelerometer"},
			seltextcolor=tabseltextcolor, unseltextcolor=tabunseltextcolor,
			font=Font.H2,
			tabchange_cb = function(self, newtab, oldtab)
				helpbutton.active = newtab == keyboardconfig and "YES" or "NO"
			end,
		}
	end
	
	local function apply()
		local oldfam = Game.GetCVar("flymodeflag")
		local newfam = fam.value=="ON" and 1 or 0
		if oldfam ~= newfam then
			Game.SetCVar("flymodeflag", newfam)
		end
		gkinterface.SetMouseLookMode(inputmode.value==km and true or false)
		gkinterface.SetMouseOptions({xinvert.value=="ON" and 2 or 1, yinvert.value=="ON" and 2 or 1})
		gkinterface.SetMouseSensitivity(tonumber(mousesensitivity.posx) or gkinterface.GetMouseSensitivity())
		if Platform == 'Android' then
			if enableaccel.value == "ON" then
				gkinterface.BindCommand(1 + 2147483648, "Turn")
				gkinterface.BindCommand(2 + 2147483648, "Pitch")
			else
				gkinterface.BindCommand(1 + 2147483648, "")
				gkinterface.BindCommand(2 + 2147483648, "")
			end
			gkinterface.SetAccelerometerOptions({accelxinvert.value=="ON" and 2 or 1, accelyinvert.value=="ON" and 2 or 1, accelzinvert.value=="ON" and 2 or 1, centeranglesetting.value})
			gkinterface.SetAccelerometerSensitivity((tonumber(accelsensitivity.posx or 100) or (gkinterface.GetAccelerometerSensitivity()*100)) / 100)
		end
		-- keyboard bind apply
		for cmd,keys in pairs(keychanges) do
			if keys.cleared then
				gkinterface.UnbindCommand(cmd)
			end
			for _,inputcode in ipairs(keys) do
				gkinterface.BindCommand(inputcode, cmd)
			end
		end
		-- joystick axis
		for joyindex, joystuff in pairs(joystickchanges) do
			for axis,axisstuff in pairs(joystuff) do
				if axisstuff.invert then
					joystick.SetJoystickSingleAxisInvert(joyindex, axis, axisstuff.invert==1)
				end
				if axisstuff.cmdindex then
					gkinterface.BindJoystickCommand(joyindex, axis, joycmdlist3[axisstuff.cmdindex])
				end
			end
		end
		applybutton.active = "NO"
	end
	helpbutton = iup.stationbutton{title="Help", active="NO", action=function()
		StationHelpDialog:Open("Mouse over a control and press \"backspace\" or \"delete\" to delete all keys bound to it. Click on a control and press a key to bind it to that key.")
	end}	
	okbutton = iup.stationbutton{title="OK", action=function() apply() Game.EnableInput() joylisttimer:Kill() HideDialog(dlg) ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER) end}
	applybutton = iup.stationbutton{title="Apply", active="NO", action=function() apply() end}
	cancelbutton = iup.stationbutton{title="Cancel", action=function() Game.EnableInput() joylisttimer:Kill() HideDialog(dlg) ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER) end}
	defaultsbutton = iup.stationbutton{title="Defaults",
		action=function()
				local retval
				QuestionDialog:SetMessage(
[[Confirmation:
Are you sure you want to reset to the default settings?]]
				, "Yes", function() retval = 1 return iup.CLOSE end, "No", function() retval = 2 return iup.CLOSE end)
				PopupDialog(QuestionDialog, iup.CENTER, iup.CENTER)
				if retval == 1 then
					gkinterface.LoadDefaults()
					HideDialog(dlg)  -- blah. this is probably the least confusing to the user
					-- because you can't undo this action.
					ShowDialog(OptionsDialog)
				end
		end
	}
	
	dlg = iup.dialog{
		iup.vbox{
			iup.hbox{tabs, expand="YES"},
			iup.pdarootframe{iup.hbox{okbutton, applybutton, cancelbutton, keyreceiver, iup.fill{}, helpbutton, defaultsbutton; gap="15"}},
			margin="7x7",
			gap=2,
		},
		bgcolor="0 0 0",
		border="NO",menubox="NO",resize="NO",
		fullscreen="YES",
		defaultesc=cancelbutton,
	}
	function dlg:k_any(keycode)
		if not editmode and keycode == iup.K_BS and keyboardtab.curline then
			keyboardtab[keyboardtab.curline..':2'] = " (none)"
			local curcmd = commandlist[tonumber(keyboardtab.curline)]
			curcmd.keys = {}
			keychanges[curcmd[1]] = {cleared=true}
			statechange()
		else
			return iup.CONTINUE -- continue to process this key
		end
	end
	
	dlg:map()

	function dlg:setup()
		joysetup()
		Game.DisableInput()

		fam.value = Game.GetCVar("flymodeflag")==1 and "ON" or "OFF"
		inputmode.value = gkinterface.GetMouseLookMode() and km or kj
		keybinds = {}

		local numcommands = (#commandlist)
		for k=1,numcommands do
			local keys = gkinterface.GetBindsForCommand(commandlist[k][1])
			commandlist[k].keys = keys
			if (#keys) == 0 then
				keyboardtab:setcell(k, 2, " (none)")
			else
				keyboardtab:setcell(k, 2, " "..table.concat(keys, " "))
				for _,keyname in ipairs(keys) do
					keybinds[keyname] = commandlist[k][1]
				end
			end
			keyboardtab["BGCOLOR"..k..":*"] = "0 0 0 0 +"
		end
		keychanges = {}


		local mouseoptions = gkinterface.GetMouseOptions()
		mousesensitivity.posx=tostring(gkinterface.GetMouseSensitivity())
		xinvert.value=mouseoptions[1].value==2 and "ON" or "OFF"
		yinvert.value=mouseoptions[2].value==2 and "ON" or "OFF"

		if Platform == 'Android' then
			local acceloptions = gkinterface.GetAccelerometerOptions()
			accelsensitivity.posx=tostring(gkinterface.GetAccelerometerSensitivity()*100)
			accelxinvert.value=acceloptions[1].value==2 and "ON" or "OFF"
			accelyinvert.value=acceloptions[2].value==2 and "ON" or "OFF"
			accelzinvert.value=acceloptions[3].value==2 and "ON" or "OFF"
			centeranglesetting[1] = acceloptions[4][1]
			centeranglesetting[2] = acceloptions[4][2]
			centeranglesetting[3] = acceloptions[4][3]
			centeranglesetting[4] = acceloptions[4][4]
			centeranglesetting[5] = acceloptions[4][5]
			centeranglesetting.value = acceloptions[4].value

			if Game.GetCommandForBind(1 + 2147483648) or Game.GetCommandForBind(2 + 2147483648) then
				enableaccel.value = "ON"
			else
				enableaccel.value = "OFF"
			end
		end

		applybutton.active = "NO"
		local x = getwidth(keyboardtab) - scrollbar_width
		keyboardtab.width1 = x/2 + 10
		keyboardtab.width2 = x/2 - 10
	end

	return dlg
end

function CreateOptionsMenu()
	inputoptionsdlg = inputoptions()
	local maindlg
	local previousdlg
	local b1,b2,b3,b4,b5,b6,b7, closebutton, logoffbutton, voicechatoptions
	
	if Platform ~= 'Android' then
		voicechatoptions = iup.stationbutton{title="Voice Chat",
					hotkey=iup.K_o,
					action=function()
						HideDialog(maindlg)
						ShowDialog(VoiceChatOptions, iup.CENTER, iup.CENTER)
						cursubdlg = inputoptionsdlg
					end}
	end

	b1 = iup.stationbutton{title="Controls",
				hotkey=iup.K_c,
				action=function()
					HideDialog(maindlg)
					inputoptionsdlg:setup()
					ShowDialog(inputoptionsdlg, iup.CENTER, iup.CENTER)
					cursubdlg = inputoptionsdlg
				end}
	b2 = iup.stationbutton{title="Game",
				hotkey=iup.K_g,
				action=function()
					HideDialog(maindlg)
					local retfunc = function(data) gkinterface.SetGameOptions(data) end
					cursubdlg = displayoptions("Game Options", gkinterface.GetGameOptions, retfunc)
				end}
	b3 = iup.stationbutton{title="Audio",
				hotkey=iup.K_a,
				action=function()
					HideDialog(maindlg)
					local retfunc = function(data) gkinterface.SetAudioOptions(data) end
					cursubdlg = displayoptions("Audio Options - "..tostring(gkinterface.GetCurrentAudioDriverName() or "None"), gkinterface.GetAudioOptions, retfunc, nil, true)
				end}
	b4 = iup.stationbutton{title="Graphics",
				hotkey=iup.K_r,
				action=function()
					HideDialog(maindlg)
					local oldoptions = gkinterface.GetGraphicsOptions()
					local retfunc = function(data)
						if oldoptions[7].value ~= data[7] and data[7] == 2 then
							local retval
							QuestionDialog:SetMessage(
[[This option will cause the client to use about 600MB of RAM memory on startup, and initial game
startup will take longer. If you have less than 1.5GB of total system memory, you should also
enable Texture Compression, or avoid using it altogether. Pre-caching will enhance certain in-game
load times, such as new ships jumping into the current sector. The client must be restarted before
this can take effect.]]
							, "Enable Anyway", function() retval = 1 return iup.CLOSE end, "Cancel", function() retval = 2 return iup.CLOSE end)
							PopupDialog(QuestionDialog, iup.CENTER, iup.CENTER)
							if retval == 1 then
							else
								data[7] = oldoptions[7].value
							end
						end
						gkinterface.SetGraphicsOptions(data)
					end
					cursubdlg = displayoptions("Graphics Options", gkinterface.GetGraphicsOptions, retfunc)
				end}
	b5 = iup.stationbutton{title="Video",
				hotkey=iup.K_v,
				action=function()
					HideDialog(maindlg)
					local retfunc = function(data)
						local oldyres = gkinterface.GetYResolution()
						local oldxres = gkinterface.GetXResolution()
						gkinterface.SetVideoOptions(data, data.reset_fov_hud)
						gkinterface.SetVisualQuality(data[1])
						local newyres = gkinterface.GetYResolution()
						local newxres = gkinterface.GetXResolution()
						if (oldyres ~= newyres) or (oldxres ~= newxres) then
							oldyres = newyres
							oldxres = newxres
							ReloadInterface()
						end
					end
					cursubdlg = displayoptions("Video Options - "..tostring(gkinterface.GetCurrentVideoDriverName()), gkinterface.GetVideoOptions, retfunc, true, nil)
				end}
	b6 = iup.stationbutton{title="Network",
				hotkey=iup.K_n,
				action=function()
					HideDialog(maindlg)
					local function retfunc(data)
						gknet.SetMSS(data[1])
					end
					local function getnetoptions()
						return {{name="MTU Discovery", value=gknet.GetMSS(), "Automatic", "Compatibility Mode"}}
					end
					cursubdlg = displayoptions("Network Options", getnetoptions, retfunc)
				end}
	b7 = iup.stationbutton{title="Interface",
				hotkey=iup.K_i,
				action=function()
					HideDialog(maindlg)
					ShowDialog(InterfaceOptionsDialog, iup.CENTER, iup.CENTER)
				end}
	closebutton = iup.stationbutton{title="Close",
		action=function()
			HideDialog(maindlg)
			ShowDialog(previousdlg)
		end }
	logoffbutton = iup.stationbutton{title="Log off",
		hotkey=iup.K_l,
		action=function()
			if not ShowLogoffDialog then
				HideDialog(maindlg)
				ShowDialog(previousdlg)
				Logout()
			else
				-- open yes/no dialog. 
				QuestionWithCheckDialog:SetMessage('Are you sure you want to log off?',
					"Yes", function()
						ShowLogoffDialog = not QuestionWithCheckDialog:GetCheckState()
						gkini.WriteInt("Vendetta", "showlogoffconfirmation", ShowLogoffDialog and 1 or 0)
						HideDialog(QuestionWithCheckDialog)
						HideDialog(maindlg)
						ShowDialog(previousdlg)
						Logout()
					end,
					"No", function()
						ShowLogoffDialog = not QuestionWithCheckDialog:GetCheckState()
						gkini.WriteInt("Vendetta", "showlogoffconfirmation", ShowLogoffDialog and 1 or 0)
						HideDialog(QuestionWithCheckDialog)
					end,
					not ShowLogoffDialog
				)
				ShowDialog(QuestionWithCheckDialog, iup.CENTER, iup.CENTER)
			end
		end }
	
	maindlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					iup.hbox{iup.fill{},iup.label{title="Options",font=Font.H3},iup.fill{},},
					iup.hbox{b1, iup.label{title="Configure Keyboard/Mouse/Joysticks"},alignment="ACENTER",gap=2},
					iup.hbox{b2, iup.label{title="Change Game Settings"},alignment="ACENTER",gap=2},
					iup.hbox{b3, iup.label{title="Change Volume"},alignment="ACENTER",gap=2},
					iup.hbox{b4, iup.label{title="General Graphics Options"},alignment="ACENTER",gap=2},
					iup.hbox{b5, iup.label{title="Video Driver Graphics Options"},alignment="ACENTER",gap=2},
					iup.hbox{b6, iup.label{title="Network Options"},alignment="ACENTER",gap=2},
					iup.hbox{b7, iup.label{title="Interface Options"},alignment="ACENTER",gap=2},
					iup.hbox{voicechatoptions, iup.label{title="Voice Chat Options"},alignment="ACENTER",gap=2},
					iup.hbox{logoffbutton,iup.fill{},iup.fill{},closebutton,},
					gap=2,
					margin="2x2",
				},
			},
		},
		menubox="NO",
		resize="NO",
		border="NO",
		defaultesc = closebutton,
		bgcolor = "0 0 0 0 *",
	}
	
	function maindlg:hide_cb()
		if cursubdlg then
			HideDialog(cursubdlg)
			cursubdlg = nil
		end
	end
	function maindlg:show_cb()
		if cursubdlg then
			HideDialog(cursubdlg)
		end
		cursubdlg = nil
	end

	maindlg:map()
	local siz = getwidth(b1)
	if siz < getwidth(b2) then siz=getwidth(b2) end
	if siz < getwidth(b3) then siz=getwidth(b3) end
	if siz < getwidth(b4) then siz=getwidth(b4) end
	if siz < getwidth(b5) then siz=getwidth(b5) end
	if siz < getwidth(b6) then siz=getwidth(b6) end
	if siz < getwidth(b7) then siz=getwidth(b7) end
	if voicechatoptions and (siz < getwidth(voicechatoptions)) then siz=getwidth(voicechatoptions) end
	if siz < getwidth(logoffbutton) then siz=getwidth(logoffbutton) end

	b1.size = siz
	b2.size = siz
	b3.size = siz
	b4.size = siz
	b5.size = siz
	b6.size = siz
	b7.size = siz
	if voicechatoptions then
		voicechatoptions.size = siz
	end
	logoffbutton.size = siz
	maindlg.size = nil
	
	function maindlg:SetMenuMode(mode, prevdlg)
		previousdlg = prevdlg
		if mode == 1 then
			logoffbutton.visible = "NO"
		elseif mode == 2 then
			logoffbutton.visible = "YES"
		end
	end
	
	return maindlg
end

OptionsDialog = CreateOptionsMenu()
