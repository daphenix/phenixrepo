local current_chattype = 3

function hextorgb(hex)
	if hex and #hex == 6 then
		return string.format("%d %d %d",
					tonumber(string.sub(hex, 1, 2), 16),
					tonumber(string.sub(hex, 3, 4), 16),
					tonumber(string.sub(hex, 5, 6), 16))
	else
		return "255 255 255"
	end
end

-- takes "rr gg bb" returns \127rrggbb in hex.
function  rgbtohex(rgb)
	if rgb and tonumber( (rgb:gsub(' ','')) ) then
		return ("\127%02x%02x%02x"):format(rgb:match("(%d+) (%d+) (%d+)"))
	else
		return rgb -- defaults to pass-thru on fail
	end
end

local chattypes = {
	[2]="CHAT_MSG_SECTOR",
	[3]="CHAT_MSG_CHANNEL_ACTIVE",
	[4]="CHAT_MSG_GROUP",
	[5]="CHAT_MSG_GUILD",
	[6]="CHAT_MSG_SYSTEM",
}

local function chattype_colors(index)
	return hextorgb(chatinfo[chattypes[index]][1]:gsub("\127", ""))
end

local parent_dlg
function chatareatemplate(stationtabname, expanded)
	local chatselbuttons, chatlog, missionlog, stationlog, currentlog
	local tabs
	local stuff

	local function logupdated(self)
		if self == chatlog then
			local color = tabunseltextcolor
			if currentlog == chatlog then
				SetChatLogRead()
				color = tabseltextcolor
			end
			tabs:SetTabTextColor(1, GetChatLogReadState() and color or "255 0 0")
		elseif self == missionlog then
			local color = tabunseltextcolor
			if currentlog == missionlog then
				SetMissionLogRead()
				color = tabseltextcolor
			end
			tabs:SetTabTextColor(2, GetMissionLogReadState() and color or "255 0 0")
		elseif self == stationlog then
			local color = tabunseltextcolor
			if currentlog == stationlog then
				SetStationLogRead()
				color = tabseltextcolor
			end
			tabs:SetTabTextColor(3, GetStationLogReadState() and color or "255 0 0")
		end
	end

	chatlog = ChatLogTemplate("45 120 158 128 *", "100 0 0 178 *", logupdated, IMAGE_DIR.."commerce_tab_bgcolor.png", true)
	chatlog.chattext.indent = "YES"
	chatlog.chattext.border = "NO"
	chatlog.chattext.boxcolor = "45 120 158 128"
	chatlog.chattext.bgcolor = "45 120 158 128 *"
	chatlog.chattext.active = "YES"
	chatlog.chattext.expand = "YES"
	chatlog.chatentry.active = "YES"
	chatlog.chatentry.wanttab = "YES"
	chatlog.chatentry.visible = "YES"
	chatlog.chatentry.border = "YES"
	chatlog.chatentry.boxcolor = nil
	missionlog = ChatLogTemplate("45 120 158 128 *", "100 0 0 178 *", logupdated, IMAGE_DIR.."commerce_tab_bgcolor.png", true)
	missionlog.chattext.border = "NO"
	missionlog.chattext.boxcolor = "45 120 158 128"
	missionlog.chattext.bgcolor = "45 120 158 128 *"
	missionlog.chattext.active = "YES"
	missionlog.chattext.expand = "YES"
	missionlog.chatentry.active = "YES"
	missionlog.chatentry.wanttab = "YES"
	missionlog.chatentry.visible = "YES"
	missionlog.chatentry.border = "YES"
	missionlog.chatentry.boxcolor = nil
	missionlog.chatentry.type = "MISSION"
	if stationtabname then
		stationlog = ChatLogTemplate("45 120 158 128 *", "100 0 0 178 *", logupdated, IMAGE_DIR.."commerce_tab_bgcolor.png", true)
		stationlog.chattext.indent = "YES"
		stationlog.chattext.border = "NO"
		stationlog.chattext.boxcolor = "45 120 158 128"
		stationlog.chattext.bgcolor = "45 120 158 128 *"
		stationlog.chattext.active = "YES"
		stationlog.chattext.expand = "YES"
		stationlog.chatentry.active = "YES"
		stationlog.chatentry.wanttab = "YES"
		stationlog.chatentry.visible = "YES"
		stationlog.chatentry.border = "YES"
		stationlog.chatentry.boxcolor = nil
		stationlog.chatentry.type = "STATION"
	end
	local expand_func
	if expanded then
		expand_func = function(self)
			local cur_dlg = iup.GetDialog(self)
			HideDialog(cur_dlg)
			stuff.setup()
			ShowDialog(parent_dlg)
		end
	else
		expand_func = function(self)
			parent_dlg = iup.GetDialog(self)
			HideDialog(parent_dlg)
			local expandedchatdlg
			if stationtabname == "Station" then
				expandedchatdlg = MaximizedStationChat
			elseif stationtabname == "ShipCom" then
				expandedchatdlg = MaximizedCapShipChat
			else
				expandedchatdlg = MaximizedSpaceChat
			end
			expandedchatdlg:setup()
			ShowDialog(expandedchatdlg, iup.CENTER, iup.CENTER)
		end
	end
	local function activatechat(index)
		current_chattype = index
		iup.SetFocus(chatlog.chatentry)
		chatlog.chatentry.fgcolor = ColorChatInput and chattype_colors(index) or "255 255 255"
--		for k,v in ipairs(chatselbuttons) do
--			v.fgcolor = "0 0 0"
--		end
--		chatselbuttons[index].fgcolor = "255 255 255"
--		chatlog.chattitle.title = chatselbuttons[index].title..":"
	end
	chatselbuttons = {}
	chatselbuttons[1] = iup.button{title="", size="16x16", image=IMAGE_DIR.."int_magnifying.png", bgcolor="255 255 255 255 *", action=expand_func}
	chatselbuttons[2] = iup.stationradio{title="Sector", font=Font.H6, action=function() chatlog.chatentry.type = "SECTOR" activatechat(2) end}
	chatselbuttons[3] = iup.stationradio{title="Channel", font=Font.H6, action=function() chatlog.chatentry.type = "CHANNEL" activatechat(3) end}
	chatselbuttons[4] = iup.stationradio{title="Group", font=Font.H6, action=function() chatlog.chatentry.type = "GROUP" activatechat(4) end}
	chatselbuttons[5] = iup.stationradio{title="Guild", font=Font.H6, action=function() chatlog.chatentry.type = "GUILD" activatechat(5) end}
	chatselbuttons[6] = iup.stationradio{title="System", font=Font.H6, action=function() chatlog.chatentry.type = "SYSTEM" activatechat(6) end}
	chatselbuttons[current_chattype].action()
	chatselbuttons[7] = iup.fill{}
	chatselbuttons.expand="YES"
	chatselbuttons.gap=3
	chatselbuttons.alignment="ACENTER"
	local radio = iup.radio{
		iup.stationsubframebg{
			iup.hbox(chatselbuttons),
			},
		value=chatselbuttons[current_chattype]
	}
	local general = iup.vbox{tabtitle="General", chatlog.vbox, radio}
	local mission = iup.vbox{tabtitle="Mission", missionlog.vbox,
			iup.stationsubframebg{
				iup.hbox{
					iup.button{title="", size="16x16", image=IMAGE_DIR.."int_magnifying.png", bgcolor="255 255 255 255 *", action=expand_func},
					iup.fill{},
				},
			},
		}
	local station
	if stationtabname then
		station = iup.vbox{tabtitle=tostring(stationtabname), stationlog.vbox,
			iup.stationsubframebg{
				iup.hbox{
					iup.button{title="", size="16x16", image=IMAGE_DIR.."int_magnifying.png", bgcolor="255 255 255 255 *", action=expand_func},
					iup.fill{},
				},
			},
		}
	end
	general.hotkey = iup.K_g
	mission.hotkey = iup.K_m
	tabs = iup.sub_tabs{
		general, mission, station,
		tabtype="RIGHT",
		seltextcolor=tabseltextcolor, unseltextcolor=tabunseltextcolor,
		tabchange_cb = function(self, newtab, oldtab)
			if newtab == mission then
				SetCurrentChatTab(2)
				iup.SetFocus(missionlog.chatentry)
				SetMissionLogRead()
				currentlog = missionlog
			elseif newtab == general then
				SetCurrentChatTab(1)
				iup.SetFocus(chatlog.chatentry)
				SetChatLogRead()
				currentlog = chatlog
			else
				SetCurrentChatTab(3)
				iup.SetFocus(stationlog.chatentry)
				SetStationLogRead()
				currentlog = stationlog
			end
		end
	}
	local chatarea = iup.stationmainframe{
		tabs,
--		expand="HORIZONTAL",
	}

	local function setup()
		chatselbuttons[current_chattype].action()
		radio.value = chatselbuttons[current_chattype]
		local currenttab = GetCurrentChatTab()
		if currenttab == 3 and stationlog then
			currentlog = stationlog
		elseif currenttab == 2 then
			currentlog = missionlog
		else
			currenttab = 1
			currentlog = chatlog
		end
		tabs:SetTab(currenttab)
	end
	currentlog = chatlog

	function chatlog.chatentry:setchatmode(mode)
		radio.value = chatselbuttons[mode]
		chatselbuttons[mode].action()
	end

	stuff = {area=chatarea, chatlog=chatlog,
		missionlog=missionlog, stationlog=stationlog,
		setup=setup,
	}
	return stuff
end

function chatareatemplate2(maximized, maximizebuttontext)
	local container
	local chatselbuttons
	local chatlog = ChatLogTemplate("0 0 0 0 *", "100 0 0 178 *", SetChatLogRead, false, true)

	local maximized_func
	if maximized then
		maximized_func = function(self)
			local cur_dlg = iup.GetDialog(self)
			if parent_dlg and not cur_dlg.OnMaximize then
				HideDialog(cur_dlg)
				ShowDialog(parent_dlg)
			else
				if cur_dlg.OnMaximize then
					cur_dlg:OnMaximize()
				end
			end
		end
	else
		maximized_func = function(self)
			parent_dlg = iup.GetDialog(self)
			HideDialog(parent_dlg)
			ShowDialog(MaximizedSpaceChat, iup.CENTER, iup.CENTER)
		end
	end

	local function activatechat(index)
		current_chattype = index
		iup.SetFocus(chatlog.chatentry)
		chatlog.chatentry.fgcolor = ColorChatInput and chattype_colors(index) or "255 255 255"
	end
	chatselbuttons = {alignment="ACENTER"}
	chatselbuttons[1] = iup.stationradio{title="Sector", font=Font.H4, action=function() chatlog.chatentry.type = "SECTOR" activatechat(2) end}
	chatselbuttons[2] = iup.stationradio{title="Channel", font=Font.H4, action=function() chatlog.chatentry.type = "CHANNEL" activatechat(3) end}
	chatselbuttons[3] = iup.stationradio{title="Group", font=Font.H4, action=function() chatlog.chatentry.type = "GROUP" activatechat(4) end}
	chatselbuttons[4] = iup.stationradio{title="Guild", font=Font.H4, action=function() chatlog.chatentry.type = "GUILD" activatechat(5) end}
	chatselbuttons[5] = iup.stationradio{title="System", font=Font.H4, action=function() chatlog.chatentry.type = "SYSTEM" activatechat(6) end}
	chatselbuttons[current_chattype-1].action()
	local activechannel = GetActiveChatChannel()
	local curchannel = iup.label{title=activechannel and ("Current channel: "..activechannel) or "No current channel", font=Font.H4, expand="HORIZONTAL", alignment="ACENTER", fgcolor=tabunseltextcolor}
	local tooltip
	if not maximized then tooltip = "Full-screen chat" end
	local maximizebutton = iup.stationbutton{
		title=maximizebuttontext or (maximized and "Minimize" or "Maximize"),
		tip=tooltip,
		font=Font.H6,
		action=maximized_func,
		size = "x"..Font.H4,
		hotkey=iup.K_x
	}
	chatselbuttons.expand="YES"
	chatselbuttons.gap=3
	chatselbuttons.alignment="ACENTER"
	local radio = iup.radio{
--		iup.stationsubframebg{
			iup.hbox(chatselbuttons),
--			},
		value=chatselbuttons[current_chattype-1]
	}
	chatlog.chattext.indent = "YES"
	chatlog.chattext.border = "NO"
	chatlog.chattext.boxcolor = "0 0 0 0"
	chatlog.chattext.bgcolor = "0 0 0 0 *"
	chatlog.chattext.active = "YES"
	chatlog.chattext.expand = "YES"
	chatlog.chatentry.active = "YES"
	chatlog.chatentry.wanttab = "YES"
	chatlog.chatentry.visible = "YES"
	chatlog.chatentry.border = "YES"
	chatlog.chatentry.bgcolor = "49 90 110 128 *"
	chatlog.chatentry.bordercolor = "70 94 106"

	container = iup.vbox{
		iup.pdasubframe_nomargin{
			iup.hbox{radio, curchannel, maximizebutton, alignment="ACENTER"},
		},
		chatlog.vbox,
	}

	function container:update_channeltitle()
		local activechannel = GetActiveChatChannel()
		curchannel.title = activechannel and ("Current channel: "..activechannel) or "No current channel"
	end

	function container:set_chatmode(mode)
		radio.value = chatselbuttons[mode-1]
		chatselbuttons[mode-1].action()
	end

	chatlog.chatentry.setchatmode = container.set_chatmode

	function container:OnShow()
		SetChatLogRead()
		SetChatLogReceiver(chatlog)
		chatselbuttons[current_chattype-1].action()
		radio.value = chatselbuttons[current_chattype-1]
		local activechannel = GetActiveChatChannel()
		curchannel.title = activechannel and ("Current channel: "..activechannel) or "No current channel"
	end

	function container:OnHide()
	end

	return container
end

