preset_buttons = {}
local PURCHASE_VERIFICATION_THRESHOLD = 200

local function clear_tree(tree)
	local id=0
	while tree["name"..id] do
		iup.TreeSetUserId(tree, id, nil)
		id = id + 1
	end
	tree:clear()
end

local reasontable = {
	[6] = "Faction personnel only\n",
	[7] = "Faction personnel only\n",
	[10] = "Winners of last week's 'Capture The Cargo' contest only\n",
	[12] = "Specially sanctioned personnel only\n",
	[14] = "Faction personnel with sufficient standing only\n",
	[21] = "Mentors who have mentored sufficient number of mentees only\n",
	[22] = "Mentors with sufficient number of good votes only\n",
	[23] = "Mentors with sufficient number of bad votes only\n",
	[49] = "Access key not found\n",
}

local alpha, selalpha = math.floor(ListColors.Alpha/255*204), math.floor(ListColors.SelectedAlpha/255*204)
local even, odd, sel = ListColors[0], ListColors[1]
local cnumbers = ListColors.Numbers[2]
sel = math.floor(cnumbers[1]*1.55).." "..math.floor(cnumbers[2]*1.55).." "..math.floor(cnumbers[3]*1.55).." "..ListColors.SelectedAlpha

local normalcolors = {
	[0] = even.." "..alpha.." *",
	[1] = odd.." "..alpha.." *",
	selcolor = sel.." *",
	textcolor = "255 255 255 255 *",
}
local cannothavecolors = {
--	[0] = "83 0 0 204 *",
--	[1] = "96 0 0 204 *",
	[0] = even.." "..alpha.." *",
	[1] = odd.." "..alpha.." *",
--	selcolor = "144 0 0 204 *",
	selcolor = sel.." *",
	textcolor = "255 0 0 255 *",
}
local cannotaffordcolors = {
	[0] = "83 83 83 "..alpha.." *",
	[1] = "96 96 96 "..alpha.." *",
	selcolor = "144 144 144 "..selalpha.." *",
	textcolor = "255 255 255 255 *",
}
local cannothaveaffordcolors = {
	[0] = "83 83 83 "..alpha.." *",
	[1] = "96 96 96 "..alpha.." *",
	selcolor = "144 144 144 "..selalpha.." *",
	textcolor = "255 0 0 255 *",
}
local spacercolors = {
	[0] = "0 0 0 0 *",
	[1] = "0 0 0 0 *",
	selcolor = "0 0 0 0 *",
}
ShipPalette_string = {}
for i=1,256 do
	local c = ShipPalette[i]
	ShipPalette_string[i] = string.format("%d %d %d",
						c:x()*255,
						c:y()*255,
						c:z()*255)
end

local purchase_profit_color = "181 247 181"
local purchase_loss_color = "247 181 181"
local purchase_normal_color = "255 255 255"
local purchase_profit_hexcolor = "b5f7b5"
local purchase_loss_hexcolor = "f7b5b5"
local purchase_normal_hexcolor = "ffffff"

function GetProfitColor(price, unitcost)
	unitcost = tonumber(unitcost)
	if unitcost then
	-- and unitcost > 0 then
		if price < unitcost then
			return purchase_loss_color
		elseif price > unitcost then
			return purchase_profit_color
		else
			return purchase_normal_color
		end
	else
		return purchase_normal_color
	end
end

function GetProfitHexColor(price, unitcost)
	unitcost = tonumber(unitcost)
	if unitcost then
	-- and unitcost > 0 then
		if price < unitcost then
			return purchase_loss_hexcolor
		elseif price > unitcost then
			return purchase_profit_hexcolor
		else
			return purchase_normal_hexcolor
		end
	else
		return purchase_normal_hexcolor
	end
end

function PrintPurchaseTransaction(name, quantity, totalvalue, totalcost)
	local profit
	local diff = totalvalue - totalcost
	if diff < 0 then
		profit = "loss"
		diff = -diff
	else
		profit = "profit"
	end
	purchaseprint(comma_value(quantity).."x of "..name.." sold for a total amount of "..comma_value(totalvalue).."c ("..comma_value(profit).." of "..comma_value(diff).."c)")
end

local AddonPortType_Small = 0
local AddonPortType_Large = 1
local AddonPortType_Engine = 3
local AddonPortType_PowerCell = 4
local AddonPortType_Turret = 5

local porttypelut = {
	["turret"] = AddonPortType_Turret,
	["battery"] = AddonPortType_PowerCell,
	["engine"] = AddonPortType_Engine,
	["heavyweapon"] = AddonPortType_Large,
	["lightweapon"] = AddonPortType_Small,
}

function GetCargoValue(shipitemid)
	local value = 0
	local cost = 0
	local shipinv = GetShipInventory(shipitemid)
	for _,itemid in pairs(shipinv.addons) do
		local itemquantity = GetInventoryItemQuantity(itemid)
		local iteminfo = GetStationSellableInventoryInfoByID(itemid)
		value = value + (GetStationSellableInventoryPriceByID(itemid, itemquantity) or 0)
		cost = cost + (iteminfo and (iteminfo.unitcost*itemquantity) or 0)
	end
	for _,itemid in pairs(shipinv.cargo) do
		local itemquantity = GetInventoryItemQuantity(itemid)
		local iteminfo = GetStationSellableInventoryInfoByID(itemid)
		value = value + (GetStationSellableInventoryPriceByID(itemid, itemquantity) or 0)
		cost = cost + (iteminfo and (iteminfo.unitcost*itemquantity) or 0)
	end
	return value, cost
end

local shiporder = ShipOrder
local shiporder_inverted = {}
for k,v in ipairs(shiporder) do
	shiporder_inverted[v] = k
end

local function sort_shipnames(a,b)
	local a_val = shiporder_inverted[a.name] or shiporder_inverted[a.sortgroup] or tonumber(a.sortgroup) or 0
	local b_val = shiporder_inverted[b.name] or shiporder_inverted[b.sortgroup] or tonumber(b.sortgroup) or 0
	
	if a_val ~= b_val then
		return a_val < b_val
	elseif a.name ~= b.name then
		return tostring(a.name) < tostring(b.name)
	else
		return a.price < b.price
	end
end

local function sort_loadunloadlists(a,b)
	if a.name ~= b.name then
		return tostring(a.name) < tostring(b.name)
	else
		return a.price < b.price
	end
end


local function makesubdlg(showquantity, showprice)
	local fontsize = Font.Default
	local pricetext
	local iconimage = iup.label{title="", image="",size=(fontsize*2).."x"..(fontsize*2),expand="NO"}
	local namelabel = iup.label{title="Name", font=fontsize}
	local desclabel = iup.label{title="Desc", font=fontsize}
	local quantitytext
	local pricequan_vbox = {alignment="ARIGHT"}
	if showprice then
		 pricetext = iup.label{title="100 c"}
		 table.insert(pricequan_vbox, pricetext)
	end
	if showquantity then
		quantitytext = iup.label{title="", alignment="ARIGHT"}
		table.insert(pricequan_vbox, quantitytext)
	end
	local entry = iup.hbox{
			iconimage,
			iup.vbox{
				namelabel,
				desclabel,
			},
			iup.fill{},
			iup.vbox(pricequan_vbox),
			alignment="ACENTER",
		}
	local dlgtable = iup.dialog{
		entry,
		border="NO",menubox="NO",resize="NO",
		active="NO",
	}

	function dlgtable:SetIcon(img)
		if not img then
			iconimage.visible = "NO"
		else
			iconimage.visible = "YES"
			iconimage.image = tostring(img)
		end
	end
	function dlgtable:SetName(name)
		namelabel.title = name or ""
	end
	function dlgtable:SetDesc(desc, centerit)
		desclabel.title = desc or ""
		if centerit then
			desclabel.alignment = "ACENTER"
			desclabel.expand = "YES"
		else
			desclabel.alignment = "ALEFT"
			desclabel.expand = "NO"
		end
	end
	function dlgtable:SetPrice(text)
		if pricetext then
			pricetext.title = text or ""
		end
	end
	function dlgtable:SetPriceColor(color)
		if pricetext then
			pricetext.fgcolor = tostring(color)
		end
	end
	function dlgtable:SetQuantity(q)
		if quantitytext then
			quantitytext.title = q and q>1 and ("x "..comma_value(q)) or ""
		end
	end
	function dlgtable:SetTextColor(color)
		if namelabel and color then
			namelabel.fgcolor = color
		end
		if desclabel and color then
			desclabel.fgcolor = color
		end
	end

	dlgtable.showquantity = showquantity
	dlgtable.showprice = showprice

	return dlgtable
end

local _itemdlgcache = {[0]={},{},{},{}}
function get_itemdlg(showquantity, showprice)
	local cache = _itemdlgcache[(showquantity and 2 or 0) + (showprice and 1 or 0)]
	local dlg
	if cache[1] then
		dlg = table.remove(cache)
		dlg.incache = false
	else
		dlg = makesubdlg(showquantity, showprice)
	end
	return dlg
end

function store_itemdlg(dlg)
	if dlg.refreshnametimer then dlg.refreshnametimer:Kill() dlg.refreshnametimer = nil end
	if dlg.refreshdesctimer then dlg.refreshdesctimer:Kill() dlg.refreshdesctimer = nil end

	if not dlg.incache then
		local cache = _itemdlgcache[(dlg.showquantity and 2 or 0) + (dlg.showprice and 1 or 0)]
		dlg.incache = true
		table.insert(cache, dlg)
	end
end

function GetItemPartialDesc(iteminfo)
	if not iteminfo then
		return nil
	end
	local longdesc = iteminfo.longdesc or ""
	longdesc = "\127ffffff"..longdesc
	if iteminfo.isnotempty == true then
		longdesc = "\127ff0000Not empty."
				.."\n\n"..longdesc
	end
	local activeshipid = GetActiveShipID()
	if activeshipid and iteminfo.itemid == activeshipid then
		longdesc = "\12700ff00This is your active ship.\n\n"
				..longdesc
	end
	if iteminfo.neededlevels and iteminfo.type ~= "commodities" then
		if iteminfo.cannotbuyreason or not CanUseMerchandise(iteminfo) then
			local prefix
			if iteminfo.cannotbuyreason then
				prefix = reasontable[iteminfo.cannotbuyreason] or "This item is not for you. ("..tostring(iteminfo.cannotbuyreason)..")\n"
			else
				prefix = ""
			end
			longdesc = "\127ff0000"..prefix.."Required licenses to equip:\n"
					..table.concat(iteminfo.neededlevels, "/")
					..(iteminfo.usable==nil and "\n\n" or "\nItem will be placed in station storage\n\n")..longdesc
		else
			longdesc = "Required licenses:\n"
					..table.concat(iteminfo.neededlevels, "/")
					.."\n\n"..longdesc
		end
	end
	return longdesc
end

function GetItemFullDesc(iteminfo)
	if not iteminfo then
		return nil
	end
	local longdesc = GetItemPartialDesc(iteminfo)

	-- do profit info
	local price = iteminfo.price
	local unitcost = iteminfo.unitcost
	if iteminfo.usable ~= false then -- note: if usable == nil it is equivalent to true
		if iteminfo.usable and iteminfo.price > GetMoney() then
			longdesc = "\127ff0000You cannot afford this item.\n\n\127ffffff"..longdesc
		else
			if iteminfo.isnotempty == true then
				local _p, _c = GetCargoValue(iteminfo.itemid)
				price = price + _p
				unitcost = unitcost + _c
			end
		end
		end
	if tonumber(unitcost) then
	-- removing this section allows ore to show total profit on the sell tab
	-- ore show up as 0 unitcost
	--and unitcost > 0
		local quan = GetInventoryItemQuantity(iteminfo.itemid)
		local totalprofit = GetStationSellableInventoryPriceByID(iteminfo.itemid,quan)-(unitcost*quan)
		local profit = comma_value(math.abs(totalprofit))
		if totalprofit >= 0 then
			longdesc = longdesc..string.format("\n\nSell price: %s c\nPurchased price: %s c\nUnit profit: \127%s%s c\127ffffff\nTotal profit: \127%s%s c\127ffffff",
					comma_value(price), comma_value(unitcost), purchase_profit_hexcolor, comma_value(math.floor(10*totalprofit/quan)/10), purchase_profit_hexcolor, profit )
		else
			longdesc = longdesc..string.format("\n\nSell price: %s c\nPurchased price: %s c\nUnit loss: \127%s%s c\127ffffff\nTotal loss: \127%s%s c\127ffffff",
					comma_value(price), comma_value(unitcost), purchase_loss_hexcolor, comma_value(math.floor(-10*totalprofit/quan)/10), purchase_loss_hexcolor, profit )
		end

	end

	return longdesc
end

function clear_listbox(listcontrol, itemlist)
	local curselindex

	listcontrol[1] = nil
	listcontrol.value = 0 -- this will cause the sel callback to not send unsel

	if not itemlist then return 0 end

	for k,subdlg in ipairs(itemlist) do
		if subdlg.sel then
			curselindex = k
			subdlg.sel = false
		end
		iup.Detach(subdlg)
		store_itemdlg(subdlg)
	end

	return curselindex
end

function fill_listbox(listcontrol, itemlist, curselindex, setup_cb, show_quantity, show_price)
	local _itemlist = {}
	for k,v in ipairs(itemlist) do
		local subdlg = get_itemdlg(show_quantity, show_price)
		if k == curselindex then
			subdlg.sel = true
		end
		table.insert(_itemlist,subdlg)
		
		setup_cb(k, v, subdlg)

		if listcontrol then iup.Append(listcontrol, subdlg) end
	end

	if listcontrol then
		listcontrol:map()
		if (#_itemlist) == 0 then
			listcontrol.scroll = "TOP"
		end

		listcontrol[1] = 1
	end

	return _itemlist
end

local function set_item_info(index, iteminfo, dlg)
	local price = iteminfo.price
	local pricestr
	local colors
	local centerit
	if not price then
		colors = spacercolors
		centerit = true
	else
		local unitcost = iteminfo.unitcost
		if iteminfo.usable ~= false then -- note: if usable == nil it is equivalent to true
			local canuse = CanUseMerchandise(iteminfo)
			if canuse then
				if iteminfo.price > GetMoney() then
					-- only test this if it is merchandise
					colors = cannotaffordcolors
				else
					if iteminfo.isnotempty == true then
						local _p, _c = GetCargoValue(iteminfo.itemid)
						price = price + _p
						unitcost = unitcost + _c
					end
					colors = normalcolors
				end
			else
				if iteminfo.price > GetMoney() then
					colors = cannothaveaffordcolors
				else
					colors = cannothavecolors
				end
			end
		else
			if iteminfo.price > GetMoney() then
				colors = cannothaveaffordcolors
			else
				colors = cannothavecolors
			end
		end
		if tonumber(unitcost) then
		-- and unitcost > 0
			pricestr = comma_value(price).." c \127ffffff("..comma_value(unitcost)..")"
		else
			pricestr = comma_value(price).." c"
		end
		dlg:SetPriceColor(GetProfitColor(price, unitcost))
	end

	dlg:SetPrice(pricestr)

	dlg.colors = colors
	if dlg.sel then
		dlg.bgcolor = colors.selcolor
	else
		dlg.bgcolor = colors[math.fmod(index, 2)]
	end

	dlg:SetQuantity(GetInventoryItemQuantity(iteminfo.itemid))
	dlg:SetName(iteminfo.name and (iteminfo.name..(iteminfo.itemid == GetActiveShipID() and " (Active Ship)" or "")..(iteminfo.isnotempty and " *Not Empty*" or "")))
	dlg:SetDesc(iteminfo.type=="commodities" and iteminfo.locallyproduced and "  Locally Produced Trade Goods" or (iteminfo.desc == 'Trade Goods' and '' or '  '..iteminfo.desc), centerit)
	dlg:SetIcon(iteminfo.icon)
	dlg:SetTextColor(colors.textcolor)
end

local function create_item_list_thingy(buyname, buyaction, maxaction, issubsub, helpfultext, hotkey, issell)
	local cursel
	local items
	local subdlglist
	local listcontrol = iup.itemlisttemplate({}, issubsub)
	local _multiline, _framebg
	if issubsub then
		_multiline = iup.stationsubsubmultiline
		_framebg = iup.stationsubsubframebg
	else
		_multiline = iup.stationsubmultiline
		_framebg = iup.stationsubframebg
	end
	local infotext = _multiline{readonly="YES", expand="YES",value=""}
	local buybutton, maxbutton, quantityedit

	local function _pricecalc(quantity)
		return GetStationSellableInventoryPriceByID(items[cursel].itemid, quantity)
	end
	local function _buyaction()
		quantityedit.value = SellItemDialog:GetQuantity()
		buyaction(buybutton)
		HideDialog(SellItemDialog)
	end
	local function _cancelaction()
		HideDialog(SellItemDialog)
		StartSellInventoryItem(0)  -- unsubscribe from updates
	end
	local function _maxaction()
		return maxaction(cursel)
	end

	buybutton = iup.stationbutton{title=buyname, action=function(self)
			if issell then
				local itemid = items[cursel].itemid
				StartSellInventoryItem(itemid, function()
						SellItemDialog:SetupCallbacks(GetInventoryItemName(itemid), _pricecalc, _maxaction, _buyaction, _cancelaction)
						ShowDialog(SellItemDialog)
					end)
			else
				buyaction(self)
			end
		end,
		active="NO", hotkey=hotkey}

	maxbutton = iup.stationbutton{title="Max", visible = issell and "NO" or "YES"}
	quantityedit = iup.text{value="1",
		size="60x",
		visible = issell and "NO" or "YES"
	}

	function maxbutton:action()
		local q = maxaction(cursel)
		if q then quantityedit.value = q end
	end

	local container
	if issubsub then
		container = iup.vbox{
			iup.hbox{
				listcontrol,
				iup.stationsubsubframehdivider{size=5},
				infotext,
			},
			iup.stationsubsubframevdivider{size=5},
			_framebg{
				iup.hbox{
					buybutton,
					iup.label{title="Quantity:", visible = issell and "NO" or "YES"},
					quantityedit,
					maxbutton,
					iup.fill{},
					alignment="ACENTER",
					expand="YES",
					gap=5,
--					margin="2x2",
				},
			},
		}
	else
		container = iup.vbox{
			iup.hbox{
				listcontrol,
				infotext,
			},
			_framebg{
				iup.vbox{
					iup.hbox{
						buybutton,
						iup.label{title="Quantity:"},
						quantityedit,
						maxbutton,
						iup.fill{},
						alignment="ACENTER",
						expand="YES",
						gap=5,
						margin="2x2",
					},
					iup.hbox{
						iup.stationbutton{title="Help", action=function() container:OnHelp() end, hotkey=iup.K_F1, tip="Help for this interface"},
						iup.fill{},
					},
				},
			},
		}
	end

	local function set_infodesc(dlginfo, iteminfo, append)
		if not iteminfo then
			infotext.value = helpfultext
			return
		end
		dlginfo.sel = true
		local longdesc = GetItemFullDesc(iteminfo) or helpfultext
		if not append then
			infotext.value = ""
			longdesc = "\127ffffff"..longdesc
		else
			longdesc = "\1279f9fff"..longdesc
		end
		infotext.fgcolor="255 255 255"
		if append then
			longdesc = "\n"..longdesc
		end

		infotext.append = longdesc
		dlginfo.bgcolor = dlginfo.colors.selcolor
		if (iteminfo.usable ~= false) then -- note: if usable == nil it is equivalent to true
			if (not iteminfo.usable) or iteminfo.price <= GetMoney() then
				buybutton.active = "YES"
			end
		end

		if not iteminfo.price then
			buybutton.active = "NO"
			quantityedit.active = "NO"
			maxbutton.active = "NO"
		else
			quantityedit.active = "YES"
			maxbutton.active = "YES"
		end
	end

	function listcontrol:action(text, index, selection)
		local dlginfo = subdlglist[index]
		local ctrl_down = gkinterface.IsCtrlKeyDown()
		if selection >= 1 then
			if selection == 2 and not dlginfo.sel then
				return
			end
			cursel = index
			set_infodesc(dlginfo, items[index], ctrl_down)
			iup.SetFocus(buybutton)
		else
			cursel = nil
			if not ctrl_down then
				infotext.value = ""
			end
			dlginfo.sel = false
			dlginfo.bgcolor = dlginfo.colors[math.fmod(index, 2)]
			buybutton.active="NO"
		end
	end

	function container:getcursel()
		return cursel
	end

	function container:getquantity()
		return tonumber(quantityedit.value)
	end

	function container:setquantity(q)
		quantityedit.value = tostring(q)
	end

	function container:clear()
		cursel = nil
		return clear_listbox(listcontrol, subdlglist)
	end

	function container:fill(_items, index)
		items = _items
		index = index and math.min(index, (#_items))
		subdlglist = fill_listbox(listcontrol, _items, index, set_item_info, true, true)
		set_infodesc(subdlglist[index], _items[index], false)
		listcontrol.value = index
		cursel = index
	end

	return container, buybutton
end

local function prompt_verification(yes_callback, no_callback)
	QuestionDialog:SetMessage("This item is not empty. Are you sure you want to sell it?",
		"Yes", yes_callback,
		"No", no_callback)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

local function prompt_verification2(yes_callback, no_callback)
	QuestionDialog:SetMessage("This item is connected to a ship. Are you sure you want to sell it?",
		"Yes", yes_callback,
		"No", no_callback)
	ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
end

function StationSellItem(button, iteminfo, quantity, callback)
	if (not quantity) or (quantity < 0) then return end
	if iteminfo then
		local previous_money
		local curquan = GetInventoryItemQuantity(iteminfo.itemid)
		quantity = math.min(curquan, quantity)
		local totalvalue = GetStationSellableInventoryPriceByID(iteminfo.itemid, quantity)
		local totalcost = iteminfo.unitcost*quantity
		if iteminfo.isnotempty == true then
			local _p, _c = GetCargoValue(iteminfo.itemid)
			totalvalue = totalvalue + _p
			totalcost = totalcost + _c
		end
		local cb_msg = function(failure_code)
			-- this is called before TRANSACTION_COMPLETED/FAILED
			if not failure_code then
				totalvalue = GetMoney() - previous_money
				PrintPurchaseTransaction(iteminfo.name, quantity, totalvalue, totalcost)
			end
			if callback then callback(failure_code) end
		end

		if iteminfo.isnotempty then
			prompt_verification(function() previous_money = GetMoney() SellInventoryItem(iteminfo.itemid, quantity, cb_msg) HideDialog(QuestionDialog) end,
				function() button.active = "YES" HideDialog(QuestionDialog) end)
		elseif iteminfo.isconnected then
			prompt_verification2(function() previous_money = GetMoney() UnloadSellCargo({{itemid=iteminfo.itemid, quantity=quantity}}, cb_msg) HideDialog(QuestionDialog) end,
				function() button.active = "YES" HideDialog(QuestionDialog) end)
		else
			local itemcontainerid = GetInventoryItemContainerID(iteminfo.itemid)
			local containerclasstype = GetInventoryItemClassType(itemcontainerid)
			previous_money = GetMoney()
			if containerclasstype and containerclasstype == CLASSTYPE_SHIP then
				UnloadSellCargo({{itemid=iteminfo.itemid, quantity=quantity}}, cb_msg)
			else
				SellInventoryItem(iteminfo.itemid, quantity, cb_msg)
			end
		end
	end
end

local function buyitem(iteminfo, quantity, callback)
	if not quantity or quantity < 0 then return end
	if iteminfo then
		PurchaseMerchandiseItem(iteminfo.itemid, quantity, 
			function(failure_code)
				if not failure_code then
					purchaseprint(comma_value(quantity).."x of "..iteminfo.name.." purchased for a total price of "..comma_value((iteminfo.price*quantity)).."c.")
				end
				if callback then callback(failure_code) end
			end)
	end
end

--[[
-- old sort function, rewrote it to use user selectable sorting.
function sort_commodities(a,b)
	local a_usable = CanUseMerchandise(a) and 1 or 0
	local b_usable = CanUseMerchandise(b) and 1 or 0
	if a_usable ~= b_usable then return a_usable > b_usable end
	if a.sortgroup ~= b.sortgroup then
		return (a.sortgroup or "ZZZ") < (b.sortgroup or "ZZZ")
	end
	if a.price and b.price and (a.price ~= b.price) then
		return a.price < b.price
	elseif a.name ~= b.name then
		return a.name < b.name
	else
		return a.itemid < b.itemid
	end
end
]]

function sort_commodities(a,b)
	local a_usable = CanUseMerchandise(a) and 1 or 0
	local b_usable = CanUseMerchandise(b) and 1 or 0
	if a_usable ~= b_usable then return a_usable > b_usable end

	local test = tonumber(SortItems) or 1
	-- death trap triggers default value, 4 is the max value on options listbox.
	if test > 4 then test = 1 end

	-- sort by name
	if test == 1 then
		if a.name == b.name then return a.price < b.price
		else return a.name < b.name
		end

	-- sort by price
	elseif test == 2 then
		--a.price and b.price then
		if a.price == b.price then return a.name < b.name
		else return a.price < b.price
		end

	-- sort by group -> name -> price
	elseif test == 3 then
		if a.sortgroup == b.sortgroup then
			if a.name == b.name then return a.price < b.price
			else return a.name < b.name
			end
		else
			return (a.sortgroup or "ZZZ") < (b.sortgroup or "ZZZ")
		end

	-- sort by group -> price -> name
	elseif test == 4 then
		if a.sortgroup == b.sortgroup then
			if a.price == b.price then return a.name < b.name
			else return a.price < b.price
			end
		else
			return (a.sortgroup or "ZZZ") < (b.sortgroup or "ZZZ")
		end
	end
end

-- this one sorts with all ship-commodities first and then station ones.
function sort_sellable_commodities(a,b)
	if a.containerid ~= b.containerid then
		if a.containerid == GetActiveShipID() then
			return true
		else
			return false
		end
	else
		return sort_commodities(a,b)
	end
end

function CreateStationCommoditiesSellTab(commoditytypefunc, issubsub, helpfultext)
	local reset = true
	local isvisible = false
	local items, subdlglist, container
	local function sellaction(self)
		local quan = tonumber(container:getquantity())
		if quan then
			self.active="NO"
			StationSellItem(self, items[container:getcursel()], quan)
			container:setquantity(1)
		else
			purchaseprint("Invalid quantity.")
			return
		end
	end

	local function maxaction(index)
		local iteminfo = items[index]
		if iteminfo then
			return GetInventoryItemQuantity(iteminfo.itemid)
		end
	end

	container = create_item_list_thingy("Sell Selected...", sellaction, maxaction, issubsub, helpfultext, nil, true)

	local function reload_list(self)
		reset = false
		local curselindex = self:clear()
		items = {}
		for i,iteminfo in StationSellableInventoryPairs() do
			iteminfo.containerid = GetInventoryItemContainerID(iteminfo.itemid)
			if commoditytypefunc(iteminfo) then
				table.insert(items, iteminfo)
			end
		end
		-- sell tab
		table.sort(items, sort_sellable_commodities)
		-- now we need to put the spacers in (and if they should be there)
		if items[1] then
			local activeshipid = GetActiveShipID()
			if items[1].containerid == activeshipid then
				-- since ship cargo is first (because of the sorter)
				-- we now need to check for station cargo
				for k,v in ipairs(items) do
					if v.containerid ~= activeshipid then
						table.insert(items, k, {desc = "Station Cargo"})
						break
					end
				end
				table.insert(items, 1, {desc = "Ship Cargo "..(GetActiveShipCargoCount() or "0").."/"..(GetActiveShipMaxCargo() or "0").." cu"})
			else
				table.insert(items, 1, {desc = "Station Cargo"})
			end
		end
		subdlglist = self:fill(items, curselindex)
	end

	function container:OnShow()
		--sell tab
		isvisible = true
		if reset then
			reload_list(self)
		end
	end

	function container:OnHide()
		isvisible = false
	end

	local wait_for_transaction_completed = false
	function container:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" then
			reset = true
		elseif eventname == "INVENTORY_ADD" or eventname == "INVENTORY_REMOVE" or eventname == "INVENTORY_UPDATE" or eventname == "STATION_UPDATE_REQUESTED" then
			wait_for_transaction_completed = true
		elseif eventname == "TRANSACTION_COMPLETED" then
			if wait_for_transaction_completed then
				wait_for_transaction_completed = false
				if isvisible then
					reload_list(self)
				else
					reset = true
				end
			end
		elseif eventname == "STATION_UPDATE_PRICE" or eventname == "PLAYER_UPDATE_STATS" then
			if isvisible then
				reload_list(self)
			else
				reset = true
			end
		end
	end

	RegisterEvent(container, "ENTERING_STATION")
	RegisterEvent(container, "INVENTORY_ADD")
	RegisterEvent(container, "INVENTORY_REMOVE")
	RegisterEvent(container, "INVENTORY_UPDATE")
	RegisterEvent(container, "TRANSACTION_COMPLETED")
	RegisterEvent(container, "STATION_UPDATE_PRICE")
	RegisterEvent(container, "STATION_UPDATE_REQUESTED")
	RegisterEvent(container, "PLAYER_UPDATE_STATS")

	return container
end

function CreateStationCommoditiesBuyTab(commoditytypefunc, issubsub, helpfultext)
	local reset = true
	local isvisible = false
	local items, subdlglist, container, buybutton
	local function purchaseaction(self)
		local quan = tonumber(container:getquantity())
		if quan then
			local iteminfo = items[container:getcursel()]
-- Check to see if purchased item is an addon and that it'll autoconnect, which should then ignore the storage limits.
local classtype = iteminfo.type
if HasActiveShip() and (classtype == "lightweapon" or classtype == "heavyweapon" or classtype == "battery" or classtype == "engine" or classtype == "turret") then
	-- see if there's an available port.
	-- count how many empty ports of this type are available
	local numports = GetActiveShipNumAddonPorts() or 0
	local availableport = false
	for portid=1,numports do
		local portinfo = GetActiveShipPortInfo(portid)
		local itematport = GetActiveShipItemIDAtPort(portid)
		if (not itematport) and portinfo and portinfo.type == porttypelut[iteminfo.type] then
			availableport = true
			break
		end
	end

	-- yes, just buy it, ignoring storage space.
	if availableport then
		buyitem(iteminfo, quan)
		container:setquantity(1)
		return  -- done
	end
end

			-- make sure items can fit
			local curmaxstationcargo, purchasablemaxcargo, purchaseincrement, purchaseprice = GetStationMaxCargo()
			local curstationstorage = GetStationCurrentCargo()
			local curshipcargo = GetActiveShipCargoCount() or 0
			local maxshipcargo = GetActiveShipMaxCargo() or 0
			local curtotalstorageavailable = ((maxshipcargo+curmaxstationcargo)-(curshipcargo+curstationstorage))
			local quanvolume = quan * iteminfo.volume

			if quanvolume > curtotalstorageavailable then
				if quanvolume <= ((maxshipcargo+purchasablemaxcargo)-(curshipcargo+curstationstorage)) then
					-- not enough station storage available but enough space to rent
					-- find out how many increments are needed.
					local needed = quanvolume - curtotalstorageavailable
					local chunksneeded = math.ceil(needed/purchaseincrement)
					
					local cost = chunksneeded*purchaseincrement*purchaseprice * GetStationFactionAppraisalModifier()
					local weeklycost = cost

					QuestionDialog:SetMessage("Warning: Purchasing "..comma_value(needed).." cu will cost up to and increase your rent by "..comma_value(weeklycost).." c.\nAre you sure you want to purchase "..comma_value(quan).."x of "..iteminfo.name.."?",
						"Yes", function() RentStorage(needed) buyitem(iteminfo, quan) container:setquantity(1) HideDialog(QuestionDialog) end,
						"No", function() HideDialog(QuestionDialog) end)
					ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
				else
					ShowDialog(NotEnoughStorageDialog, iup.CENTER, iup.CENTER)
				end
			else
				if quan > PURCHASE_VERIFICATION_THRESHOLD then
					QuestionDialog:SetMessage("Are you sure you want to purchase "..comma_value(quan).."x of "..iteminfo.name.."?",
						"Yes", function() buyitem(iteminfo, quan) container:setquantity(1) HideDialog(QuestionDialog) end,
						"No", function() HideDialog(QuestionDialog) end)
					ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
				else
					buyitem(iteminfo, quan)
					container:setquantity(1)
				end
			end
		else
			purchaseprint("Invalid quantity.")
		end
	end

	local function maxaction(index)
		local iteminfo = items[index]
		if iteminfo then
			local quan
			if iteminfo.usable == nil then
				quan = GetInventoryItemQuantity(iteminfo.itemid)
			elseif iteminfo.usable == false then
				quan = 0
			else
				quan = 1
				if HasActiveShip() then
					if iteminfo.type == "battery" or
						iteminfo.type == "turret" or
						iteminfo.type == "engine" or
						iteminfo.type == "lightweapon" or
						iteminfo.type == "heavyweapon" then
						-- count how many empty ports of this type are available
						local numports = GetActiveShipNumAddonPorts() or 0
						quan = 0
						for portid=1,numports do
							local portinfo = GetActiveShipPortInfo(portid)
							local itematport = GetActiveShipItemIDAtPort(portid)
							if (not itematport) and portinfo and portinfo.type == porttypelut[iteminfo.type] then
								quan = quan + 1
							end
						end
					else
						local curcargo = GetActiveShipCargoCount() or 0
						local maxcargo = GetActiveShipMaxCargo() or 0
						quan = math.max(math.floor((maxcargo-curcargo)/iteminfo.volume), 1)  -- always make it at least one
					end
				end
				-- calc max quantity based on price
				local maxviaprice = math.floor(GetMoney()/iteminfo.price)
				quan = math.min(quan, maxviaprice>0 and maxviaprice or 1)
			end

			return quan
		end
	end

	container, buybutton = create_item_list_thingy("Purchase Selected", purchaseaction, maxaction, issubsub, helpfultext, iup.K_p, false)
local newcontainer=iup.frame{
	bgcolor="0 0 0 0 *",
	segmented="0 0 1 1",
	container
	}

	local function reload_list(self)
		reset = false
		local curselindex = self:clear()
		local numStationItems = GetNumStationMerch()
		items = {}
		for i=1,numStationItems do
			local iteminfo = GetStationMerchInfo(i)
			if commoditytypefunc(iteminfo) then
				table.insert(items, iteminfo)
			end
		end
		-- buy tab
		table.sort(items, sort_commodities)
		subdlglist = self:fill(items, curselindex)
	end

	function newcontainer:OnShow()
		--buy tab
		isvisible = true
		if reset then
			reload_list(container)
		end
	end

	function newcontainer:OnHide()
		isvisible = false
	end

	local wait_for_transaction_completed = false
	function newcontainer:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" then
			reset = true
		elseif eventname == "STATION_UPDATE_REQUESTED" then
			wait_for_transaction_completed = true
		elseif eventname == "STATION_UPDATE_PRICE" or eventname == "PLAYER_UPDATE_STATS" then
			if isvisible then
				reload_list(container)
			else
				reset = true
			end
		elseif eventname == "TRANSACTION_COMPLETED" then
			if wait_for_transaction_completed then
				wait_for_transaction_completed = false
				if isvisible then
					reload_list(container)
				else
					reset = true
				end
			end
		end
	end

	RegisterEvent(newcontainer, "ENTERING_STATION")
	RegisterEvent(newcontainer, "STATION_UPDATE_REQUESTED")
	RegisterEvent(newcontainer, "STATION_UPDATE_PRICE")
	RegisterEvent(newcontainer, "PLAYER_UPDATE_STATS")
	RegisterEvent(newcontainer, "TRANSACTION_COMPLETED")

	return newcontainer, buybutton
end


function CreateStationShipStatusTab()
	local reset = true
	local isvisible = false
	local container, view, maximizebutton, shipcontentslist, iteminfotext
	local shiphealthtext
	local purchaseammobutton, replenishweaponbutton, replenishallbutton
	local curselid, replenishallprice

	viewcontrol = iup.modelview{value="", expand="VERTICAL", size="%45x"}
	maximizebutton = iup.stationbutton{title="Maximize", font=Font.H6,
		tip = "View full-screen",
		size = "x"..Font.H4,
		action=function(self)
			local activeshipid = GetActiveShipID()
			if activeshipid then
				local parent = iup.GetDialog(self)
				HideDialog(parent)
				local meshname, meshfile, colorindex = GetShipMeshInfo(activeshipid)
				Big3DViewDialog:SetOwner(parent)
				Big3DViewDialog:SetShip(meshname, meshfile, colorindex)
				ShowDialog(Big3DViewDialog)
			end
		end,
	}
	shipcontentslist = iup.stationsubsubtree{expand="YES",
		selection_cb=function(self, id, state)
			if state == 1 then
				local addonid = iup.TreeGetUserId(self, id)
				curselid = addonid
				if addonid then
					local curammo, maxammo = GetAddonItemInfo(curselid)
					local ammoinfo = GetStationAmmoInfoByID(curselid)
					if ammoinfo and maxammo and maxammo > 0 and (maxammo-curammo) > 0 then
						local quantity = maxammo - curammo
						local priceweapon = ammoinfo.price*quantity
						purchaseammobutton.title="Purchase Ammo (1) "..comma_value(ammoinfo.price).."c"
						replenishweaponbutton.title="Refill Weapon ("..comma_value(quantity)..") "..comma_value(priceweapon).."c"
						if priceweapon > GetMoney() then
							replenishweaponbutton.active = "NO"
						else
							replenishweaponbutton.active = "YES"
						end
						if ammoinfo.price > GetMoney() then
							purchaseammobutton.active = "NO"
						else
							purchaseammobutton.active = "YES"
						end
					else
						purchaseammobutton.active = "NO"
						purchaseammobutton.title="Purchase Ammo (1)"
						replenishweaponbutton.active = "NO"
						replenishweaponbutton.title="Refill Weapon"
					end
					iteminfotext.value = string.gsub(GetInventoryItemExtendedDesc(addonid) or "", "|", "\n")
					iteminfotext.scroll = "TOP"
				else
					curselid = nil
					iteminfotext.value = ""
					purchaseammobutton.active = "NO"
					purchaseammobutton.title="Purchase Ammo (1)"
					replenishweaponbutton.active = "NO"
					replenishweaponbutton.title="Refill Weapon"
				end
			end
		end,
	}
	iteminfotext = iup.stationsubsubmultiline{readonly="YES", expand="YES",value=""}
	shiphealthtext = iup.label{title="", expand="HORIZONTAL", alignment="ACENTER",}

	purchaseammobutton = iup.stationbutton{title="Purchase Ammo (1) 00c", expand="HORIZONTAL",
		active="NO",
		action=function(self)
			local ammoinfo = GetStationAmmoInfoByID(curselid)
			local curammo, maxammo = GetAddonItemInfo(curselid)
			if curammo then
				local quantity = maxammo - curammo
				ReplenishWeapon(curselid, 1,
					function(errid)
						if not errid then
							purchaseprint("1x of "..ammoinfo.name.." purchased for a total price of "..comma_value(ammoinfo.price).."c.")
						end
					end
					)
			end
		end,
	}
	replenishweaponbutton = iup.stationbutton{title="Refill Weapon (1) 000c", expand="HORIZONTAL",
		active="NO",
		action=function(self)
			local ammoinfo = GetStationAmmoInfoByID(curselid)
			local curammo, maxammo = GetAddonItemInfo(curselid)
			if curammo then
				local quantity = maxammo - curammo
				ReplenishWeapon(curselid, quantity,
					function(errid)
						if not errid then
							purchaseprint(comma_value(quantity).."x of "..ammoinfo.name.." purchased for a total price of "..comma_value((ammoinfo.price*quantity)).."c.")
						end
					end
					)
			end
		end,
	}
	replenishallbutton = iup.stationbutton{title="Refill Active Ship 000c", expand="HORIZONTAL",
		action=function(self)
			ReplenishAll(GetActiveShipID(),
				function(errid)
					if not errid then
						purchaseprint("All ammo in active ship purchased for a total price of "..comma_value((replenishallprice or "???")).."c.")
					end
				end
				)
		end,
	}

	container = iup.hbox{
		iup.vbox{
			iup.stationsubsubframe{
				iup.vbox{maximizebutton, viewcontrol, alignment="ALEFT"},
			},
			iup.stationsubsubframebg{
				iup.hbox{
					iup.fill{},
					iup.vbox{purchaseammobutton, replenishweaponbutton, replenishallbutton, expand="NO"},
					iup.fill{},
				}
--				iup.hbox{iup.fill{},purchaseammobutton, iup.fill{}, replenishweaponbutton, iup.fill{}, replenishallbutton, iup.fill{}},
			},
		},
		iup.stationsubsubframehdivider{size=5},
		iup.vbox{
			iup.stationsubsubframebg{
				shiphealthtext,
			},
			shipcontentslist,
			iup.stationsubsubframevdivider{size=5},
			iteminfotext,
			expand="YES",
		},
	}

	local function reload_info()
		reset = false
		local activeshipid = GetActiveShipID()
		local oldsel = shipcontentslist.value
		clear_tree(shipcontentslist)
		if activeshipid then
			-- display ship health
			local d1,d2,d3,d4,d5,d6,d7, maxhp, shieldstrength = GetActiveShipHealth()
			local totalpercent = math.floor(100*(1-(d7/maxhp))+0.5)
			shiphealthtext.title = string.format("Current Ship Health: %d%%", totalpercent)

			local meshname, meshfile, shipcolor = GetShipMeshInfo(activeshipid)
			SetViewObject(viewcontrol, meshname, meshfile, shipcolor)
			iteminfotext.value = string.gsub(GetInventoryItemExtendedDesc(activeshipid), "|", "\n")
			iteminfotext.scroll = "TOP"
			shipcontentslist:setname(0, GetInventoryItemName(activeshipid))
			local itemicon = GetInventoryItemIcon(activeshipid)
			shipcontentslist:setimage(0, itemicon)
			shipcontentslist:setimageexpanded(0, itemicon)
			iup.TreeSetUserId(shipcontentslist, 0, activeshipid)
			-- add addons
			shipcontentslist.addbranch0 = "Equipment"
			shipcontentslist.depth1 = 1
			local shipinv = GetShipInventory(activeshipid, true)
			local curid = 1
			for _,addonid in ipairs(shipinv.addons) do
				local addonicon, addonname = GetInventoryItemInfo(addonid)
				local curammo, maxammo, ammoname = GetAddonItemInfo(addonid)
				local _addonname = addonname
				if maxammo and maxammo > 0 then
					_addonname = string.format("%s (%d/%d)", addonname, curammo, maxammo)
				end
				shipcontentslist['addleaf'..curid] = _addonname
				curid = curid + 1
				shipcontentslist['depth'..curid] = 2
				shipcontentslist['image'..curid] = addonicon
				shipcontentslist['imageexpanded'..curid] = addonicon
				iup.TreeSetUserId(shipcontentslist, curid, addonid)
			end
			-- add cargo
			shipcontentslist:addbranch(curid, string.format("Cargo %d/%d cu", GetActiveShipCargoCount() or "0", GetActiveShipMaxCargo() or "0"))
			curid = curid + 1
			shipcontentslist['depth'..curid] = 1
			for _,addonid in ipairs(shipinv.cargo) do
				local addonicon, addonname = GetInventoryItemInfo(addonid)
				local q = GetInventoryItemQuantity(addonid)
				addonname = q > 1 and (q.."x "..addonname) or (addonname)
				shipcontentslist['addleaf'..curid] = addonname
				curid = curid + 1
				shipcontentslist['depth'..curid] = 2
				shipcontentslist['image'..curid] = addonicon
				shipcontentslist['imageexpanded'..curid] = addonicon
				iup.TreeSetUserId(shipcontentslist, curid, addonid)
			end
			local ammoprices = GetShipAmmoPrices(GetActiveShipID())
			local priceallactiveweapons = ammoprices.allammoprice
			if not priceallactiveweapons or priceallactiveweapons > GetMoney() then
				replenishallbutton.active = "NO"
				priceallactiveweapons = priceallactiveweapons or 0
			else
				replenishallbutton.active = "YES"
			end
			replenishallprice = priceallactiveweapons
			replenishallbutton.title = "Refill Active Ship "..comma_value(priceallactiveweapons).."c"
		else
			SetViewObject(viewcontrol, nil)
			iteminfotext.value = ""
			shipcontentslist:setname(0, "No active ship")
			purchaseammobutton.active = "NO"
			purchaseammobutton.title="   Purchase Ammo (1)   "
			replenishweaponbutton.active = "NO"
			replenishweaponbutton.title="   Refill Weapon   "
			replenishallbutton.active = "NO"
			replenishallbutton.title="   Refill Active Ship   "
		end
		shipcontentslist.value = oldsel
	end

	function container:OnShow()
		if reset then
			reload_info()
		end
		isvisible = true
	end

	function container:OnHide()
		isvisible = false
	end

	local wait_for_transaction_completed = false
	function container:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" then
			if isvisible then
				reload_info()
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
					reload_info(self)
				else
					reset = true
				end
			end
		elseif eventname == "PLAYER_UPDATE_STATS" then
			if isvisible then
				reload_info(self)
			else
				reset = true
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
	RegisterEvent(container, "PLAYER_UPDATE_STATS")

	return container
end

local function checkstorageandpurchaseship(buy_fn)
	local curmaxstationcargo, purchasablemaxcargo, purchaseincrement, purchaseprice = GetStationMaxCargo()
	local curstationstorage = GetStationCurrentCargo()

	local curtotalstorageavailable = curmaxstationcargo - curstationstorage

	local quanvolume = GetInventoryItemVolume(GetActiveShipID()) or 0

	if (quanvolume > 0) and (quanvolume > curtotalstorageavailable) then
		if quanvolume <= ((purchasablemaxcargo)-(curstationstorage)) then
			-- not enough station storage available but enough space to rent
			-- find out how many increments are needed.
			local needed = quanvolume - curtotalstorageavailable
			local chunksneeded = math.ceil(needed/purchaseincrement)
			
			local cost = chunksneeded*purchaseincrement*purchaseprice * GetStationFactionAppraisalModifier()
			local weeklycost = cost
			
			QuestionDialog:SetMessage("Warning: Purchasing "..comma_value(needed).." cu will cost up to and increase your rent by "..comma_value(weeklycost).." c.\nAre you sure you want to purchase this ship?",
				"Yes", function() RentStorage(needed) buy_fn() HideDialog(QuestionDialog) end,
				"No", function() HideDialog(QuestionDialog) end)
			ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
		else
			ShowDialog(NotEnoughStorageDialog, iup.CENTER, iup.CENTER)
		end
	else
		buy_fn()
	end
end

local function checkstorageandselectship(newselectionshipid)
	local curmaxstationcargo, purchasablemaxcargo, purchaseincrement, purchaseprice = GetStationMaxCargo()
	local curstationstorage = GetStationCurrentCargo()

	local curtotalstorageavailable = curmaxstationcargo - curstationstorage

	local quanvolume = GetInventoryItemVolume(GetActiveShipID()) or 0
	if quanvolume == 0 then
		SelectActiveShip(newselectionshipid)
		return
	end
	
	quanvolume = quanvolume - (GetInventoryItemVolume(newselectionshipid) or 0)

	if quanvolume > curtotalstorageavailable then
		if quanvolume <= ((purchasablemaxcargo)-(curstationstorage)) then
			-- not enough station storage available but enough space to rent
			-- find out how many increments are needed.
			local needed = quanvolume - curtotalstorageavailable
			local chunksneeded = math.ceil(needed/purchaseincrement)
			
			local cost = chunksneeded*purchaseincrement*purchaseprice * GetStationFactionAppraisalModifier()
			local weeklycost = cost

			QuestionDialog:SetMessage("Warning: Purchasing "..comma_value(needed).." cu will cost up to and increase your rent by "..comma_value(weeklycost).." c.\nAre you sure you want to change ships?",
				"Yes", function() RentStorage(needed) SelectActiveShip(newselectionshipid) HideDialog(QuestionDialog) end,
				"No", function() HideDialog(QuestionDialog) end)
			ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
		else
			ShowDialog(NotEnoughStorageDialog, iup.CENTER, iup.CENTER)
		end
	else
		SelectActiveShip(newselectionshipid)
	end
end

function CreateStationShipPurchaseTab()
	local reset = true
	local isvisible = false
	local container
	local view, colorpicker, shiplist, shipdesc
	local purchasebutton, maximizebutton
	local t_shiplist, select_ship

	local xres = gkinterface.GetXResolution()
	local colorpickersize = (198*xres/800)..'x'..(66*xres/800)

	view = iup.modelview{value="", expand="YES"}
	maximizebutton = iup.stationbutton{title="Maximize", font=Font.H6,
		tip = "View full-screen",
		size = "x"..Font.H4,
		action=function(self)
			local parent = iup.GetDialog(self)
			local iteminfo = t_shiplist[tonumber(shiplist.value)]
			if iteminfo then
				HideDialog(parent)
				Big3DViewDialog:SetOwner(parent)
				Big3DViewDialog:SetShip(iteminfo.meshname, iteminfo.meshfile, GetShipPurchaseColor())
				ShowDialog(Big3DViewDialog)
			end
		end,
	}
	colorpicker = iup.zbox{
		iup.label{title="", image="images/ship_palette.tga", uv="0 0 1 1", size=colorpickersize, filter="POINT"},
		iup.canvas{
			button_cb=function(self, button, state, x, y, modifiers)
				if button == iup.LMBUTTON and state == 1 then
					x = x - tonumber(self.x)
					y = y - tonumber(self.y)
					x = 32*x/tonumber(self.w)
					y = 8*y/tonumber(self.h)
					local paletteindex = (math.floor(y)*32 + math.floor(x))
					SetShipPurchaseColor(paletteindex)
					view.fgcolor = ShipPalette_string[paletteindex + 1]
				end
			end
		},
		expand="NO",
		ALL="YES",
	}
	shiplist = iup.stationsubsublist{expand="YES",
		action=function(self, text, index, state)
			if state == 1 then
				select_ship(t_shiplist[index])
			end
		end,
	}
	shipdesc = iup.stationsubsubmultiline{expand="YES",readonly="YES",
	}
	purchasebutton = iup.stationbutton{title="Purchase Selected",
		hotkey = iup.K_p,
		action=function(self)
			local iteminfo = t_shiplist[tonumber(shiplist.value)]
			local purchaseid = iteminfo.itemid
			if purchaseid then
				checkstorageandpurchaseship(function()
					PurchaseMerchandiseItem(purchaseid, 1,
						function()
							purchaseprint("1x of "..iteminfo.name.." purchased for a total price of "..comma_value(iteminfo.price).."c.")
						end
						)
					end)
			end
		end,
	}
	for i=1,4 do
		local index = i
		preset_buttons[index] = iup.stationbutton{title="Purchase Preset "..index, size="125x",
			action=function(self)
				if ShipPresets[index] then
					checkstorageandpurchaseship(function()
						local dlg = iup.GetDialog(self)
						HideDialog(dlg)
						CancelLoadoutPurchaseDialog:SetMessage("Purchasing...", "Cancel",
								function()
									purchaseprint("Preset purchase cancelled but some items may have been purchased.")
									CancelPurchaseShipLoadout()
									HideDialog(CancelLoadoutPurchaseDialog)
									ShowDialog(dlg)
								end)
						ShowDialog(CancelLoadoutPurchaseDialog, iup.CENTER, iup.CENTER)
						PurchaseShipLoadout(function(success)
							purchaseprint(success and "Preset purchased." or "Preset purchase failed. Not all items were purchased.")
							purchaseprint("Total cost of purchase is "..comma_value(GetLastShipLoadoutPurchaseCost()).." credits")
							HideDialog(CancelLoadoutPurchaseDialog)
							ShowDialog(dlg)
							end, ShipPresets[index])
						end)
				else
						purchaseprint("Preset "..index.." is empty.")
				end
			end}
	end
	local function activatepresetbuttons()
		for index=1,4 do
			if ShipPresets[index] then
				preset_buttons[index].active = "YES"
			else
				preset_buttons[index].active = "NO"
			end
		end
	end

	select_ship = function(iteminfo)
		SetViewObject(view, iteminfo.meshname, iteminfo.meshfile, GetShipPurchaseColor())
		-- extendeddesc also includes the LongDesc field in objtable
		local longdesc = iteminfo.desc..'\n'..iteminfo.extendeddesc 
		if iteminfo.usable == false then
			local prefix
			if iteminfo.cannotbuyreason then
				prefix = reasontable[iteminfo.cannotbuyreason] or ""
			else
				prefix = ""
			end
			longdesc = prefix.."Required licenses:\n"
					..table.concat(iteminfo.neededlevels, "/")
					.."\n\n"..longdesc
			shipdesc.fgcolor="255 0 0"
			purchasebutton.active = "NO"
		else
			if iteminfo.neededlevels then
				longdesc = "Required licenses:\n"
						..table.concat(iteminfo.neededlevels, "/")
						.."\n\n"..longdesc
			end
			if GetMoney() < iteminfo.price then
				longdesc = "You cannot afford this ship.\n\n"..longdesc
				shipdesc.fgcolor="255 0 0"
				purchasebutton.active = "NO"
			else
				shipdesc.fgcolor="255 255 255"
				purchasebutton.active = "YES"
			end
		end
		shipdesc.value = longdesc
		shipdesc.scroll = "TOP"
	end

	local function setup_ship_purchase_tab()
		reset = false
		local numStationItems = GetNumStationMerch()
		local k=1
		t_shiplist = {}
		for i=1,numStationItems do
			local iteminfo = GetStationMerchInfo(i)
			if iteminfo.type == "ship" then  -- only ships are shown here
				t_shiplist[k] = iteminfo
				k=k+1
			end
		end
		-- sort
		table.sort(t_shiplist, sort_shipnames)

		-- add ships to listbox
		k=1
		for index,iteminfo in ipairs(t_shiplist) do
			local name_color = ''
			if iteminfo.usable ~= false then
				if iteminfo.price > GetMoney() then
					name_color = "\1277f7f7f"
				end
			else
				name_color = "\127ff0000"
			end
			local name = name_color..iteminfo.name.."   [ "..comma_value(iteminfo.price).." c ]"
			shiplist[index] = name
			k=k+1
		end
		shiplist[k] = nil

		local curselindex = tonumber(shiplist.value)
		-- note: try selecting first item if non are selected.
		if curselindex <= 0 and (#t_shiplist) > 0 then
			-- well, try to select first purchasable ship
			local curmoney = GetMoney()
			curselindex = 1
			for k,v in ipairs(t_shiplist) do
				if v.usable and curmoney >= v.price then
					curselindex = k
					shiplist.value = k
					break
				end
			end
		end
		if curselindex > 0 then
			select_ship(t_shiplist[curselindex])
		else
			SetViewObject(view, nil)
			shipdesc.value = ""
			purchasebutton.active = "NO"
		end
	end


	container = iup.hbox{
		iup.vbox{
			iup.stationsubsubframe{
				iup.vbox{maximizebutton,view, alignment="ALEFT"},
			},
			iup.stationsubsubframevdivider{size=4},
			iup.stationsubsubframebg{
				iup.hbox{
					iup.vbox{
						iup.hbox{iup.fill{},iup.label{title="Choose a color:"}},
						iup.fill{},
						iup.hbox{purchasebutton,iup.fill{}},
					},
					colorpicker,
				},
			},
			alignment="ACENTER",
		},
		iup.stationsubsubframehdivider{size=5},
		iup.vbox{
			expand="YES",
			iup.stationsubsubframebg{
				iup.hbox{iup.fill{},iup.label{title="Ship Name [Buy Price]"},iup.fill{}},
			},
			shiplist,
			iup.stationsubsubframebg{
				iup.hbox{iup.fill{},iup.label{title="Ship Description"},iup.fill{}},
			},
			shipdesc,
			iup.stationsubsubframevdivider{size=5},
			iup.stationsubsubframebg{
				iup.vbox{
					iup.hbox{preset_buttons[1], preset_buttons[2], gap=2},
					iup.hbox{preset_buttons[3], preset_buttons[4], gap=2},
					gap=2,
				},
			},
		},
		alignment="ABOTTOM",
	}
container=iup.frame{
	bgcolor="0 0 0 0 *",
	segmented="0 0 1 1",
	container
	}

	function container:OnShow()
		isvisible = true
		if reset then
			setup_ship_purchase_tab()
		end

		activatepresetbuttons()
	end

	function container:OnHide()
		isvisible = false
	end

	local wait_for_transaction_completed = false
	function container:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" or eventname == "PLAYER_UPDATE_STATS" then
			if isvisible then
				setup_ship_purchase_tab()
			else
				reset = true
			end
		elseif eventname == "STATION_UPDATE_REQUESTED" then
			wait_for_transaction_completed = true
		elseif eventname == "TRANSACTION_COMPLETED" then
			if wait_for_transaction_completed then
				wait_for_transaction_completed = false
				if isvisible then
					setup_ship_purchase_tab()
				else
					reset = true
				end
			end
		end
	end

	RegisterEvent(container, "ENTERING_STATION")
	RegisterEvent(container, "PLAYER_UPDATE_STATS")
	RegisterEvent(container, "TRANSACTION_COMPLETED")
	RegisterEvent(container, "STATION_UPDATE_REQUESTED")

	return container, purchasebutton
end

function CreateStationShipSelectionTab()
	local reset = true
	local isvisible = false
	local container
	local view, shiplist, selectshipbutton, maximizebutton, iteminfotext
	local purchaseammobutton, replenishweaponbutton, replenishallbutton
	local replenishallprice = 0
	local set_preset_buttons = {}
	local shipinventory

	local function treeid2shipid(id)
		local itemid = iup.TreeGetUserId(shiplist, id)
		if itemid then
			local selshipid
			local itemclasstype = GetInventoryItemClassType(itemid)
			if itemclasstype == CLASSTYPE_SHIP then
				selshipid = itemid
			else
				selshipid = GetInventoryItemContainerID(itemid)
			end
			return selshipid, itemid
		end
	end

	local function selectshipbytreeid(id)
		local selshipid = treeid2shipid(id)
		if selshipid and (GetInventoryItemLocation(selshipid) == GetStationLocation()) then
			checkstorageandselectship(selshipid)
		end
	end

	purchaseammobutton = iup.stationbutton{title="   Purchase Ammo (1)   ", expand="HORIZONTAL",
		active="NO",
		action=function(self)
			local shipid, curselid = treeid2shipid(shiplist.value)
			local ammoinfo = GetStationAmmoInfoByID(curselid)
			local curammo, maxammo = GetAddonItemInfo(curselid)
			if curammo and ammoinfo then
				ReplenishWeapon(curselid, 1,
					function(errid)
						if not errid then
							if shipid == curselid then
								purchaseprint(ammoinfo.name.." repaired for a total price of "..comma_value(ammoinfo.price).."c.")
							else
								purchaseprint("1x of "..ammoinfo.name.." purchased for a total price of "..comma_value(ammoinfo.price).."c.")
							end
						end
					end
					)
			end
		end,
	}
	replenishweaponbutton = iup.stationbutton{title="   Refill Weapon   ", expand="HORIZONTAL",
		active="NO",
		action=function(self)
			local shipid, curselid = treeid2shipid(shiplist.value)
			local ammoinfo = GetStationAmmoInfoByID(curselid)
			local curammo, maxammo = GetAddonItemInfo(curselid)
			if curammo then
				local quantity = maxammo - curammo
				ReplenishWeapon(curselid, quantity,
					function(errid)
						if not errid then
							purchaseprint(quantity.."x of "..ammoinfo.name.." purchased for a total price of "..comma_value((ammoinfo.price*quantity)).."c.")
						end
					end
					)
			end
		end,
	}
	replenishallbutton = iup.stationbutton{title="   Refill Selected Ship   ", expand="HORIZONTAL", hotkey=iup.K_e,
		action=function(self)
			local shipid = treeid2shipid(shiplist.value)
			ReplenishAll(shipid,
				function(errid)
					if not errid then
						purchaseprint("All ammo in selected ship purchased for a total price of "..(replenishallprice or "???").."c.")
					end
				end
				)
		end,
	}

	iteminfotext = iup.stationsubsubmultiline{readonly="YES", expand="YES",value=""}
	view = iup.modelview{value="", expand="VERTICAL", size="%45x"}
	maximizebutton = iup.stationbutton{title="Maximize", font=Font.H6,
		tip = "View full-screen",
		size = "x"..Font.H4,
		action=function(self)
			local selshipid = treeid2shipid(shiplist.value)
			if selshipid then
				local parent = iup.GetDialog(self)
				HideDialog(parent)
				local meshname, meshfile, colorindex = GetShipMeshInfo(selshipid)
				Big3DViewDialog:SetOwner(parent)
				Big3DViewDialog:SetShip(meshname, meshfile, colorindex)
				ShowDialog(Big3DViewDialog)
			end
		end,
	}
	shiplist = iup.stationsubsubtree{expand="YES",
		selection_cb=function(self, id, state)
			if state == 1 then
				local selshipid, itemid = treeid2shipid(id)
				if selshipid then
					local locationofitem = GetInventoryItemLocation(selshipid)
					local islocal = (locationofitem==0) or (locationofitem == GetStationLocation())
					selectshipbutton.active = islocal and "YES" or "NO"
					local meshname, meshfile, shipcolor = GetShipMeshInfo(selshipid)
					SetViewObject(view, meshname, meshfile, shipcolor)
					iteminfotext.value = string.gsub(GetInventoryItemExtendedDesc(selshipid) or "", "|", "\n")
					iteminfotext.scroll = "TOP"

					-- enable/disable ammo buttons appropriately
					if islocal then
						local ammoprices = GetShipAmmoPrices(selshipid)
						local priceallactiveweapons = ammoprices.allammoprice
						if (ammoprices.allammoquantity <= 0) or (not priceallactiveweapons) or (priceallactiveweapons > GetMoney()) then
							replenishallbutton.active = "NO"
							priceallactiveweapons = priceallactiveweapons or 0
						else
							replenishallbutton.active = "YES"
						end
						replenishallprice = priceallactiveweapons
						replenishallbutton.title = "Refill Selected Ship "..comma_value(priceallactiveweapons).."c"
					else
						replenishallbutton.active = "NO"
						replenishallbutton.title = "   Refill Selected Ship   "
					end
					local curammo, maxammo = GetAddonItemInfo(itemid)
					local ammoinfo = GetStationAmmoInfoByID(itemid)
					if islocal and ammoinfo and maxammo and maxammo > 0 and (maxammo-curammo) > 0 then
						-- if it's the ship itself then change button words to repairing ship or something.
						if selshipid == itemid then
							local quantity = maxammo - curammo
							purchaseammobutton.title="Repair Ship "..comma_value(ammoinfo.price).."c"
							if ammoinfo.price > GetMoney() then
								purchaseammobutton.active = "NO"
							else
								purchaseammobutton.active = "YES"
							end
							replenishweaponbutton.active = "NO"
							replenishweaponbutton.title="   Refill Weapon   "
						else
							local quantity = maxammo - curammo
							local priceweapon = ammoinfo.price*quantity
							purchaseammobutton.title="Purchase Ammo (1) "..comma_value(ammoinfo.price).."c"
							replenishweaponbutton.title="Refill Weapon ("..comma_value(quantity)..") "..comma_value(priceweapon).."c"
							if priceweapon > GetMoney() then
								replenishweaponbutton.active = "NO"
							else
								replenishweaponbutton.active = "YES"
							end
							if ammoinfo.price > GetMoney() then
								purchaseammobutton.active = "NO"
							else
								purchaseammobutton.active = "YES"
							end
						end
					else
						purchaseammobutton.active = "NO"
						purchaseammobutton.title="   Purchase Ammo (1)   "
						replenishweaponbutton.active = "NO"
						replenishweaponbutton.title="   Refill Weapon   "
					end
				else
					SetViewObject(view, nil)
					iteminfotext.value = ""
				end
			end
		end,
		renamenode_cb=function(self, id, name)
			selectshipbytreeid(id)
		end,
	}
	selectshipbutton = iup.stationbutton{title="Select Ship",
		action=function(self)
			selectshipbytreeid(shiplist.value)
		end,
	}
	for i=1,4 do
		local index = i
		set_preset_buttons[index] = iup.stationbutton{title="Set Preset "..index,
			action=function(self)
				local selshipid = treeid2shipid(shiplist.value)
				if selshipid then
					ShipPresets[index] = SaveShipLoadout(selshipid)
					SaveShipPresets(index)
					purchaseprint("Preset saved.")
				end
			end}
	end

	local function additemtotree(curid, shipid, index)
		local itemicon, shipname,quan,mass,desc,longdesc,extdesc,container,classtype = GetInventoryItemInfo(shipid)
		local isactiveship = (shipid == GetActiveShipID())
		if isactiveship then
			shipname = "*Active ship* "..shipname
		else
			-- mark non-local ships as red
			if GetInventoryItemLocation(shipid) ~= GetStationLocation() then
				shipname = "\127ff0000(not local)"..shipname
			end
		end
		if curid < 0 then
			shiplist:setname(0, shipname)
			curid = 0
		else
			shiplist:addbranch(curid, shipname)
			curid = curid + 1
		end
		shiplist:setdepth(curid, 0)
		shiplist:setimage(curid, itemicon)
		shiplist:setimageexpanded(curid, itemicon)
		iup.TreeSetUserId(shiplist, curid, shipid)
		local shipweapontable = GetShipInventory(shipid, true)
		for _,addonid in ipairs(shipweapontable.addons) do
			local addonicon, addonname = GetInventoryItemInfo(addonid)
			local curammo, maxammo, ammoname = GetAddonItemInfo(addonid)
			local _addonname = addonname
			if maxammo and maxammo > 0 then
				_addonname = string.format("(%d/%d) %s", curammo, maxammo, addonname)
			end
			shiplist:addleaf(curid, _addonname)
			curid = curid + 1
			shiplist:setdepth(curid, 1)
			shiplist:setimage(curid, addonicon)
			shiplist:setimageexpanded(curid, addonicon)
			iup.TreeSetUserId(shiplist, curid, addonid)
		end
		return curid
	end

	local function setup_ship_selection_tab()
		reset = false
		shipinventory = GetShipList()
		local activeshipid = GetActiveShipID()

		table.sort(shipinventory, function(a,b)
				if a == activeshipid then
					return true
				elseif b == activeshipid then
					return false
				else
					local aloc = GetInventoryItemLocation(a)
					local bloc = GetInventoryItemLocation(b)
					if aloc ~= bloc then
						return storagelocationcompare(aloc,bloc)
					else
						return (GetInventoryItemName(a) or "") < (GetInventoryItemName(b) or "")
					end
				end
			end)

		-- clear tree
		local cursel = shiplist.value
		local curid = treeid2shipid(cursel)
		clear_tree(shiplist)
		shiplist:setname(0, "(no ships at this location)")
		shiplist:setimage(0, "images/treebranchcollapsed.png")
		shiplist:setimageexpanded(0, "images/treebranchexpanded.png")

		local curindex = -1
		for index,shipid in pairs(shipinventory) do
			curindex = additemtotree(curindex, shipid, index)
		end

		local newid = treeid2shipid(cursel)
		if newid and curid == newid then
			shiplist.value = cursel
		end

		cursel = shiplist.value
		local selshipid = treeid2shipid(cursel)
		if selshipid then
			shiplist.value = cursel
--			selectshipbutton.active = "YES"
--			local meshname, meshfile, shipcolor = GetShipMeshInfo(selshipid)
--			SetViewObject(view, meshname, meshfile, shipcolor)
--			iteminfotext.value = string.gsub(GetInventoryItemExtendedDesc(selshipid) or "", "|", "\n")
--			iteminfotext.scroll = "TOP"
		else
			selectshipbutton.active = "NO"
			SetViewObject(view, nil)
			iteminfotext.value = ""
		end
	end

	container = iup.hbox{
		iup.vbox{
			iup.stationsubsubframe{
				iup.vbox{maximizebutton, view, alignment="ALEFT"},
			},
			iup.stationsubsubframevdivider{size=5},
			iup.stationsubsubframebg{
				iup.hbox{
					iup.fill{},
					iup.vbox{purchaseammobutton, replenishweaponbutton, replenishallbutton, expand="NO", gap=2},
					iup.fill{},
				}
--				iup.hbox{iup.fill{},purchaseammobutton, iup.fill{}, replenishweaponbutton, iup.fill{}, replenishallbutton, iup.fill{}},
			},
		},
		iup.stationsubsubframehdivider{size=5},
		iup.vbox{
			expand="YES",
			shiplist,
			iup.stationsubsubframevdivider{size=5},
			iteminfotext,
			iup.stationsubsubframevdivider{size=5},
			iup.stationsubsubframebg{
				iup.vbox{
					iup.hbox{selectshipbutton,iup.fill{}},
					iup.hbox{set_preset_buttons[1], set_preset_buttons[2], gap=2},
					iup.hbox{set_preset_buttons[3], set_preset_buttons[4], gap=2},
					gap=2,
--					margin="2x2",
				},
			},
		},
	}

	function container:OnShow()
		isvisible = true
		if reset then
			setup_ship_selection_tab()
		end
	end

	function container:OnHide()
		isvisible = false
	end

	local wait_for_transaction_completed = false
	function container:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" then
			if isvisible then
				setup_ship_selection_tab()
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
					setup_ship_selection_tab(self)
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


local function process_mission_title(xml)
	local str

	for _,value in ipairs(xml) do
		local ty = type(value)
		if ty == "string" then
			str = (str and str..value) or value
		elseif (ty == "table") and (value[0] == 'countdown') and (value.time) then
			local _, s = TagFuncs.countdown(value)
			s = tostring(s)
			str = (str and str..s) or s
		end
	end

	return str
end

local mission_category_icons = {
	[1]="images/icon_mission_general.png",
	[2]="images/icon_mission_training.png",
	[3]="images/icon_mission_combat.png",
	[4]="images/icon_mission_trade.png",
	[5]="images/icon_mission_mining.png",
	[6]="images/icon_mission_manufacturing.png",
	[7]="images/icon_mission_recon.png",
	[8]="images/icon_mission_research.png",
	[9]="images/icon_mission_clandestine.png"
}

local function set_mission_info(index, iteminfo, dlg)
	dlg.colors = normalcolors
	if dlg.sel then
		dlg.bgcolor = normalcolors.selcolor
	else
		dlg.bgcolor = normalcolors[math.fmod(index, 2)]
	end

	local name = iteminfo.name
--[[
	if name:find("<countdown", 1, true) then
		local xml = ParseXML(name)
		if xml then
			name = process_mission_title(xml)
			dlg.refreshnametimer = dlg.refreshnametimer or Timer()
			dlg.refreshnametimer:SetTimeout(1000, function() dlg:SetName(process_mission_title(xml)) dlg.refreshnametimer:SetTimeout(1000) end)
		end
	end
--]]

	local desc = "  "..iteminfo.desc
	if desc:find("<countdown", 1, true) then
		local xml = ParseXML(desc)
		if xml then
			desc = process_mission_title(xml)
			dlg.refreshdesctimer = dlg.refreshdesctimer or Timer()
			dlg.refreshdesctimer:SetTimeout(1000, function() dlg:SetDesc(process_mission_title(xml), false) dlg.refreshdesctimer:SetTimeout(1000) end)
		end
	end

	dlg:SetName(name)
	dlg:SetDesc(desc, false)
	dlg:SetIcon(mission_category_icons[iteminfo.category] or iteminfo.icon)
--	dlg:SetIcon((not iteminfo.notamission) and "images/icon_mission01.gtx" or nil)
end


local function create_mission_list_thingy(buyname, buyaction)
	local cursel
	local items
	local subdlglist
	local listcontrol = iup.itemlisttemplate({}, true)
	local buybutton
	local group1, group2
	local mission_stat_color = rgbtohex(tabseltextcolor) or ""
	local mission_stat_label = rgbtohex(tabunseltextcolor) or ""

	buybutton = iup.stationbutton{title=buyname, action=buyaction, active="NO"}
	group1 = iup.label{title = '',expand='HORIZONTAL'} -- Missions Available: 1234
	group2 = iup.label{title = '', expand='HORIZONTAL'} -- [group member]
	
	local container = iup.vbox{
		iup.hbox{
			listcontrol,
		},
		iup.stationsubsubframevdivider{size=5},
		iup.stationsubsubframebg{
			iup.hbox{
				buybutton,
				group1, iup.fill{},group2,iup.fill{},
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

	local function set_infodesc(dlginfo)
		if not dlginfo then
			buybutton.active="NO"
			return
		end
		dlginfo.sel = true
		dlginfo.bgcolor = dlginfo.colors.selcolor
		buybutton.active="YES"
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
			set_infodesc(dlginfo)
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

	function container:fill(_items, index, numavailablemissions)
		items = _items
		index = index and math.min(index, (#_items))
		subdlglist = fill_listbox(listcontrol, _items, index, set_mission_info, false, false)
		set_infodesc(subdlglist[index])
		listcontrol.value = index
		cursel = index

		-- active mission status
		local active_mission_test = GetNumActiveMissions()
		if active_mission_test > 0 then
			local active_num = mission_stat_color..active_mission_test
			group1.title = mission_stat_label..'Active Missions: '..active_num
		else
			group1.title = mission_stat_label..'Missions Available: '..mission_stat_color..tostring(numavailablemissions)
		end
		
 		-- group check
 		local group_test = GetNumGroupMembers() -- returns 0 if not in a group
 		if group_test > 0 then
 			local group_txt = mission_stat_color..'Group Member'..mission_stat_label
 			group2.title = mission_stat_label..'['..group_txt..']'
 		else
 			group2.title = ''
 		end
	end

	return container, buybutton
end

function CreateStationMissionBuyTab()
	local reset = true
	local isvisible = false
	local availablemissionlist, subdlglist, container, buybutton
	local function purchaseaction(self)
	---- pull mission by table index value
	RequestMissionDetails(availablemissionlist[container:getcursel()].index)
	end

	container, buybutton = create_mission_list_thingy("Info", purchaseaction)

	local function reload_list(self)
		reset = false
		local curselindex = self:clear()

		availablemissionlist = {}
		local numavailablemissions = 0
		if PlayerInStation() then
			numavailablemissions = GetNumAvailableMissions()
			
			if numavailablemissions == 0 then
				-- no mission list yet
				table.insert(availablemissionlist, {name="Receiving mission list...", desc="", notamission=true})
			else
				-- mission list
				for i=1,numavailablemissions do
					local missioninfo = GetAvailableMissionInfo(i)
					-- index value inserted
					missioninfo.index = i
					if missioninfo.itemtype == 0 then
						-- special case mission with itemtype=0 meaning there are no missions.
						local groupownerid = GetGroupOwnerID()
						if (groupownerid ~= 0) and (groupownerid ~= GetCharacterID()) then
							table.insert(availablemissionlist, {name="Only group leaders can start group missions.", desc="", notamission=true})
						elseif groupownerid == GetCharacterID() then
							table.insert(availablemissionlist, {name="This station has no missions at this time because you are in a group.\nLeave the group before trying to take missions.", desc="", notamission=true})
						else
							table.insert(availablemissionlist, {name="This station has no missions at this time.", desc="", notamission=true})
						end
						-- if there's a mission with itemtype=0 then that means there are no missions.
						numavailablemissions = 0
					else
						table.insert(availablemissionlist, missioninfo)
					end
				end
			end
		else
			table.insert(availablemissionlist, {name="Missions are only available in-station.", desc="", notamission=true})
		end

		-- sorts the mission list 
		table.sort(availablemissionlist, function(a,b)
			-- sort with training missions first on the list
			if a.name:match('Training') and b.name:match('Training') then return a.name < b.name
			elseif a.name:match('Training') then return true
			elseif b.name:match('Training') then return false

			-- then sort by name then by description
			elseif a.name == b.name then return a.desc < b.desc
			else return a.name < b.name
			end
		end
		)

		subdlglist = self:fill(availablemissionlist, curselindex, numavailablemissions)
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

	local waitfortransactioncompleted = false

	function container:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" or
			eventname == "STATION_UPDATED" or
			eventname == "MISSIONLIST_UPDATED" then
			if isvisible then
				reload_list(self)
			else
				reset = true
			end
		elseif eventname == "MISSION_ADDED" then
			waitfortransactioncompleted = true
			if isvisible then
				StationPDAMissionsTab:SetTab(StationPDAMissionLogTab)
			end
		elseif eventname == "MISSION_REMOVED" then
			waitfortransactioncompleted = true
		elseif eventname == "TRANSACTION_COMPLETED"
			and waitfortransactioncompleted == true then
			waitfortransactioncompleted = false
			if isvisible then
				reload_list(self)
			else
				reset = true
			end
		end
	end

	RegisterEvent(container, "ENTERING_STATION")
	RegisterEvent(container, "STATION_UPDATED")
	RegisterEvent(container, "MISSIONLIST_UPDATED")
	RegisterEvent(container, "MISSION_ADDED")
	RegisterEvent(container, "MISSION_REMOVED")
	RegisterEvent(container, "TRANSACTION_COMPLETED")

	return container, buybutton
end

function CreateStationCommoditiesLoadTab()
	local reset = true
	local isvisible = false
	local loadbutton, unloadbutton, unloadallbutton
	local unloadsellbutton, unloadsellallbutton, stationrentalbutton
	local shipcargolable
	local shipcargolist, stationcargolist
	local loadquantity, unloadquantity, unloadsellquantity
	local loadquantityedit, loadquantitymass, loadquantitycu
	local unloadquantityedit, unloadsellquantityedit
	local shipcargolabel, stationcargolabel
	local t_ship
	local check_ship_cargo_selection_state
	local check_station_cargo_selection_state

	shipcargolabel = iup.label{title="", expand="HORIZONTAL", alignment="ACENTER"}
	stationcargolabel = iup.label{title="", expand="HORIZONTAL", alignment="ACENTER"}
	loadquantityedit = iup.text{expand="HORIZONTAL"}
	loadquantitymass = iup.label{title = "mass", expand="HORIZONTAL"}
	loadquantitycu = iup.label{title = "cu", expand="HORIZONTAL"}
	unloadquantityedit = iup.text{expand="HORIZONTAL"}
	unloadsellquantityedit = iup.text{expand="HORIZONTAL"}
	shipcargolist = iup.stationsubtree{expand="YES", size="1x1",
		selection_cb=function(self, id, state)
			if state == 1 then
				check_ship_cargo_selection_state()
			end
		end,
	}
	stationcargolist = iup.stationsubtree{expand="YES", size="1x1",
		selection_cb=function(self, id, state)
			if state == 1 then
				check_station_cargo_selection_state()
			end
		end,
	}
	loadbutton = iup.stationbutton{title="<- Load", expand="HORIZONTAL", hotkey=iup.K_l,
		action = function(self)
			local sel = tonumber(stationcargolist.value)+1

			local cargolist = {}
			local t_station = GetStationCargoList()
			-- load button was clicked, the itemid is in the index table
			local itemid = stationcargolist.index[sel]  -- itemid 
				--t_station[sel]
			if itemid then
				local quantity = tonumber(loadquantityedit.value)
				if quantity and quantity > 0 then
					table.insert(cargolist, {itemid=itemid, quantity=quantity})
					LoadCargo(cargolist)
				end
			end
		end,}
	unloadbutton = iup.stationbutton{title="Unload ->", expand="HORIZONTAL",
		action = function(self)
			local sel = tonumber(shipcargolist.value)+1
			local cargolist = {}
			local item = t_ship[sel]
			if item then
				local quantity = tonumber(unloadquantityedit.value)
				if quantity and quantity > 0 then
					table.insert(cargolist, {itemid=item.itemid, quantity=quantity})
					CheckStorageAndUnloadCargo(cargolist)
				end
			end
		end,}
	unloadallbutton = iup.stationbutton{title="Unload All", expand="HORIZONTAL",
		action = function(self)
			local cargolist = {}
			for k,v in ipairs(t_ship) do
				local icon, name, quantity = GetInventoryItemInfo(v.itemid)
				if icon then
					table.insert(cargolist, {itemid=v.itemid, quantity=quantity})
				end
			end
			CheckStorageAndUnloadCargo(cargolist)
		end,}
	unloadsellbutton = iup.stationbutton{title="Unload & Sell", expand="HORIZONTAL", hotkey=iup.K_u,
		action = function(self)
			local sel = tonumber(shipcargolist.value)+1
			local cargolist = {}
			local item = t_ship[sel]
			local itemicon, itemname, itemquantity = GetInventoryItemInfo(item and item.itemid)
			if itemicon then
				local totalprice = 0
				local totalcost = 0
				local quantity = tonumber(unloadsellquantityedit.value)
				if quantity and quantity > 0 then
					table.insert(cargolist, {itemid=item.itemid, quantity=quantity})
					totalprice = totalprice + GetStationSellableInventoryPriceByID(item.itemid, quantity)
					totalcost = totalcost + item.unitcost*quantity
					local previous_money = GetMoney()
					local cb_msg = function()
						totalprice = GetMoney() - previous_money
						PrintPurchaseTransaction(itemname, quantity, totalprice, totalcost)
					end
					UnloadSellCargo(cargolist, cb_msg)
				end
			end
		end,}
	unloadsellallbutton = iup.stationbutton{title="Unload and Sell All", expand="HORIZONTAL", hotkey=iup.K_a,
		action = function(self)
			local cargolist = {}
			local totalprice = 0
			local totalcost = 0
			local quantity = 0
			for k,v in ipairs(t_ship) do
				local itemicon, itemname, itemquantity = GetInventoryItemInfo(v.itemid)
				if itemquantity then
					table.insert(cargolist, {itemid=v.itemid, quantity=itemquantity})
					totalprice = totalprice + GetStationSellableInventoryPriceByID(v.itemid, itemquantity)
					totalcost = totalcost + v.unitcost*itemquantity
					quantity = quantity + itemquantity
				end
			end
			local previous_money = GetMoney()
			local cb_msg = function()
				totalprice = GetMoney() - previous_money
				PrintPurchaseTransaction("Cargo", quantity, totalprice, totalcost)
			end



			if not ShowSellAllDialog then
				UnloadSellCargo(cargolist, cb_msg)
			else
				-- dialog box here, yes/no
				QuestionWithCheckDialog:SetMessage('Are you sure you want to Unload and Sell All?',
					"Yes", function()
						ShowSellAllDialog = not QuestionWithCheckDialog:GetCheckState()
						gkini.WriteInt("Vendetta", "showsellallconfirmation", ShowSellAllDialog and 1 or 0)
						UnloadSellCargo(cargolist, cb_msg)
						HideDialog(QuestionWithCheckDialog)
					end,
					"No", function()
						ShowSellAllDialog = not QuestionWithCheckDialog:GetCheckState()
						gkini.WriteInt("Vendetta", "showsellallconfirmation", ShowSellAllDialog and 1 or 0)
						HideDialog(QuestionWithCheckDialog)
					end,
					not ShowSellAllDialog
					)
				ShowDialog(QuestionWithCheckDialog,iup.CENTER,iup.CENTER)
			end

		end,}

	stationrentalbutton = iup.stationbutton{title="Storage Rental", expand="HORIZONTAL", hotkey=iup.K_r,
		action = function(self)
			ShowDialog(StorageRentalDialog, iup.CENTER, iup.CENTER)
		end,}

	check_ship_cargo_selection_state = function()
		local sel = tonumber(shipcargolist.value)+1
		local quan
		local counter = 0
		local cursel = t_ship[sel]
		if cursel then
			quan = GetInventoryItemQuantity(cursel.itemid)
			counter = counter + 1
		end
		if counter > 0 then
			unloadsellbutton.active = "YES"
			unloadbutton.active = "YES"
		else
			unloadsellbutton.active = "NO"
			unloadbutton.active = "NO"
		end
		unloadquantityedit.value = quan or ""
		unloadsellquantityedit.value = quan or ""
	end

	check_station_cargo_selection_state = function()
		-- when you click an item to load
		local sel = tonumber(stationcargolist.value)+1
		local quan
		local counter = 0
		local mass
		local cu
		
--		local curselid = GetStationCargoList()[sel]
		local curselid = stationcargolist.index[sel]  -- itemid 
		if curselid then
			quan = GetInventoryItemQuantity(curselid)
			mass = comma_value(math.floor(1000*(GetInventoryItemMass(curselid) or 0)+0.5)..' kg')
			cu = GetInventoryItemVolume(curselid)..' cu'
			counter = counter + 1
		end
		if counter > 0 then
			loadbutton.active = "YES"
		else
			loadbutton.active = "NO"
		end
		loadquantityedit.value = quan or ""
		loadquantitycu.title = cu or ""
		loadquantitymass.title = mass or ""
	end

	local function setup_ship_cargo_tab()
		reset = false
		local activeshipid = GetActiveShipID()
		local _t_ship = {}
		local t_station
		t_ship = _t_ship
		-- should show non-sellable items in list now.
		-- so, we grab a list of items in the ship by itemid, and then remove them if they are sellable in the StationSellableInventoryPairs for-loop.
		-- then we add all the left over ones with some virtual iteminfo thing.
		local shipinv = GetShipInventory(activeshipid)
		local unsellableshipcargoitems = {}
		for index,itemid in ipairs(shipinv.cargo) do
			unsellableshipcargoitems[itemid] = true
		end
		
		for i,iteminfo in StationSellableInventoryPairs() do
			if GetInventoryItemContainerID(iteminfo.itemid) == activeshipid then
				local portid = GetActiveShipPortIDOfItem(iteminfo.itemid)
				if portid == nil then
					table.insert(_t_ship, iteminfo)
					unsellableshipcargoitems[iteminfo.itemid] = nil  -- remove from the unsellable list
				end
			end
		end
		-- now we have the unsellable list. go thru it and add the items to _t_ship
		for itemid,_ in pairs(unsellableshipcargoitems) do
			table.insert(_t_ship, {itemid=itemid,price=0,unitcost=GetInventoryItemUnitCost(itemid)})
		end
		table.sort(_t_ship, sort_loadunloadlists)
		local i
		i=1
		shipcargolist:clear()
		while _t_ship[i] do
			local iteminfo = _t_ship[i]
			local itemicon, name, quantity = GetInventoryItemInfo(iteminfo.itemid)
			if itemicon then
				if tonumber(iteminfo.unitcost) then
				-- and iteminfo.unitcost > 0 then
					local hexprice = GetProfitHexColor(iteminfo.price, iteminfo.unitcost)
					name = comma_value(quantity).."x "..name.."  \127"..hexprice..comma_value(iteminfo.price).." c \127ffffff("..comma_value(iteminfo.unitcost)..")"
				else
					name = comma_value(quantity).."x "..name.."  "..comma_value(iteminfo.price).." c"
				end
			else
				name = "?x ????????  "..comma_value(iteminfo.price).." c each"
			end
			if i == 1 then
				shipcargolist:setname(0, name)
				shipcargolist:setimage(0, itemicon)
				shipcargolist:setimageexpanded(0, itemicon)
			else
				shipcargolist:addbranch(i-2, name)
				shipcargolist:setdepth(i-1, 0)
				if itemicon then
					shipcargolist:setimageexpanded(i-1, itemicon)
				end
			end
			i = i + 1
		end
		if i == 1 then
			shipcargolist:setname(0, "(empty)")
			shipcargolist:setimage(0, "")
			shipcargolist:setimageexpanded(0, "")
			unloadallbutton.active = "NO"
			unloadsellallbutton.active = "NO"
		else
			unloadallbutton.active = "YES"
			unloadsellallbutton.active = "YES"
		end
		check_ship_cargo_selection_state()
		shipcargolabel.title = string.format("Ship Cargo (%s/%s) [%s]",
			comma_value(GetActiveShipCargoCount() or 0),
			comma_value(GetActiveShipMaxCargo() or 0),
			comma_value(math.floor(1000*(GetActiveShipMass() or 0)+0.5).. " kg"))
		i=1
		t_station = GetStationCargoList()
		stationcargolist:clear()
		--sort the cargolist  for loading/unloading
		table.sort(t_station,function(a,b) return (GetInventoryItemName(a) or "") < (GetInventoryItemName(b) or "") end)
		stationcargolist.index = {} -- table to hold sort index values
		while t_station[i] do
			local itemicon, name, quantity = GetInventoryItemInfo(t_station[i])
			local itemid = t_station[i]
			if itemicon then
				name = string.format("%sx %s", comma_value(quantity), name)
			else
				name = "?x ????????"
			end
			stationcargolist.index[i] = itemid
			if i == 1 then
				stationcargolist:setname(0, name)
				stationcargolist:setimage(0, itemicon)
				stationcargolist:setimageexpanded(0, itemicon)
			else
				stationcargolist:addbranch(i-2, name)
				stationcargolist:setdepth(i-1, 0)
				if itemicon then
					stationcargolist:setimage(i-1, itemicon)
					stationcargolist:setimageexpanded(i-1, itemicon)
				end
			end
			i = i + 1
		end
		if i == 1 then
			stationcargolist:setname(0, "(empty)")
			stationcargolist:setimage(0, "")
			stationcargolist:setimageexpanded(0, "")
		end
		stationcargolist[i] = nil
		local curmaxstationcargo, purchasablemaxcargo, purchaseincrement, purchaseprice = GetStationMaxCargo()
		local curstationstorage = GetStationCurrentCargo()
		stationcargolabel.title = string.format("Station Cargo (%s/%s)",
			comma_value(curstationstorage or 0),
			comma_value(curmaxstationcargo or 0) )
		check_station_cargo_selection_state()
		
		if purchaseincrement <= 0 then
			stationrentalbutton.active = "NO"
		else
			stationrentalbutton.active = "YES"
		end
	end

	local container
	container = iup.vbox{
		iup.pdasubframebg{
			iup.hbox{
				iup.stationbutton{title="Help", hotkey=iup.K_F1, tip="Help for this interface",
					action=function()
						if container.OnHelp then container.OnHelp() end
					end},
				iup.fill{},
			},
		},
		iup.hbox{
			iup.vbox{
				iup.stationsubframebg{
					shipcargolabel,
				},
				shipcargolist,
				iup.stationsubframebg{
					iup.vbox{
						unloadallbutton,
						unloadsellallbutton,
						gap=5,
						margin="2x2",
					},
				},
				alignment="ACENTER",
			},
			iup.stationsubframebg{
				iup.vbox{
					iup.fill{},
					loadbutton,
					loadquantityedit,
					iup.hbox{iup.label{title = 'Mass: '}, loadquantitymass,},
					iup.hbox{iup.label{title = 'Volume: '}, loadquantitycu,},
					iup.fill{},
					unloadbutton,
					unloadquantityedit,
					iup.fill{},
					unloadsellbutton,
					unloadsellquantityedit,
					iup.fill{},
					expand="VERTICAL",
					margin="2x2",
				},
			},
			iup.vbox{
				iup.stationsubframebg{
					iup.hbox{iup.fill{},stationcargolabel,iup.fill{}},
				},
				stationcargolist,
				alignment="ACENTER",
				iup.stationsubframebg{
					iup.vbox{
						stationrentalbutton,
						gap=5,
						margin="2x2",
					},
				},
			},
		},
	}

	function container:OnShow()
		isvisible = true
		if reset then
			setup_ship_cargo_tab()
		end
	end

	function container:OnHide()
		isvisible = false
	end

	local wait_for_transaction_completed = false
	function container:OnEvent(eventname, ...)
		if eventname == "ENTERING_STATION" then
			reset = true
		elseif eventname == "INVENTORY_ADD" or eventname == "INVENTORY_REMOVE" or eventname == "INVENTORY_UPDATE" or eventname == "STATION_UPDATE_REQUESTED" then
			wait_for_transaction_completed = true
		elseif eventname == "TRANSACTION_COMPLETED" then
			if wait_for_transaction_completed then
				wait_for_transaction_completed = false
				if isvisible then
					setup_ship_cargo_tab()
				else
					reset = true
				end
			end
		elseif eventname == "STATION_UPDATE_PRICE" or eventname == "PLAYER_UPDATE_STATS" then
			if isvisible then
				setup_ship_cargo_tab()
			else
				reset = true
			end
		end
	end

	RegisterEvent(container, "ENTERING_STATION")
	RegisterEvent(container, "INVENTORY_ADD")
	RegisterEvent(container, "INVENTORY_REMOVE")
	RegisterEvent(container, "INVENTORY_UPDATE")
	RegisterEvent(container, "TRANSACTION_COMPLETED")
	RegisterEvent(container, "STATION_UPDATE_PRICE")
	RegisterEvent(container, "STATION_UPDATE_REQUESTED")
	RegisterEvent(container, "PLAYER_UPDATE_STATS")

	return container
end
