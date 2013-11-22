-- user selection menu
local sortedlist = {}
local dlg, update_timer

local usermatrix = iup.matrix{
	numcol=2,
	numcol_visible=2, numlin_visible=15,
	resizematrix="YES",
	expand="YES",
	alignment1 = "ALEFT",
	alignment2 = "ACENTER",
	bgcolor = "0 0 0 0 +",
}
usermatrix:setcell(0,1,"Name")
usermatrix:setcell(0,2,"Nation")

local closebutton = iup.stationbutton{title="Close"}

local frame = iup.stationhighopacityframe{ iup.stationhighopacityframebg{
	iup.vbox{
		iup.label{title="Click on a player to target their ship"},
		usermatrix,
		closebutton,
		alignment="ACENTER",
	}
}}

update_timer = Timer()

local function hide_dlg(dlg)
	update_timer:Kill()
	HideDialog(dlg)
end

dlg = iup.dialog{
	frame,
	resize="NO",
	border="NO",
	menubox="NO",
	size="xTWOTHIRD",
	bgcolor="0 0 0 0 +",
	defaultesc=closebutton,
	k_any=function(self, ch)
		if gkinterface.GetCommandForKeyboardBind(ch) == "+TopList" then
			hide_dlg(dlg)
			ShowDialog(HUD.dlg)
			return iup.IGNORE
		end
		return iup.CONTINUE
	end,
}
dlg:map()

function usermatrix:enteritem_cb(row, col)
	local charid = sortedlist[row]
	radar.SetRadarSelection(GetPlayerNodeID(charid), GetPrimaryShipIDOfPlayer(charid))
	hide_dlg(dlg)
	ShowDialog(HUD.dlg)
end
function closebutton:action()
	hide_dlg(dlg)
	ShowDialog(HUD.dlg)
end

local function clear_matrix()
	usermatrix.dellin = "1-"..(#sortedlist)  -- one way of deleting all items in the matrix
end

local function load_matrix()
	sortedlist = {}
	
	ForEachPlayer( function(characterid)
			if characterid and characterid ~= 0 then
				table.insert(sortedlist, characterid)
			end
		end)
	table.sort(sortedlist,
		function(a,b)
			local afac = GetPlayerFaction(a) or 0
			local bfac = GetPlayerFaction(b) or 0
			-- put all bots last in userlist
			afac = afac == 0 and 1000 or afac
			bfac = bfac == 0 and 1000 or bfac
			if afac==bfac then
				local aname = GetPlayerName(a)
				local bname = GetPlayerName(b)
				if aname and bname then
					return aname < bname
				else
					return a < b
				end
			else
				return afac < bfac
			end
		end)

	usermatrix.numlin = (#sortedlist)

	for k,v in ipairs(sortedlist) do
		usermatrix:setcell(k, 1, GetPlayerName(v))
		local faction = GetPlayerFaction(v) or 0
		usermatrix:setcell(k, 2, tostring(FactionName[faction]))
		local c = FactionColor_RGB[faction]
		local dist = GetPlayerDistance(v)
		if (not dist) or (dist > GetMaxRadarDistance()) then
			c = c.." 128"
		end
		usermatrix["FGCOLOR"..k..":1"] = c
		usermatrix["FGCOLOR"..k..":2"] = c
	end
end

local function reload_matrix()
	clear_matrix()
	load_matrix()
end

local function update_matrix()
	for k,v in ipairs(sortedlist) do
		local c = FactionColor_RGB[GetPlayerFaction(v) or 0]
		local dist = GetPlayerDistance(v) or 1e6  -- GetPlayerDistance() returns nil if player is self or player isn't in sector or player doesn't have a ship (they exploded or something)
		if dist > GetMaxRadarDistance() then
			c = c.." 128"
		end
		usermatrix["FGCOLOR"..k..":1"] = c
		usermatrix["FGCOLOR"..k..":2"] = c
	end
end

local function timer_cb()
	if dlg.visible == "YES" then
		update_matrix()
		update_timer:SetTimeout(1000)
	end
end
function dlg:show_cb()
	update_timer:SetTimeout(1000, timer_cb)
end


local callback = {}

--RegisterEvent(callback, "PLAYERLIST_TOGGLE")
RegisterEvent(callback, "PLAYER_ENTERED_SECTOR")
RegisterEvent(callback, "PLAYER_LEFT_SECTOR")
RegisterEvent(callback, "UPDATE_CHARINFO")

function callback:OnEvent(eventname, ...)
	if eventname == "PLAYERLIST_TOGGLE" then
		if dlg.visible == "YES" then
			hide_dlg(dlg)
			ShowDialog(HUD.dlg)
		elseif HUD.IsVisible then
			HideDialog(HUD.dlg)
			HideAllDialogs()
			reload_matrix()
			ShowDialog(dlg, iup.CENTER, iup.CENTER)
		end
	elseif eventname == "PLAYER_ENTERED_SECTOR" or
			eventname == "UPDATE_CHARINFO" or
			eventname == "PLAYER_LEFT_SECTOR" then
		if dlg.visible == "YES" then
			reload_matrix()
			ShowDialog(dlg, iup.CENTER, iup.CENTER)
		end
	end
end

dlg.callbacktable = callback

UserSelectMenu = dlg
