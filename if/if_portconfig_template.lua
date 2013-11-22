local helpfulequiptext = "This is the Addons interface. From here you can equip addons you have purchased onto your ship. First click on a port on the picture of your ship. Then double-click to select addons from the list on the left-hand side. Red addons are not compatible with the selected port. There are Small Ports, Large Ports and Power Cell Ports. You may only load Small Port Addons into Small Ports, and so on. Any addons to be equipped must be present in your local station inventory; addons at other stations cannot be loaded without traveling and equipping there."
local helpfulgrouptext = "Here you can pick which ports are \"fired\" by which triggers. The triggers default to the three mouse buttons. You also have six groups of definitions, marked by the Key buttons at the top, which default through number keys 1 through 6. For each Key you can define different uses for the three Triggers. The first Key is always your default group. See Help for more information."
local helpfulwrongaddontext = "This addon is not compatible with the port type that you currently have selected. You may only load addons onto compatible port types, Small to Small, Large to Large, and so on. To load this addon onto your ship, you either need to select a compatible port (if one exists), or upgrade to a different type of ship with a greater variety of port types. Here are the stats for the selected addon:\n"

local portlocations_equip = {}  -- indexed by itemtype
local portlocations_group = {}  -- indexed by itemtype

local AddonPortType_Small = 0
local AddonPortType_Large = 1
local AddonPortType_Engine = 3
local AddonPortType_PowerCell = 4
local AddonPortType_Turret = 5

local portconfig = {
	[AddonPortType_Small] = { -- small port addons
		emptyicon = "images/icon_s_empty.png",
		iconsize = "32x32",
	},
	[AddonPortType_Large] = { -- large port addons
		emptyicon = "images/icon_l_empty.png",
		iconsize = "48x48",
	},
	[AddonPortType_Engine] = { -- engines
		emptyicon = "images/hud_target.jpg",
		iconsize = "48x48",
	},
	[AddonPortType_PowerCell] = { -- batteries
		emptyicon = "images/icon_addon_empty.png",
		iconsize = "48x48",
	},
	[AddonPortType_Turret] = { -- turret
		emptyicon = "images/icon_ship_turret.png",
		iconsize = "48x48",
	},
}

local K = 15
local K2 = 100
local M = 1
local DAMP = 0.5

function OverlapPrevention(icon_positions)
	local t = .05
	local function single_iteration(icon_positions)
		local overlap = false
		local sx, sy
		for k,v in pairs(icon_positions) do
			v.fx = -K * (v.newx - v.originx)
			v.fy = -K * (v.newy - v.originy)
		end
		for k,v in pairs(icon_positions) do
			for a,b in pairs(icon_positions) do
				if k < a then
					local diffx = v.newx-b.newx
					local min_dist = (v.size+b.size)+5
					if math.abs(diffx) < min_dist then
						local diffy = v.newy-b.newy
						if math.abs(diffy) < min_dist then
							if diffx > 0 then sx = 1 else sx = -1 end
							if diffy > 0 then sy = 1 else sy = -1 end
							diffx = math.abs(diffx)
							diffy = math.abs(diffy)
							if diffx > 0 then
								v.fx = v.fx - -K2*(min_dist - diffx)*sx
								b.fx = b.fx + -K2*(min_dist - diffx)*sx
							end
							if diffy > 0 then
								v.fy = v.fy - -K2*(min_dist - diffy)*sy
								b.fy = b.fy + -K2*(min_dist - diffy)*sy
							end
							overlap = true
						end
					end
				end
			end
		end
--		if overlap then
			for k,v in pairs(icon_positions) do
--debugprint(k.." : "..v.fx)
				v.vx = (v.vx + (v.fx/M)*t)*DAMP
				v.vy = (v.vy + (v.fy/M)*t)*DAMP
				v.newx = v.newx + (v.vx)*t
				v.newy = v.newy + (v.vy)*t
			end
--		end
		return overlap
	end

	if icon_positions.done then return end

	for k,v in pairs(icon_positions.icon_positions) do
		v.newx = v.pos:x()
		v.newy = v.pos:y()
		v.vx = v.vx or 0
		v.vy = v.vy or 0
	end
	for i=1,1 do
		if not single_iteration(icon_positions.icon_positions) then icon_positions.done = true break end
	end
	for k,v in pairs(icon_positions.icon_positions) do
		v.pos:SetX(v.newx)
		v.pos:SetY(v.newy)
	end
end

function ReinitIconPositions(icontimer, shipitemid, viewport, iconlist, iconcontainer, icon_position_cache)
	if not shipitemid then return end
	local shipitemtype = GetInventoryItemType(shipitemid)
	local viewposx = math.floor(tonumber(viewport.x))
	local viewposy = math.floor(tonumber(viewport.y))
	local viewposw = math.floor(tonumber(viewport.w))
	local viewposh = math.floor(tonumber(viewport.h))
	local icon_positions = icon_position_cache[shipitemtype]
	if (not icon_positions) or (viewposw ~= icon_positions.width) or (viewposh ~= icon_positions.height) then
		icon_positions = {icon_positions={},width = viewposw,height = viewposh}
		icon_position_cache[shipitemtype] = icon_positions
		local icon_position_data = icon_positions.icon_positions
		for portid,portdata in pairs(iconlist) do
			local portinfo = GetActiveShipPortInfo(portid)
			local proj = viewport:ProjectPoint(portinfo and portinfo.position or gvector(0,0,0))
			if proj then
				icon_position_data[portid] = {
					pos = proj,
					size = portdata.porttype==AddonPortType_Small and 16 or 24,
					newx = 0,
					newy = 0,
					originx = proj:x(),
					originy = proj:y(),
				}
			end
		end
	end
	OverlapPrevention(icon_positions)
	for portid,v in pairs(icon_positions.icon_positions) do
		local portdata = iconlist[portid]
		if portdata then  -- check this because portid may be = "done" because I add that thing to the table
			portdata.iconcontainer.cx = v.pos:x() - viewposx - v.size
			portdata.iconcontainer.cy = v.pos:y() - viewposy - v.size
		end
	end
	iconcontainer.refresh = 1

	local counter = 0
	icontimer:SetTimeout(20, function()
			OverlapPrevention(icon_positions)
			for portid,v in pairs(icon_positions.icon_positions) do
				local portdata = iconlist[portid]
				if portdata then  -- check this because portid may be = "done" because I add that thing to the table
					iup.StoreAttribute(portdata.iconcontainer, "CX", v.pos:x() - viewposx - v.size)
					iup.StoreAttribute(portdata.iconcontainer, "CY", v.pos:y() - viewposy - v.size)
				end
			end
			iconcontainer.refresh = 1
			counter = counter + 1
			if counter < 200 then
				icontimer:SetTimeout(20)
			else
				icontimer = nil
				icon_positions.done = true
			end
		end)
end



local function create_ship_equip_tab(_iconlist)
	local container
	local addonlist, equipportinfo
	local equipbutton, unequipbutton, unequipallbutton
	local t_station, curselport
	local iconlist = _iconlist
	local setup_info_text_by_itemid, setup_info_text_by_portid

	local function ActivateEquipButton()
		local itemid = t_station[tonumber(addonlist.value)+1]
		local canuse, reqlevels = CanUseAddon(itemid)
		if not canuse then
			equipbutton.active = "NO"
			return
		end
		if curselport ~= 0 and itemid then
			local str
			local icon, name, quan, mass, desc, longdesc = GetInventoryItemInfo(itemid)
			str = (name or "").."\n"..string.gsub((longdesc or ""), "|", "\n")

			local thing = GetActiveShipPortInfo(curselport)
			if thing and GetInventoryItemClassSubType(itemid) == thing.type then
				equipbutton.active = "YES"
			else
				equipbutton.active = "NO"
				str = helpfulwrongaddontext..str
			end
			equipportinfo.value = str
			equipportinfo.scroll = "TOP"
		else
			equipbutton.active = "NO"
		end
	end
	local function ShowValidPorts()
		if not HasActiveShip() then return end
		local itemsubtype = GetInventoryItemClassSubType(t_station[tonumber(addonlist.value)+1])
		for portid,portdata in pairs(iconlist) do
			if portdata.icon then
				local shipportdata = GetActiveShipPortInfo(portid)
				if shipportdata and (not itemsubtype or itemsubtype == shipportdata.type) then
					portdata.icon.bgcolor = "255 255 255 255 *"
				else
					portdata.icon.bgcolor = "255 92 92 255 *"
				end
			end
		end
	end

	curselport = 0
	equipportinfo = iup.pdasubsubsubmultiline{expand="YES", readonly="YES",
		value=helpfulequiptext,
	}
	addonlist = iup.pdasubsubsubtree{expand="YES",
					selection_cb=function(self, index, state)
						if state == 1 then
							ActivateEquipButton()
							ShowValidPorts()
							setup_info_text_by_itemid("", t_station[tonumber(index)+1])
						elseif state == 2 and equipbutton.active == "YES" then
							equipbutton:action()
						end
					end,
					begindrag_cb=function(self, index)
						local itemid = t_station[tonumber(index)+1]
						local itemicon, name
						if itemid then
							itemicon, name = GetInventoryItemInfo(itemid)
							iup.DoDragDrop({type="invitem", text=name, itemid=itemid, image=itemicon},self,iup.DROP_COPY+iup.DROP_MOVE)
						end
					end,
					givefeedback_cb=function(self,effect)
						if effect ~= iup.DROP_NONE then
							local itemid = t_station[tonumber(self.value)+1]
							local itemicon, name
							if itemid then
								itemicon, name = GetInventoryItemInfo(itemid)
								gkinterface.SetMouseCursor(itemicon)
								gkinterface.SetMouseHotspot(.5,.5)
								return 1
							end
						end
					end,
					dragresult_cb=function(self,effect)
					end,
					querycontinuedrag_cb=function(self,escapekeystate, keystate)
						return iup.DRAG_DROP
					end,
					dragenter_cb=function(self,dataobject, x, y, keystate, effect)
						if dataobject.type == "invitem" then
							return iup.DROP_MOVE
						else
							return iup.DROP_NONE
						end
					end,
					dragleave_cb=function(self)
					end,
					dragover_cb=function(self,x, y, keystate, effect)
						return iup.DROP_MOVE
					end,
					drop_cb=function(self,dataobject, x, y, keystate, effect)
						-- return DROP_NONE because this function does the full action.
						DisconnectAddon(dataobject.itemid)
						return iup.DROP_NONE
					end,
	}
	equipbutton = iup.stationbutton{title="Equip", expand="HORIZONTAL", hotkey=iup.K_e,
		action=function(self)
			local portid = curselport
			local itemid = t_station[tonumber(addonlist.value)+1]
			if portid and itemid then
				ConnectAddon(portid, itemid) -- this will auto-unequip whatever's there.
			end
		end,
	}
	unequipbutton = iup.stationbutton{title="Unequip", expand="HORIZONTAL", hotkey=iup.K_u,
		action=function(self)
			local portid = curselport
			if portid and portid > 0 then
				local itemid = GetActiveShipItemIDAtPort(portid)
				DisconnectAddon(itemid)
			end
		end,
	}
	unequipallbutton = iup.stationbutton{title="Unequip All", expand="HORIZONTAL",
		action=function(self)
			DisconnectAllAddons()
		end,
	}

	container = iup.vbox{
		iup.vbox{
			iup.pdasubsubsubframebg{
				iup.hbox{iup.fill{},iup.label{title="Double-click on an addon to attach to selected port"},iup.fill{}},
			},
			addonlist,
			alignment="ACENTER"
		},
		iup.pdasubsubsubframebg{
			iup.hbox{
				equipbutton, unequipbutton, unequipallbutton,
				gap=5,
				margin="2x2",
			},
		},
		iup.vbox{
			equipportinfo,
			alignment="ACENTER"
		},
		expand="VERTICAL",
	}

	setup_info_text_by_itemid = function(prefix, itemid)
		local str
		local selitemid = t_station[tonumber(addonlist.value)+1]
		if curselport ~= 0 and selitemid and GetInventoryItemClassSubType(selitemid) ~= GetActiveShipPortInfo(curselport).type then
			prefix = helpfulwrongaddontext..(prefix or "")
		end
		if itemid then
			local canuse, reqlevels = CanUseAddon(itemid)
			if reqlevels then
				str = string.format("\n%sRequired License: %s/%s/%s/%s/%s\n",
					canuse and "" or "\127ff0000",
					tostring(reqlevels[1]),
					tostring(reqlevels[2]),
					tostring(reqlevels[3]),
					tostring(reqlevels[4]),
					tostring(reqlevels[5])
					)
			else
				str = "\n"
			end
			local icon, name, quan, mass, desc, longdesc = GetInventoryItemInfo(itemid)
			str = tostring(name)..str..string.gsub(tostring(longdesc), "|", "\n")
			if curselport ~= 0 then
				unequipbutton.active = "YES"
			end
		else
			str = "(empty)"
			unequipbutton.active = "NO"
		end
		equipportinfo.value = (prefix or "")..str
		equipportinfo.scroll = "TOP"
	end

	setup_info_text_by_portid = function(portid, portinfo)
		local itemid = GetActiveShipItemIDAtPort(portid)
		setup_info_text_by_itemid((portinfo and portinfo.name or ("Unknown port id "..tostring(portid)))..":\n", itemid)
	end

	function container:setup()
		local activeshipid = GetActiveShipID()
		local numports = GetActiveShipNumAddonPorts() or 0

		curselport = 0
		for k,v in pairs(iconlist) do
			v.selimage.visible = "NO"
			-- show the battery and turret
			if (v.porttype == AddonPortType_PowerCell) or (v.porttype == AddonPortType_Turret) then
				v.iconcontainer.visible = "YES"
			end
		end

		local i=1
		t_station = GetStationAddonList()
		table.sort(t_station, function(a,b)
				local a_addontype = GetInventoryItemClassSubType(a)
				local b_addontype = GetInventoryItemClassSubType(b)
				if a_addontype == b_addontype then
					return GetInventoryItemName(a) < GetInventoryItemName(b)
				else
					return a_addontype < b_addontype
				end
			end)
--[[
		for k,itemid in ipairs(t_station) do
			local itemname = GetInventoryItemName(itemid)
			local quan = GetInventoryItemQuantity(itemid)
			if quan > 1 then
				itemname = string.format("%dx %s", quan, itemname)
			end
			if not CanUseAddon(itemid) then
				itemname = "\127ff0000"..itemname
			end
			addonlist[k] = itemname
			i=k+1
		end
		addonlist[i] = nil
--]]
		addonlist:clear()
		while t_station[i] do
			local itemicon, name, quantity = GetInventoryItemInfo(t_station[i])
			if itemicon then
				name = string.format("%dx %s", quantity, name)
			else
				name = "?x ????????"
			end
			if i == 1 then
				addonlist:setname(0, name)
				addonlist:setimage(0, itemicon)
				addonlist:setimageexpanded(0, itemicon)
			else
				addonlist:addbranch(i-2, name)
				addonlist:setdepth(i-1, 0)
				if itemicon then
					addonlist:setimage(i-1, itemicon)
					addonlist:setimageexpanded(i-1, itemicon)
				end
			end
			i = i + 1
		end
		if i == 1 then
			addonlist:setname(0, "(empty)")
			addonlist:setimage(0, "")
			addonlist:setimageexpanded(0, "")
		end
		addonlist[i] = nil

		-- show proper desc
		if curselport == 0 then
			equipportinfo.value = ""
			equipbutton.active = "NO"
			unequipbutton.active = "NO"
		else
			local portid = curselport
			local portinfo = GetActiveShipPortInfo(portid)
			setup_info_text_by_portid(portid, portinfo)
		end

		ShowValidPorts()
		ActivateEquipButton()
		local selecteditemid = t_station[tonumber(addonlist.value)+1]
		if selecteditemid then
			setup_info_text_by_itemid("", selecteditemid)
		else
			equipportinfo.value = helpfulequiptext
			equipportinfo.scroll = "TOP"
		end
	end

	function container:onportclick(button_self, portid, portinfo)
		curselport = portid
		ActivateEquipButton()
		setup_info_text_by_portid(portid, portinfo)
		for k,v in pairs(iconlist) do
			if v.icon == button_self then
				v.selimage.visible = "YES"
			else
				v.selimage.visible = "NO"
			end
		end
	end

	container.OnHelp = HelpStationAddonEquip

	function container:OnShow()
	end

	function container:OnHide()
	end

	return container
end

function create_ship_group_template(_iconlist, issubsub)
	local container
	local weapongroupgrouptree
	local weapongroupportinfo, weapongroupclearbutton, weapongroupsavebutton
	local weapongroupneedssaving = false
	local iconlist = _iconlist
	local group1button,group2button,group3button,group4button,group5button,group6button
	local activemode = 1  -- 1,2,3 for primary, secondary, tertiary
	local activegroup = 0
	local grouplist = {}
	local primary_id, secondary_id, tertiary_id

	local function save_activegroup()
		if weapongroupneedssaving then
			weapongroupneedssaving = false
			local _grouplist = grouplist[activegroup]
			ConfigureMultipleWeaponGroups({[activegroup+1]=_grouplist[1], [activegroup+7]=_grouplist[2], [activegroup+13]=_grouplist[3]})
		end
	end

	local function update_selections()
		local _grouplist = grouplist[activegroup]
		for k,v in pairs(iconlist) do
			v.selimage.visible = (_grouplist[activemode] and _grouplist[activemode][k]) and "YES" or "NO"
			-- hide the battery and turret
			if (v.porttype == AddonPortType_PowerCell) or (v.porttype == AddonPortType_Turret) then
				v.iconcontainer.visible = "NO"
			end
		end
	end

	local function set_port_list(groupid)
		activegroup = groupid
		local _grouplist = grouplist[groupid] or {}
		grouplist[groupid] = _grouplist
		_grouplist[1] = _grouplist[1] or GetActiveShipWeaponGroup(groupid)
		_grouplist[2] = _grouplist[2] or GetActiveShipWeaponGroup(groupid+6)
		_grouplist[3] = _grouplist[3] or GetActiveShipWeaponGroup(groupid+12)

		local primarykeys = gkinterface.GetBindsForCommand("+Shoot2")
		local secondarykeys = gkinterface.GetBindsForCommand("+Shoot1")
		local tertiarykeys = gkinterface.GetBindsForCommand("+Shoot3")

		weapongroupgrouptree:clear()
		local index = 0
		weapongroupgrouptree:setname(0, "Primary Trigger - ("..table.concat(primarykeys, ", ")..")")
		primary_id = index
		if activemode == 1 then
			weapongroupgrouptree.value = index
		end
		if _grouplist[1] then
			for k,v in pairs(_grouplist[1]) do
				local portinfo = GetActiveShipPortInfo(k)
				weapongroupgrouptree:addleaf(index, portinfo and portinfo.name or "Unknown port")
				index = index + 1
--				weapongroupgrouptree["icon"..index] = icon
			end
		end
		weapongroupgrouptree:addbranch(index, "Secondary Trigger - ("..table.concat(secondarykeys, ", ")..")")
		index = index + 1
		secondary_id = index
		weapongroupgrouptree:setdepth(index, 0)
		if activemode == 2 then
			weapongroupgrouptree.value = index
		end
		if _grouplist[2] then
			for k,v in pairs(_grouplist[2]) do
				local portinfo = GetActiveShipPortInfo(k)
				weapongroupgrouptree:addleaf(index, portinfo and portinfo.name or "Unknown port")
				index = index + 1
--				weapongroupgrouptree["icon"..index] = icon
			end
		end
		weapongroupgrouptree:addbranch(index, "Tertiary Trigger - ("..table.concat(tertiarykeys, ", ")..")")
		index = index + 1
		tertiary_id = index
		weapongroupgrouptree:setdepth(index, 0)
		if activemode == 3 then
			weapongroupgrouptree.value = index
		end
		if _grouplist[3] then
			for k,v in pairs(_grouplist[3]) do
				local portinfo = GetActiveShipPortInfo(k)
				weapongroupgrouptree:addleaf(index, portinfo and portinfo.name or "Unknown port")
				index = index + 1
--				weapongroupgrouptree["icon"..index] = icon
			end
		end

		update_selections()
	end

	local groupbuttons
	local function unhilightbuttons()
		for k,v in ipairs(groupbuttons) do
			v.fgcolor = tabunseltextcolor
		end
	end
	group1button = iup.stationbutton{title="Key 1", action=function(self) save_activegroup() set_port_list(0) unhilightbuttons() self.fgcolor = tabseltextcolor end}
	group2button = iup.stationbutton{title="Key 2", action=function(self) save_activegroup() set_port_list(1) unhilightbuttons() self.fgcolor = tabseltextcolor end}
	group3button = iup.stationbutton{title="Key 3", action=function(self) save_activegroup() set_port_list(2) unhilightbuttons() self.fgcolor = tabseltextcolor end}
	group4button = iup.stationbutton{title="Key 4", action=function(self) save_activegroup() set_port_list(3) unhilightbuttons() self.fgcolor = tabseltextcolor end}
	group5button = iup.stationbutton{title="Key 5", action=function(self) save_activegroup() set_port_list(4) unhilightbuttons() self.fgcolor = tabseltextcolor end}
	group6button = iup.stationbutton{title="Key 6", action=function(self) save_activegroup() set_port_list(5) unhilightbuttons() self.fgcolor = tabseltextcolor end}
	groupbuttons = {group1button,group2button,group3button,group4button,group5button,group6button}
	groupbuttons[activegroup+1].fgcolor = tabseltextcolor

	local multiline, framebg, tree
	if issubsub then
		multiline = iup.pdasubsubsubmultiline
		framebg = iup.pdasubsubsubframebg
		tree = iup.pdasubsubsubtree
	else
		multiline = iup.stationsubmultiline
		framebg = iup.stationsubframebg
		tree = iup.stationsubtree
	end

	weapongroupportinfo = multiline{expand="YES", readonly="YES",
		value=helpfulgrouptext,
	}
	weapongroupgrouptree = tree{expand="YES",
		size="40x40",
		IMAGEBRANCHEXPANDED="",
		IMAGEBRANCHCOLLAPSED="",
		IMAGEEXPANDED0="",
		IMAGE0="",
		selection_cb=function(self, id, status)
			if status == 1 then
				local haschanged = false
				local parentid = tonumber(self["PARENT"..id])
				if id == primary_id or parentid == primary_id then
					activemode = 1
					if id ~= primary_id then self.value = primary_id haschanged = true end
				elseif id == secondary_id or parentid == secondary_id then
					activemode = 2
					if id ~= secondary_id then self.value = secondary_id haschanged = true end
				elseif id == tertiary_id or parentid == tertiary_id then
					activemode = 3
					if id ~= tertiary_id then self.value = tertiary_id haschanged = true end
				end
				update_selections()
				return haschanged and iup.IGNORE
			end
		end,
	}
	weapongroupclearbutton = iup.stationbutton{title="Clear Group",
		action=function(self)
			local function yes_callback()
				local _grouplist = grouplist[activegroup]
				_grouplist[1] = {}
				_grouplist[2] = {}
				_grouplist[3] = {}
				set_port_list(activegroup)
				weapongroupneedssaving = true
				HideDialog(QuestionDialog)
			end
			QuestionDialog:SetMessage("Are you sure you want to clear this weapon group?",
					"Yes", yes_callback,
					"No", function() HideDialog(QuestionDialog) end)
			ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
		end,
	}
	
	weapongroupsavebutton = iup.stationbutton{title="Save Group",
		action=function(self)
			save_activegroup()
		end,
	}

	container = iup.vbox{
		iup.vbox{
			framebg{
				iup.vbox{
					iup.hbox{iup.fill{},iup.label{title="Press a Key button to pick a group to define"},iup.fill{}},
					iup.hbox{group1button,group2button,group3button,gap=2,},
					iup.hbox{group4button,group5button,group6button,gap=2,},
					iup.hbox{iup.fill{},iup.label{title="Then pick a trigger (Primary, Secondary, etc) and\nselect ship ports to fire with that trigger.",alignment="ACENTER"},iup.fill{}},
					gap=2,
					alignment="ACENTER",
				},
			},
			weapongroupgrouptree,
			alignment="ACENTER"
		},
		iup.hbox{
			framebg{
				iup.hbox{iup.fill{},weapongroupclearbutton,iup.fill{},weapongroupsavebutton,iup.fill{}, margin="2x2",},
			},
		},
		weapongroupportinfo,
--		expand="VERTICAL",
	}

	function container:setup()
		local keys
		keys = gkinterface.GetBindsForCommand("Weapon1")
		group1button.title = "Key "..(keys[1] or "<none>")
		keys = gkinterface.GetBindsForCommand("Weapon2")
		group2button.title = "Key "..(keys[1] or "<none>")
		keys = gkinterface.GetBindsForCommand("Missile1")
		group3button.title = "Key "..(keys[1] or "<none>")
		keys = gkinterface.GetBindsForCommand("Missile2")
		group4button.title = "Key "..(keys[1] or "<none>")
		keys = gkinterface.GetBindsForCommand("Missile3")
		group5button.title = "Key "..(keys[1] or "<none>")
		keys = gkinterface.GetBindsForCommand("Mine1")
		group6button.title = "Key "..(keys[1] or "<none>")
		grouplist = {}
		weapongroupneedssaving = false

		set_port_list(activegroup)
	end

	function container:onportclick(button_self, portid, portinfo)
		local str
		local itemid = GetActiveShipItemIDAtPort(portid)
		if itemid then
			local itemicon, name, quan, mass, desc, longdesc = GetInventoryItemInfo(itemid)
			str = ":\n"..tostring(name).."\n"..string.gsub(tostring(longdesc), "|", "\n")
		else
			str = ":\n\1277f7f7f(empty)"
		end
		weapongroupportinfo.value = portinfo.name..str
		weapongroupportinfo.scroll = "TOP"
		weapongroupneedssaving = true
		local _grouplist = grouplist[activegroup][activemode]
		for k,v in pairs(iconlist) do
			if v.icon == button_self then
				v.selimage.visible = v.selimage.visible~="YES" and "YES" or "NO"
				if _grouplist then
					_grouplist[k] = v.selimage.visible=="YES" and true or nil
				end
				set_port_list(activegroup)
				break
			end
		end
	end

	container.OnHelp = HelpStationAddonGroups

	function container:OnShow()
	end

	function container:OnHide()
		save_activegroup()
	end

	return container
end

function CreateLowGridPowerDialog()
	local dlg
	local infolabel = iup.label{font=Font.H4,title="Not enough Grid Power:\nYour power cell does not have enough Grid Power\nto support the Grid Usage of the equipped addons.\n For more information, see Help.", expand="YES"}
	local donotshowagaintoggle = iup.stationtoggle{title="Do not show this dialog again.", value="OFF", tip="This setting can be changed\nin Options->Interface"}
	local button1 = iup.stationbutton{title="OK", action=function()
			ShowLowGridPowerDialog = donotshowagaintoggle.value=="OFF"
			HideDialog(dlg)
		end}
	local helpbutton = iup.stationbutton{title="Help",
		action=HelpGridPower}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{size=dlgposx},
			iup.vbox{
				iup.fill{size=dlgposy},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
							donotshowagaintoggle,
							iup.label{title="This setting can be changed in Options->Interface",font=Font.H6,fgcolor=tabunseltextcolor},
							iup.hbox{
								helpbutton,
								iup.fill{},
								button1,
								iup.fill{},
							},
						},
						expand="NO",
						size=dlgsize,
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button1,
		fullscreen="YES",
		bgcolor = bgcolor or "0 0 0 128 *",
--		topmost="YES",
	}

	return dlg
end

LowGridPowerDialog = CreateLowGridPowerDialog()

function CreateStationPortConfigTab()
	local reset = true
	local isvisible = false
	local container
	local portview, iconcontainer, iconlist, shipnamelabel, gridusagelabel
	local curseltab
	local addonportinstruction

	portview = iup.modelview{value="", expand="YES", mode=1, active="NO"}
	shipnamelabel = iup.label{title="", expand="HORIZONTAL"}
	gridusagelabel = iup.label{title="", expand="HORIZONTAL"}
	iconcontainer = iup.cbox{active="NO", expand="YES"}
	iconlist = {}
	addonportinstruction = iup.label{title="Click on a Port icon"}

	local equiptab = create_ship_equip_tab(iconlist) equiptab.tabtitle = "Addons" equiptab.hotkey = iup.I_a
	local grouptab = create_ship_group_template(iconlist, true) grouptab.tabtitle = "Groups" grouptab.hotkey = iup.I_p

	curseltab = equiptab
	container = iup.hbox{
		iup.vbox{
			iup.stationsubsubframebg{iup.hbox{shipnamelabel, iup.fill{}, addonportinstruction}},
			iup.stationsubsubframe{
				iup.zbox{portview,iconcontainer, all="YES", margin="-5x-5", expand="YES"},
			},
			iup.stationsubsubframebg{iup.hbox{gridusagelabel, iup.fill{}}},
		},
		iup.stationsubsubframehdivider{size=4},
		iup.vbox{
			iup.subsubsubtabtemplate{
				equiptab,
				{expand="HORIZONTAL", spacer=true},
				grouptab,
				tabchange_cb = function(self, newtab, oldtab)
					oldtab = curseltab
					curseltab = newtab
					if newtab == equiptab then
						addonportinstruction.visible = "YES"
					else
						addonportinstruction.visible = "NO"
					end
					if isvisible then
						oldtab:OnHide()
						curseltab:OnShow()
						newtab:setup()
					end
				end,
			},
			expand="VERTICAL",
		}
	}

	local icontimer = Timer()
	local lowpowericontimer = Timer()
	local lowpowericonvisibilityflag = true

	local function setup_tab()
		local activeshipid = GetActiveShipID()
		local numports = GetActiveShipNumAddonPorts() or 0

		iup.CancelDragDrop()

		shipnamelabel.title = GetActiveShipName() or ""
		local meshname, meshfile, shipcolor = GetShipMeshInfo(activeshipid)
		SetViewObject(portview, meshname, meshfile, shipcolor)
		portview:SetOrientation(math3d.MakeQuatFromGVectors(gvector(0,0,1), gvector(0,1,0)))
		
		local gridpower, gridusage = GetActiveShipGridPowerAndUsage()
		local lowgridpower = gridpower and (gridpower > 0) and (gridpower < gridusage)
--		local lowgridpower = gridpower and (gridpower < gridusage)
		gridusagelabel.title = string.format("Grid Power Usage: %u/%u units", gridusage or 0, gridpower or 0)

		iup.SetFocus(portview)
		for k,v in pairs(iconlist) do
			HideTooltip()
			v.iconcontainer:detach()
			v.iconcontainer:destroy()
			iconlist[k] = nil
		end
		for k=1,numports do
			local portid = k
			local portinfo = GetActiveShipPortInfo(portid)
--			if portinfo and portinfo.type ~= 3 and portinfo.type ~= 4 then -- skip engines and batteries
			if portinfo and portinfo.type ~= 3 then -- skip engines
				local portdata = {}
				local itemidatport = GetActiveShipItemIDAtPort(portid)
				local itemicon, name = GetInventoryItemInfo(itemidatport)
				local portimage = itemicon or (portconfig[portinfo.type] and portconfig[portinfo.type].emptyicon or "images/hud_target.jpg")
				portdata.porttype = portinfo.type
				local iconsize = portconfig[portinfo.type] and portconfig[portinfo.type].iconsize or "32x32"
				portdata.selimage = iup.label{title="",image="images/icon_powerupselect.tga", size=iconsize, active="NO", visible="NO", bgcolor="255 255 255 255 +"}
				if lowgridpower then
					-- only do this if there's a power cell connected, which is indicated by non-zero gridpower.
					portdata.lowpower = iup.label{title="",image="images/icon_lowpower.png", size=iconsize, active="NO", visible="YES", bgcolor="255 255 255 255 *"}
				end
				portdata.icon = iup.button{title="",size=iconsize,image=portimage, bgcolor="255 255 255 255 *",
					enterwindow_cb=function(self)
						local portinfo = GetActiveShipPortInfo(portid)
						if not portinfo then return end
						local str
						local itemid = GetActiveShipItemIDAtPort(portid)
						if itemid then
							local itemicon, name = GetInventoryItemInfo(itemid)
							str = ":\n"..tostring(name)
						else
							str = ":\n\1277f7f7f(empty)"
						end

						ShowTooltip(self.x + self.w, -self.y, portinfo.name..str)
					end,
					leavewindow_cb=function(self)
						HideTooltip()
					end,
					begindrag_cb=function(self)
						local itemid = GetActiveShipItemIDAtPort(portid)
						local itemicon, name
						if itemid then
							itemicon, name = GetInventoryItemInfo(itemid)
							iup.DoDragDrop({type="invitem", text=name, itemid=itemid, image=itemicon, portid=portid},self,iup.DROP_COPY+iup.DROP_MOVE)
						end
					end,
					givefeedback_cb=function(self,effect)
						if effect ~= iup.DROP_NONE then
							local itemid = GetActiveShipItemIDAtPort(portid)
							local itemicon, name
							if itemid then
								itemicon, name = GetInventoryItemInfo(itemid)
								gkinterface.SetMouseCursor(itemicon)
								gkinterface.SetMouseHotspot(.5,.5)
								return 1
							end
						end
					end,
					dragresult_cb=function(self,effect)
					end,
					querycontinuedrag_cb=function(self,escapekeystate, keystate)
						return iup.DRAG_DROP
					end,
					dragenter_cb=function(self,dataobject, x, y, keystate, effect)
						if dataobject.type == "invitem" and CanUseAddon(dataobject.itemid) then
							local shipportdata = GetActiveShipPortInfo(portid)
							local itemsubtype = GetInventoryItemClassSubType(dataobject.itemid)
							if shipportdata and (not itemsubtype or itemsubtype == shipportdata.type) then
								portdata.dataobject = dataobject
						local portinfo = GetActiveShipPortInfo(portid)
						if not portinfo then return end
						local str
						local itemid = GetActiveShipItemIDAtPort(portid)
						if itemid then
							local itemicon, name = GetInventoryItemInfo(itemid)
							local _, newname = GetInventoryItemInfo(dataobject.itemid)
							str = ":\n"..tostring(name)
							if dataobject.portid ~= portid then
								str = str.."\n\nReplaced by:\n"..newname
							end
						else
							str = ":\n\1277f7f7f(empty)"
							if dataobject.portid ~= portid then
								local _, newname = GetInventoryItemInfo(dataobject.itemid)
								str = str.."\n\n\127ffffffConnecting:\n"..newname
							end
						end

						ShowTooltip(self.x + self.w, -self.y, portinfo.name..str)

								return iup.DROP_MOVE
							else
								return iup.DROP_NONE
							end
						else
							return iup.DROP_NONE
						end
					end,
					dragleave_cb=function(self)
						portdata.dataobject = nil
						HideTooltip()
					end,
					dragover_cb=function(self,x, y, keystate, effect)
						if portdata.dataobject then
							return iup.DROP_MOVE
						end
					end,
					drop_cb=function(self,dataobject, x, y, keystate, effect)
						if portdata.dataobject and dataobject.portid ~= portid then
							-- return DROP_NONE because this function does the full action.
							ConnectAddon(portid, dataobject.itemid)
							portdata.dataobject = nil
						end
						return iup.DROP_NONE
					end,
				}
				portdata.icon.action=function(button_self)
					curseltab:onportclick(button_self, portid, portinfo)
				end
				portdata.iconcontainer = iup.zbox{cx=0,cy=0,portdata.icon, portdata.selimage, portdata.lowpower, expand="NO",all="YES"}
				iconlist[portid] = portdata
				iup.Append(iconcontainer, portdata.iconcontainer)

				-- cbox is gay so I have to do this.
				-- mainly, it's because I am adding controls to a window that's not visible
				portdata.icon.visible = "NO"
				portdata.iconcontainer:map()
				portdata.icon.visible = "YES"
			end
		end

		ReinitIconPositions(icontimer, activeshipid, portview, iconlist, iconcontainer, portlocations_group)

		curseltab:setup()

-- TODO: if powercell is connected and GridUsage > GridPower then
--   display warning dialog if enabled
--   flash lightning bolts over all addons
-- end
		if lowgridpower then
			lowpowericonvisibilityflag = true
			lowpowericontimer:SetTimeout(1000,function()
					lowpowericonvisibilityflag = not lowpowericonvisibilityflag
					for k,v in pairs(iconlist) do
						if v.lowpower then
							v.lowpower.visible = lowpowericonvisibilityflag and "YES" or "NO"
						end
					end
					lowpowericontimer:SetTimeout(1000)
				end)
			gridusagelabel.fgcolor = "255 0 0"
		else
			lowpowericontimer:Kill()
			gridusagelabel.fgcolor = "255 255 255"
		end
	end

	function container:OnShow()
		isvisible = true
		curseltab:OnShow()
		if reset then
			reset = false
			setup_tab()
		else
			curseltab:setup()
		end
	end

	function container:OnHide()
		isvisible = false
		curseltab:OnHide()
	end

	function container:OnHelp()
		curseltab:OnHelp()
	end

	local wait_for_transaction_completed = false
	function container:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" then
			if isvisible then
				setup_tab()
			else
				reset = true
			end
		elseif eventname == "INVENTORY_ADD"
			or eventname == "INVENTORY_REMOVE"
			or eventname == "INVENTORY_UPDATE"
			or eventname == "SHIP_UPDATED"
			or eventname == "SHIP_CHANGED" then
			wait_for_transaction_completed = true
		elseif eventname == "TRANSACTION_COMPLETED" then
			if wait_for_transaction_completed then
				wait_for_transaction_completed = false
				if isvisible then
					setup_tab(self)
				else
					reset = true
				end
			end
		end
	end

	RegisterEvent(container, "ENTERING_STATION")
	RegisterEvent(container, "INVENTORY_ADD")
	RegisterEvent(container, "INVENTORY_REMOVE")
	RegisterEvent(container, "INVENTORY_UPDATE")
	RegisterEvent(container, "TRANSACTION_COMPLETED")
	RegisterEvent(container, "SHIP_UPDATED")
	RegisterEvent(container, "SHIP_CHANGED")

	return container
end
