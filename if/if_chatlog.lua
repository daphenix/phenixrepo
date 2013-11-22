_generalchatlog = GetGeneralChatLog()
_missionlog = GetMissionChatLog()
_stationlog = GetStationChatLog()
GeneralChatPanel = {log=_generalchatlog}
MissionLogPanel = {log=_missionlog}
StationLogPanel = {log=_stationlog}

local input_history = {}
local input_historyindex = 0

local function get_args(str)
	local quotechar
	local i=0
	local args,argn,rest={},1,{}
	while true do
		local found,nexti,arg = string.find(str, '^"(.-)"%s*', i+1)
		if not found then found,nexti,arg = string.find(str, "^'(.-)'%s*", i+1) end
		if not found then found,nexti,arg = string.find(str, "^(%S+)%s*", i+1) end
		if not found then break end
		table.insert(rest, string.sub(str, nexti+1))
		table.insert(args, arg)
		i = nexti
	end
	return args,rest
end

local function get_arg(str, n) 
	return get_args(str)[n]
end

local function chatprint(self, str, noupdate)
	local log = self and self.log or _generalchatlog
	str = tostring(str)
	local loglen = (#log)
	if loglen > 100 then
		table.remove(log, 1)
	end
	table.insert(log, str)
	log.updated = true

	if self then
		if self.chattext then
			if self.scrolledback then
				if loglen > 0 then str = '\n'..str end
				self.chattext.append = str
			else
				self.chattext.value = table.concat(log, "\n")
			end
		end
		if self.update_cb and not noupdate then self:update_cb() end
	end
end

local function chataction(self, ch, str)
	if ch == 13 then -- FIXME: this should be KEY_RETURN after we fix IUP/OnChar/OnKey/blah
		self.value = ""
		if str == "" then ProcessEvent("CHAT_DONE") return iup.DEFAULT end
		table.insert(input_history, 1, str)
		input_history[0] = nil
		input_historyindex = 0
		ProcessEvent("CHAT_DONE")
		if string.byte(str, 1) == iup.K_slash then
			local cmd,rest = get_args(str)
			-- execute this command
			if cmd[1] == "/me" then
				str = substitute_vars(str)
				ProcessEvent("EMOTE_ENTERED", str)
				SendChat(str, self.type)
			elseif cmd[1] =='/clear' then
				ClearGeneralChatLog()
				_generalchatlog = GetGeneralChatLog()
				self.chatcontainer.reset()
				self.chatcontainer.log = _generalchatlog
				self.chatcontainer.chattext.value = ''
			elseif cmd[1] == "/msg" then
				local recipient, message = substitute_vars(cmd[2]), substitute_vars(rest[2])
				if message and message ~= '' then
					SendChat(message, "PRIVATE", recipient)
					ProcessEvent("CHAT_MSG_PRIVATEOUTGOING", {msg=message, name=recipient})
				end
			elseif cmd[1] == "/roper" then
				roper(rest[1])
			elseif cmd[1] == "/oper" then
				oper(rest[1])
			elseif cmd[1] == "/pcc" then -- pcc message
				SendChat(rest[1], "CHANNEL", 50434300)
			elseif cmd[1] == "/help" then -- help message
				SendChat(rest[1], "CHANNEL", 1)
			elseif cmd[1] == "/nation" then -- nation message
				SendChat(rest[1], "CHANNEL", 11)
			elseif cmd[1] == "/rp" then -- rp message
				SendChat(rest[1], "CHANNEL", 300)
			else
				gkinterface.GKProcessCommand(string.sub(str, 2))
			end
		else
			if not self.type then
				local prefix
				if string.sub(self.prefix, 1,1) == '/' then
					prefix = string.sub(self.prefix, 2)
				else
					prefix = self.prefix
				end
				gkinterface.GKProcessCommand(prefix.." "..str)
			else
				ProcessEvent("CHAT_ENTERED", str)
				SendChat(str, self.type, self.channelid)
			end
		end
	elseif ch == iup.K_UP then
		if input_historyindex < (#input_history) then
			input_historyindex = input_historyindex + 1
			self.value = input_history[input_historyindex]
		end
	elseif ch == iup.K_DOWN then
		if input_historyindex > 1 then
			input_historyindex = input_historyindex - 1
			self.value = input_history[input_historyindex]
		else
			input_historyindex = 0
			self.value = input_history[0]
		end
	elseif ch == 27 then -- FIXME
		ProcessEvent("CHAT_CANCELLED")
		self.value = ""
--		self.type = nil
		return iup.IGNORE  -- prevents Esc from calling dialog's defaultesc button
	elseif ch == 9 then -- FIXME
		self.value = tabcomplete(self.value, self.caret)
		input_history[0] = self.value
	elseif ch == iup.K_PGUP then
		self.chatcontainer.chattext.scroll = "PAGEUP"
	elseif ch == iup.K_PGDN then
		self.chatcontainer.chattext.scroll = "PAGEDOWN"
	elseif ch == iup.K_SP and self.setchatmode then
		local startindex, endindex, capture = string.find(str, "^/(%a) ")
		if capture then
			-- switch to specified chat mode
			local keycommand = gkinterface.GetCommandForKeyboardBind(string.byte(capture, 1))
			local newmode
			if keycommand == "say_sector" then
				newmode = 2
			elseif keycommand == "say_channel" then
				newmode = 3
			elseif keycommand == "say_group" then
				newmode = 4
			elseif keycommand == "say_guild" then
				newmode = 5
			elseif keycommand == "say_system" then
				newmode = 6
			end
			if newmode then
				self.value = ""
				self:setchatmode(newmode)
			end
		else
			startindex, endindex, capture = string.find(str, "^/(%d+) ")
			capture = tonumber(capture)
			if capture then
				-- switch to specified channel
				JoinChannel({capture})
				self:setchatmode(3)
				self.value = ""
			end
		end
	else
		input_history[0] = str
	end
	return iup.DEFAULT
end

function ChatLogTemplate(bgcolor, scrolledbgcolor, updatecallback, editbg, clickable)
	local chatentry = iup.text{active="NO", expand="HORIZONTAL", border="NO", boxcolor="0 0 0", font=Font.H5}
	local chattitle, editregion
	if editbg == nil then
		chattitle = iup.label{title="", active="NO", expand="NO", font=Font.H5}
		editregion = iup.hbox{chattitle,chatentry}
	else
		editregion = chatentry
	end
--	local chattext = iup.multiline{size="xFIFTH",active="NO", expand="HORIZONTAL", border="NO", boxcolor="0 0 0", readonly="YES", font=Font.H5}
	local chattext = iup.multiline{active="NO", expand="YES", border="NO", boxcolor="0 0 0", readonly="YES", font=Font.H5}
	if editbg then
		editregion = iup.frame{ editregion,
			image=editbg, segmented="0 0 1 1", expand="YES", bgcolor="255 255 255 255 *",
			}
	end
	local outputregion
	if clickable then
		outputregion = iup.zbox{all="YES", 
			iup.canvas{  -- this control just allows the player to click on the output part to set focus to the editbox.
				-- it has to be after the text control in the zbox so the scrollbars work
				border="NO",
				button_cb = function(self, button, pressed, x, y, status)
					if pressed == 1 then
						iup.SetFocus(chatentry)
					end
				end,
			},
			chattext,
		}
	else
		outputregion = chattext
	end
	local template = iup.vbox{
		outputregion,
		editregion
	}
	local chatcontainer = {}
	chatcontainer.chatentry = chatentry
	chatcontainer.chattitle = chattitle
	chatcontainer.chattext = chattext
	chatcontainer.update_cb = updatecallback
	chatcontainer.vbox = template

	chatentry.action=chataction
	chatentry.chatcontainer = chatcontainer
	local draggingdataobject
	function chatentry:dragenter_cb(dataobject, x, y, keystate, effect)
		if dataobject.text then
			draggingdataobject = dataobject
			return iup.DROP_COPY
		else
			draggingdataobject = nil
			return iup.DROP_NONE
		end
	end
	function chatentry:dragleave_cb()
		draggingdataobject = nil
	end
	function chatentry:dragover_cb(x, y, keystate, effect)
		if draggingdataobject.text then
			return iup.DROP_COPY
		else
			return iup.DROP_NONE
		end
	end
	function chatentry:drop_cb(dataobject, x, y, keystate, effect)
		self.insert = dataobject.text or ""
		return iup.DROP_COPY
	end
	function chattext:caret_cb(r,c)
		if r == 1 then
			chatcontainer.scrolledback = nil
			self.bgcolor = bgcolor
		else
			chatcontainer.scrolledback = true
			self.bgcolor = scrolledbgcolor
		end
	end
	chattext.bgcolor = bgcolor

	function chatcontainer.reset()
		chatcontainer.scrolledback = nil
		chattext.bgcolor = bgcolor
		chattext.scroll = "BOTTOM"
	end

	return chatcontainer
end

function SetChatLogRead()
	_generalchatlog.updated = false
end
function SetMissionLogRead()
	_missionlog.updated = false
end
function SetStationLogRead()
	_stationlog.updated = false
end

function GetChatLogReadState()
	return _generalchatlog.updated ~= true
end
function GetMissionLogReadState()
	return _missionlog.updated ~= true
end
function GetStationLogReadState()
	return _stationlog.updated ~= true
end

function SetChatLogReceiver(chatlog)
	if chatlog and GeneralChatPanel ~= chatlog then
		GeneralChatPanel = chatlog
		chatlog.log = _generalchatlog
		chatlog.chattext.value = table.concat(_generalchatlog, "\n")
		if _generalchatlog.updated and chatlog.update_cb then
			chatlog:update_cb()
		end
	elseif not chatlog then
		GeneralChatPanel = {log=_generalchatlog}
	end
end

function SetMissionLogReceiver(chatlog)
	if chatlog and MissionLogPanel ~= chatlog then
		MissionLogPanel = chatlog
		chatlog.log = _missionlog
		chatlog.chattext.value = table.concat(_missionlog, "\n")
		if _missionlog.updated and chatlog.update_cb then
			chatlog:update_cb()
		end
	end
end

function SetStationLogReceiver(chatlog)
	if not chatlog then
		StationLogPanel = {log=_stationlog}
		return
	end
	if StationLogPanel ~= chatlog then
		StationLogPanel = chatlog
		chatlog.log = _stationlog
		chatlog.chattext.value = table.concat(_stationlog, "\n")
		if _stationlog.updated and chatlog.update_cb then
			chatlog:update_cb()
		end
	end
end

local faction_colors = {
[0]="c4c4c4",
	"6080ff",
	"cf2020",
	"c0c000",
	"ffffff",
	"ffffff",
	"ffffff",
	"ffffff",
	"ffffff",
	"808080",
	"ffffff",
	"ffffff",
	"ffffff",
	"ffffff",
}

--[[
for factionindex=0,13 do
	local color = ShipPalette[ FactionColor[factionindex] ]
	faction_colors[factionindex] = string.format("%02x%02x%02x", math.floor(color:x()*255), math.floor(color:y()*255), math.floor(color:z()*255))
end
--]]

local function colorizename(name, faction)
	if ColorName and faction_colors[faction] then
		return string.format("\127%s%s\127o", faction_colors[faction], name)
	else
		return name
	end
end

local function formatchat(str, args)
	str = string.gsub(str, "<factionname>", tostring(FactionName[args.faction or 0]))
	str = string.gsub(str, "<factionnamefull>", tostring(FactionName[args.faction or 0]))
	str = string.gsub(str, "<location>", tostring(ShortLocationStr(args.location or 0)))
	str = string.gsub(str, "<channelid>", tostring(args.channelid))
	local name = string.gsub(tostring(args.name), "%%", "%%%%")
	str = string.gsub(str, "<name>", tostring(name))
	str = string.gsub(str, "<cname>", tostring(colorizename(name, args.faction)))
	local msg = string.gsub(tostring(args.msg), "%%", "%%%%")
	str = string.gsub(str, "<msg>", msg)
	return str
end

chatinfo = {
	["CHAT_MSG_MOTD"] = {string.char(127).."ffffff"},
	["CHAT_MSG_ERROR"] = {string.char(127).."ffffff"},
	["CHAT_MSG_PRINT"] = {string.char(127).."28b4f0"},
	["CHAT_MSG_SERVER"] = {string.char(127).."ffffff"},
	["CHAT_MSG_CONFIRMATION"] = {string.char(127).."ffffff"},
	["CHAT_MSG_PRIVATE"] = {string.char(127).."ff0000", "filterprivatemsgs"},
	["CHAT_MSG_PRIVATEOUTGOING"] = {string.char(127).."80ff80"},
	["CHAT_MSG_DEATH"] = {string.char(127).."ffffff"},
	["CHAT_MSG_DISABLED"] = {string.char(127).."ffffff"},
	["CHAT_MSG_SERVER_CHANNEL"] = {string.char(127).."0050f0"},
	["CHAT_MSG_SERVER_CHANNEL_ACTIVE"] = {string.char(127).."28b4f0"},
	["CHAT_MSG_CHANNEL_EMOTE"] = {string.char(127).."0050f0", "filterchannelmsgs"},
	["CHAT_MSG_CHANNEL"] = {string.char(127).."0050f0", "filterchannelmsgs"},
	["CHAT_MSG_CHANNEL_EMOTE_ACTIVE"] = {string.char(127).."28b4f0", "filterchannelmsgs"},
	["CHAT_MSG_CHANNEL_ACTIVE"] = {string.char(127).."28b4f0", "filterchannelmsgs"},
	["CHAT_MSG_SERVER_SECTOR"] = {string.char(127).."ffffff"},
	["CHAT_MSG_SECTOR_EMOTE"] = {string.char(127).."00ff00", "filtersectormsgs"},
	["CHAT_MSG_SECTOR"] = {string.char(127).."00ff00", "filtersectormsgs"},
	["CHAT_MSG_GLOBAL_SERVER"] = {string.char(127).."ffffff"},
	["CHAT_MSG_NATION"] = {string.char(127).."40ffff"},
	["CHAT_MSG_SERVER_GUILD"] = {string.char(127).."ffffff"},
	["CHAT_MSG_GUILD_EMOTE"] = {string.char(127).."ffb935", "filterguildmsgs"},
	["CHAT_MSG_GUILD"] = {string.char(127).."ffb935", "filterguildmsgs"},
	["CHAT_MSG_GUILD_MOTD"] = {string.char(127).."ffb935", "filterguildmsgs"},
	["CHAT_MSG_GUIDE"] = {string.char(127).."ffffff"},
	["CHAT_MSG_GROUP"] = {string.char(127).."ffff00", "filtergroupmsgs"},
	["CHAT_MSG_GROUP_NOTIFICATION"] = {string.char(127).."ffff00", "filtergroupmsgs"},
	["CHAT_MSG_SYSTEM"] = {string.char(127).."ff00ff", "filterhelpmsgs"},
	["CHAT_MSG_MISSION"] = {string.char(127).."00ff00"},
	["CHAT_MSG_SECTORD"] = {string.char(127).."00ffff"},
	["CHAT_MSG_SECTORD_SECTOR"] = {string.char(127).."00ffff"},
	["CHAT_MSG_SECTORD_MISSION"] = {string.char(127).."00ff00"},
	["CHAT_MSG_BAR_EMOTE"] = {string.char(127).."ffffff"},
	["CHAT_MSG_BAR"] = {string.char(127).."ffffff"},
	["CHAT_MSG_BAR_EMOTE1"] = {string.char(127).."6080ff"},
	["CHAT_MSG_BAR1"] = {string.char(127).."6080ff"},
	["CHAT_MSG_BAR_EMOTE2"] = {string.char(127).."ff2020"},
	["CHAT_MSG_BAR2"] = {string.char(127).."ff2020"},
	["CHAT_MSG_BAR_EMOTE3"] = {string.char(127).."C0C000"},
	["CHAT_MSG_BAR3"] = {string.char(127).."C0C000"},
	["CHAT_MSG_BARENTER"] = {string.char(127).."ffffff"},
	["CHAT_MSG_BARLEAVE"] = {string.char(127).."ffffff"},
	["CHAT_MSG_BARLIST"] = {string.char(127).."ffffff"},
	["CHAT_MSG_BUDDYNOTE"] = {string.char(127).."80ff80"},
	["CHAT_MSG_INCOMINGBUDDYNOTE"] = {string.char(127).."ff0000"},
}

for k,v in pairs(chatinfo) do v.default = v[1] end

chatinfo.CHAT_MSG_SERVER.formatstring = gkini.ReadString("chatformat", "server", "*** <msg>")
chatinfo.CHAT_MSG_PRIVATE.formatstring = gkini.ReadString("chatformat", "msgincoming", "*<cname>* <msg>")
chatinfo.CHAT_MSG_PRIVATEOUTGOING.formatstring = gkini.ReadString("chatformat", "msgoutgoing", "-><name>: <msg>")
chatinfo.CHAT_MSG_SERVER_CHANNEL.formatstring = gkini.ReadString("chatformat", "serverchannel", "[<channelid>] *** <msg>")
chatinfo.CHAT_MSG_SERVER_CHANNEL_ACTIVE.formatstring = gkini.ReadString("chatformat", "serverchannelactive", "[<channelid>] *** <msg>")
chatinfo.CHAT_MSG_CHANNEL_EMOTE.formatstring = gkini.ReadString("chatformat", "channelemote", "[<channelid>] <cname> <msg>")
chatinfo.CHAT_MSG_CHANNEL.formatstring = gkini.ReadString("chatformat", "channel", "[<channelid>] <<cname>> <msg>")
chatinfo.CHAT_MSG_CHANNEL_EMOTE_ACTIVE.formatstring = gkini.ReadString("chatformat", "activechannelemote", "[<channelid>] <cname> <msg>")
chatinfo.CHAT_MSG_CHANNEL_ACTIVE.formatstring = gkini.ReadString("chatformat", "activechannel", "[<channelid>] <<cname>> <msg>")
chatinfo.CHAT_MSG_SECTOR_EMOTE.formatstring = gkini.ReadString("chatformat", "sectoremote", "<cname> <msg>")
chatinfo.CHAT_MSG_SECTOR.formatstring = gkini.ReadString("chatformat", "sector", "<<cname>> <msg>")
chatinfo.CHAT_MSG_GLOBAL_SERVER.formatstring = gkini.ReadString("chatformat", "globalserver", "*** <msg>")
chatinfo.CHAT_MSG_NATION.formatstring = gkini.ReadString("chatformat", "nation", "*** <msg>")
chatinfo.CHAT_MSG_SERVER_GUILD.formatstring = gkini.ReadString("chatformat", "guildserver", "(guild) <msg>")
chatinfo.CHAT_MSG_GUILD_EMOTE.formatstring = gkini.ReadString("chatformat", "guildemote", "(guild) [<location>] <cname> <msg>")
chatinfo.CHAT_MSG_GUILD.formatstring = gkini.ReadString("chatformat", "guild", "(guild) [<location>] <<cname>> <msg>")
chatinfo.CHAT_MSG_GUILD_MOTD.formatstring = gkini.ReadString("chatformat", "guildmotd", "[Guild MOTD] <msg>")
chatinfo.CHAT_MSG_GUIDE.formatstring = gkini.ReadString("chatformat", "guide", "*<name>* <msg>")
chatinfo.CHAT_MSG_GROUP.formatstring = gkini.ReadString("chatformat", "group", "(group) [<location>] <<cname>> <msg>")
chatinfo.CHAT_MSG_GROUP_NOTIFICATION.formatstring = gkini.ReadString("chatformat", "group", "(group) <msg>")
chatinfo.CHAT_MSG_SYSTEM.formatstring = gkini.ReadString("chatformat", "help", "[<location>] <<cname>> <msg>")
chatinfo.CHAT_MSG_BAR.formatstring = gkini.ReadString("chatformat", "bar", "<<cname>> <msg>")
chatinfo.CHAT_MSG_BAR_EMOTE.formatstring = gkini.ReadString("chatformat", "baremote", "<cname> <msg>")
chatinfo.CHAT_MSG_BAR1.formatstring = gkini.ReadString("chatformat", "bar1", chatinfo.CHAT_MSG_BAR.formatstring)
chatinfo.CHAT_MSG_BAR2.formatstring = gkini.ReadString("chatformat", "bar2", chatinfo.CHAT_MSG_BAR.formatstring)
chatinfo.CHAT_MSG_BAR3.formatstring = gkini.ReadString("chatformat", "bar3", chatinfo.CHAT_MSG_BAR.formatstring)
chatinfo.CHAT_MSG_BAR_EMOTE1.formatstring = gkini.ReadString("chatformat", "baremote1", chatinfo.CHAT_MSG_BAR_EMOTE.formatstring)
chatinfo.CHAT_MSG_BAR_EMOTE2.formatstring = gkini.ReadString("chatformat", "baremote2", chatinfo.CHAT_MSG_BAR_EMOTE.formatstring)
chatinfo.CHAT_MSG_BAR_EMOTE3.formatstring = gkini.ReadString("chatformat", "baremote3", chatinfo.CHAT_MSG_BAR_EMOTE.formatstring)
chatinfo.CHAT_MSG_BUDDYNOTE.formatstring = gkini.ReadString("chatformat", "outgoingbuddynote", "-><name>: <msg>")
chatinfo.CHAT_MSG_INCOMINGBUDDYNOTE.formatstring = gkini.ReadString("chatformat", "incomingbuddynote", "[Note from <name>] <msg>")

chatinfo.CHAT_MSG_BUDDYNOTE[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.buddynote", "80ff80")
chatinfo.CHAT_MSG_INCOMINGBUDDYNOTE[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.incomingbuddynote", "ff0000")
chatinfo.CHAT_MSG_PRIVATEOUTGOING[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.msgoutgoing", "80ff80")
chatinfo.CHAT_MSG_PRIVATE[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.msgincoming", "ff0000")
chatinfo.CHAT_MSG_BARLIST[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.barlist", "ffffff")
chatinfo.CHAT_MSG_BARENTER[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.barenter", "ffffff")
chatinfo.CHAT_MSG_BARLEAVE[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.barleave", "ffffff")
chatinfo.CHAT_MSG_BAR[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.bar", "ffffff")
local bar1color = gkini.ReadString("colors", "chatcolors.bar1", "6080ff")
chatinfo.CHAT_MSG_BAR1[1] = string.char(127)..bar1color
chatinfo.CHAT_MSG_BAR_EMOTE1[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.baremote1", bar1color)
local bar2color = gkini.ReadString("colors", "chatcolors.bar2", "ff2020")
chatinfo.CHAT_MSG_BAR2[1] = string.char(127)..bar2color
chatinfo.CHAT_MSG_BAR_EMOTE2[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.baremote2", bar2color)
local bar3color = gkini.ReadString("colors", "chatcolors.bar3", "C0C000")
chatinfo.CHAT_MSG_BAR3[1] = string.char(127)..bar3color
chatinfo.CHAT_MSG_BAR_EMOTE3[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.baremote3", bar3color)
local sectorcolor = gkini.ReadString("colors", "chatcolors.sector", "00ff00")
chatinfo.CHAT_MSG_SECTOR[1] = string.char(127)..sectorcolor
chatinfo.CHAT_MSG_SECTOR_EMOTE[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.sectoremote", sectorcolor)
chatinfo.CHAT_MSG_MISSION[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.mission", "00ff00")
chatinfo.CHAT_MSG_SECTORD_MISSION[1] = chatinfo.CHAT_MSG_MISSION[1]
chatinfo.CHAT_MSG_GUILD[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.guild", "ffb935")
chatinfo.CHAT_MSG_GUILD_EMOTE[1] = chatinfo.CHAT_MSG_GUILD[1]
chatinfo.CHAT_MSG_GUIDE[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.guide", "ffffff")
chatinfo.CHAT_MSG_GROUP[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.group", "ffff00")
chatinfo.CHAT_MSG_GROUP_NOTIFICATION[1] = chatinfo.CHAT_MSG_GROUP[1]
chatinfo.CHAT_MSG_SYSTEM[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.system", "ff00ff")
chatinfo.CHAT_MSG_SECTORD[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.sd", "00ffff")
chatinfo.CHAT_MSG_CHANNEL_ACTIVE[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.activechannel", "28b4f0")
chatinfo.CHAT_MSG_CHANNEL_EMOTE_ACTIVE[1] = chatinfo.CHAT_MSG_CHANNEL_ACTIVE[1]
chatinfo.CHAT_MSG_CHANNEL[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.inactivechannel", "0050f0")
chatinfo.CHAT_MSG_CHANNEL_EMOTE[1] = chatinfo.CHAT_MSG_CHANNEL[1]
chatinfo.CHAT_MSG_NATION[1] = string.char(127)..gkini.ReadString("colors", "chatcolors.nation", "40ffff")


chatreceiver = {}

for key,_ in pairs(chatinfo) do
	RegisterEvent(chatreceiver, key)
end
RegisterEvent(chatreceiver, "LOGIN_SUCCESSFUL")

function log_chat(string)
	log_print('['..os.date()..'] '..string)
end

function chatreceiver:OnEvent(eventname, ...)
	if eventname == "LOGIN_SUCCESSFUL" then
		ClearGeneralChatLog()
		ClearMissionChatLog()
		ClearStationChatLog()
		_generalchatlog = GetGeneralChatLog()
		_missionlog = GetMissionChatLog()
		_stationlog = GetStationChatLog()
		GeneralChatPanel = {log=_generalchatlog}
		MissionLogPanel = {log=_missionlog}
		StationLogPanel = {log=_stationlog}
	else
		local msginfo = ...
		local checkfiltername = chatinfo[eventname][2]
		if checkfiltername then
			if Game.GetCVar(checkfiltername) == 0 then
				return
			end
		end
		if eventname == "CHAT_MSG_BAR" or eventname == "CHAT_MSG_BAR_EMOTE" then
			if msginfo.faction then
				local neweventname = eventname..msginfo.faction
				if chatinfo[neweventname] then
					eventname = neweventname
				end
			end
		end
		local printstr = tostring(chatinfo[eventname][1])..(chatinfo[eventname].formatstring and formatchat(chatinfo[eventname].formatstring, msginfo) or tostring(msginfo.msg))
		if eventname == "CHAT_MSG_MISSION" or eventname == "CHAT_MSG_SECTORD_MISSION" then
			if (msginfo.missionid or 0) == 0 then
				chatprint(MissionLogPanel, printstr)
				HUD:PrintSecondaryMissionMsg(printstr)
				log_chat(printstr)
			end
			return
		elseif string.sub(eventname, 1, 12) == "CHAT_MSG_BAR" then
			chatprint(StationLogPanel, printstr, eventname == "CHAT_MSG_BARLEAVE")
			log_chat(printstr)
			return
		end
		chatprint(GeneralChatPanel, printstr)
		log_chat(printstr)
	end
end

print = function(printstr) printstr = tostring(printstr) log_print(printstr) chatprint(GeneralChatPanel, printstr) end

function purchaseprint(str)
	ProcessEvent("CHAT_MSG_CONFIRMATION", {msg=tostring(str)})
end

function sectorprint(str)
	ProcessEvent("CHAT_MSG_SERVER_SECTOR", {msg=tostring(str)})
end

function generalprint(str)
	ProcessEvent("CHAT_MSG_PRINT", {msg=tostring(str)})
end


local function CreateMaximizedChatLog(maximizebuttontext)
	local chatarea, dlg
	chatarea = chatareatemplate2(true, maximizebuttontext)
	dlg = iup.dialog{
		iup.hbox{ margin="4x4",
			iup.pdarootframe{
				chatarea,
			}
		},
		fullscreen="YES",
		bgcolor="0 0 0 0 +",
	}
	function dlg:k_any(ch)
		local keycommand = gkinterface.GetCommandForKeyboardBind(ch)
		if keycommand == "say_sector" then
			chatarea:set_chatmode(2)
		elseif keycommand == "say_channel" then
			chatarea:set_chatmode(3)
		elseif keycommand == "say_group" then
			chatarea:set_chatmode(4)
		elseif keycommand == "say_guild" then
			chatarea:set_chatmode(5)
		elseif keycommand == "say_system" then
			chatarea:set_chatmode(6)
		end
		return iup.CONTINUE
	end

	function dlg:show_cb()
		chatarea:OnShow()
	end

	function dlg:hide_cb()
		chatarea:OnHide()
	end

	dlg:map()

	return dlg
end

MaximizedSpaceChat = CreateMaximizedChatLog()
MaximizedStationChat = CreateMaximizedChatLog()
MaximizedCapShipChat = CreateMaximizedChatLog()
MaximizedGunnerWaitChat = CreateMaximizedChatLog("Leave Ship")
function MaximizedGunnerWaitChat:OnMaximize()
	QuestionDialog:SetMessage("Are you sure you want to leave the ship?",
		"Yes", function() Gunner.Leave() HideDialog(QuestionDialog) end,
		"No", function() HideDialog(QuestionDialog) end,
		"ACENTER")
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end
function MaximizedGunnerWaitChat:OnEvent(eventname, ...)
	if eventname == "WAITING_FOR_CAPSHIP_LAUNCH" then
		HideAllDialogs()
		HideDialog(HUD.dlg)
		ShowDialog(self)
	elseif (eventname == "GUNNER_KICKED") or (eventname == "GUNNER_LEFT") then
		HideDialog(self)
		HideDialog(QuestionDialog)
	end
end
RegisterEvent(MaximizedGunnerWaitChat, "GUNNER_KICKED")
RegisterEvent(MaximizedGunnerWaitChat, "GUNNER_LEFT")
RegisterEvent(MaximizedGunnerWaitChat, "WAITING_FOR_CAPSHIP_LAUNCH")




--[[
[chatformat]
server=*** <msg>
msgincoming=*<cname>* <msg>
msgoutgoing=-><name>: <msg>
serverchannel=*** <msg>
serverchannelactive=*** <msg>
channelemote=[<channelid>] <cname> <msg>
channel=[<channelid>] <<cname>> <msg>
activechannelemote=[<channelid>] <cname> <msg>
activechannel=[<channelid>] <<cname>> <msg>
sectoremote=<cname> <msg>
sector=<<cname>> <msg>
globalserver=*** <msg>
nation=*** <msg>
guildserver=(guild) <msg>
guildemote=(guild) [<location>] <cname> <msg>
guild=(guild) [<location>] <<cname>> <msg>
guildmotd=[Guild MOTD] <msg>
guide=*<name>* <msg>
group=(group) [<location>] <<cname>> <msg>
group_notification=(group) [<location>] <msg>
help=[<location>] <<cname>> <msg>
bar=<<cname>> <msg>
bar1=<<cname>> <msg>
bar2=<<cname>> <msg>
bar3=<<cname>> <msg>
baremote=<cname> <msg>
baremote1=<cname> <msg>
baremote2=<cname> <msg>
baremote3=<cname> <msg>
outgoingbuddynote=-><name>: <msg>


[colors]
chatcolors.buddynote=80ff80
chatcolors.msgoutgoing=80ff80
chatcolors.msgincoming=ff0000
chatcolors.barlist=ffffff
chatcolors.barenter=ffffff
chatcolors.barleave=ffffff
chatcolors.bar=ffffff
chatcolors.bar1=6080ff
chatcolors.bar2=ff2020
chatcolors.bar3=C0C000
chatcolors.sector=00ff00
chatcolors.mission=00ff00
chatcolors.guild=ffb935
chatcolors.nation=40ffff
chatcolors.guide=ffffff
chatcolors.group=ffff00
chatcolors.system=ff00ff
chatcolors.sd=00ffff
chatcolors.activechannel=28b4f0
chatcolors.inactivechannel=0050f0

]]--

