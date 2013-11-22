local closebutton = iup.stationbutton{title="Close",
	action=function()
		HideDialog(HUDHelpMenu)
		ShowDialog(HUD.dlg)
	end}

local column1, column2

local commandlist1 = {
	{
		title="Movement",
		"+Accelerate",
		"+Decelerate",
		"+StrafeLeft",
		"+StrafeRight",
		"+StrafeUp",
		"+StrafeDown",
		"+Turbo",
		"+Brakes",
		"+RotateCCW",
		"+RotateCW",
	},
	{
		title="Chat",
		"Say_Sector",
		"Say_Channel",
		"Say_Group",
		"Say_Guild",
		"scrollback",
		"scrollforward",
		"hail",
	},
}
local commandlist2 = {
	{
		title="Radar Selection",
		"RadarNextFront",
		"RadarNextFrontEnemy",
		"RadarNextNearestEnemy",
		"RadarHitBy",
	},
	{
		title="Weapons",
		"+Shoot2",
		"+Shoot1",
		"+Shoot3",
		"Select Weapon Group",
	},
	{
		title="Other",
		"Activate",
		"Jettison",
		"+TopList",
		"FlyModeToggle",
		"MLookToggle",
		"charinfo",
		"nav",
	},
	{
		title="Mission",
		"missionchat",
	},
}

local allkeylabels = {}
column1 = {}
for k,v in ipairs(commandlist1) do
	local sub = {margin="10x10"}
	table.insert(sub, iup.label{title=v.title, expand="HORIZONTAL", alignment="ACENTER", fgcolor="0 191 223", font=Font.H2})
	local c1={}
	local c2={}
	for a,b in ipairs(v) do
		local keys
		if b ~= "Select Weapon Group" then
			keys = table.concat(gkinterface.GetBindsForCommand(b), " ")
		else
			keys = "1-7"
		end
		table.insert(c1, iup.label{title=tostring(command_pretty_names[b] or b), alignment="ARIGHT", expand="HORIZONTAL", fgcolor="0 191 127"})
		local keylabel = iup.label{title=tostring(keys), expand="HORIZONTAL"}
		table.insert(c2, keylabel)
		allkeylabels[b] = keylabel
	end
	table.insert(sub, iup.hbox{iup.vbox(c1),iup.vbox(c2), gap=10})
	table.insert(column1, iup.vbox(sub))
end
column2 = {}
for k,v in ipairs(commandlist2) do
	local sub = {margin="10x10"}
	table.insert(sub, iup.label{title=v.title, expand="HORIZONTAL", alignment="ACENTER", fgcolor="0 191 223", font=Font.H2})
	local c1={}
	local c2={}
	for a,b in ipairs(v) do
		local keys
		if b ~= "Select Weapon Group" then
			keys = table.concat(gkinterface.GetBindsForCommand(b), " ")
		else
			keys = "1-7"
		end
		table.insert(c1, iup.label{title=tostring(command_pretty_names[b] or b), alignment="ARIGHT", expand="HORIZONTAL", fgcolor="0 191 127"})
		local keylabel = iup.label{title=tostring(keys), expand="HORIZONTAL"}
		table.insert(c2, keylabel)
		allkeylabels[b] = keylabel
	end
	table.insert(sub, iup.hbox{iup.vbox(c1),iup.vbox(c2), gap=10})
	table.insert(column2, iup.vbox(sub))
end

HUDHelpMenu = iup.dialog{
	iup.stationhighopacityframe{
		iup.stationhighopacityframebg{
			iup.vbox{
				iup.label{title="Vendetta Online Common Keys", alignment="ACENTER", expand="HORIZONTAL", fgcolor="0 223 191", font=Font.H1},
				iup.hbox{
					iup.vbox(column1),
					iup.vbox(column2),
				},
				iup.hbox{
					iup.fill{},
					closebutton,
					iup.fill{},
				},
			},
		},
	},
	defaultesc = closebutton,
	border="NO",
	resize="NO",
	menubox="NO",
	bgcolor = "0 0 0 0 *",
}

function HUDHelpMenu:k_any(ch)
	if gkinterface.GetCommandForKeyboardBind(ch) == "Help" then
		HideDialog(self)
		ShowDialog(HUD.dlg)
		return iup.IGNORE
	end
	return iup.CONTINUE
end

function HUDHelpMenu:setup()
	for k,v in pairs(allkeylabels) do
		local keys
		if k ~= "Select Weapon Group" then
			keys = table.concat(gkinterface.GetBindsForCommand(k), " ")
		else
			keys = "1-7"
		end
		v.title=tostring(keys)
	end
end

RegisterEvent(HUDHelpMenu, "HUD_HELP_TOGGLE")

function HUDHelpMenu:OnEvent(eventname, ...)
	if eventname == "HUD_HELP_TOGGLE" then
		if HUDHelpMenu.visible == "YES" then
			HideDialog(HUDHelpMenu)
			ShowDialog(HUD.dlg)
		elseif HUD.dlg.visible == "YES" then
			HideDialog(HUD.dlg)
			HUDHelpMenu:setup()
			ShowDialog(HUDHelpMenu, iup.CENTER, iup.CENTER)
		end
	end
end
