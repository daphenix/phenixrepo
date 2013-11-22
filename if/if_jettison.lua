local evencolor = "30 60 60 204 *" -- "0 76 0"
local oddcolor = "42 78 78 204 *" -- "0 89 0"
local selcolor = "84 156 156 204 *" -- "0 204 0"

local function j_action(self)
	local q = tonumber(self.quantity.value)
	if q then
		JettisonSingle(self.id, q)
		iup.SetFocus(iup.GetDialog(self)) 
	end
end

local function makesubdlg(itemid)
	local quantity = iup.text{value=1, size="60x",expand="NO"}
	local j_button = iup.stationbutton{title="J", action=j_action,expand="NO"}
	local otherinfo = iup.label{title="", alignment="ARIGHT"}
	j_button.id = itemid
	j_button.quantity = quantity
	local iconlabel = iup.label{title="", image="",size="32x32",expand="NO"}
	local namelabel = iup.label{title=""}
	local desclabel = iup.label{title=""}
	local entry = iup.hbox{
			iconlabel,
			iup.vbox{
				namelabel,
				desclabel,
			},
			iup.fill{},
			iup.vbox{
				iup.hbox{
					quantity,
					j_button,
					alignment="ACENTER",
				},
				otherinfo,
				alignment="ARIGHT",
			},
			alignment="ACENTER",
		}
	local subdlg = iup.dialog{
		entry,
		size="HALFx",
		border="NO",menubox="NO",resize="NO",
		active="NO",
	}

	subdlg.otherdata = {itemid = itemid, quantityedit = quantity, j_button=j_button, otherinfo=otherinfo}

	function subdlg.otherdata.SetInfo(itemid)
		local itemicon, itemname, itemquantity, m, itemdesc = GetInventoryItemInfo(itemid)

		subdlg.otherdata.itemid = itemid
		j_button.id = itemid
		iconlabel.image = itemicon or ""
		namelabel.title = itemname or ""
		desclabel.title = itemdesc or ""
		quantity.value = tostring(itemquantity)
		if PlayerInStation() then
			j_button.visible = "NO"
			quantity.visible = "NO"
		else
			j_button.visible = "YES"
			quantity.visible = "YES"
		end
	end

	return subdlg
end

local _jettisonitemdlgcache = {}
function get_jettisonitemdlg(itemid)
	local dlg
	if _jettisonitemdlgcache[1] then
		dlg = table.remove(_jettisonitemdlgcache)
		dlg.incache = false
	else
		dlg = makesubdlg(itemid)
	end
	dlg.otherdata.SetInfo(itemid)
	return dlg
end

function store_jettisonitemdlg(dlg)
	if not dlg.incache then
		dlg.incache = true
		table.insert(_jettisonitemdlgcache, dlg)
	end
end


function create_jettison_control()
	local isvisible = false
	local container
	local selcount = 0
	local _cargolist = {}
	local jettisonbutton = iup.stationbutton{title="Jettison Selected", hotkey=iup.K_a}
	local curcargolabel = iup.label{title="", alignment="ACENTER", expand="HORIZONTAL"}
	local cargolist = iup.stationsubsublist{expand="YES", size="THIRDx1", control="YES"}

	local function collateitems(listbox, items)
		local size, curmaxsize

		for index,subdlg in ipairs(items) do
			if subdlg.sel then
					subdlg.bgcolor = selcolor
			else
				if math.fmod(index, 2) == 0 then
					subdlg.bgcolor = evencolor
				else
					subdlg.bgcolor = oddcolor
				end
			end
			local unitmass = GetInventoryItemMass(subdlg.otherdata.itemid) or 0
			local unitvolume = GetInventoryItemVolume(subdlg.otherdata.itemid) or 0
			local quantity = GetInventoryItemQuantity(subdlg.otherdata.itemid) or 0
		local bestprice, location = GetBestPriceInfoOfItem(subdlg.otherdata.itemid)
			local bestpricestr
			if bestprice then
				local totalcost = GetInventoryItemUnitCost(subdlg.otherdata.itemid)*GetInventoryItemQuantity(subdlg.otherdata.itemid)
				local color = GetProfitHexColor(bestprice, totalcost)
				bestpricestr = string.format("Best price: \127%s%s c\127ffffff (%s) @ %s",
						color,
						comma_value(bestprice),
						comma_value(totalcost),
						ShortLocationStr(math.floor(location/100)))
			else
				bestpricestr = "Best price: N/A"
			end
			if quantity > 1 then
				subdlg.otherdata.otherinfo.title = string.format("%s  (%d cu/%.f kg) x %d = (%d cu/%.f kg)",
						bestpricestr,
						unitvolume, unitmass*1000,
						quantity,
						quantity*unitvolume, quantity*unitmass*1000
					)
			else
				subdlg.otherdata.otherinfo.title = string.format("%s  (%d cu/%.f kg)",
						bestpricestr,
						unitvolume, unitmass*1000)
			end
			subdlg:map()
			size = subdlg.size
			if (not curmaxsize) or curmaxsize < size then curmaxsize = size end
		end

		for index,subdlg in ipairs(items) do
			subdlg.size = curmaxsize
			iup.Append(listbox, subdlg)
		end
		listbox:map()
	end

	local function j_selected(self)
		local jettisonlist = {}
		for k,subdlg in ipairs(_cargolist) do
			if subdlg.sel then
				local q = tonumber(subdlg.otherdata.quantityedit.value)
				if q then
					table.insert(jettisonlist, {id=subdlg.otherdata.itemid, quantity=q})
				end
			end
		end
		JettisonMultiple(jettisonlist)
	end

	local function j_all(self)
		JettisonAll()
		HideDialog(iup.GetDialog(self))
		ShowDialog(HUD.dlg)
	end

	local function cargoselfunc(index, state, list)
		local subdlg = list[index]
		if not subdlg.sel then
			subdlg.sel = true
			subdlg.bgcolor = selcolor
			selcount = selcount + 1
		else
			selcount = selcount - 1
			subdlg.sel = false
			if math.fmod(index, 2) == 0 then
				subdlg.bgcolor = evencolor
			else
				subdlg.bgcolor = oddcolor
			end
		end
		if selcount == 0 then
			jettisonbutton.title = "   Jettison All   "
			jettisonbutton.action = j_all
		else
			jettisonbutton.title = "Jettison Selected"
			jettisonbutton.action = j_selected
		end
	end

	local function recount_sel()
		selcount = 0
		for k,subdlg in ipairs(_cargolist) do
			if subdlg.sel then
				selcount = selcount + 1
			end
		end
		if selcount == 0 then
			jettisonbutton.title = "   Jettison All   "
			jettisonbutton.action = j_all
		else
			jettisonbutton.title = "Jettison Selected"
			jettisonbutton.action = j_selected
		end
	end

	function cargolist:action(text, index, selection)
		if selection == 1 then
			cargoselfunc(index, selection, _cargolist)
		end
	end

	local function setuplist(preserve_selections)
		local curfocus = iup.GetFocus()
		curfocus = curfocus and iup.GetDialog(curfocus)
		-- first, clear out and free old list, also record what is selected
		local cursel = {}
		cargolist[1] = nil
		for k,v in ipairs(_cargolist) do
			if preserve_selections and v.sel then cursel[v.otherdata.itemid] = true end
			v.sel = false
			store_jettisonitemdlg(v)
			if curfocus == v then
				curfocus = nil
				iup.SetFocus(iup.GetDialog(cargolist)) -- because dlg being destroyed may have focus
			end
			iup.Detach(v)
			_cargolist[k] = nil
		end

		-- second, get cargo and make subdialogs
		local shipinv = GetShipInventory(GetActiveShipID())
		table.sort(shipinv.cargo)
		for k,itemid in ipairs(shipinv.cargo) do
			local subdlg = get_jettisonitemdlg(itemid)
			table.insert(_cargolist, subdlg)
			if preserve_selections and cursel[itemid] then subdlg.sel = true end
		end

		-- third, add subdlgs to listcontrol
		collateitems(cargolist, _cargolist)
		cargolist[1] = 1

		recount_sel()

		local curcargo = GetActiveShipCargoCount() or 0
		local maxcargo = GetActiveShipMaxCargo() or 0
		curcargolabel.title = string.format("Cargo: %d/%d cu", curcargo, maxcargo)
	end

	container = 
		iup.vbox{
			iup.stationsubsubframebg{
				curcargolabel,
			},
			cargolist,
			iup.stationsubsubframebg{
				iup.vbox{
					alignment='ACENTER',
					iup.hbox{
						iup.fill{},
						jettisonbutton,
						iup.fill{},
					},
					iup.label{title="Prices update once a minute."},
					iup.label{title="Best price is only based on stations in the current system. Best prices in other systems will vary."},
				},
			},
		}

	function container:OnShow()
		isvisible = true
		selcount = 0
		if PlayerInStation() then
			jettisonbutton.visible = "NO"
		else
			jettisonbutton.visible = "YES"
		end
		jettisonbutton.title = "   Jettison All   "
		jettisonbutton.action = j_all

		setuplist(false)
	end

	function container:OnHide()
		isvisible = false
	end

	function container:k_any(ch)
		local index = ch - iup.K_1  -- make it zero-based
		if index >= 0 and index <= 9 then
			local subdlg = _cargolist[index+1] -- it needs to be one-based
			if subdlg then
				subdlg.otherdata.j_button:action()
			end
		end
		return iup.CONTINUE
	end

	function container:OnEvent(eventname, ...)
		if isvisible and
			(eventname == "INVENTORY_ADD" or
			 eventname == "INVENTORY_REMOVE" or
			 eventname == "INVENTORY_UPDATE" or
			 eventname == "SYSTEM_BEST_PRICE") then
			setuplist(true)
		end
	end

	RegisterEvent(container, "INVENTORY_ADD")
	RegisterEvent(container, "INVENTORY_REMOVE")
	RegisterEvent(container, "INVENTORY_UPDATE")
	RegisterEvent(container, "SYSTEM_BEST_PRICE")

	return container
end
