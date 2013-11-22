local title_text, alignment_text
local list1, list2, accombox
local list1_title, list2_title, accomplishment_title
local closebutton
local givemoneybutton, msgbutton, ignorebutton, groupinvitebutton, guildinvitebutton, duelbutton, duel2button, buddyinvitebutton
local playername, playerid

local confirmationdlg = msgpromptdlgtemplate2()

closebutton = iup.stationbutton{title="Close",
	action=function()
		HideDialog(CharInfoMenu)
		ShowDialog(HUD.dlg)
	end
}

givemoneybutton = iup.stationbutton{title="Give Money",
	action=function()
		if not playername then return end
		confirmationdlg:SetString("")
		confirmationdlg:SetMessage("How many credits do you want to give to "..playername.."?",
			"Give", function()
					local amount = tonumber(confirmationdlg:GetString()) or 0
					if amount > 0 then
						HideDialog(confirmationdlg)
						GiveMoney(playername, amount)
						HideDialog(CharInfoMenu)
						ShowDialog(HUD.dlg)
					else
						-- error message/sound or something.
						HideDialog(confirmationdlg)
						ShowDialog(InvalidAmountDialog, iup.CENTER, iup.CENTER)
					end
				end,
			"Cancel", function()
					HideDialog(confirmationdlg)
				end)
		ShowDialog(confirmationdlg, iup.CENTER, iup.CENTER)
	end
}

msgbutton = iup.stationbutton{title="Message",
	action=function()
		if not playername then return end

		confirmationdlg:SetString("")
		confirmationdlg:SetMessage("Type in a message to send to "..playername..".",
			"Send", function()
					local message = confirmationdlg:GetString()
					if message and message ~= "" then
						HideDialog(confirmationdlg)
						SendChat(message, "PRIVATE", playername)
						ProcessEvent("CHAT_MSG_PRIVATEOUTGOING", {msg=message, name=playername})
						HideDialog(CharInfoMenu)
						ShowDialog(HUD.dlg)
					else
						-- error message/sound or something.
					end
				end,
			"Cancel", function()
					HideDialog(confirmationdlg)
				end)
		ShowDialog(confirmationdlg, iup.CENTER, iup.CENTER)
	end
}

ignorebutton = iup.stationbutton{title="Ignore",
	action=function(self)
		if not playername then return end
		local actionstr
		local yes_callback
		if self.title == "Ignore" then
			actionstr = "ignore"
			yes_callback = function()
				Ignore.Ignore(playername)
				HideDialog(QuestionDialog)
				HideDialog(CharInfoMenu)
				ShowDialog(HUD.dlg)
				end
		else
			actionstr = "unignore"
			yes_callback = function()
				Ignore.Unignore(playername)
				HideDialog(QuestionDialog)
				HideDialog(CharInfoMenu)
				ShowDialog(HUD.dlg)
				end
		end
		QuestionDialog:SetMessage("Are you sure you want to "..actionstr.." "..playername.."?",
			"Yes", yes_callback,
			"No", function() HideDialog(QuestionDialog) end)
		ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
	end
}

guildinvitebutton = iup.stationbutton{title="Guild Invite",
	action=function(self)
		if not playername then return end
		local yes_callback = function()
				Guild.invite(playername)
				HideDialog(QuestionDialog)
				HideDialog(CharInfoMenu)
				ShowDialog(HUD.dlg)
			end
		QuestionDialog:SetMessage("Are you sure you want to invite "..playername.." to be in your guild?",
			"Yes", yes_callback,
			"No", function() HideDialog(QuestionDialog) end)
		ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
	end
}

local function groupinviteaction(self)
	if not playername then return end
	local yes_callback = function()
			Group.Invite(playername)
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Are you sure you want to invite "..playername.." to be in your group?",
		"Yes", yes_callback,
		"No", function() HideDialog(QuestionDialog) end)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

local function groupjoinaction(self)
	if not playername then return end
	local yes_callback = function()
			Group.Join(playername)
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Do you want to join "..playername.."'s group?",
		"Yes", yes_callback,
		"No", function() HideDialog(QuestionDialog) end)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

local function groupleaveaction(self)
	if not playername then return end
	local yes_callback = function()
			Group.Leave()
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Are you sure you want to leave the group?",
		"Yes", yes_callback,
		"No", function() HideDialog(QuestionDialog) end)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

groupinvitebutton = iup.stationbutton{title="Group Invite",
	action=groupinviteaction,
}

local function buddy_invite_action(self)
	if not playername then return end
	local yes_callback = function()
			Buddy.invite(playername)
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Are you sure you want to invite "..playername.." to be your buddy?",
		"Yes", yes_callback,
		"No", function() HideDialog(QuestionDialog) end)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

local function buddy_accept_action(self)
	if not playername then return end
	local yes_callback = function()
			Buddy.accept(playername)
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	local no_callback = function()
			Buddy.decline(playername)
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Press 'Accept' to accept "..playername.."'s request to be your buddy.",
		"Accept", yes_callback,
		"Decline", no_callback)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

local function buddy_remove_action(self)
	if not playername then return end
	local yes_callback = function()
			Buddy.remove(playername)
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Are you sure you want to stop being a buddy of "..playername.."?",
		"Yes", yes_callback,
		"No", function() HideDialog(QuestionDialog) end)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

buddyinvitebutton = iup.stationbutton{title="Buddy Invite",
	action=buddy_invite_action
}

local function duel_challenge_action(self)
	if not playername then return end
	local yes_callback = function()
			Duel.challenge(GetCharacterIDByName(playername))
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Are you sure you want to challenge "..playername.." to a duel?",
		"Yes", yes_callback,
		"No", function() HideDialog(QuestionDialog) end)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

local function duel_accept_action(self)
	if (not playername) or (not playerid) then return end
	local yes_callback = function()
			Duel.accept(playerid)
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	local no_callback = function()
			Duel.decline(playerid)
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Press 'Accept' to accept "..playername.."'s challenge to a duel.",
		"Accept", yes_callback,
		"Decline", no_callback)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end


local function duel_abort_action(self)
	if (not playername) or (not IsInDuel()) then return end
	local yes_callback = function()
			Duel.abort()
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Are you sure you want to request "..playername.." to abort?",
		"Yes", yes_callback,
		"No", function() HideDialog(QuestionDialog) end)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

local function duel_forfeit_action(self)
	if (not IsInDuel()) then return end
	local yes_callback = function()
			Duel.forfeit()
			HideDialog(QuestionDialog)
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		end
	QuestionDialog:SetMessage("Are you sure you want to forfeit the duel?",
		"Yes", yes_callback,
		"No", function() HideDialog(QuestionDialog) end)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

duelbutton = iup.stationbutton{title="Duel Challenge",
	action=duel_challenge_action
}

duel2button = iup.stationbutton{title="Abort Duel",
	action=duel_abort_action
}


title_text = iup.label{font=Font.Big,title="Information for ", expand="HORIZONTAL"}
alignment_text = iup.label{font=Font.H1,title="Alignment: ", expand="HORIZONTAL"}
list1 = iup.stationhighopacitysubmultiline{readonly="YES", expand="YES"}
list2 = FactionStandingTemplate(nil, iup.stationhighopacitysubframe, iup.stationhighopacityframebgfiller, "VERTICAL") -- iup.stationsubmultiline{readonly="YES", expand="YES"}
list1_title = iup.label{title="Statistics:", expand="HORIZONTAL"}
list2_title = iup.label{title="Faction Standings:", expand="HORIZONTAL"}
accomplishment_title = iup.label{title="Accomplishments:", expand="HORIZONTAL"}


accombox = AccomplishmentTemplate()

CharInfoMenu = iup.dialog{
	iup.hbox{
		margin="10x10",
		iup.stationhighopacityframe{
			iup.vbox{
				iup.stationhighopacityframebg{
					iup.vbox{
						title_text,
						alignment_text,
					},
				},
				iup.hbox{
					iup.vbox{iup.stationhighopacityframebg{iup.vbox{list1_title,expand="HORIZONTAL"}}, list1, iup.stationhighopacityframebg{iup.vbox{accomplishment_title, accombox, expand="YES"}}, expand="YES"},
					iup.vbox{iup.stationhighopacityframebg{iup.vbox{list2_title,expand="HORIZONTAL"}}, list2, expand="VERTICAL"},
				},
				iup.stationhighopacityframebg{
					iup.vbox{
						iup.hbox{
	givemoneybutton, msgbutton, ignorebutton, groupinvitebutton,
							iup.fill{},
							gap = 5,
						},
						iup.hbox{
	guildinvitebutton, buddyinvitebutton, duelbutton, duel2button,
							iup.fill{},
							closebutton,
							gap = 5,
						},
						gap = 5,
					},
				},
			},
		},
	},
	bgcolor="0 0 0 0 *",
	defaultesc = closebutton,
	fullscreen="YES",
--	size="800x600",
	border="NO",
	menubox="NO",
	resize="NO",
}

function CharInfoMenu:k_any(ch)
	if gkinterface.GetCommandForKeyboardBind(ch) == "CharInfo" then
		HideDialog(CharInfoMenu)
		ShowDialog(HUD.dlg)
		return iup.IGNORE
	end
	return iup.CONTINUE
end

local requestedcharid

function CharInfoMenu:Clear()
	playername = nil
	playerid = nil
	requestedcharid = RequestTargetStats()
	title_text.title = "Requesting information..."
	alignment_text.title = ""
	list1.value = ""
	list1_title.visible = "NO"
	list2:HideAll()
	list2_title.visible = "NO"
	accomplishment_title.visible = "NO"
	accombox:ClearAccomplishments()
	givemoneybutton.visible = "NO"
	msgbutton.visible = "NO"
	ignorebutton.visible = "NO"
	groupinvitebutton.visible = "NO"
	guildinvitebutton.visible = "NO"
	buddyinvitebutton.visible = "NO"
	duelbutton.visible = "NO"
	duel2button.visible = "NO"
	return requestedcharid
end

function FillInPlayerInfo(charid)
	local guildtag = GetGuildTag(charid)
	playername = GetPlayerName(charid)
	playerid = charid
	if guildtag ~= "" then
		title_text.title = "Information for ["..guildtag.."] "..playername
	else
		title_text.title = "Information for "..playername
	end
	alignment_text.title = "Alignment: "..(FactionNameFull[GetPlayerFaction(charid)] or "Unknown")
	list1_title.visible = "YES"
	list2_title.visible = "YES"
	accomplishment_title.visible = "YES"

	local charkills, chardeaths, charpkills = GetCharacterKillDeaths(charid)
	local killdeathratio = charkills/(chardeaths>0 and chardeaths or 1)
-- when you press 'k' on a char
	local stuff = {
		string.format("Kills/Deaths: %s / %s (%2.2f)", comma_value(charkills), comma_value(chardeaths), killdeathratio),
		string.format("Player Kills: %s: %s / %s: %s / %s: %s",
			FactionName[1], comma_value(GetNationKills(1, charid)),
			FactionName[2], comma_value(GetNationKills(2, charid)),
			FactionName[3], comma_value(GetNationKills(3, charid))),
	}
	if GetCharacterID() == charid then
		table.insert(stuff, "Number of missions completed: "..comma_value(GetNumCompletedMissions()))
		table.insert(stuff, "Credits: "..comma_value(GetMoney()))
		table.insert(stuff, "")
		for i=1,Skills.n do
			local cur, max = GetSkillLevel(i)
			local curlicense = GetLicenseLevel(i)
			local min = GetLicenseRequirement(curlicense)
			local str = string.format("%s License: %u (%u/%u)", Skills.Names[i], curlicense, math.max(cur-min, 0), math.max(max-min, 0))
			table.insert(stuff, str)
		end
	else
		table.insert(stuff, "")
		for i=1,Skills.n do
			local str = string.format("%s License: %u", Skills.Names[i], GetLicenseLevel(i, charid))
			table.insert(stuff, str)
		end
	end
	
	table.insert(stuff, GetCharacterDescription(charid))
	list1.value = table.concat(stuff, "\n")
	accombox:UpdateAccomplishments(charid)
	if GetNumAccomplishments(charid) == 0 then
		accomplishment_title.title = "Accomplishments: None"
	else
		accomplishment_title.title = "Accomplishments:"
	end

	if playername then
		givemoneybutton.visible = "YES"
		msgbutton.visible = "YES"
		ignorebutton.visible = "YES"
		groupinvitebutton.visible = "YES"
		guildinvitebutton.visible = "YES"
		buddyinvitebutton.visible = "YES"
		duelbutton.visible = "YES"
		if IsInDuel() then
			duelbutton.title = "Forfeit Duel"
			duelbutton.action = duel_forfeit_action
			duel2button.visible = "YES"
		else
			if IsPlayerRequestingDuel(playername) then
				duelbutton.title = "Duel Reply"
				duelbutton.action = duel_accept_action
			else
				duelbutton.title = "Duel Challenge"
				duelbutton.action = duel_challenge_action
			end
			duel2button.visible = "NO"
		end

		if Ignore.IsIgnored(playername) then
			ignorebutton.title = "Unignore"
		else
			ignorebutton.title = "Ignore"
		end
		
		-- if a lieutenant or commander, then enable guildinvitebutton else disable it.
		local _charid,rank,_charname = GetGuildMemberInfoByCharID(GetCharacterID())
		if rank and (rank == 1 or rank == 3 or rank == 4) and not IsGuildMember(charid) then
			guildinvitebutton.active = "YES"
		else
			guildinvitebutton.active = "NO"
		end
	
		-- if group owner, then enable groupinvitebutton else disable it.
		-- or if player not in a group, it is created implicitly
		local groupinvited = IsPlayerRequestingGroupInvite(playername)
		if (GetCharacterID() == GetGroupOwnerID() and not IsGroupMember(charid)) or
				(GetNumGroupMembers() == 0) or
				groupinvited then
			groupinvitebutton.active = "YES"
			if groupinvited then
				groupinvitebutton.action = groupjoinaction
				groupinvitebutton.title = " Join Group "
			else
				groupinvitebutton.title = "Group Invite"
				groupinvitebutton.action = groupinviteaction
			end
		else
			groupinvitebutton.title = "Leave Group"
			groupinvitebutton.action = groupleaveaction
			groupinvitebutton.active = "YES"
		end
	
		-- if not already a buddy, enable buddyinvitebutton else disable it.
		if not GetBuddyInfo(charid) then
			if IsPlayerRequestingBuddy(playername) then
				buddyinvitebutton.title = "Buddy Reply"
				buddyinvitebutton.action = buddy_accept_action
			else
				buddyinvitebutton.title = "Buddy Invite"
				buddyinvitebutton.action = buddy_invite_action
			end
		else
			buddyinvitebutton.title = "Remove Buddy"
			buddyinvitebutton.action = buddy_remove_action
		end
	end

	list2:Setup(charid)
end

function FillInObjectInfo(msg1, msg2)
	title_text.title = "Information for "..msg1
	alignment_text.title = ""
	list1.value = msg2

	list2:HideAll()
end

function CharInfoMenu:map_cb()
	RegisterEvent(self, "CHARINFOMENU_TOGGLE")
	RegisterEvent(self, "PLAYER_STATS_UPDATED")
	RegisterEvent(self, "OBJECT_INFO_UPDATED")
	RegisterEvent(self, "UPDATE_BUDDY_LIST")
	RegisterEvent(self, "UPDATE_DUEL_INFO")
end

function CharInfoMenu:OnEvent(eventname, ...)
	if eventname == "CHARINFOMENU_TOGGLE" then
		if CharInfoMenu.visible == "YES" then
			HideDialog(CharInfoMenu)
			ShowDialog(HUD.dlg)
		elseif HUD.IsVisible then
			HideDialog(HUD.dlg)
			HideAllDialogs()
			local requestedcharid = CharInfoMenu:Clear()
			if requestedcharid == GetCharacterID() then
				PDATab1:SetTab(PDACharacterTab)
				PDACharacterTab:SetTab(PDACharacterStatsTab)
				ShowDialog(PDADialog, iup.CENTER, iup.CENTER)
			else
				ShowDialog(CharInfoMenu, iup.CENTER, iup.CENTER)
			end
		end
	elseif (eventname == "UPDATE_BUDDY_LIST") or (eventname == "UPDATE_DUEL_INFO") then
		if (not requestedcharid) and playerid and CharInfoMenu.visible == "YES" then
			FillInPlayerInfo(playerid)
		end
	elseif eventname == "PLAYER_STATS_UPDATED" then
		local charid = ...
		if requestedcharid and requestedcharid == charid then
			FillInPlayerInfo(requestedcharid)
			requestedcharid = nil
			if charid ~= GetCharacterID() then
				HideDialog(HUD.dlg)
				ShowDialog(CharInfoMenu, iup.CENTER, iup.CENTER)
			end
		end
	elseif eventname == "OBJECT_INFO_UPDATED" then
		local objid1, objid2 = ...
		FillInObjectInfo(objid1, objid2)
		iup.Refresh(CharInfoMenu)
	end
end

CharInfoMenu:map()
