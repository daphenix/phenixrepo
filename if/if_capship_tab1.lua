local normalcolors = {
	[0] = "30 55 78 204 *",
	[1] = "42 74 96 204 *",
	selcolor = "84 146 156 204 *",
}
local occupiedcolors = {
	[0] = "110 0 0 204 *",
	[1] = "128 0 0 204 *",
	selcolor = "192 0 0 204 *",
}
local deadcolors = {
	[0] = "110 110 110 204 *",
	[1] = "128 128 128 204 *",
	selcolor = "192 192 192 204 *",
}

local turretnametable

local function set_turret_info(index, iteminfo, dlg)
	local colors
	if iteminfo.isdead then
		colors = deadcolors
	elseif iteminfo.controller then
		colors = occupiedcolors
	else
		colors = normalcolors
	end
	dlg.colors = colors
	if dlg.sel then
		dlg.bgcolor = colors.selcolor
	else
		dlg.bgcolor = colors[math.fmod(index, 2)]
	end

	local armorstr
	local desc
	if iteminfo.controller then
		desc = GetPlayerName(iteminfo.controller) or "Controlled by unknown???"
		armorstr = "Armor: "..iteminfo.armorpercent.."%"
	else
		desc = iteminfo.isdead and "Destroyed" or "Active"
		armorstr = iteminfo.isdead and "" or "Armor: "..iteminfo.armorpercent.."%"
	end

	if not turretnametable then
		turretnametable = GetTurretNamesByStationType(GetStationType())
	end

	dlg:SetName(turretnametable[iteminfo.itemid or 0] or "")
	dlg:SetDesc(desc, false)
	dlg:SetPrice(armorstr)
	dlg:SetIcon("images/icon_ship_turret.png")
end


local function create_turret_list_thingy(buyname, buyaction)
	local cursel
	local items
	local subdlglist
	local listcontrol = iup.itemlisttemplate({}, true)
	local buybutton

	buybutton = iup.stationbutton{title=buyname, action=buyaction, active="NO"}

	local container = iup.vbox{
		iup.stationsubframe_nomargin{
			listcontrol,
		},
		iup.stationsubframevdivider{size=5},
		iup.stationsubframebg{
			iup.hbox{
				buybutton,
				iup.fill{},
				alignment="ACENTER",
				expand="YES",
				gap=5,
				margin="2x2",
			},
		},
	}
container=iup.frame{
	bgcolor="0 0 0 0 *",
	segmented="0 0 1 1",
	container
	}

	local function set_infodesc(dlginfo, iteminfo)
		if (not dlginfo) or (not iteminfo) then
			buybutton.active="NO"
			return
		end
		dlginfo.sel = true
		dlginfo.bgcolor = dlginfo.colors.selcolor
		if iteminfo.isdead then
			buybutton.active="NO"
		else
			buybutton.active="YES"
		end
	end

	function listcontrol:action(text, index, selection)
		local dlginfo = subdlglist[index]
		if selection >= 1 then
			if selection == 2 and not dlginfo.sel then
				return
			elseif selection == 2 then
				buybutton:action()
				return
			end
			cursel = index
			set_infodesc(dlginfo, items[index])
			iup.SetFocus(buybutton)
		else
			cursel = nil
			dlginfo.sel = false
			dlginfo.bgcolor = dlginfo.colors[math.fmod(index, 2)]
			buybutton.active="NO"
		end
	end

	function container:getcursel()
		return cursel
	end

	function container:clear()
		cursel = nil
		return clear_listbox(listcontrol, subdlglist)
	end

	function container:fill(_items, index)
		items = _items
		index = index and math.min(index, (#_items))
		subdlglist = fill_listbox(listcontrol, _items, index, set_turret_info, false, true)
		set_infodesc(subdlglist[index], items[index])
		listcontrol.value = index
		cursel = index
	end

	function container:update(index)
		set_turret_info(index, items[index], subdlglist[index])
	end

	return container, buybutton
end



function CreateCapShipTurretTab()
	local reset = true
	local isvisible = false
	local availableturretlist, container, buybutton
	local function purchaseaction(self)
		local turretinfo = GetStationTurretInfo(container:getcursel())
		if turretinfo then
			PurchaseMerchandiseItem(turretinfo.itemid)
		end
	end

	container, buybutton = create_turret_list_thingy("Select", purchaseaction)

	local function reload_list(self)
		reset = false
		local curselindex = self:clear()

		availableturretlist = {}
		local n = GetNumStationTurrets()
		for i=1,n do
			local turretinfo = GetStationTurretInfo(i)
			table.insert(availableturretlist, turretinfo)
		end

		if not turretnametable then
			turretnametable = GetTurretNamesByStationType(GetStationType())
		end
		self:fill(availableturretlist, curselindex)
	end

	function container:OnShow()
		isvisible = true
		if reset then
			reload_list(self)
		end
	end

	function container:OnHide()
		isvisible = false
	end

	function container:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" or
			eventname == "STATION_UPDATED" or
			eventname == "STATION_UPDATE_PRICE" then
			if eventname == "ENTERING_STATION" then turretnametable = nil end
			if isvisible then
				reload_list(self)
			else
				reset = true
			end
		elseif eventname == "STATION_TURRET_HEALTH_UPDATE" and availableturretlist then
			local arg1, arg2, arg3 = ...
			-- find index of this turret
			for index,v in pairs(availableturretlist) do
				if v.nodeid == arg1 and v.objectid == arg2 then
					v.armorpercent = arg3
					self:update(index)
					break
				end
			end
		elseif eventname == "LEAVING_STATION" then
			turretnametable = nil
		end
	end

	RegisterEvent(container, "ENTERING_STATION")
	RegisterEvent(container, "LEAVING_STATION")
	RegisterEvent(container, "STATION_UPDATED")
	RegisterEvent(container, "STATION_UPDATE_PRICE")
	RegisterEvent(container, "STATION_TURRET_HEALTH_UPDATE")

	return container, buybutton
end
