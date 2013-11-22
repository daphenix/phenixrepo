-- HUD chat code

local function incomingchat_cb(self)
	self.log.updated = false
end

local chattypes = {
	["SAY"]="CHAT_MSG_SECTOR",
	["SECTOR"]="CHAT_MSG_SECTOR",
	["CHANNEL"]="CHAT_MSG_CHANNEL_ACTIVE",
	["GROUP"]="CHAT_MSG_GROUP",
	["GUILD"]="CHAT_MSG_GUILD",
	["SYSTEM"]="CHAT_MSG_SYSTEM",
}

local function chattype_colors(index)
	if index and chattypes[index] and chatinfo[chattypes[index]] then
		local cstr = chatinfo[chattypes[index]][1]
		return hextorgb(cstr:gsub("\127", ""))
	else
		return 1
	end
end

function HUD:CreateChatArea()
	self.chatcontainer = ChatLogTemplate("0 0 0 0 +", "100 0 0 178 *", incomingchat_cb)
	self.chatcontainer.chattext.size = nil -- "xSIXTH"
	self.chatcontainer.chattext.indent = "YES"
	self.chatcontainer.chattext.expand = "YES"
	self.chatcontainer.chattext.scrollbarstyle = "1"
	self.chatcontainer.chattext.SCROLLBARWIDTH = "8"
	self.chatcontainer.chattext.IMAGESCROLLTHUMB = IMAGE_DIR.."hud_chat_scroller.png"
	self.chatcontainer.chattext.IMAGESCROLLBACKGROUND = IMAGE_DIR.."hud_chat_scroller_bg.png"
	self.chatcontainer.chattext.font=Font.H4*font_HUD_SCALE
	self.chatcontainer.chatentry.font=Font.H4*font_HUD_SCALE
	self.chatcontainer.chattitle.font=Font.H4*font_HUD_SCALE
	self.missionlogcontainer = ChatLogTemplate("0 0 0 0 +", "100 0 0 178 *", incomingchat_cb)
	self.missionlogcontainer.chattext.size = nil -- "xSIXTH"
	self.missionlogcontainer.chattext.expand = "YES"
	self.missionlogcontainer.chattext.scrollbarstyle = "1"
	self.missionlogcontainer.chattext.SCROLLBARWIDTH = "8"
	self.missionlogcontainer.chattext.IMAGESCROLLTHUMB = IMAGE_DIR.."hud_chat_scroller.png"
	self.missionlogcontainer.chattext.IMAGESCROLLBACKGROUND = IMAGE_DIR.."hud_chat_scroller_bg.png"
	self.missionlogcontainer.chattext.font=Font.H4*font_HUD_SCALE
	self.missionlogcontainer.chatentry.font=Font.H4*font_HUD_SCALE
	function self.chatcontainer.chatentry.setchatmode(_self, mode)
		-- modes: 2=sector, 3=channel, 4=group, 5=guild, 6=system
		if mode == 2 then
			self:ShowGeneralChatEdit("Sector:", "SECTOR")
		elseif mode == 3 then
			self:ShowGeneralChatEdit("Channel:", "CHANNEL")
		elseif mode == 4 then
			self:ShowGeneralChatEdit("Group:", "GROUP")
		elseif mode == 5 then
			self:ShowGeneralChatEdit("Guild:", "GUILD")
		elseif mode == 6 then
			self:ShowGeneralChatEdit("System:", "SYSTEM")
		end
	end
	self.chatframe = iup.vbox{
		iup.hudchatframe{iup.zbox{self.chatcontainer.vbox,self.missionlogcontainer.vbox}, expand="YES",},
--		gap="-6",
		size=HUDSize(nil, .2),
		active="NO",
		expand="HORIZONTAL",
	}
end

function HUD:cancel_chat()
	if self.chatcontainer then
		self.chatcontainer.chatentry.visible = "NO"
		self.chatcontainer.chatentry.active = "NO"
		self.chatcontainer.chattitle.title = ""
	end
	if self.missionlogcontainer then
		self.missionlogcontainer.chatentry.visible = "NO"
		self.missionlogcontainer.chatentry.active = "NO"
		self.missionlogcontainer.chattitle.title = ""
	end
	if (self.IsVisible or self.dlg.visible == "YES") and
		PDADialog.visible ~= "YES" and
		StationDialog.visible ~= "YES" and
		CapShipDialog.visible ~= "YES" and
		CapShipShiplessDialog.visible ~= "YES" and
		MaximizedSpaceChat.visible ~= "YES" then
		gkinterface.HideMouse()
		Game.SetInputMode(1)
	end
end

function HUD:ShowGeneralChatEdit(title, chattype, channelid)
	if self.chatcontainer then
		self.chatcontainer.chatentry.value = ""
		self.chatcontainer.chatentry.visible = "YES"
		self.chatcontainer.chatentry.active = "YES"
		self.chatcontainer.chatentry.type = chattype
		self.chatcontainer.chatentry.prefix = title
		self.chatcontainer.chatentry.channelid = channelid
		self.chatcontainer.chattitle.title = title
		self.chatcontainer.chattitle.fgcolor = ColorChatInput and chattype_colors(chattype) or "255 255 255"
		self.dlg.size = nil
		iup.SetFocus(self.chatcontainer.chatentry)
		
		if gkinterface.IsTouchModeEnabled() then
			OpenVirtualKeyboard(self.chatcontainer.chatentry)
		end
	end
end

function HUD:PrintSecondaryMissionMsg(msg)
	if self.dlg.visible == "YES" then
		self:PrintSecondaryMsg(msg)
	end
end
local hudlabelcache = {}
function HUD:PrintSecondaryMsg(msg)
	local newlabel = table.remove(hudlabelcache)
	if newlabel then
		newlabel.title = msg
	else
		newlabel = iup.label{title=msg, WORDWRAP="YES", size="1x", expand="HORIZONTAL", font=Font.H4*font_HUD_SCALE}
	end
	table.insert(self.secondarychatarealines, newlabel)
	iup.Append(self.secondarychatarea, newlabel)
	FadeControl(newlabel, 5, 5, 0, function()
			newlabel:detach()
			table.insert(hudlabelcache, newlabel)
			table.remove(self.secondarychatarealines, 1) -- first one is always the oldest one
			iup.ShowXY(self.secondarychatarea, 0, 0)
		end)
--	iup.ShowXY(self.layer3_other1, 0, 0)
	self.dlg:map()
	iup.Refresh(self.dlg)
	newlabel.visible = "YES"
end
