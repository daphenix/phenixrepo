-- HUD group element and update code
local GROUP_OWNER_COLOR = "255 255 255"
local GROUP_MEMBER_COLOR = "192 192 192"

function HUD:CreateGroupArea()
	self.groupinfo = iup.vbox{gap=5, expand="YES"}
	self.groupinfoframe = iup.hudrightframe{self.groupinfo, expand="HORIZONTAL", size="100"}
end

local function makegroupmembercontainer(memberid)
	local name = GetPlayerName(memberid)
	local health = GetPlayerHealth(memberid)  -- Note: GetPlayerHealth() returns 2 values, health and shieldstrength
	local location = GetGroupMemberLocation(memberid)
	local memberhealth = iup.stationprogressbar{visible=((health>=0) and "YES" or "NO"), active="NO",size="x12",expand="HORIZONTAL",title=""}
	memberhealth.minvalue = 0
	memberhealth.maxvalue = 100
	memberhealth.uppercolor = "128 128 128 128 *"
	memberhealth.lowercolor = "64 255 64 128 *"
	memberhealth.lowercolor = calc_health_color(health/100, 128)
	memberhealth.value = health
	local locationstr = iup.label{title=((location > 0) and ShortLocationStr(location) or ""),size="x12",expand="HORIZONTAL", font=Font.H4*font_HUD_SCALE, align="ACENTER", visible=((health<0) and "YES" or "NO"), }
	local speechicon = iup.label{title="", image=VoiceChat.IsPlayerMuted(memberid) and "images/no.png" or "images/vc_speak.png", bgcolor="255 255 255 255 &", visible=(VoiceChat.IsPlayerTalking(memberid) or VoiceChat.IsPlayerMuted(memberid)) and "YES" or "NO", size=(Font.H4*font_HUD_SCALE).."x"..(Font.H4*font_HUD_SCALE)}
	local listenicon -- = iup.label{title="", image=IMAGE_DIR.."vc_listen.png", bgcolor="255 255 255 255 &", visible=VoiceChat.IsPlayerListening(memberid) and "YES" or "NO", size=(Font.H4*font_HUD_SCALE).."x"..(Font.H4*font_HUD_SCALE)}
	local membername = iup.label{title=name, fgcolor=GROUP_MEMBER_COLOR, font=Font.H4*font_HUD_SCALE}
	local memberdata = 
		iup.vbox{
			iup.hbox{speechicon,iup.fill{size="2"},membername},
--			iup.hbox{iup.zbox{all="YES", speechicon, listenicon},membername},
			iup.zbox{all="YES",memberhealth,locationstr},
		}
	return {container=memberdata, healthbar=memberhealth, name=membername, location=locationstr, listenicon=listenicon, speechicon=speechicon}
end

function HUD:CreateGroupList()
	local container
	local memberid
	local n = GetNumGroupMembers()
	if n == 0 then return end

	self.groupdisplay = {}

	local groupownerid = GetGroupOwnerID()
	-- add members
	for index=1,n do
		memberid = GetGroupMemberID(index)
		container = makegroupmembercontainer(memberid)
		if memberid == GetCharacterID() then
			container.healthbar.visible = "YES"
			container.location.visible = "NO"
		end
		self.groupinfo:append(container.container)
		self.groupdisplay[memberid] = container
		if memberid == groupownerid then
			container.name.fgcolor = GROUP_OWNER_COLOR
		end
	end
	self.dlg:map()
	iup.Refresh(self.dlg)
end

function HUD:DestroyGroupList()
	if self.groupdisplay then
		for charid,data in pairs(self.groupdisplay) do
			data.container:detach()
			data.container:destroy()
		end
		self.dlg:map()
		iup.Refresh(self.dlg)
		self.groupdisplay = nil
	end
end

function HUD:ShowGroupList()
	self.group_list_visible = true
	self.groupinfoframe.visible = self.visibility.groupinfo
	self.selfinfoframe.visible = "NO"
end

function HUD:UpdateGroupList()
	self:DestroyGroupList()
	self:CreateGroupList()
	self:UpdateHUDvisibility()
end

function HUD:ResetGroupList()
	if self.groupdisplay then
		for charid,data in pairs(self.groupdisplay) do
			data.healthbar.value = 0
			data.healthbar.visible = "NO"
			data.location.visible = "NO"
		end
	end
end

function HUD:HideGroupList()
	self.group_list_visible = false
	self.groupinfoframe.visible = "NO"
	self.selfinfoframe.visible = self.visibility.selfinfo
end

function HUD:ToggleGroupList()
	if GetNumGroupMembers() > 0 then
		if self.group_list_visible then
			self:HideGroupList()
		else
			self:ShowGroupList()
		end
	end
end

function HUD:UpdateGroupOwner()
	if self.groupdisplay then
		local groupowner = GetGroupOwnerID()
		for charid,data in pairs(self.groupdisplay) do
			if charid == groupowner then
				data.name.fgcolor = GROUP_OWNER_COLOR
			else
				data.name.fgcolor = GROUP_MEMBER_COLOR
			end
		end
	end
end

function HUD:UpdateGroupMemberInfo(charid)
	local data = self.groupdisplay and self.groupdisplay[charid]
	if data then
		data.name.title = GetPlayerName(charid)
	end
end

function HUD:UpdateGroupMemberHealth(charid, healthpercent, shieldstrength) -- percent as 0-100 or -1 if unknown
	if self.groupdisplay then
		local data = self.groupdisplay[charid]
		if data then
			if healthpercent and (healthpercent >= 0) then
				data.healthbar.value = healthpercent
				data.healthbar.lowercolor = calc_health_color(healthpercent/100, 128)
				data.healthbar.visible = "YES"
				data.location.visible = "NO"
			else
				data.healthbar.value = 0
				data.healthbar.visible = "NO"
				data.location.title = ShortLocationStr(GetGroupMemberLocation(charid))
				data.location.visible = "YES"
				self.dlg.size = nil
			end
		end
	end
end

function HUD:SetGroupMemberTalkStatus(charid, status)
	if self.groupdisplay then
		local data = self.groupdisplay[charid]
		if data then
			data.speechicon.visible = (status or VoiceChat.IsPlayerMuted(charid)) and "YES" or "NO"
		end
	end
end

function HUD:SetGroupMemberMuteStatus(charid, status)
	if self.groupdisplay then
		local data = self.groupdisplay[charid]
		if data then
			data.speechicon.image = status and "images/no.png" or "images/vc_speak.png"
			data.speechicon.visible = (status or VoiceChat.IsPlayerTalking(charid)) and "YES" or "NO"
		end
	end
end

function HUD:SetGroupMemberListenStatus(charid, status)
--[[
	if self.groupdisplay then
		local data = self.groupdisplay[charid]
		if data then
			data.listenicon.visible = status and "YES" or "NO"
		end
	end
--]]
end
