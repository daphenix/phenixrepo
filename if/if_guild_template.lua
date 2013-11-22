local guildhelptext = "Guilds are organizations of pilots, created for various purposes. Pilots belonging to guilds can be identified by the [NAME] acronym before their handle, where \"NAME\" is replaced with an acronym for the guild's name. Different guilds have different agendas, which should be visible on the \"Player Guilds\" selection of the website (eventually available here as well). If a guild is actively recruiting new members, contacting a member in-game could result in an invitation to join.\n\nCreating your own guild can be achieved by using the \"/guild\" command in the chat interface. Do a \"/guild help\" (no quotes) for a listing of guild-related commands. Ten people are required to found a guild, and all must be online at the time of guild creation. The ten founding members will be divided into the Commander (one) and Council (nine). For more information on guild voting, organization and command hierarchy, see the online manual via the website."

local guildrank = {
	[0] = "Member",
	[1] = "Lieutenant",
	[2] = "Council member",
	[3] = "Council member and Lieutenant",
	[4] = "Commander"
}

local bg_numbers = ListColors.Numbers

function guildaccessdialogtemplate()
	local dlg
	local infolabel = iup.label{font=Font.H1,title="Bank Access Setup", expand="YES", alignment="ACENTER"}
	local buttoncancel = iup.stationbutton{title="Cancel", action=function() HideDialog(dlg) end}
	local buttonok = iup.stationbutton{title="OK"}
	local depcheck1,depcheck2,depcheck3
	local withcheck1,withcheck2,withcheck3
	local logcheck1,logcheck2,logcheck3
	local memberlimittitle, councillimittitle, lieutenantlimittitle
	local memberlimit, councillimit, lieutenantlimit
	local dp,wp,lp
	local wlm,wll,wlc
	
	memberlimittitle = iup.label{title="Member:", alignment="ARIGHT"}
	councillimittitle = iup.label{title="Council:", alignment="ARIGHT"}
	lieutenantlimittitle = iup.label{title="Lieutenant:", alignment="ARIGHT"}
	memberlimit = iup.text{expand="HORIZONTAL"}
	councillimit = iup.text{expand="HORIZONTAL"}
	lieutenantlimit = iup.text{expand="HORIZONTAL"}
	
	depcheck1 = iup.stationtoggle{title="Member", value="ON"}
	depcheck2 = iup.stationtoggle{title="Lieutenant", value="ON"}
	depcheck3 = iup.stationtoggle{title="Council", value="ON"}
	local deplut={[Guild.RankMember]=depcheck1, [Guild.RankLieutenant]=depcheck2, [Guild.RankCouncil]=depcheck3}
	local depinitial={[Guild.RankMember]=false, [Guild.RankLieutenant]=false, [Guild.RankCouncil]=false}
	
	withcheck1 = iup.stationtoggle{title="Member", value="ON"}
	withcheck2 = iup.stationtoggle{title="Lieutenant", value="ON"}
	withcheck3 = iup.stationtoggle{title="Council", value="ON"}
	local withlut={[Guild.RankMember]=withcheck1, [Guild.RankLieutenant]=withcheck2, [Guild.RankCouncil]=withcheck3}
	local withinitial={[Guild.RankMember]=false, [Guild.RankLieutenant]=false, [Guild.RankCouncil]=false}
	
	logcheck1 = iup.stationtoggle{title="Member", value="ON"}
	logcheck2 = iup.stationtoggle{title="Lieutenant", value="ON"}
	logcheck3 = iup.stationtoggle{title="Council", value="ON"}
	local loglut={[Guild.RankMember]=logcheck1, [Guild.RankLieutenant]=logcheck2, [Guild.RankCouncil]=logcheck3}
	local loginitial={[Guild.RankMember]=false, [Guild.RankLieutenant]=false, [Guild.RankCouncil]=false}

	function buttonok:action()
		local mlimit = tonumber(memberlimit.value)
		local llimit = tonumber(lieutenantlimit.value)
		local climit = tonumber(councillimit.value)
		if mlimit ~= wlm then
			local err = Guild.setwithdrawallimit(Guild.RankMember, mlimit)
			if err then print(err) end
		end
		if llimit ~= wll then
			local err = Guild.setwithdrawallimit(Guild.RankLieutenant, llimit)
			if err then print(err) end
		end
		if climit ~= wlc then
			local err = Guild.setwithdrawallimit(Guild.RankCouncil, climit)
			if err then print(err) end
		end
		local allowedlist = {}
		local changed = false
		for k,v in pairs(deplut) do
			local value = v.value
			if value == "ON" then
				table.insert(allowedlist, k)
			end
			if depinitial[k] ~= value then changed = true end
		end
		if changed then Guild.allowdepositors(allowedlist) end
		allowedlist = {}
		changed = false
		for k,v in pairs(withlut) do
			local value = v.value
			if value == "ON" then
				table.insert(allowedlist, k)
			end
			if withinitial[k] ~= value then changed = true end
		end
		if changed then Guild.allowwithdrawalers(allowedlist) end
		allowedlist = {}
		changed = false
		for k,v in pairs(loglut) do
			local value = v.value
			if value == "ON" then
				table.insert(allowedlist, k)
			end
			if loginitial[k] ~= value then changed = true end
		end
		if changed then Guild.allowlogviewers(allowedlist) end
		HideDialog(dlg)
	end
	local page


	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
							iup.hbox{
								iup.vbox{iup.label{title="Deposit Access:"},depcheck1,depcheck2,depcheck3},
								iup.fill{size="5"},
								iup.vbox{iup.label{title="Withdrawal Access:"},withcheck1,withcheck2,withcheck3},
								iup.fill{size="5"},
								iup.vbox{iup.label{title="Log Access:"},logcheck1,logcheck2,logcheck3},
							},
							iup.fill{size="5"},
							iup.label{title="24 Hour Withdrawal Limits: (0=unlimited)"},
							iup.hbox{memberlimittitle,memberlimit},
							iup.hbox{lieutenantlimittitle,lieutenantlimit},
							iup.hbox{councillimittitle,councillimit},
							iup.hbox{
								iup.fill{},
								buttonok,
								iup.fill{},
								buttoncancel,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = buttonok,
		defaultesc = buttoncancel,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
		map_cb = function(self)
			local width = lieutenantlimittitle.w
			memberlimittitle.size=width
			councillimittitle.size=width
		end,
		show_cb = function(self)
			depcheck1.value = "OFF"
			depcheck2.value = "OFF"
			depcheck3.value = "OFF"
			withcheck1.value = "OFF"
			withcheck2.value = "OFF"
			withcheck3.value = "OFF"
			logcheck1.value = "OFF"
			logcheck2.value = "OFF"
			logcheck3.value = "OFF"
			depinitial={[Guild.RankMember]="OFF", [Guild.RankLieutenant]="OFF", [Guild.RankCouncil]="OFF"}
			withinitial={[Guild.RankMember]="OFF", [Guild.RankLieutenant]="OFF", [Guild.RankCouncil]="OFF"}
			loginitial={[Guild.RankMember]="OFF", [Guild.RankLieutenant]="OFF", [Guild.RankCouncil]="OFF"}
			dp,wp,lp = GetGuildBankPrivileges()
			for k,v in ipairs(dp) do
				if deplut[v] then
					deplut[v].value = "ON"
					depinitial[v] = "ON"
				end
			end
			for k,v in ipairs(wp) do
				if withlut[v] then
					withlut[v].value = "ON"
					withinitial[v] = "ON"
				end
			end
			for k,v in ipairs(lp) do
				if loglut[v] then
					loglut[v].value = "ON"
					loginitial[v] = "ON"
				end
			end
			wlm,wll,wlc = GetGuildBankWithdrawalLimits()
			memberlimit.value = wlm
			lieutenantlimit.value = wll
			councillimit.value = wlc
		end,
	}

	return dlg
end

function guildactivitylogdialogtemplate()
	local dlg
	local infolabel = iup.label{font=Font.H1,title="Activity Log", expand="YES", alignment="ACENTER"}
	local buttonclose = iup.stationbutton{title="Close", action=function() HideDialog(dlg) end}
	local buttonnext = iup.stationbutton{title="Next Page ->"}
	local buttonprev = iup.stationbutton{title="<- Previous Page"}
--	local itemlistbox = iup.stationsubsublist{expand="YES", size="%70x%33"}
	local matrix = iup.pdasubsubmatrix{
		numcol = 2,
		expand = "YES",
		size="%70x%33",
	}
	matrix["0:1"] = "Date"
	matrix["0:2"] = "Activity"
	matrix.alignment1 = "ALEFT"
	matrix.alignment2 = "ALEFT"

	function matrix:fgcolor_cb(row, col)
		local c = bg_numbers[math.fmod(row,2)]
		return c[1],c[2],c[3],c[4],iup.DEFAULT
	end
	matrix.bgcolor_cb = matrix.fgcolor_cb
	function matrix:edition_cb(line, col, mode)
		return iup.IGNORE
	end

	local page

	function buttonnext:action()
		page = page + 1
		infolabel.title = "Activity Log Page "..page
		matrix.dellin = "1--1"
--		itemlistbox[1] = "Getting page "..page.."..."
--		itemlistbox[2] = nil
		Guild.getactivitylogpage(page)
	end

	function buttonprev:action()
		page = page - 1
		if page < 1 then page = 1 return end
		infolabel.title = "Activity Log Page "..page
		matrix.dellin = "1--1"
--		itemlistbox[1] = "Getting page "..page.."..."
--		itemlistbox[2] = nil
		Guild.getactivitylogpage(page)
	end

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
--							itemlistbox,
							matrix,
							iup.hbox{
								iup.fill{},
								buttonprev,
								iup.fill{},
								buttonclose,
								iup.fill{},
								buttonnext,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = buttonnext,
		defaultesc = buttonclose,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
		show_cb = function(self)
			page = 1
			infolabel.title = "Activity Log Page "..page
			matrix.numlin = 10
			matrix.dellin = "1--1"
--			itemlistbox[1] = "Getting log..."
--			itemlistbox[2] = nil
			Guild.getactivitylogpage(page)
		end,
	}

	function dlg:OnEvent(eventname, ...)
		local loginfo = ...
		
		matrix.numlin = #loginfo
		for k,v in ipairs(loginfo) do
			matrix:setcell(k, 1, gkmisc.date("%c", v.timestamp))
			matrix:setcell(k, 2, v.activity)
		end
--		for k,v in ipairs(loginfo) do
--			itemlistbox[k] = gkmisc.date("%c", v.timestamp).."  "..v.activity
--		end
--		itemlistbox[(#loginfo)+1] = nil
		if #loginfo == 10 then
			buttonnext.active = "YES"
		else
			buttonnext.active = "NO"
		end
		if page == 1 then
			buttonprev.active = "NO"
		else
			buttonprev.active = "YES"
		end
	end

	RegisterEvent(dlg, "GUILD_ACTIVITY_LOG")

	return dlg
end

function guildbanklogdialogtemplate()
	local dlg
	local infolabel = iup.label{font=Font.H1,title="Bank Log", expand="YES", alignment="ACENTER"}
	local buttonclose = iup.stationbutton{title="Close", action=function() HideDialog(dlg) end}
	local buttonnext = iup.stationbutton{title="Next Page ->"}
	local buttonprev = iup.stationbutton{title="<- Previous Page"}
	local matrix = iup.pdasubsubmatrix{
		numcol = 6,
		expand = "YES",
		size="%80x%33",
	}
	matrix["0:1"] = "Date"
	matrix["0:2"] = "Name"
	matrix["0:3"] = "Withdrawal (-)"
	matrix["0:4"] = "Deposit (+)"
	matrix["0:5"] = "Balance"
	matrix["0:6"] = "Description"
	matrix.alignment1 = "ALEFT"
	matrix.alignment2 = "ALEFT"
	matrix.alignment3 = "ARIGHT"
	matrix.alignment4 = "ARIGHT"
	matrix.alignment5 = "ARIGHT"
	matrix.alignment6 = "ALEFT"

	function matrix:fgcolor_cb(row, col)
		local c = bg_numbers[math.fmod(row,2)]
		return c[1],c[2],c[3],c[4],iup.DEFAULT
	end
	matrix.bgcolor_cb = matrix.fgcolor_cb
	function matrix:edition_cb(line, col, mode)
		return iup.IGNORE
	end

	local page

	function buttonnext:action()
		page = page + 1
		infolabel.title = "Bank Log Page "..page
		matrix.dellin = "1--1"
		Guild.getbanklogpage(page)
	end

	function buttonprev:action()
		page = page - 1
		if page < 1 then page = 1 return end
		infolabel.title = "Bank Log Page "..page
		matrix.dellin = "1--1"
		Guild.getbanklogpage(page)
	end

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
							matrix,
							iup.hbox{
								iup.fill{},
								buttonprev,
								iup.fill{},
								buttonclose,
								iup.fill{},
								buttonnext,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = buttonnext,
		defaultesc = buttonclose,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
		show_cb = function(self)
			page = 1
			infolabel.title = "Bank Log Page "..page
			matrix.numlin = 10
			matrix.dellin = "1--1"
			Guild.getbanklogpage(page)
		end,
	}

	function dlg:OnEvent(eventname, ...)
		if dlg.visible ~= "YES" then return end
		local loginfo = ...
		
		matrix.numlin = #loginfo
-- guild bank history
		for k,v in ipairs(loginfo) do
			matrix:setcell(k, 1, gkmisc.date("%c", v.timestamp))
			matrix:setcell(k, 2, v.charname)
			local diff = v.current - v.previous
			matrix:setcell(k, 3, comma_value((diff < 0) and (-diff) or "" ))
			matrix:setcell(k, 4, comma_value((diff > 0) and (diff) or ""))
			matrix:setcell(k, 5, v.current.."  ") -- space between columns
			matrix:setcell(k, 6, "  "..v.description)
		end
		if #loginfo == 10 then
			buttonnext.active = "YES"
		else
			buttonnext.active = "NO"
		end
		if page == 1 then
			buttonprev.active = "NO"
		else
			buttonprev.active = "YES"
		end
	end

	RegisterEvent(dlg, "GUILD_BANK_LOG")

	return dlg
end

local function ranklisttostring(list)
	local t = {}
	for k,v in ipairs(list) do
		table.insert(t, Guild.RankName[v] or v)
	end
	return table.concat(t, ", ")
end


function create_char_guild_tab(issubsub)
	local reset = true
	local isvisible = false
	local container
	local stats, statshelp
	local activitylogbutton, banklogbutton, setaccessbutton
	local depositbutton, withdrawbutton

	local activitydlg = guildactivitylogdialogtemplate()
	activitydlg:map()
	local banklogdlg = guildbanklogdialogtemplate()
	banklogdlg:map()
	local depositdlg = msgpromptdlgtemplate2lines()
	depositdlg:map()
	local withdrawdlg = msgpromptdlgtemplate2lines()
	withdrawdlg:map()
	local setaccessdlg = guildaccessdialogtemplate()
	setaccessdlg:map()

	depositbutton = iup.stationbutton{title="Deposit"}
	withdrawbutton = iup.stationbutton{title="Withdraw"}
	activitylogbutton = iup.stationbutton{title="Activity Log"}
	banklogbutton = iup.stationbutton{title="Bank Log"}
	setaccessbutton = iup.stationbutton{title="Set Privileges"}
	if issubsub then
		stats = iup.stationsubsubmultiline{size="HALF",readonly="YES", expand="YES",value=""}
		statshelp = iup.stationsubsubmultiline{readonly="YES", expand="YES",value=guildhelptext}
		container =	iup.hbox{
			iup.vbox{stats,
				expand="VERTICAL",
				iup.stationsubsubframebg{
					iup.hbox{depositbutton, withdrawbutton, activitylogbutton, banklogbutton, setaccessbutton,
						iup.fill{}, alignment="ACENTER", expand="YES", margin="2x2", gap=2,
					},
				},
			},
			iup.stationsubsubframehdivider{size=5},
			statshelp,
		}
	else
		stats  = iup.stationsubmultiline{readonly="YES", expand="YES",value=""}
		statshelp = iup.stationsubmultiline{readonly="YES", expand="YES",value=guildhelptext}
		container = iup.pdasubframebg{iup.hbox{
				iup.vbox{stats,
					iup.stationsubsubframebg{
						iup.hbox{depositbutton, withdrawbutton, activitylogbutton, banklogbutton, setaccessbutton,
							iup.fill{}, alignment="ACENTER", expand="YES", margin="2x2", gap=2,
						},
					},
				},
				statshelp,
			},
		}
	end

	function activitylogbutton:action()
		ShowDialog(activitydlg, iup.CENTER, iup.CENTER)
	end
	function banklogbutton:action()
		ShowDialog(banklogdlg, iup.CENTER, iup.CENTER)
	end
	function setaccessbutton:action()
		ShowDialog(setaccessdlg, iup.CENTER, iup.CENTER)
	end
	function depositbutton:action()
		depositdlg:SetString("")
		depositdlg:SetMessage("How many credits do you want to deposit?",
			"Please enter a reason for the deposit:",
			"Deposit", function()
					local amount = tonumber(depositdlg:GetString()) or 0
					local reason = strip_whitespace(depositdlg:GetString2())
					if amount > 0 then
						HideDialog(depositdlg)
						local err = Guild.deposit(amount, reason)
						if err then print(err) end
					else
						-- error message/sound or something.
						HideDialog(depositdlg)
						ShowDialog(InvalidAmountDialog, iup.CENTER, iup.CENTER)
					end
				end,
			"Cancel", function()
					HideDialog(depositdlg)
				end)
		ShowDialog(depositdlg, iup.CENTER, iup.CENTER)
	end
	function withdrawbutton:action()
		withdrawdlg:SetString("")
		withdrawdlg:SetMessage("How many credits do you want to withdraw?",
			"Please enter a reason for the withdrawal:",
			"Withdraw", function()
					local amount = tonumber(withdrawdlg:GetString()) or 0
					local reason = strip_whitespace(withdrawdlg:GetString2())
					if amount > 0 and reason ~= "" then
						HideDialog(withdrawdlg)
						local err = Guild.withdraw(amount, reason)
						if err then print(err) end
					else
						-- error message/sound or something.
						HideDialog(withdrawdlg)
						ShowDialog(InvalidAmountDialog, iup.CENTER, iup.CENTER)
					end
				end,
			"Cancel", function()
					HideDialog(withdrawdlg)
				end)
		ShowDialog(withdrawdlg, iup.CENTER, iup.CENTER)
	end

	local function setup_char_guild_tab()
		local guildtag = GetGuildTag()
		if guildtag ~= "" then
			local info = '['..guildtag..'] You are a member of the guild '..(GetGuildName() or guildtag)..'\n'
			local motd = GetGuildMOTD()
			if motd and motd ~= "" then
				info = info..'\n'..motd..'\n'
			end
			local guildbalance = GetGuildBalance()
			info = info..'\nGuild Bank Balance: '..comma_value(guildbalance)..'c\n'
			local nummembers = GetNumGuildMembers()
			local sorttable = {}
			for i=1,nummembers do
				local id, rank, name = GetGuildMemberInfo(i)
				table.insert(sorttable, {rank, name})
			end
			table.sort(sorttable, function (a,b)
					if a[1] == b[1] then
						return a[2] < b[2]
					else
						return a[1] > b[1]
					end
				end)
			info = info..'\nMembers Currently Online ('..#sorttable..'):'
			for k,v in ipairs(sorttable) do
				info = info..'\n'..v[2]..": "..(guildrank[v[1]] or "??")
			end
--[[
			for i=1,nummembers do
				local id, rank, name = GetGuildMemberInfo(i)
				info = info..'\n'..name..": "..(guildrank[rank] or "??")
			end
--]]
			local dp,wp,lp = GetGuildBankPrivileges()
			info = info..'\n\n'..string.format("Bank Privileges:\n  deposit: %s\n  withdrawal: %s\n  log viewing: %s", ranklisttostring(dp),ranklisttostring(wp),ranklisttostring(lp))..'\n'
			local wlm,wll,wlc = GetGuildBankWithdrawalLimits()
			local wlmdesc, wlcdesc, wlldesc
			for k,v in ipairs(wp) do
				if v == Guild.RankMember then wlmdesc = wlm>0 and (comma_value(wlm).."c") or "unlimited"
				elseif v == Guild.RankCouncil then wlcdesc = wlc>0 and (comma_value(wlc).."c") or "unlimited"
				elseif v == Guild.RankLieutenant then wlldesc = wll>0 and (comma_value(wll).."c") or "unlimited"
				end
			end
			info = info..'\n'..string.format("24 Hour Withdrawal Limits:\n Members: %s\n Lieutenants: %s\n Council: %s\n Commander: unlimited",
											wlmdesc or "No Access",
											wlldesc or "No Access",
											wlcdesc or "No Access")
			stats.value = info
			stats.scroll = "TOP"
			
			-- check to see if player can do these
			local id, rank, name = GetGuildMemberInfoByCharID(GetCharacterID())
			depositbutton.active = "NO"
			withdrawbutton.active = "NO"
			activitylogbutton.active = "NO"
			banklogbutton.active = "NO"
			for k,v in ipairs(lp) do
				if v == rank or v == Guild.RankMember or ((v==Guild.RankCouncil or v==Guild.RankLieutenant) and rank==Guild.RankCouncilLieutenant)then
					activitylogbutton.active = "YES"
					banklogbutton.active = "YES"
					break
				end
			end
			for k,v in ipairs(dp) do
				if v == rank or v == Guild.RankMember or ((v==Guild.RankCouncil or v==Guild.RankLieutenant) and rank==Guild.RankCouncilLieutenant)then
					depositbutton.active = "YES"
					break
				end
			end
			for k,v in ipairs(wp) do
				if v == rank or v == Guild.RankMember or ((v==Guild.RankCouncil or v==Guild.RankLieutenant) and rank==Guild.RankCouncilLieutenant)then
					withdrawbutton.active = "YES"
					break
				end
			end
			if rank == Guild.RankCommander then
				setaccessbutton.active = "YES"
			else
				setaccessbutton.active = "NO"
			end
		else
			stats.value = "You are not a member of a guild."
			depositbutton.active = "NO"
			withdrawbutton.active = "NO"
			activitylogbutton.active = "NO"
			banklogbutton.active = "NO"
			setaccessbutton.active = "NO"
		end
	end


	function container:OnShow()
		isvisible = true
		if reset then
			reset = false
			setup_char_guild_tab()
		end
	end
	function container:OnHide()
		isvisible = false
	end
	function container:OnEvent(eventname, ...)
		if isvisible then
			setup_char_guild_tab()
		else
			reset = true
		end
	end

	RegisterEvent(container, "GUILD_PRIVILEGES_UPDATED")
	RegisterEvent(container, "GUILD_BALANCE_UPDATED")
	RegisterEvent(container, "GUILD_MOTD_UPDATED")
	RegisterEvent(container, "GUILD_MEMBERS_UPDATED")
	RegisterEvent(container, "GUILD_MEMBER_ADDED")
	RegisterEvent(container, "GUILD_MEMBER_REMOVED")
	RegisterEvent(container, "GUILD_MEMBER_UPDATED")
	RegisterEvent(container, "PLAYER_GUILD_TAG_UPDATED")
	RegisterEvent(container, "PLAYER_ENTERED_GAME")

	return container
end


