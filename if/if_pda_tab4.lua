-- Comm menu
local scrollbar_width = Font.Default

local alpha = ListColors.Alpha
local even, odd = ListColors[0], ListColors[1]

local bg = {
	[0] = even.." "..alpha,
	[1] = odd.." "..alpha,
}
local bg_numbers = ListColors.Numbers

local function create_news_tab()
	local isvisible = false
	local reset = true
	local container
	local itemlistbox, infobutton, requestbutton
	local articles

	itemlistbox = iup.stationsubsublist{expand="YES", size="1x1"}
	function itemlistbox:action(text, index, selection)
		if selection == 2 then
			infobutton:action()
		elseif selection == 1 then
			infobutton.active="YES"
		else
			infobutton.active="NO"
		end
	end
	infobutton = iup.stationbutton{
		title="Read Article",
		hotkey=iup.K_a,
		active="NO",
	}
	function infobutton:action()
		local articleinfo = articles[tonumber(itemlistbox.value)]
		if articleinfo then
			RequestNewsArticle(articleinfo.index)
			NewsDialog:SetHeader(articleinfo.headline)
			ShowDialog(NewsDialog)
		end
	end

	local function setup()
		reset = false
--[[
		if not PlayerInStation() then
			itemlistbox[1] = "News is only available in the station at this time."
			itemlistbox[2] = nil
			infobutton.active = "NO"
			itemlistbox.active = "NO"
			return
		end
--]]
		local n = GetNumNewsHeadlines()
		articles = {}
		for i=1,n do
			local headline, timestamp, subject = GetNewsHeadline(i)
			articles[i] = {index=i, headline=headline, timestamp=timestamp, subject=subject}
		end
		table.sort(articles,
			function(a,b)
				if a.timestamp==b.timestamp then
					return a.headline < b.headline
				else
					return a.timestamp > b.timestamp
				end
			end)
		for i=1,n do
			itemlistbox[i] = gkmisc.date("%c", articles[i].timestamp).."  "..articles[i].headline
		end
		itemlistbox[n+1] = nil
	end

	container = iup.vbox{
		itemlistbox,
		iup.stationsubsubframebg{
			iup.hbox{infobutton, iup.fill{}, alignment="ACENTER", expand="YES", margin="2x2"},
		}
	}

	function container:OnShow()
		isvisible = true
		if reset then
			setup()
		end
	end
	function container:OnHide()
		isvisible = false
	end

	function container:OnEvent(eventname, ...)
		if eventname == "TRANSACTION_COMPLETED"
			or eventname == "ENTERING_STATION"
			or eventname == "UPDATE_NEWS_HEADLINES" then
			if isvisible then
				setup()
			else
				reset = true
			end
		end
	end

	RegisterEvent(container, "TRANSACTION_COMPLETED")
	RegisterEvent(container, "ENTERING_STATION")
	RegisterEvent(container, "UPDATE_NEWS_HEADLINES")

	
	return container
end



local function create_player_matrix(columndefs, defsort)
	local matrix
	local sortedlist
	local update_matrix
	local sort_key = defsort -- default to sort by distance
	local numcolumns = (#columndefs)
	local function set_sort_mode(mode)
		-- clicked on title of column
		sort_key = mode
		-- color the text accordingly
		for i=1,numcolumns do
			matrix:setattribute("FGCOLOR", 0, i, mode == i and tabseltextcolor or tabunseltextcolor)
		end
	end

	matrix = iup.pdasubsubmatrix{
		numcol = numcolumns,
		expand = "YES",
		size="200x100",
	}
	for i=1,numcolumns do
		matrix["ALIGNMENT"..i] = columndefs[i].alignment
		matrix["0:"..i] = columndefs[i].title
	end
	set_sort_mode(defsort)
	function matrix:fgcolor_cb(row, col)
		local c = (columndefs[col].fgcolor or bg_numbers)[math.fmod(row,2)]
		return c[1],c[2],c[3],c[4],iup.DEFAULT
	end
	matrix.bgcolor_cb = matrix.fgcolor_cb
	function matrix:click_cb(row, col)
		if row == 0 and tonumber(matrix.NUMLIN) > 0 then --insures we have data to sort
			set_sort_mode(col)
			update_matrix(self)
		elseif columndefs.on_sel then
			columndefs.on_sel(matrix, row, sortedlist[row])
		end
	end
	function matrix:edition_cb()
		return iup.IGNORE
	end
	function matrix:mousemove_cb(row, column)
		if columndefs[column].movemove_cb then columndefs[column].mousemove_cb() end
	end

	local function sort_list(sort_key, list)
		table.sort(list, columndefs[sort_key].fn)
	end

	local function reload_matrix(matrix, list)
		matrix.numlin = (#list)
	
		for index,v in ipairs(list) do
			columndefs.update_entry(matrix, index, v)
		end
	end
	
	local function reset_matrix(self, characterlist)
		matrix.dellin = "1--1"  -- one way of deleting all items in the matrix
		sortedlist = characterlist
		sort_list(sort_key, sortedlist)
		reload_matrix(matrix, sortedlist)
	end

	update_matrix = function(self)
		set_sort_mode(sort_key)
		sort_list(sort_key, sortedlist)
		reload_matrix(matrix, sortedlist)
	end

	matrix.update = update_matrix
	matrix.reset = reset_matrix

	return matrix
end

local confirmationdlg = msgpromptdlgtemplate2()

local function create_buddies_tab()
	local container
	local buddy_matrix
	local group_matrix
	local isvisible = false
	local buddyremovebutton, buddynotebutton
	local buddy_location_notification_toggle_ctrl

	buddy_location_notification_toggle_ctrl = {}

	buddyremovebutton = iup.stationbutton{
		title="Remove Buddy",
		active="NO",
	}

	buddynotebutton = iup.stationbutton{
		title="Send Message",
		active="NO",
	}

local buddy_sortfuncs = {
	[1] = {
		title="L",
		alignment="ACENTER",
		fgcolor={[0]={255,255,255,255}, [1]={255,255,255,255}, [2]={255,255,255,255} },
		fn = function(a,b)
			if a.showLocation == b.showLocation then
				return a.name < b.name
			else
				return (a.showLocation and 1 or 0) > (b.showLocation and 1 or 0)
			end
		end,
		},
	[2] = {
		title="Name",
		alignment="ALEFT",
		fn = function(a,b)
			return a.name < b.name
		end,
		},
	[3] = {
		title="Location",
		alignment="ALEFT",
		fn = function(a,b)
			if a.location == b.location then
				return a.name < b.name
			elseif (not a.location) then
				return false
			elseif (not b.location) then
				return true
			else
				return a.location < b.location
			end
		end,
		},
	update_entry = function(matrix, index, data)
		local showLocationCtl = iup.stationtoggle{title="", value = data.showLocation and "ON" or "OFF"}
		buddy_location_notification_toggle_ctrl[data.charid] = showLocationCtl
		showLocationCtl.action = function(self, state)
			if state == 1 then
				Buddy.selfnotify(data.name, true)
			else
				Buddy.selfnotify(data.name, false)
			end
		end

		matrix[index..':1'] = showLocationCtl

		matrix:setcell(index, 2, " "..data.name)
		if data.location then
			matrix:setcell(index, 3, " "..((data.location ~= 0 and (ShortLocationStr(data.location))) or "Logged In"))
		else
			matrix:setcell(index, 3, " Not Logged In")
		end

		local c = (data.location and "200 200 200") or "128 128 128"
		matrix:setattribute("FGCOLOR", index, -1, c)
	end,
}

	local oldbuddyrow
	local oldbuddyrowdata
	buddy_sortfuncs.on_sel = function(mat, row, data)
		if oldbuddyrow then
			mat:setattribute("FGCOLOR", oldbuddyrow, -1, (oldbuddyrowdata and oldbuddyrowdata.location and "200 200 200") or "128 128 128")
		end
		oldbuddyrow = row
		oldbuddyrowdata = data
		mat:setattribute("FGCOLOR", row, -1, "255 255 255")
		buddyremovebutton.active = "YES"
		if oldbuddyrowdata and oldbuddyrowdata.location then
			buddynotebutton.title = "Send Message"
		else
			buddynotebutton.title = "Leave Note"
		end
		buddynotebutton.active = "YES"
	end

	buddyremovebutton.action=function()
		local buddyname = oldbuddyrowdata and oldbuddyrowdata.name
		if buddyname then
			local yes_callback = function()
					Buddy.remove(buddyname)
					HideDialog(QuestionDialog)
				end
			QuestionDialog:SetMessage("Are you sure you want to stop being a buddy of "..buddyname.."?",
				"Yes", yes_callback,
				"No", function() HideDialog(QuestionDialog) end)
			ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
		end
	end

	buddynotebutton.action=function()
		local buddyname = oldbuddyrowdata and oldbuddyrowdata.name
		if buddyname then
			confirmationdlg:SetString("")
			confirmationdlg:SetMessage("Type in a message to send to "..buddyname..".",
				"Send", function()
						local message = confirmationdlg:GetString()
						if message and message ~= "" then
							HideDialog(confirmationdlg)
							ProcessEvent("CHAT_MSG_BUDDYNOTE", {msg=message, name=buddyname})
							Buddy.note(buddyname, message)
						else
							-- error message/sound or something.
						end
					end,
				"Cancel", function()
						HideDialog(confirmationdlg)
					end)
			ShowDialog(confirmationdlg, iup.CENTER, iup.CENTER)
		end
	end

	buddy_matrix = create_player_matrix(buddy_sortfuncs, 3)
	buddy_matrix.width1 = 16

	local buddy_container = iup.vbox{
		buddy_matrix,
		iup.stationsubsubframebg{
			iup.hbox{buddyremovebutton, buddynotebutton, iup.fill{}, alignment="ACENTER", expand="YES", margin="2x2", gap=2},
		}
	}

--- group stuff here
	local group_leave_button, group_join_button, group_invite_button, group_create_button, group_mute_button
	local group_talking_icon = {}
	local group_sortfuncs = {
		[1] = {
			title="V",
			alignment="ACENTER",
			fn = function(a,b)
				local mute_a = VoiceChat.IsPlayerMuted(a.id) and 1 or 0
				local mute_b = VoiceChat.IsPlayerMuted(b.id) and 1 or 0
				if mute_a == mute_b then
					return a.name < b.name
				else
					return mute_a < mute_b
				end
			end,
			},
		[2] = {
			title="Name",
			alignment="ALEFT",
			fn = function(a,b)
				return a.name < b.name
			end,
			},
		[3] = {
			title="Faction",
			alignment="ALEFT",
			fn = function(a,b)
				return a.faction > b.faction
			end,
			},
		[4] = {
			title="Location",
			alignment="ALEFT",
			fn = function(a,b)
				if a.location == b.location then
					return a.name < b.name
				elseif (not a.location) or a.location == 0 then
					return false
				elseif (not b.location) or b.location == 0 then
					return true
				else
					return a.location < b.location
				end
			end,
			},
		[5] = {
			title="Health",
			alignment="ALEFT",
			fn = function(a,b)
				if a.health == b.health then
					return a.name < b.name
				else
					return a.health > b.health
				end
			end,
			},
		update_entry = function(matrix, index, data)
			local icon = iup.label{title="", image=VoiceChat.IsPlayerMuted(data.id) and "images/no.png" or "images/vc_speak.png", bgcolor="255 255 255 255 &", size=(Font.H4*HUD_SCALE).."x"..(Font.H4*HUD_SCALE)}
			matrix[index..':1'] = icon
			matrix:setcell(index, 2, data.name or 'n/a') -- name
			matrix:setcell(index, 3, data.faction or 'n/a') -- faction
			matrix:setcell(index, 4, data.location > 0 and ShortLocationStr(data.location) or 'n/a') -- location
			matrix:setcell(index, 5, data.health or 'n/a') -- health
			-- this has to be done after putting it into the matrix because the matrix forces it visible when it is added
			icon.visible = (VoiceChat.IsPlayerTalking(data.id) or VoiceChat.IsPlayerMuted(data.id)) and "YES" or "NO"
			-- must store this object so it can be manipulated and destroyed when no longer used.
			group_talking_icon[data.id] = icon
			matrix:setattribute("FGCOLOR", index, -1, data.health_color)
		end,
	}

	local oldgrouprow
	local oldgrouprowdata
	group_sortfuncs.on_sel = function(mat, row, data)
		if oldgrouprow and tonumber(mat.NUMLIN) > 0 then
			mat:setattribute("FGCOLOR", oldgrouprow, -1, oldgrouprowdata.health_color)
		end
		oldgrouprow = row
		oldgrouprowdata = data
		mat:setattribute("FGCOLOR", row, -1, "255 255 255")
		group_mute_button.active = "YES"
	end
	
	group_matrix = create_player_matrix(group_sortfuncs, 1)
	group_matrix.width1 = 16
	group_matrix.width3 = 75
	group_matrix.width5 = 75

	group_leave_button = iup.stationbutton{title="Leave", active="NO", action=Group.Leave}
	group_join_button = iup.stationbutton{title="Join Group", active="YES", action=function()
		confirmationdlg:SetString(InterfaceManager.mostrecentinvite or '')
		confirmationdlg:SetMessage("What is the name of the group leader?",
			"Join", function()
					local leadername = confirmationdlg:GetString()
					if leadername and leadername ~= "" then
						HideDialog(confirmationdlg)
						Group.Join(leadername)
					end
				end,
			"Cancel", function()
					HideDialog(confirmationdlg)
				end)
		ShowDialog(confirmationdlg, iup.CENTER, iup.CENTER)
	end}
	group_invite_button = iup.stationbutton{title="Invite", active="NO", action=function()
		confirmationdlg:SetString("")
		confirmationdlg:SetMessage("What is the name of the person you want to invite?",
			"Invite", function()
					local invitename = confirmationdlg:GetString()
					if invitename and invitename ~= "" then
						HideDialog(confirmationdlg)
						Group.Invite(invitename)
					end
				end,
			"Cancel", function()
					HideDialog(confirmationdlg)
				end)
		ShowDialog(confirmationdlg, iup.CENTER, iup.CENTER)
	end}
	group_create_button = iup.stationbutton{title="Create Group", active="YES", action=function() gkinterface.GKProcessCommand("group create") end}

	local function reset_buddy_matrix()
		local sortedlist = {}
		ForEachBuddy( function(name, is_online, location, buddycharid, showLocation)
				table.insert(sortedlist, {charid=buddycharid, name=name, location=location, showLocation=showLocation})
			end)
		local width = getwidth(buddy_matrix) - scrollbar_width
		buddy_matrix.width2 = width/2
		buddy_matrix.width3 = width/2
		local ctrls = buddy_location_notification_toggle_ctrl
		buddy_location_notification_toggle_ctrl = {}
		buddy_matrix:reset(sortedlist)
		for k,v in pairs(ctrls) do
			iup.Destroy(v)
		end
		oldbuddyrow = nil
		oldbuddyrowdata = nil
		buddyremovebutton.active = "NO"
		buddynotebutton.active = "NO"
		buddynotebutton.title = "Send Message"
	end

	local function reset_matrix()
--group stuff here
		local width = getwidth(group_matrix) - scrollbar_width
		width = width - group_matrix.width1
		for i=2, 5 do group_matrix["WIDTH"..i] = width/4 end
		if not IsGroupMember(GetCharacterID()) then
			 group_leave_button.active = "NO"
			 group_join_button.active = "YES"
			 group_invite_button.active = "NO"
			 group_create_button.active = "YES"
		else
			 group_leave_button.active = "YES"
			 group_join_button.active = "NO"
			 group_invite_button.active = GetGroupOwnerID() == GetCharacterID() and "YES" or "NO"
			 group_create_button.active = "NO"
		end
		group_mute_button.active = "NO"
		--group matrix
		local grouplist = {}
		local group_leader = GetGroupOwnerID() -- userid or 0 for no group

		for x = 1,GetNumGroupMembers() do
			local memberid = GetGroupMemberID(x)
			if not memberid then break end  --sanity check

			-- member name
			local member_name = GetPlayerName(memberid)
			if group_leader == memberid then member_name = '* '..member_name end

			-- member location
			local location = GetGroupMemberLocation(memberid)

			-- member health
			local health = tonumber(string.format("%." .. (0) .. "f",GetPlayerHealth(memberid)))
			local member_health
			if health > 0 then
				member_health = health..'%'
			elseif health == 0 then
				member_health = 'disabled'
			else
				member_health = ''
			end
			local health_color = calc_health_color(health/100,128)

			-- member faction
			local faction = FactionName[GetPlayerFaction(memberid)]

			grouplist[x] = {
				id = memberid,
				name = member_name, 
				location = location, 
				health = member_health,
				health_color = health_color,
				faction = faction,
			}
		end -- for group loop
		local icons = group_talking_icon
		group_talking_icon = {}
		group_matrix:reset(grouplist)
		for k,v in pairs(icons) do
			iup.Destroy(v)
		end
		oldgrouprow = nil
		oldgrouprowdata = nil
		-- end group data
	end

	group_mute_button = iup.stationbutton{title="Mute", active="NO", action=function()
		local id = oldgrouprowdata and oldgrouprowdata.id or 0
		if VoiceChat.IsPlayerMuted(id) then
			VoiceChat.MutePlayer(id, false)
		else
			VoiceChat.MutePlayer(id, true)
		end
--		reset_matrix()
	end
	}

	local group_container = iup.vbox{
		group_matrix,
		iup.stationsubsubframebg{
			iup.hbox{
				group_create_button,
				group_join_button, 
				group_invite_button, 
				group_leave_button, 
				group_mute_button,
				iup.fill{},
				alignment="ACENTER", expand="YES", margin="2x2", gap=2
			},
		}
	}

-- end groupstuff
	
	container = iup.hbox {
			buddy_container,
			group_container,
		}

	
	function container:OnShow()
		isvisible = true
		RegisterEvent(container, "UPDATE_BUDDY_LIST")
		RegisterEvent(container, "GROUP_MEMBER_HEALTH_UPDATE")
		RegisterEvent(container, "GROUP_MEMBER_JOINED")
		RegisterEvent(container, "GROUP_MEMBER_KILLED")
		RegisterEvent(container, "GROUP_CREATED")
		RegisterEvent(container, "GROUP_SELF_JOINED")
		RegisterEvent(container, "GROUP_SELF_LEFT")
		RegisterEvent(container, "GROUP_OWNER_CHANGED")
		RegisterEvent(container, "GROUP_MEMBER_LEFT")
		RegisterEvent(container, "GROUP_MEMBER_LOCATION_CHANGED")
		RegisterEvent(container, "GROUP_MEMBER_UPDATE")
		RegisterEvent(container, "PLAYER_GOT_HIT")
		RegisterEvent(container, "VOICECHAT_PLAYER_TALK_STATUS")
		RegisterEvent(container, "VOICECHAT_PLAYER_MUTE_STATUS")

		reset_matrix()
		reset_buddy_matrix()
	end

	function container:OnHide()
		isvisible = false
		UnregisterEvent(container, "UPDATE_BUDDY_LIST")

		UnregisterEvent(container, "GROUP_MEMBER_HEALTH_UPDATE")
		UnregisterEvent(container, "GROUP_MEMBER_JOINED")
		UnregisterEvent(container, "GROUP_MEMBER_KILLED")
		UnregisterEvent(container, "GROUP_CREATED")
		UnregisterEvent(container, "GROUP_SELF_JOINED")
		UnregisterEvent(container, "GROUP_SELF_LEFT")
		UnregisterEvent(container, "GROUP_OWNER_CHANGED")
		UnregisterEvent(container, "GROUP_MEMBER_LEFT")
		UnregisterEvent(container, "GROUP_MEMBER_LOCATION_CHANGED")
		UnregisterEvent(container, "GROUP_MEMBER_UPDATE")
		UnregisterEvent(container, "PLAYER_GOT_HIT")
		UnregisterEvent(container, "VOICECHAT_PLAYER_TALK_STATUS")
		UnregisterEvent(container, "VOICECHAT_PLAYER_MUTE_STATUS")
	end

	function container:OnEvent(eventname, ...)
		if isvisible then
			if eventname == "VOICECHAT_PLAYER_TALK_STATUS" then
				local charid, status = ...
				local icon = group_talking_icon[charid]
				if icon then
					icon.visible = (status or VoiceChat.IsPlayerMuted(charid)) and "YES" or "NO"
				end
			elseif eventname == "VOICECHAT_PLAYER_MUTE_STATUS" then
				local charid, status = ...
				local icon = group_talking_icon[charid]
				if icon then
					icon.image = status and "images/no.png" or "images/vc_speak.png"
					icon.visible = (status or VoiceChat.IsPlayerTalking(charid)) and "YES" or "NO"
				end
			elseif eventname == "UPDATE_BUDDY_LIST" then
				reset_buddy_matrix()
			else
				reset_matrix()
			end
		end
	end

	return container
end

dofile(IF_DIR.."if_guild_template.lua")


-- ignore tab
local function create_ignore_tab()
	local isvisible = false
	local ignore_matrix, container, AddUserbutton, DelUserbutton

	local user_names = {}	-- users that have said stuff on a channel

	local oldrow -- matrix stuff
	local oldrowdata
	local name
	local matrix_FG = "128 128 128" -- standard fg color
	local matrix_H_FG = "255 255 255" -- highligh fg color
	local wid = (gkinterface.GetXResolution() * .78) / 2

	local Chatty_users = iup.stationsubsublist{visible_items = '20',dropdown = "yes",expand="HORIZONTAL"}
	local ignore_duration = iup.stationsubsublist{'Forever','Session','30 mins','1 hour','2 hour','3 hour','4 hour','5 hours',dropdown='YES',}
	local AddUserbutton = iup.stationbutton{ title="Ignore User",active="NO",}
	local ManualAddbutton = iup.stationbutton{ title="Manual Add",active="YES",}
	local DelUserbutton = iup.stationbutton{title="Unignore User",active="NO",}
	local Purgebutton = iup.stationbutton{title="Remove All",active="YES",}


	local sortfuncs = {
		[1] = {title="Name", alignment="ALEFT",
			fn = function(a,b)
				return a.name < b.name
			end,
			},
		[2] = {title="Duration", alignment="ALEFT",
			fn = function(a,b)
				return a.duration < b.duration
			end,
			},
		update_entry = function(matrix, index, data)
			matrix:setcell(index, 1, " "..data.name)
			matrix:setcell(index, 2, " "..data.duration)
			matrix:setattribute("FGCOLOR", index, -1, matrix_FG)
		end,
		on_sel = function(mat, row, data)
			if oldrow then
				mat:setattribute("FGCOLOR", oldrow, -1, matrix_FG)
			end
			oldrow = row
			oldrowdata = data
			mat.index = row
			mat:setattribute("FGCOLOR", row, -1, matrix_H_FG)
			DelUserbutton.active="YES"
		end,
	}
	ignore_matrix = create_player_matrix(sortfuncs, 1)
	ignore_matrix.width1 = wid
	ignore_matrix.width2 = wid
	
	-- dumps names into the table and into the dropdown listbox
	local function add_stuff(name)
		local notfoundflag = true
		-- add the name to the list if it does not exist currently.
		for index,lowercasename in ipairs(user_names) do
			if lowercasename == string.lower(name) then
				notfoundflag = false
				break
			end
		end
		if notfoundflag then -- we need to add the username.
			table.insert(user_names, string.lower(name))
			table.sort(user_names)
			for index,lowercasename in ipairs(user_names) do
				Chatty_users[index] = lowercasename
			end
			AddUserbutton.active = "YES"
		end 
	end

	-- refreshes the matrix with the table data
	local function reset_matrix()
		local width = getwidth(ignore_matrix) - scrollbar_width
		ignore_matrix.width1 = width/2
		ignore_matrix.width2 = width/2
		local tbl = Ignore.GetIgnoreList()
		if #tbl ~= #ignore_time then
			ignore_time = {}		
	
			for index,name in ipairs(tbl) do
				ignore_time[index] = {name=name,duration="Forever"}
				add_stuff(name)
			end
		end
		-- read values from above table into ignore_time
		ignore_matrix:reset(ignore_time)
	end
	

	-- user changed the line on the listbox, 
	function Chatty_users:action(text,index,sel)
		AddUserbutton.active = "YES"
		if sel ~= 0 then -- new selection
			for x,v in ipairs(ignore_time) do
				if v.name == text then 
					AddUserbutton.active = "NO"
				end
			end
		end
	end
	
	function Purgebutton:action()
		Ignore.UnignoreAll()
		reset_matrix()
	end

	local function add_ignore(name)
		-- take Chatty_users index and add to itemlistbox
		table.insert(ignore_time, {
			name = name,
			duration = ignore_duration[ignore_duration.value],
		})
		Ignore.Ignore(name)
		AddUserbutton.active = "NO"

		if tonumber(ignore_duration.value) > 2 then --set a timer to purge after period x.
		print ('duration is '..ignore_duration[ignore_duration.value])
			local test = tonumber(ignore_duration.value) - 3
			local value = 3600000 * (test == 0 and .5 or test) --/ 30 short testing number
			local timer1 = Timer()
			timer1:SetTimeout(value,function() 
				Ignore.Unignore(name) 
				reset_matrix()				
			end)
		end
	end

	function AddUserbutton:action()
		local name = Chatty_users[Chatty_users.value]
		add_ignore(name)
		reset_matrix()
	end
	
	function DelUserbutton:action()
		local user = ignore_time[tonumber(ignore_matrix.index)]
		local name = user and user.name
		Ignore.Unignore(name)
		table.remove(ignore_time, ignore_matrix.index)
		reset_matrix()
		DelUserbutton.active="NO"
	end

	function ManualAddbutton:action()
		local dlg = msgpromptdlgtemplate2()
		
		dlg:SetString("")
		dlg:SetMessage("User to ignore",
			"Ok",function() 
				HideDialog(dlg)
				name = dlg:GetString()
				if name ~= "" then
					add_ignore(name)
					reset_matrix()
				end
			end,
			"Cancel", function() HideDialog(dlg) end
		)
		ShowDialog(dlg,iup.CENTER,iup.CENTER)
	end
	
	container = iup.vbox{
		iup.stationsubsubframebg{iup.hbox{DelUserbutton,iup.fill{},Purgebutton,},
			alignment="ACENTER", expand= "HORIZONTAL", margin="2x4"
		},
		ignore_matrix,
		iup.stationsubsubframebg{
 			iup.vbox{
 				iup.hbox{
 					ManualAddbutton, iup.label{title=' Ignore: '}, Chatty_users,ignore_duration, AddUserbutton,
 				},
 			},
		}
	}

	function container:OnShow()
		isvisible = true
		reset_matrix()
	end
	function container:OnHide()
		isvisible = false
	end


	function container:OnEvent(eventname, ...)

		if eventname == "PLAYER_ENTERED_SECTOR" then
			local id = ...
			local name = GetPlayerName(id)
			if not name:match("reading transponder") and not name:match("^*") and id ~= 0 then
				add_stuff(name)
			end
		elseif eventname == 'PLAYER_LOGGED_OUT' or eventname == 'UNLOAD_INTERFACE' then
			for x,v in ipairs(ignore_time) do
				-- purge all session ignores and timers
				if (v.duration ~= 'Forever') and (v.duration ~= 'never') then
					Ignore.Unignore(v.name)
				end
			end
		else
			local arg = {...}
			local name = arg[1].name
			add_stuff(name)
		end
	end


	RegisterEvent(container, "CHAT_MSG_CHANNEL")
	RegisterEvent(container, "CHAT_MSG_CHANNEL_EMOTE")
	RegisterEvent(container, "CHAT_MSG_CHANNEL_ACTIVE")
	RegisterEvent(container, "CHAT_MSG_CHANNEL_EMOTE_ACTIVE")
	RegisterEvent(container, "CHAT_MSG_PRIVATE")
	RegisterEvent(container, "CHAT_MSG_SECTOR")
	RegisterEvent(container, "CHAT_MSG_SECTOR_EMOTE")
	RegisterEvent(container, "PLAYER_ENTERED_SECTOR")
	RegisterEvent(container, "PLAYER_LOGGED_OUT")
	RegisterEvent(container, "UNLOAD_INTERFACE")

	return container
end
-- ignore tab

function CreateCommPDATab()
	local tab1, tab2, tab3, tab4, tab5

	tab1 = create_news_tab() tab1.tabtitle="News"  tab1.hotkey=iup.K_N
	tab2 = create_buddies_tab() tab2.tabtitle="Buddies/Group" tab2.hotkey=iup.K_B
	tab3 = create_char_guild_tab(true) tab3.tabtitle="GUild"  tab3.hotkey=iup.K_U
	tab4 = create_ignore_tab(true) tab4.tabtitle="Ignore"  tab4.hotkey=iup.K_i
	tab5 = CreateFriendKeysPDATab(true) tab5.tabtitle="Friend Keys"  tab5.hotkey=iup.K_f

	tab1.OnHelp = HelpStationNews
	tab2.OnHelp = HelpStationBuddies
	tab3.OnHelp = HelpCharGuild
	tab4.OnHelp = HelpIgnore
	tab5.OnHelp = HelpFriendKeys

	return iup.subsubtabtemplate{
		tab1,
		tab2,
		tab3,
		tab4,
		tab5,
	}
end

