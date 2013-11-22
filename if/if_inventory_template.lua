local TOO_MUCH_CARGO_COLOR = "\127ff0000"
local CURRENTLY_RENTING_COLOR = "\127ffff00"

function storagelocationcompare(stationid_a,stationid_b)
	local systemid_a, x_a, y_a = SplitSectorID(GetSectorIDOfStation(stationid_a))
	local systemid_b, x_b, y_b = SplitSectorID(GetSectorIDOfStation(stationid_b))
	
	local na = SystemNames[systemid_a]
	local nb = SystemNames[systemid_b]
	if stationid_a == GetCurrentStationID() then
		return true
	elseif stationid_b == GetCurrentStationID() then
		return false
	else
		if na == nb then
			if x_a == x_b then
				if y_a == y_b then
					return tostring(GetStationName(stationid_a)) < tostring(GetStationName(stationid_b))
				else
					return y_a < y_b
				end
			else
				return x_a < x_b
			end
		else
			return na < nb
		end
	end
end

local function entrysortfunc(a,b)
	if not a then return true
	elseif not b then return false
	end
	local a_classtype = a.dataclasstype
	local b_classtype = b.dataclasstype

	if a_classtype == CLASSTYPE_SHIP and GetInventoryItemContainerID(a.data) == 0 then
		return true
	elseif b_classtype == CLASSTYPE_SHIP and GetInventoryItemContainerID(b.data) == 0 then
		return false
	elseif a_classtype == CLASSTYPE_STORAGE and
			b_classtype == CLASSTYPE_STORAGE then
			return storagelocationcompare(GetStorageItemInfo(a.data), GetStorageItemInfo(b.data))
	else
		local aname = a.dataitemname
		local bname = b.dataitemname
		if aname ~= bname then
			return aname < bname
		else
			return a.data < b.data
		end
	end
end

function create_char_inventory_tab(expand_local_branches, show_prices, showsellbutton)
	local reset = true
	local isvisible = false
	local wait_for_transaction_completed = false
	local container
	local treectl, invinfoctl, tree_info, sellbutton
	local show_info
	local inv_sort_funcs
	local which_setup_func
	local sort_chooser
	
	sort_chooser = iup.stationsubsublist{
			"Location",
			"Type",
			dropdown="YES", value=1, visible_items=5,expand="NO",
			action=function(self,str,index,state)
				if state==1 then
					which_setup_func = inv_sort_funcs[index]
					which_setup_func()
				end
			end
			}

	treectl = iup.stationsubsubtree{expand="YES",
		addexpanded="NO",
		selection_cb=function(self, id, state)
			if state == 1 then
				show_info(id)
			end
		end,
		renamenode_cb=function(self, id, name)
			if self['KIND'..id] == "BRANCH" then
				local state = self['STATE'..id]
				if state == "EXPANDED" then
					self:setstate(id, "COLLAPSED")
				else
					self:setstate(id, "EXPANDED")
				end
			end
		end,
	}

	invinfoctl = iup.stationsubsubmultiline{readonly="YES", expand="YES",value=""}
	if showsellbutton then
		sellbutton = iup.stationbutton{title="Sell Selected",
			action=function(self)
				self.active = "NO"
				local entry = tree_info[tonumber(treectl.value)]
				if entry then
					local iteminfo = GetStationSellableInventoryInfoByID(entry.data)
					if iteminfo then
						local q = GetInventoryItemQuantity(entry.data)
						StationSellItem(self, iteminfo, q)
					end
				end
			end}
		container = iup.vbox{
			iup.hbox{
				treectl,
				invinfoctl,
			},
			iup.stationsubsubframebg{
				iup.hbox{
					sellbutton,
					iup.fill{},
				}
			}
		}
	else
		container = iup.vbox{
			iup.stationsubsubframebg{iup.hbox{iup.label{title='Sort by:'},sort_chooser,iup.fill{}}},
			iup.hbox{
				treectl,
				iup.stationsubsubframehdivider{size=5},
				invinfoctl,
			}
		}
	end



	local function add_hierarchy(entry, index, depth, expand_branches)
		local entry_data = entry.data
		local itemicon = GetInventoryItemIcon(entry_data)
		local itemname = entry.dataitemname
		local itemquantity = GetInventoryItemQuantity(entry_data)
		local classtype = entry.dataclasstype
		if classtype == CLASSTYPE_STORAGE then
			local stationid = GetStorageItemInfo(entry_data)
			local maxcargo, _, _, _, mincargo = GetStationMaxCargo(stationid)
			if (not entry[1]) and (maxcargo==mincargo) then return index end  -- don't show empty storage unless you're renting it.
			if stationid ~= GetCurrentStationID() then
				local curcargo = GetStationCurrentCargo(stationid)
				local infocolor
				
				-- Ticket #251 change color based on rent/usage
				if curcargo > maxcargo then
					-- too much cargo = red
					infocolor = TOO_MUCH_CARGO_COLOR
				elseif maxcargo > mincargo then
					-- currently renting = yellow
					infocolor = CURRENTLY_RENTING_COLOR
				else
					infocolor = ""
				end
				local sectorid = GetSectorIDOfStation(stationid)
				itemname = string.format(infocolor.."%s - %s (%s / %s cu)", tostring(ShortLocationStr(sectorid)), tostring(GetStationName(stationid)), comma_value(curcargo), comma_value(maxcargo))
				itemicon = "images/treebranchcollapsed.png"
			else
				itemname = nil
			end
		elseif classtype == CLASSTYPE_SHIP then
			if entry_data == GetActiveShipID() then
				itemname = itemname.." (Active Ship)"
			end
			local shipinv = GetShipInventory(entry_data, true)
			-- show addons and cargo in sub branches
			local numitems = entry and (#entry) or 0
			treectl:addbranch(index, string.format("%s - %s %s", itemname, comma_value(numitems), (numitems==1 and "item" or "items")))
			index=index+1
			if expand_branches then treectl:setstate(index, "EXPANDED") end
			tree_info[index] = entry
			treectl:setdepth(index, depth)
			treectl:setimage(index, itemicon)
			treectl:setimageexpanded(index, itemicon)
			-- add addons
			treectl:addbranch(index, "Equipment")
			index=index+1
			treectl:setstate(index, "EXPANDED")
			tree_info[index] = entry
			treectl:setdepth(index, depth+1)
			for _,addonid in ipairs(shipinv.addons) do
				if entry[1] then
					for __,b in ipairs(entry) do
						if b.data == addonid then
							index = add_hierarchy(b, index, depth+2, expand_branches)
							break
						end
					end
				end
			end
			-- add cargo
			treectl:addbranch(index, string.format("Cargo %d/%d cu", GetShipCargoCount(entry_data) or "0", GetShipMaxCargo(entry_data) or "0"))
			index=index+1
			treectl:setstate(index, "EXPANDED")
			tree_info[index] = entry
			treectl:setdepth(index, depth+1)
			for _,cargoid in ipairs(shipinv.cargo) do
				if entry[1] then
					for __,b in ipairs(entry) do
						if b.data == cargoid then
							index = add_hierarchy(b, index, depth+2, expand_branches)
							break
						end
					end
				end
			end
			return index
		elseif classtype == CLASSTYPE_ADDON then
			local curammo, maxammo = GetAddonItemInfo(entry_data)
			if maxammo and maxammo > 0 then
				itemname = string.format("(%d/%d) %s", curammo, maxammo, itemname)
			end
		end
		if (itemquantity > 1) and (classtype ~= CLASSTYPE_STORAGE) then
			itemname = string.format("%sx %s", comma_value(itemquantity), tostring(itemname))
		end
		
		if entry[1] then
			if itemname then
				local numitems = (#entry)
				treectl:addbranch(index, string.format("%s - %s %s", itemname, comma_value(numitems), (numitems==1 and "item" or "items")))
				index=index+1
				if expand_branches then treectl:setstate(index, "EXPANDED") end
				tree_info[index] = entry
				treectl:setdepth(index, depth)
				if classtype ~= CLASSTYPE_STORAGE then
					-- don't bother showing icon for storage, since there is no icon made for storage (yet)
					treectl:setimage(index, itemicon)
					treectl:setimageexpanded(index, itemicon)
				end
				depth = depth + 1
			end
			table.sort(entry, entrysortfunc)
			for k,v in ipairs(entry) do
				index = add_hierarchy(v, index, depth, expand_branches)
			end
		elseif itemname then
			treectl:addleaf(index, itemname)
			index=index+1
			tree_info[index] = entry
			treectl:setdepth(index, depth)
			treectl:setimage(index, itemicon)
		end
		return index
	end

	show_info = function(index)
		local entry = tree_info[index]
		if entry then
			local itemicon, itemname, q, m, desc, longdesc, extdesc, c, classtype = GetInventoryItemInfo(entry.data)
			if classtype ~= CLASSTYPE_STORAGE then
				local fulldesc = ""
				if classtype == CLASSTYPE_SHIP then
					fulldesc = string.gsub(extdesc or "", "|", "\n")
				else
					fulldesc = string.gsub(longdesc or "", "|", "\n")
				end
				if show_prices then
					local iteminfo = GetStationSellableInventoryInfoByID(entry.data)
					if iteminfo then
						local price, unitcost = GetStationSellableInventoryPriceByID(entry.data,q)
						if iteminfo.usable ~= false then -- note: if usable == nil it is equivalent to true
							local isnotempty
							if classtype == CLASSTYPE_SHIP then
								local shipinv = GetShipInventory(iteminfo.itemid)
								if next(shipinv.addons) or next(shipinv.cargo) then
									isnotempty = true
								else
									isnotempty = nil
								end
								if isnotempty == true then
									fulldesc = "\127ff0000Not empty.\127ffffff\n\n"
											..fulldesc
								end
								local activeshipid = GetActiveShipID()
								if activeshipid and iteminfo.itemid == activeshipid then
									fulldesc = "\12700ff00This is your active ship.\127ffffff\n\n"
											..fulldesc
								end
							elseif classtype == CLASSTYPE_ADDON then
								if GetInventoryItemClassType(c) == CLASSTYPE_SHIP then
									iteminfo.isconnected = GetShipPortIDOfItem(c, entry.data) and true or false
								else
									iteminfo.isconnected = false
								end
							end
							iteminfo.isnotempty = isnotempty
							if isnotempty == true then
								local _p, _c = GetCargoValue(iteminfo.itemid)
								price = price + _p
								unitcost = unitcost + _c
							end
						end
						if unitcost and unitcost >= 0 then
							local color = GetProfitHexColor(price, unitcost)
							local totalprofit = price-(unitcost*q)
							if totalprofit >= 0 then
								fulldesc = string.format("Sell price: %s c\nPurchased price: %s c\nUnit profit: \127%s%s c\127ffffff\nTotal profit: \127%s%s c\127ffffff\n\n",
										comma_value(price), comma_value(unitcost), color, comma_value(math.floor(10*totalprofit/q)/10), color, comma_value(totalprofit))..fulldesc
							else
								local totalloss = -totalprofit
								fulldesc = string.format("Sell price: %s c\nPurchased price: %s c\nUnit loss: \127%s%s c\127ffffff\nTotal loss: \127%s%s c\127ffffff\n\n",
										comma_value(price), comma_value(unitcost), color, comma_value(math.floor(10*totalloss/q)/10), color, comma_value(totalloss))..fulldesc
							end
							if sellbutton then sellbutton.active = "YES" end
						else
							if sellbutton then sellbutton.active = "NO" end
						end
					else
						fulldesc = "\127ff0000You cannot sell this here.\n\n\127ffffff"..fulldesc
						if sellbutton then sellbutton.active = "NO" end
					end
				end
				-- extdesc also includes LongDesc from objtable already
				if desc and fulldesc then
					invinfoctl.value = desc.."\n\n"..fulldesc
				else
					invinfoctl.value = desc or fulldesc or ""
				end
			else
				local stationid = GetStorageItemInfo(entry.data)
				local stationname = GetStationName(stationid)
				if stationname then
					local curcargo = GetStationCurrentCargo(stationid)
					local maxcargo, purchasablemaxcargo, purchaseincrement, purchaseprice, mincargo, costperweek = GetStationMaxCargo(stationid)
					local rentedcargo = maxcargo - mincargo
					invinfoctl.value = string.format("%s\n\nStorage:\n%s / %s cu\n%s cu rented @ %s c/week\n\n%s\n\n%s", tostring(stationname), comma_value(curcargo), comma_value(maxcargo), comma_value(rentedcargo), comma_value(costperweek), tostring(FactionNameFull[GetStationFaction(stationid)]), tostring(ShortLocationStr(GetSectorIDOfStation(stationid))))
				else
					invinfoctl.value = tostring(ShortLocationStr(GetSectorIDOfStation(stationid)))
				end
				if sellbutton then sellbutton.active = "NO" end
			end
		else
			local stationname = GetStationName()
			if stationname then
				local curcargo = GetStationCurrentCargo()
				local maxcargo, purchasablemaxcargo, purchaseincrement, purchaseprice, mincargo, costperweek = GetStationMaxCargo()
				local rentedcargo = maxcargo - mincargo
				invinfoctl.value = string.format("%s\n\nStorage:\n%s / %s cu\n%s cu rented @ %s c/week\n\n%s\n\n%s", tostring(stationname), comma_value(curcargo), comma_value(maxcargo), comma_value(rentedcargo), comma_value(costperweek), tostring(FactionNameFull[GetStationFaction()]), tostring(ShortLocationStr(GetCurrentSectorid())))
			else
				invinfoctl.value = tostring(ShortLocationStr(GetCurrentSectorid()))
			end
			if sellbutton then sellbutton.active = "NO" end
		end
		invinfoctl.scroll = "TOP"
	end

	local function setup_char_inventory_tab()
		local hierarchy = {}
		tree_info = {}
		for itemid,_ in PlayerInventoryPairs() do
			local containerid = GetInventoryItemContainerID(itemid)
			local entry = hierarchy[itemid] or {}
			hierarchy[itemid] = entry
			entry.data = itemid
			entry.dataclasstype = GetInventoryItemClassType(itemid)
			entry.dataitemname = GetInventoryItemName(itemid)

			local parententry = hierarchy[containerid] or {}
			hierarchy[containerid] = parententry
			table.insert(parententry, entry)
		end

		treectl:clear()
		local index = 0
		treectl:setname(0, "Local Inventory")
		local globallist = hierarchy[0]
		if globallist then
			table.sort(globallist, entrysortfunc)
			local depth = 1
			local numlocalitems = 0
			for k,v in ipairs(globallist) do
				local classtype = v.dataclasstype -- GetInventoryItemClassType(v.data)
				if classtype == CLASSTYPE_STORAGE then
					local stationid = GetStorageItemInfo(v.data)
					if stationid == GetCurrentStationID() then
						numlocalitems = numlocalitems + (#v)
						depth = 1
					else
						depth = nil
					end
				elseif depth == 1 then
					numlocalitems = numlocalitems + 1
				end

				index = add_hierarchy(v, index, depth or 0, depth==1 and expand_local_branches or false)
				depth = nil  -- depth = 1 for first item, and = 0 for all next items
			end
			local curcargo = GetStationCurrentCargo()
			local maxcargo, _, _, _, mincargo = GetStationMaxCargo()
			local infocolor
			-- Ticket #251 change color based on rent/usage
			if curcargo > maxcargo then
				-- too much cargo = red
				infocolor = TOO_MUCH_CARGO_COLOR
			elseif maxcargo > mincargo then
				-- currently renting = yellow
				infocolor = CURRENTLY_RENTING_COLOR
			else
				infocolor = ""
			end
			treectl:setname(0, infocolor.."Local Inventory "..(maxcargo > 0 and string.format("(%s / %s cu)", comma_value(curcargo), comma_value(maxcargo)) or "").." - "..comma_value(numlocalitems)..(numlocalitems==1 and " item" or " items"))
			index = tonumber(treectl.value)
		end
		show_info(index)
	end


local classtype_lut = {
	[CLASSTYPE_GENERIC]	= "Commodities",
	[CLASSTYPE_SHIP]		= "Ships",
	[CLASSTYPE_ADDON]		= "Addons"
}

	local function setup_char_inventory_tab_by_itemtype()
		local hierarchy = {[0] = {}}
		tree_info = {}
		for itemid,_ in PlayerInventoryPairs() do
			local containerid = GetInventoryItemContainerID(itemid)
			local itemtype = GetInventoryItemType(itemid)
			local entry = hierarchy[itemtype]
			if not entry then
				entry = {quantity=0,
					dataclasstype = GetInventoryItemClassType(itemid),
					dataitemname = GetInventoryItemName(itemid),
					dataicon = GetInventoryItemIcon(itemid),
					itemtype = itemtype,
					containers = {}
					}
				if GetInventoryItemClassType(itemid) ~= CLASSTYPE_STORAGE then
					table.insert(hierarchy[0], entry)
				end
			end
			hierarchy[itemtype] = entry
			
			entry.containers[containerid] = (entry.containers[containerid] or 0) + GetInventoryItemQuantity(itemid)
			
			entry.quantity = entry.quantity + GetInventoryItemQuantity(itemid)
		end
		
		treectl:clear()
		local index = 0
		local currentclasstype = CLASSTYPE_GENERIC
		treectl:setname(index, classtype_lut[currentclasstype])
--		index = index + 1
		local globallist = hierarchy[0]
		if globallist then
			table.sort(globallist, function(a,b)
						if a.dataclasstype == b.dataclasstype then
							return a.dataitemname < b.dataitemname
						else
							return a.dataclasstype < b.dataclasstype
						end
					end)
			
			for k,entry in ipairs(globallist) do
				local itemtype = entry.itemtype
				if currentclasstype ~= hierarchy[itemtype].dataclasstype then
					currentclasstype = hierarchy[itemtype].dataclasstype
					treectl:addbranch(index, classtype_lut[currentclasstype] or tostring(currentclasstype))
					index=index+1
					treectl:setstate(index, "EXPANDED")
					treectl:setdepth(index, 0)
				end

				treectl:addbranch(index, hierarchy[itemtype].quantity..'x '..hierarchy[itemtype].dataitemname)
				index=index+1
				treectl:setstate(index, "COLLAPSED")
				treectl:setdepth(index, 1)
				treectl:setimage(index, hierarchy[itemtype].dataicon)
				treectl:setimageexpanded(index, hierarchy[itemtype].dataicon)

				for containerid,quantity in pairs(hierarchy[itemtype].containers) do
					local containername
					local iconname
					if GetInventoryItemClassType(containerid) == CLASSTYPE_STORAGE then
						local stationid = GetStorageItemInfo(containerid)
						local sectorid = GetSectorIDOfStation(stationid)
						containername = quantity..'x @ '..tostring(ShortLocationStr(sectorid))..' - '..tostring(GetStationName(stationid))
						iconname = "images/treebranchcollapsed.png"
					else
						if containerid > 0 then
							containername = quantity..'x @ '..tostring(GetInventoryItemName(containerid))
							iconname = GetInventoryItemIcon(containerid) or "images/treebranchcollapsed.png"
						else
							containername = quantity..'x \12700ff00Local'
							iconname = "images/treebranchcollapsed.png"
						end

						-- get containers container name
						local containercontainerid = GetInventoryItemContainerID(containerid)
						if containercontainerid and GetInventoryItemClassType(containercontainerid) == CLASSTYPE_STORAGE then
							local stationid = GetStorageItemInfo(containercontainerid)
							local sectorid = GetSectorIDOfStation(stationid)
							containername = containername..' @ '..tostring(ShortLocationStr(sectorid))..' - '..tostring(GetStationName(stationid))
						elseif containercontainerid == 0 then
							containername = containername..' \12700ff00Local'
						end
					end

					treectl:addleaf(index, containername)
					index=index+1
					treectl:setdepth(index, 2)
					treectl:setimage(index, iconname)
				end
				
			end
			
		end
	end

	inv_sort_funcs = {
		setup_char_inventory_tab,
		setup_char_inventory_tab_by_itemtype
	}

	which_setup_func = setup_char_inventory_tab

	function container:OnShow()
		isvisible = true
		if reset then
			reset = false
			which_setup_func()
		end
	end
	function container:OnHide()
		isvisible = false
	end
	function container:OnEvent(eventname, ...)
		if eventname == "INVENTORY_ADD"
			or eventname == "INVENTORY_REMOVE"
			or eventname == "INVENTORY_UPDATE"
			or eventname == "SECTOR_CHANGED"
			or eventname == "SHIP_UPDATED"
			or eventname == "SHIP_CHANGED" then
				if IsTransactionInProgress() then
					wait_for_transaction_completed = true
				else
					if isvisible then
						which_setup_func()
					else
						reset = true
					end
				end
		elseif eventname == "STATION_UPDATE_REQUESTED" then
			wait_for_transaction_completed = true
		elseif eventname == "TRANSACTION_COMPLETED" then
			if wait_for_transaction_completed then
				wait_for_transaction_completed = false
				if isvisible then
					which_setup_func()
				else
					reset = true
				end
			end
		end
	end

	RegisterEvent(container, "INVENTORY_ADD")
	RegisterEvent(container, "INVENTORY_REMOVE")
	RegisterEvent(container, "INVENTORY_UPDATE")
	RegisterEvent(container, "SHIP_UPDATED")
	RegisterEvent(container, "SHIP_CHANGED")
	RegisterEvent(container, "SECTOR_CHANGED")
	RegisterEvent(container, "TRANSACTION_COMPLETED")
	RegisterEvent(container, "STATION_UPDATE_REQUESTED")

	return container, treectl
end
