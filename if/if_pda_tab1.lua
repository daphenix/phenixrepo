-- nearby ships menu
local scrollbar_width = Font.Default

local alpha, selalpha = ListColors.Alpha, ListColors.SelectedAlpha
local even, odd, sel = ListColors[0], ListColors[1], ListColors[2]

local bg = {
	[0] = even.." "..alpha,
	[1] = odd.." "..alpha,
	[2] = sel.." "..selalpha,
}
local bg_numbers = ListColors.Numbers

local sortfuncs = {
	[1] = {
		title="Name",
		alignment="ALEFT",
		fn = function(a,b)
		
			return GetPlayerName(a) < GetPlayerName(b)
		end,
		},
	[2] = {
		title="Faction",
		alignment="ALEFT",
		fn = function(a,b)
			local faction1 = GetPlayerFaction(a) or 0
			local faction2 = GetPlayerFaction(b) or 0
			-- put all unaligned last in list
			faction1 = faction1 == 0 and 1000 or faction1
			faction2 = faction2 == 0 and 1000 or faction2
			if faction1==faction2 then
				local aname = GetPlayerName(a)
				local bname = GetPlayerName(b)
				if aname and bname then
					return aname < bname
				else
					return a < b
				end
			else
				return faction1 < faction2
			end
		end,
		},
	[3] = {
		title="Ship",
		alignment="ALEFT",
		fn = function(a,b)
			local ship1 = GetPrimaryShipNameOfPlayer(a)
			local ship2 = GetPrimaryShipNameOfPlayer(b)
			if ship1 and not ship2 then
				return true
			elseif ship2 and not ship1 then
				return false
			elseif ship1 == ship2 then
				local aname = GetPlayerName(a)
				local bname = GetPlayerName(b)
				if aname and bname then
					return aname < bname
				else
					return a < b
				end
			else
				return ship1 < ship2
			end
		end,
		},
	[4] = {
		title="Distance",
		alignment="ARIGHT",
		fn = function(a,b)
			local dist1 = GetPlayerDistance(a)
			local dist2 = GetPlayerDistance(b)
			if dist1 and not dist2 then
				return true
			elseif dist2 and not dist1 then
				return false
			elseif dist1 == dist2 then
				local aname = GetPlayerName(a)
				local bname = GetPlayerName(b)
				if aname and bname then
					return aname < bname
				else
					return a < b
				end
			else
				return dist1 < dist2
			end
		end,
		},
	update_entry = function(matrix, index, charid)
		local faction = GetPlayerFaction(charid) or 0
		local c = FactionColor_RGB[faction] or "254 54 233"
		local dist = GetPlayerDistance(charid)
		local health = GetPlayerHealth(charid)
		if health > 0 then
			health = string.format(" [%.1f%%]", health)
		elseif health == 0 then
			health = " [disabled]"
		else
			health = ""
		end
		if (not dist) or (dist > GetMaxRadarDistance()) then
			dist = nil
			c = c.." 128"
		end
		matrix:setcell(index, 1, " "..GetPlayerName(charid)..health)
		matrix:setcell(index, 2, " "..(FactionName[faction] or "Invalid faction"))
		matrix:setcell(index, 3, " "..(GetPrimaryShipNameOfPlayer(charid) or ""))
		matrix:setcell(index, 4, comma_value(dist and string.format(" %dm", dist) or ""))
		matrix:setattribute("FGCOLOR", index, -1, c)
	--	matrix:setattribute("BGCOLOR", index, -1, bg[math.fmod(index,2))
	end,
	on_sel = function(charid)
		radar.SetRadarSelection(GetPlayerNodeID(charid), GetPrimaryShipIDOfPlayer(charid))
	end,
}

local killsortfuncs = {
	[1] = {
		title="Time",
		alignment="ALEFT",
		fn = function(a,b)
			local vala = a.timestamp
			local valb = b.timestamp
			if vala == valb then
				local aname = a.name or a.charid
				local bname = b.name or b.charid
				return aname < bname
			else
				return vala > valb
			end
		end,
		},
	[2] = {
		title="Name",
		alignment="ALEFT",
		fn = function(a,b)
			return (a.name or a.charid) < (b.name or b.charid)
		end,
		},
	[3] = {
		title="Faction",
		alignment="ALEFT",
		fn = function(a,b)
			local faction1 = a.faction or 0
			local faction2 = b.faction or 0
			-- put all unaligned last in list
			faction1 = faction1 == 0 and 1000 or faction1
			faction2 = faction2 == 0 and 1000 or faction2
			if faction1==faction2 then
				local aname = a.name or a.charid
				local bname = b.name or b.charid
				return aname < bname
			else
				return faction1 < faction2
			end
		end,
		},
	[4] = {
		title="Location",
		alignment="ALEFT",
		fn = function(a,b)
			local vala = a.location
			local valb = b.location
			if vala == valb then
				local aname = a.name or a.charid
				local bname = b.name or b.charid
				return aname < bname
			else
				return vala > valb
			end
		end,
		},
	update_entry = function(matrix, index, data)
		local c = FactionColor_RGB[data.faction] or "254 54 233"
		matrix:setcell(index, 1, " "..(gkmisc.date("%c", data.timestamp)))
		matrix:setcell(index, 2, " "..(data.name or "???"))
		matrix:setcell(index, 3, " "..(FactionName[data.faction] or "Invalid faction"))
		matrix:setcell(index, 4, " "..data.location)
		matrix:setattribute("FGCOLOR", index, -1, c)
	--	matrix:setattribute("BGCOLOR", index, -1, bg[math.fmod(index,2))
	end,
	on_sel = function(data)
		radar.SetRadarSelection(GetPlayerNodeID(data.charid), GetPrimaryShipIDOfPlayer(data.charid))
	end,
}

local stationsortfuncs = {
	[1] = {
		title="Time",
		alignment="ALEFT",
		fn = function(a,b)
			local vala = a.timestamp
			local valb = b.timestamp
			if vala == valb then
				local aname = a.name or "Unknown Station"
				local bname = b.name or "Unknown Station"
				return aname < bname
			else
				return vala > valb
			end
		end,
		},
	[2] = {
		title="Station Name",
		alignment="ALEFT",
		fn = function(a,b)
			return (a.name or "Unknown Station") < (b.name or "Unknown Station")
		end,
		},
	[3] = {
		title="Faction",
		alignment="ALEFT",
		fn = function(a,b)
			local faction1 = a.faction or 0
			local faction2 = b.faction or 0
			-- put all unaligned last in list
			faction1 = faction1 == 0 and 1000 or faction1
			faction2 = faction2 == 0 and 1000 or faction2
			if faction1==faction2 then
				local aname = a.name or "Unknown Station"
				local bname = b.name or "Unknown Station"
				return aname < bname
			else
				return faction1 < faction2
			end
		end,
		},
	[4] = {
		title="Location",
		alignment="ALEFT",
		fn = function(a,b)
			local vala = a.location
			local valb = b.location
			if vala == valb then
				local aname = a.name or "Unknown Station"
				local bname = b.name or "Unknown Station"
				return aname < bname
			else
				return vala > valb
			end
		end,
		},
	update_entry = function(matrix, index, data)
		local c = FactionColor_RGB[data.faction] or "254 54 233"
		matrix:setcell(index, 1, " "..(gkmisc.date("%c", data.timestamp)))
		matrix:setcell(index, 2, " "..(data.name or "???"))
		matrix:setcell(index, 3, " "..(FactionName[data.faction] or "Invalid faction"))
		matrix:setcell(index, 4, " "..data.location)
		matrix:setattribute("FGCOLOR", index, -1, c)
	--	matrix:setattribute("BGCOLOR", index, -1, bg[math.fmod(index,2))
	end,
}

local friendkeyssortfuncs = {
	[1] = {
		title="Used",
		alignment="ALEFT",
		fn = function(a,b)
			local vala = a.isUsed and 0 or 1 -- 0=used,1=not used so sorting works,
			local valb = b.isUsed and 0 or 1
			if vala == valb then
				local aname = a.name or "???"
				local bname = b.name or "???"
				return aname < bname
			else
				return vala < valb
			end
		end,
		},
	[2] = {
		title="Date",
		alignment="ALEFT",
		fn = function(a,b)
			return (a.ts or 0) < (b.ts or 0)
		end,
		},
	[3] = {
		title="Name",
		alignment="ALEFT",
		fn = function(a,b)
			return (a.name or "???") < (b.name or "???")
		end,
		},
	update_entry = function(matrix, index, data)
		local c = data.used and "254 54 233" or "255 255 255"
		matrix:setcell(index, 1, " "..(data.isUsed and "Yes" or "NO"))
		matrix:setcell(index, 2, " "..(os.date("!%c", data.ts)))
		matrix:setcell(index, 3, " "..(data.name or "???"))
		matrix:setattribute("FGCOLOR", index, -1, c)
	--	matrix:setattribute("BGCOLOR", index, -1, bg[math.fmod(index,2))
	end,
}

local function create_player_matrix(columndefs, defsort, sortmodecb)
	local matrix
	local sortedlist
	local update_matrix
	local sort_key = defsort -- default to sort by distance
	local numcolumns = (#columndefs)
	local function set_sort_mode(mode)
		-- clicked on title of column
		sort_key = mode
		if sortmodecb then sortmodecb(mode) end
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
		local targetobj_nodeid = radar.GetRadarSelectionID()
		local colorindex = math.fmod(row,2)
		if targetobj_nodeid and targetobj_nodeid == GetPlayerNodeID(sortedlist[row]) then
			colorindex = 2
		end
		local c = bg_numbers[colorindex]
		return c[1],c[2],c[3],c[4],iup.DEFAULT
	end
	matrix.bgcolor_cb = matrix.fgcolor_cb
	function matrix:click_cb(row, col)
		if row == 0 then
			set_sort_mode(col)
			update_matrix(self)
		elseif columndefs.on_sel then
			columndefs.on_sel(sortedlist[row])
			update_matrix(self)
		end
	end
	function matrix:edition_cb()
		return iup.IGNORE
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

function CreateNearbyShipsPDATab()
	local isvisible = false
	local matrix, proxtoggle, proxdistance, oneoffproxtoggle, warnpcproxtoggle, warnnpcproxtoggle
	local update_timer

	update_timer = Timer()

	matrix = create_player_matrix(sortfuncs, SensorSort,
			function(sortmode)
				SensorSort = sortmode
				gkini.WriteInt("Vendetta", "sensorsort", sortmode)
			end)

	function matrix:edition_cb(line, col, mode)
		-- close the window
		ProcessEvent("PLAYERLIST_TOGGLE")
		return iup.IGNORE
	end

	proxtoggle = iup.stationtoggle{
		title = "Proximity Warning",
		action = function(self, state)
				if state == 1 then
					EnableProximityWarning()
				else
					DisableProximityWarning()
				end
			end,
	}

	oneoffproxtoggle = iup.stationtoggle{
		title = "Only Once",
		tip = 'Warn only once until\nproximity exceeded to\nprevent multiple occlusion\nwarnings';
		action = function(self, state)
				if state == 1 then
					EnableOneOffProximityWarning()
				else
					DisableOneOffProximityWarning()
				end
			end,
	}

	warnpcproxtoggle = iup.stationtoggle{
		title = "PC Prox",
		action = function(self, state)
				if state == 1 then
					EnablePlayerProximityWarning()
				else
					DisablePlayerProximityWarning()
				end
			end,
	}

	warnnpcproxtoggle = iup.stationtoggle{
		title = "NPC Prox",
		action = function(self, state)
				if state == 1 then
					EnableNPCProximityWarning()
				else
					DisableNPCProximityWarning()
				end
			end,
	}

	local function setproxdist(str)
		local num = tonumber(str) or -1
		proxdistance.value = tostring(num)
		SetProximityWarningDistance(num)
	end

	proxdistance = iup.text{
		value = "2000",
		size = tostring(Font.Default*5),
		action = function(self, ch, after)
				if ch == 13 then -- FIXME: this should be KEY_RETURN after we fix IUP/OnChar/OnKey/blah
					setproxdist(self.value)
					return iup.IGNORE
				end
			end,
		killfocus_cb = function(self)
				setproxdist(self.value)
			end,
	}

	local container = iup.vbox{
		matrix,
		iup.stationsubsubframevdivider{size=4},
		iup.pdasubsubframebg{
			iup.hbox{
				iup.fill{},
				proxtoggle,
				proxdistance,
				iup.label{title="meters "},
				warnpcproxtoggle,
				warnnpcproxtoggle,
				oneoffproxtoggle,
				alignment = "ACENTER",
				gap="5",
			},
		},
	}

	local function reset_matrix()
		local sortedlist = {}
		ForEachPlayer( function(characterid)
				if characterid and characterid ~= 0 then
					table.insert(sortedlist, characterid)
				end
			end)
		matrix:reset(sortedlist)
	end

	local function timer_cb()
		matrix:update()
		update_timer:SetTimeout(1000)
	end


	function container:OnShow()
		local wid = (getwidth(matrix) - scrollbar_width) / 4
		matrix.width1 = wid * 1.6 -- name
		matrix.width2 = wid * 0.7    -- faction
		matrix.width3 = wid * 1.2 -- ship
		matrix.width4 = wid * 0.5    -- distance
		isvisible = true
		RegisterEvent(container, "PLAYER_ENTERED_SECTOR")
		RegisterEvent(container, "PLAYER_LEFT_SECTOR")
		RegisterEvent(container, "UPDATE_CHARINFO")
		reset_matrix()
		proxtoggle.value = IsProximityWarningEnabled() and "ON" or "OFF"
		oneoffproxtoggle.value = IsOneOffProximityWarningEnabled() and "ON" or "OFF"
		warnpcproxtoggle.value = IsPlayerProximityWarningEnabled() and "ON" or "OFF"
		warnnpcproxtoggle.value = IsNPCProximityWarningEnabled() and "ON" or "OFF"
		proxdistance.value = tostring(GetProximityWarningDistance())
		update_timer:SetTimeout(1000, timer_cb)
	end

	function container:OnHide()
		isvisible = false
		UnregisterEvent(container, "PLAYER_ENTERED_SECTOR")
		UnregisterEvent(container, "PLAYER_LEFT_SECTOR")
		UnregisterEvent(container, "UPDATE_CHARINFO")
		update_timer:Kill()
	end

	function container:OnEvent(eventname, ...)
		if eventname == "PLAYER_ENTERED_SECTOR" or
				eventname == "UPDATE_CHARINFO" or
				eventname == "PLAYER_LEFT_SECTOR" then
			if isvisible then
				reset_matrix()
			end
		end
	end

	return container
end

function CreateKilledPDATab()
	local isvisible = false
	local matrix, killlist

	killlist = {}

	matrix = create_player_matrix(killsortfuncs, 1)

	local container = iup.vbox{
		matrix,
	}

	local function reset_matrix()
		matrix:reset(killlist)
	end

	function container:OnShow()
		local wid = (getwidth(matrix) - scrollbar_width) / 4
		matrix.width1 = wid        -- time
		matrix.width2 = wid * 1.5 -- name
		matrix.width3 = wid * .75    -- faction
		matrix.width4 = wid * .75 -- location
		isvisible = true
		reset_matrix()
	end

	function container:OnHide()
		isvisible = false
	end

	function container:OnEvent(eventname, ...)
		local arg1, arg2 = ...
		if eventname == "PLAYER_DIED" and arg2 == GetCharacterID() then
			table.insert(killlist, 1, {
					timestamp = os.time(),
					name=GetPlayerName(arg1),
					faction=GetPlayerFaction(arg1),
					location=ShortLocationStr(GetCurrentSectorid()),
				})
			if (#killlist) > 20 then
				table.remove(killlist)
			end
			if isvisible then
				reset_matrix()
			end
		elseif eventname == "PLAYER_ENTERED_GAME" then
			killlist = {} -- or we could load it from some file that was saved when the player logs out or something.
		end
	end
	RegisterEvent(container, "PLAYER_DIED")
	RegisterEvent(container, "PLAYER_ENTERED_GAME")

	return container
end

function CreateKilledByPDATab()
	local isvisible = false
	local matrix, killlist

	killlist = {}

	matrix = create_player_matrix(killsortfuncs, 1)

	local container = iup.vbox{
		matrix,
	}

	local function reset_matrix()
		matrix:reset(killlist)
	end

	function container:OnShow()
		local wid = (getwidth(matrix) - scrollbar_width) / 4
		matrix.width1 = wid        -- time
		matrix.width2 = wid * 1.5 -- name
		matrix.width3 = wid * .75    -- faction
		matrix.width4 = wid * .75-- location
		isvisible = true
		reset_matrix()
	end

	function container:OnHide()
		isvisible = false
	end

	function container:OnEvent(eventname, ...)
		local arg1, arg2 = ...
		if eventname == "PLAYER_DIED" and arg1 == GetCharacterID() then
			table.insert(killlist, 1, {
					timestamp = os.time(),
					name=GetPlayerName(arg2),
					faction=GetPlayerFaction(arg2),
					location=ShortLocationStr(GetCurrentSectorid()),
				})
			if (#killlist) > 20 then
				table.remove(killlist)
			end
			if isvisible then
				reset_matrix()
			end
		elseif eventname == "PLAYER_ENTERED_GAME" then
			killlist = {} -- or we could load it from some file that was saved when the player logs out or something.
		end
	end
	RegisterEvent(container, "PLAYER_DIED")
	RegisterEvent(container, "PLAYER_ENTERED_GAME")

	return container
end

-- pvp tab --
local pvpsortfuncs = {
	[1] = {
		title="Name",
		alignment="ALEFT",
		fn = function(a,b)
			return a.name < b.name
		end,
		},
	[2] = {
		title="Location",
		alignment="ALEFT",
		fn = function(a,b)
			return a.location < b.location
		end,
		},
	[3] = {
		title="Killed",
		alignment="ARIGHT",
		fn = function(a,b)
			return a.killed > b.killed
		end,
		},
	[4] = {
		title="Killed by",
		alignment="ARIGHT",
		fn = function(a,b)
			return a.killed_by > b.killed_by
		end,
		},
	[5] = {
		title="Ratio",
		alignment="ARIGHT",
		fn = function(a,b)
			return a.ratio > b.ratio
		end,
		},
	update_entry = function(matrix, index, data)
		matrix:setcell(index, 1, data.name)
		matrix:setcell(index, 2, data.location)
		matrix:setcell(index, 3, data.killed)
		matrix:setcell(index, 4, data.killed_by)
		matrix:setcell(index, 5, data.ratio)

		local c = FactionColor_RGB[data.faction] or "254 54 233"
		matrix:setattribute("FGCOLOR", index, 1, c)
	end,
} -- pvpsortfuncs

function CreatePVPTab()
	local isvisible = false
	local pvplist = {}

	local matrix = create_player_matrix(pvpsortfuncs, 1)

	-- t_* is totals for the stats on the bottom of the matrix.
	local t_players = iup.label{title='12345'}
	local t_killed = iup.label{title='12345'}
	local t_killed_by = iup.label{title='12345'}
	local t_ratio = iup.label{title='12345'}

	local container = iup.vbox{
		matrix,
		iup.stationsubsubframevdivider{size=4},
		iup.pdasubsubframebg{
			iup.hbox {
				iup.label{title='Total Players:'}, t_players, iup.fill{},
				iup.label{title='Total Kills:'}, t_killed, iup.fill{},
				iup.label{title='Total Deaths:'}, t_killed_by, iup.fill{},
				iup.label{title='Average Ratio:'}, t_ratio, iup.fill{},
				expand='YES', margin='2x2', gap=2
			},
		},
	}
	
	local function make_pvp_stats()
		if #pvplist > 0 then -- only if we have data
			-- total players we know, #pvplist, 
			-- average ratio we can get = r1 + r2 + .... rN / N 
			local killed = 0
			local killed_by = 0
			local ratio = 0
		
			for x,v in ipairs(pvplist) do
				killed = killed + v.killed
				killed_by = killed_by + v.killed_by
				ratio = ratio + v.ratio
			end
			ratio = string.format("%.2f", killed / killed_by) -- stop .xxxxxxxx format
			t_players.title = #pvplist
			t_killed.title = killed
			t_killed_by.title = killed_by
			t_ratio.title = ratio
		else
			-- default empty set,
			t_players.title = '0'
			t_killed.title = '0'
			t_killed_by.title = '0'
			t_ratio.title = '-'
		end
	end -- end make_pvp_stats

	local function update_tbl(tbl,name,offset)
		local notfoundflag = true
		local faction = GetPlayerFaction(name)
		local guildtag = GetGuildTag(name)
		local Tag = (guildtag ~= '') and '['..guildtag..'] ' or ''
		local player_name = Tag..GetPlayerName(name)
		local location = ShortLocationStr(GetCurrentSectorid())

		for x,v in ipairs(tbl) do
			if v.name == player_name then
				-- we have a record, increase the count by 1.
				if offset then v.killed = v.killed + 1
				else v.killed_by = v.killed_by + 1
				end
				v.location = location
				if v.killed_by < 1 then 
					v.ratio = tbl[x].killed
				else
					v.ratio = math.floor(100*v.killed/v.killed_by)/100 or v.killed or 'x'
				end
				notfoundflag = false
				break
			end
		end
	
		if notfoundflag and offset then
			table.insert(tbl, 1, {name=player_name, location=location,
				killed = 1,
				killed_by = 0,
				ratio = 1,
				faction=faction,
				})
		elseif notfoundflag and not offset then
			table.insert(tbl, 1, {name=player_name, location=location,
				killed = 0,
				killed_by = 1,
				ratio = 0,
				faction=faction,
			})
		end
		return tbl
	end -- end update_tbl

	local function reset_matrix()
		matrix:reset(pvplist)
		make_pvp_stats()
	end

	function container:OnShow()
		local wid = (getwidth(matrix) - scrollbar_width) / 4
		matrix.width1 = wid * 1.5 -- name
		matrix.width2 = wid -- location
		matrix.width3 = wid / 2 -- killed
		matrix.width4 = wid / 2 -- killed by
		matrix.width5 = wid / 2 -- ratio
		isvisible = true
		reset_matrix()
	end

	function container:OnHide()
		isvisible = false
	end
	
	function container:OnEvent(eventname, ...)
		--arg1 = victim, arg2 = killer, arg3 = weaponid
		local victim_id, killer_id = ...
		local me = GetCharacterID()

		if eventname == "PLAYER_DIED" then
			local killed_by = GetPlayerName(killer_id)
			local killed = GetPlayerName(victim_id)
			
			--ignore explodes and bots
			if killer_id == me and not killed:match("\^*") and victim_id ~= me then
				-- we killed some player
				pvplist = update_tbl(pvplist,victim_id,true)

			elseif victim_id == me and not killed_by:match("\^*") and killer_id ~= me then
				-- we died to some player
				pvplist = update_tbl(pvplist,killer_id,false)
			end
			if (#pvplist) > 50 then -- several have reached more than 20
				table.remove(pvplist)
			end
			if isvisible then
				reset_matrix()
			end
		elseif eventname == "PLAYER_ENTERED_GAME" then
			pvplist = {}
		end
	end
	RegisterEvent(container, "PLAYER_DIED")
	RegisterEvent(container, "PLAYER_ENTERED_GAME")

	return container
end -- function CreatePVPTab()
-- pvp tab --


--[[

Num available: x/max
Num per month: y

name  date  accepted

[Give]

--]]

emailpromptdlg = emailpromptdlgtemplate("Give",
	function()
		local email = emailpromptdlg:GetString2()
		-- validate email
		if email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") then
			if FriendKeys.give(emailpromptdlg:GetString1(), emailpromptdlg:GetString2(), emailpromptdlg:GetString3()) then
				HideDialog(emailpromptdlg)
			else
				OpenAlarm("Error", "Please type in your friend's name.", "OK")
			end
		else
			OpenAlarm("Error", "An invalid email address has been entered.", "OK")
		end
	end,
	"Cancel",
	function() HideDialog(emailpromptdlg) end
	)

function CreateFriendKeysPDATab()
	local isvisible = false
	local reloadinfo = true
	local matrix, friendkeylist, give_button
	local info1, info2

	friendkeylist = {}

	matrix = create_player_matrix(friendkeyssortfuncs, 2)

	give_button = iup.stationbutton{title="Give...", active="NO", action=function()
			emailpromptdlg:SetYourName(FriendKeys.GetAccountName())
			ShowDialog(emailpromptdlg)
		end}

	info1 = iup.label{title="0/0",expand="HORIZONTAL"}
	info2 = iup.label{title="0",expand="HORIZONTAL"}

	local container = iup.vbox{
		matrix,
		iup.stationsubsubframebg{
			iup.vbox{
				iup.hbox{iup.label{title="Number of available keys: "},info1},
				iup.hbox{iup.label{title="Number of new keys per subscribed month: "},info2},
				give_button,
				iup.fill{},
				alignment="ACENTER", expand="YES", margin="2x2", gap=2
			},
		}
	}

	local function reset_matrix()
		if reloadinfo then
			friendkeylist = {}

			FriendKeys.ForEach(function(id,ts,isUsed,name) table.insert(friendkeylist, {id=id,ts=ts,isUsed=isUsed,name=name}) end)

			give_button.active = (FriendKeys.GetNumAvailableKeys() > 0) and "YES" or "NO"

			info1.title = FriendKeys.GetNumAvailableKeys().."/"..FriendKeys.GetMaxNumKeys()
			info2.title = FriendKeys.GetNumNewKeysPerMonth()
		end

		matrix:reset(friendkeylist)
	end

	function container:OnShow()
		local wid = (getwidth(matrix) - scrollbar_width) / 3
		matrix.width1 = wid * .25    -- used
		matrix.width2 = wid * 1     -- timstamp
		matrix.width3 = wid * 1.75   -- name
		isvisible = true
		reset_matrix()
	end

	function container:OnHide()
		isvisible = false
	end

	function container:OnEvent(eventname, ...)
		if eventname == "UPDATE_FRIENDKEY_LIST" then
			
			reloadinfo = true

			if isvisible then
				reset_matrix()
			end
		end
	end

	RegisterEvent(container, "UPDATE_FRIENDKEY_LIST")

	return container
end

function CreateStationVisitsPDATab()
	local isvisible = false
	local matrix, stationvisitlist

	stationvisitlist = {}

	matrix = create_player_matrix(stationsortfuncs, 1)

	local container = iup.vbox{
		matrix,
	}

	local function reset_matrix()
		matrix:reset(stationvisitlist)
	end

	function container:OnShow()
		local wid = (getwidth(matrix) - scrollbar_width) / 4
		matrix.width1 = wid       -- time
		matrix.width2 = wid * 1.5 -- name
		matrix.width3 = wid * .75   -- faction
		matrix.width4 = wid * .75   -- location
		isvisible = true
		reset_matrix()
	end

	function container:OnHide()
		isvisible = false
	end

	function container:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" then
			table.insert(stationvisitlist, 1, {
					timestamp = os.time(),
					name=tostring(GetStationName()),
					faction=GetStationFaction(),
					location=ShortLocationStr(GetCurrentSectorid()),
				})
			if (#stationvisitlist) > 20 then
				table.remove(stationvisitlist)
			end
			if isvisible then
				reset_matrix()
			end
		elseif eventname == "PLAYER_ENTERED_GAME" then
			stationvisitlist = {} -- or we could load it from some file that was saved when the player logs out or something.
		end
	end
	RegisterEvent(container, "ENTERING_STATION")
	RegisterEvent(container, "PLAYER_ENTERED_GAME")

	return container
end

function CreateNavigationPDATab()
	local isvisible = false
	local reset = true
	local container, distancetext, jumpbutton, zoombutton, undolastbutton
	local distanceupdatetimer, close_dlg

	close_dlg = function(self)
		SaveNavpath(NavRoute.GetCurrentRoute(), nil)
		HideDialog(iup.GetDialog(self))
		container.SetDesc("")
		if PlayerInStation() then
			ShowDialog(StationDialog)
		else
			ShowDialog(HUD.dlg)
		end
	end

	distanceupdatetimer = Timer()

	container, distancetext, jumpbutton, zoombutton, undolastbutton = navmenu_template(true, close_dlg, true)

--	function container:k_any(ch)
----		if (ch == iup.K_j and jumpbutton.active == "YES") or
----			(ch == iup.K_u and undolastbutton.active == "YES") or
--		if (ch == iup.K_j) or
--			(ch == iup.K_u) or
--			(ch == iup.K_z) then
--			return iup.IGNORE
--		end
--		return iup.CONTINUE
--	end

	function container:OnShow()
		isvisible = true
		if reset then
			reset = false
			container:init()
		end

		if PlayerInStation() then
			distancetext.visible = "NO"
			jumpbutton.visible = "NO"
		else
			distanceupdatetimer:SetTimeout(10, function()
					local dist = radar.GetNearestObjectDistance()
					if dist < 0 or dist >= GetMinJumpDistance() then
						jumpbutton.active = "YES"
						dist = GetMinJumpDistance()
						distancetext.fgcolor = "0 255 0"
					else
						jumpbutton.active = "NO"
						distancetext.fgcolor = "255 0 0"
					end
					distancetext.title = string.format("Dist: %dm", dist)
					distanceupdatetimer:SetTimeout(20)
				end)
			distancetext.visible = "YES"
			jumpbutton.visible = "YES"
		end
	end

	function container:OnHide()
		isvisible = false
		distanceupdatetimer:Kill()
	end

	function container:OnEvent(eventname, ...)
		if eventname == "NAVROUTE_CHANGED" then
			container.update()
		elseif eventname == "NAVROUTE_UNDOLAST" then
			container.undo_last()
		elseif eventname == "NAVROUTE_ADD" then
			local sectoridtoadd = ...
			container.SetClickedSector(sectoridtoadd)
		elseif eventname == "SECTOR_CHANGED" then
			container.enter_sector()
		elseif eventname == "CONQUERED_SECTORS_UPDATED" then
			if isvisible then container.update_conquered_sectors() end
		end
		reset = true
	end

	RegisterEvent(container, "NAVROUTE_CHANGED")
	RegisterEvent(container, "NAVROUTE_ADD")
	RegisterEvent(container, "NAVROUTE_UNDOLAST")
	RegisterEvent(container, "SECTOR_CHANGED")
	RegisterEvent(container, "CONQUERED_SECTORS_UPDATED")

	return container
end

function CreateShipCargoPDATab()
	return create_jettison_control()
end

function CreateShipPDATab()
	local tab1

	tab1 = CreateNavigationPDATab() tab1.tabtitle="Navigation"

	tab1.OnHelp = HelpStationNav

	return iup.subsubtabtemplate{tab1}, tab1
end

function CreateSensorPDATab()
	local tab1, tab2, tab3, tab4, stationvisits

	tab1 = CreateNearbyShipsPDATab() tab1.tabtitle="Nearby Ships"  tab1.hotkey=iup.K_u
	stationvisits = CreateStationVisitsPDATab() stationvisits.tabtitle="Stations" stationvisits.hotkey=iup.K_a
	tab2 = CreateKilledPDATab() tab2.tabtitle="Killed List" tab2.hotkey=iup.K_d
	tab3 = CreateKilledByPDATab() tab3.tabtitle="Killed-By List" tab3.hotkey=iup.K_b
	tab4 = CreatePVPTab() tab4.tabtitle="PVP" tab4.hotkey=iup.K_v

	tab1.OnHelp = HelpPDANearbyShips
	stationvisits.OnHelp = HelpPDAStationVisitsList
	tab2.OnHelp = HelpPDAKilledList
	tab3.OnHelp = HelpPDAKilledByList
	tab4.OnHelp = HelpPDAPVPList

	return iup.subsubtabtemplate{tab1,stationvisits, tab2,tab3, tab4}, tab1, tab2, tab3, stationvisits, tab4
end

dofile(IF_DIR.."if_keychain_template.lua")

function CreateInventoryPDATab()
	local tab1, tab2, tab3

	tab1 = create_char_inventory_tab() tab1.tabtitle="Inventory"
	tab2 = CreateShipCargoPDATab() tab2.tabtitle="Cargo"
	tab3 = create_keychain_tab(true) tab3.tabtitle="Keychain"  tab3.hotkey=iup.K_k

	tab1.OnHelp = HelpCharInventory
	tab2.OnHelp = HelpPDAJettison
	tab3.OnHelp = HelpCharKeychain

	return iup.subsubtabtemplate{tab1, tab2, tab3}, tab1, tab2, tab3
end
