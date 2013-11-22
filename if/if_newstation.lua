local faction_desc = {
[1] = [[	The Itani are an advanced people, having the longest history of space travel among the three races.  Their civilization, living in isolation and peace for a thousand years, has made great developments in science, the arts, and spiritual, mental, and martial powers.  However, a darkness lingers in their past.  The Serco, once fellow colonists on Terra II, suffered countless atrocities commanded by the purist Itani leaders.  The climactic battle of this war drove the Itani people near to extinction, and they fled the planet in search of a new life.  Though the culture as a whole has moved beyond their bloody past, the Serco seem committed to reviving old hatreds, and the Itani have had no choice but to fight back.]],
[2] = [[	The Serco Dominion is a proud nation, valuing personal strength and honor in combat above all else.  They were once a peaceful people, scientists and thinkers whose advanced research methods proved crucial for the Exiles' survival.  However, philosophical and cultural differences with the other Terra II colonists quickly began to alienate the Serco people, eventually leading to all-out war.  Their enemies, the Itani, were driven off the planet, and Serco military leaders instated a provisional government to protect its people against any future attacks.  This government, and the culture of war it fostered, have persisted for over a thousand years, leaving the Serco with the largest military in known space.]],
[3] = [[	The UIT is formed of a loose conglomeration of corporations, civilians and other subfactions, most of whom owe allegiance (at least in name) to the UIT Senate. In reality, the UIT is nearly a constant power struggle between various corporations, who vie for technology, resources and Serco/Itani contracts. During the early advent of the interstellar Serco/Itani conflict, most of the corporations began their own weapons and ship development programs, hoping to capitalize on the war by selling their products to the embattled major nations. However, a second purpose became apparent when a "rogue pirate clan", who may have actually been mercenaries or employees of Axia Technology Corp, assaulted a Valent Robotics station, devestating the development site for a new product that competed with a similar Axia creation. Both were competing for the same Serco contract, but this was the first time competition had been raised to such levels. Valent responded in kind, launching a full assault on Axia and sparking the first of the corporate wars. These conflicts were finally brought to an end when TPG, the five hundred pound gorilla of UIT military research, forcibly engaged all the other corporations simultaneously with a massive armada and dictated a cease-fire. Since then there has been a wary and untrusting "peace" among the UIT corporations, where they all play nicely in view of the Senate or TPG, but are known to continue their in-corporate conflicts in secret.]],
[4] = [[	TPG is the largest corporate member of the Union of Independent Territories. Also the most powerful and well-known organization in the UIT, surpassing even the government Senate. TPG Corp originally allowed the people of the UIT to escape from Serco Prime, through the creation of the original UIT spacecraft. Today they are the largest manufacturer of spacecraft in the known universe, maintaining diplomatic and technological relations with both the Serco and Itani. Founded in the distant past by a group of free-thinking dreamers and hopeful engineers, TPG has managed to keep their innocence more than most of the other UIT corporations. They are by far the most morally upstanding of the UIT members, often railing against the corporate warfare, feuding and espionage which has become so commonplace in the Union.]],
[5] = [[	BioCom is a relative startup in the UIT corporate family. Founded not long after the historic Serco request of diplomatic relations with the UIT in AD4346, BioCom was created by a group of scientists who acquired access to Serco recent bio-engineering and implantation technology. More recently, they have diversified into other areas, combining their bio-engineering and implantation expertise with the AI and robotics knowledge of Valent Robotics. Little is known of the fruits of this rare cooperative effort between two UIT corporations, but all developments are shrouded in heavy secrecy and security.]],
[6] = [[	The second-eldest of the UIT corporations, after TPG, was founded not long after the UIT left their planetary homes on Serco Prime to find a better life among the stars. Valent became an early pioneer in mining robotics and other mechanisms that were extrordinarily important during those first years of spaceborne colonization. More recently they've come to diversify heavily into a number of fields, including weapons research, but their primary bread-and-butter comes from semi-automated mining drone design. Rumors have persisted for several decades of an impressive cooperative project with BioCom. However, the two companies have been remarkably successful at keeping a lid on their activities.]],
[7] = [[	Orion started out making drill bits for Xithricite excavation (long before the advent of laser drilling), and has since expanded into a multifaceted powerhouse with divisions developing everything from large-scale space station projects to advanced weapons design. Like most of the other UIT member corporations, Orion diversified into weapons and spacecraft following the start of the second Serco-Itani conflict. They now construct a number of popular spacecraft and weapon designs, as well as larger scale freighter and transport projects for several nations and factions.]],
[8] = [[	Axia Technology Corp]],
[9] = [[	Corvus, while not a corporation in any legal sense, certainly has a tangible economic impact on activities within the UIT, and the universe as a whole. This black market cluster of stations has become a major haven for pirate activity, mercenaries and corporations who simply wish to avoid Senate oversight. All manner of underground activities take place here under the baleful eye of the mysterious Syndicate, the little-known enforcing overlords of Corvus Prime. No lawful entities attempt to bring this region under their sway, partially because of the Syndicate's not-insignificant influence and firepower, and partially because of the logic that.. if Corvus were destroyed, they would simply reorganize in another, unknown location. "Better to know where the hornets nest" stated one law enforcement representative. This rationale is made that much easier by the Syndicate's strictly defensive posture within Corvus space. No attempts are made to expand or to influence other regions, and in fact the Syndicate is almost never heard from, even within their own territory. It is believed they have high-level economic dealings with several of the major corporations, but nothing is known of their membership, size, organization or leadership. Law enforcement agencies ceased to attempt to penetrate the organization long ago, when operative after undercover operative failed to return or report.]],
[10] = [[	Tunguska Heavy Mining Concern]],
[11] = [[	Aeolus Trading Prefectorate]],
[12] = [[	Ineubis Defense Research]],
[13] = [[	Xang Xi is a longtime developer of component systems for computing and robotics. Occasionally a competitor of Valent Robotics, they mostly focus their efforts on government and defense contracts. They are well established in the areas of targeting computers, missile and torpedo autonomous performance and behaviour. Civilian contracts also make up a large part of their portfolio, with everything from autonomous waste treatment to station enhancement and construction. In recent years they have become one of the primary manufacturers of critical components for mineral refinement.
	The organization and background of Xang Xi are somewhat more bizarre and less known than their public portfolio. They maintain the facade of normal corporate management, but their CEO is apparently appointed by an unusual eight-member group within the company known as the Octagon. It is believed that this group actually makes all significant decisions for the company. Xang Xi is also the corporation that is most often linked to the Corvus Syndicate, but only rumor and conjecture exist to connect the two.]],
}

local Commodityhelpfultext = "This panel lists the commodities available at the station where your ship is docked. Commodities include mined minerals and ores, as well as more complex trade goods."
local CommoditySellhelpfultext = "This panel lists your commodities stored at this station and in your ship's cargo hold. Commodities include mined minerals and ores, as well as more complex trade goods."
local SmallAddonhelpfultext = "This panel lists the small addons available at the station where your ship is docked. Small addons can only be used in the small weapon ports of ships."
local LargeAddonhelpfultext = "This panel lists the large addons available at the station where your ship is docked. Large addons can only be used in the large weapon ports of ships."
local OtherAddonhelpfultext = "This panel lists other addons available at the station where your ship is docked. Power cells are currently the only items listed."
local ShipSellhelpfultext = "This panel lists all the ships you own at the station where your ship is docked. Selling a non-empty ship will automatically sell all the addons and cargo in that ship."
local SmallAddonSellhelpfultext = "This panel lists the small addons you own that are not already connected to any ships at the station where your ship is docked. Small addons can only be used in the small weapon ports of ships."
local LargeAddonSellhelpfultext = "This panel lists the large addons you own that are not already connected to any ships at the station where your ship is docked. Large addons can only be used in the large weapon ports of ships."
local OtherAddonSellhelpfultext = "This panel lists the other addons you own that are not already connected to any ships at the station where your ship is docked."

dofile(IF_DIR.."if_portconfig_template.lua")

function GetShipAmmoPrices(shipid)
	local priceallactiveweapons
	local q = 0
	local retval = {}
	for i,ammoinfo in StationPlayerAmmoPairs() do
		local curammo, maxammo = GetAddonItemInfo(ammoinfo and ammoinfo.itemid)
		if curammo then
			local quantity = maxammo - curammo
			local weaponcontainer = GetInventoryItemContainerID(ammoinfo.itemid)
			if shipid == weaponcontainer then
				if quantity > 0 then
					q = q + quantity
					retval[ammoinfo.itemid] = ammoinfo.price*quantity
					priceallactiveweapons = (priceallactiveweapons or 0) + ammoinfo.price*quantity
				end
			end
		end
	end

	retval.allammoprice = priceallactiveweapons
	retval.allammoquantity = q

	return retval
end


function CreateStationBlankTab()
	local container = iup.vbox{
		iup.fill{}
	}

	function container:OnShow()
	end

	function container:OnHide()
	end

	function container:OnEvent(eventname, ...)
	end

	return container
end


local bg = {
	[0] = ListColors[0].." "..ListColors.Alpha,
	[1] = ListColors[1].." "..ListColors.Alpha,
	[2] = ListColors[2].." "..ListColors.SelectedAlpha,
}
local bg_numbers = ListColors.Numbers

local sortfuncs = {
	[1] = function(a,b)
			local qa = GetInventoryItemQuantity(a)
			local qb = GetInventoryItemQuantity(b)
			if qa ~= qb then
				return qa > qb
			else
				return (GetInventoryItemName(a) or "") < (GetInventoryItemName(b) or "")
			end
		end,
	[2] = function(a,b)
			local iteminfoa = GetStationSellableInventoryInfoByID(a)
			local iteminfob = GetStationSellableInventoryInfoByID(b)
			if iteminfoa and iteminfob and iteminfoa.price ~= iteminfob.price then
				return iteminfoa.price > iteminfob.price
			else
				return (GetInventoryItemName(a) or "") < (GetInventoryItemName(b) or "")
			end
		end,
	[3] = function(a,b)
			local iteminfoa = GetStationSellableInventoryInfoByID(a)
			local iteminfob = GetStationSellableInventoryInfoByID(b)
			local profita = iteminfoa and iteminfoa.price-iteminfoa.unitcost
			local profitb = iteminfob and iteminfob.price-iteminfob.unitcost
			if profita and profitb and profita ~= profitb then
				return profita > profitb
			else
				return (GetInventoryItemName(a) or "") < (GetInventoryItemName(b) or "")
			end
		end,
	[4] = function(a,b)
			return (GetInventoryItemName(a) or "") < (GetInventoryItemName(b) or "")
		end,
}

function CheckStorageAndUnloadCargo(cargolist, callback_fn)
	if not cargolist then return end
	-- make sure item(s) can fit
	local curmaxstationcargo, purchasablemaxcargo, purchaseincrement, purchaseprice = GetStationMaxCargo()
	local curstationstorage = GetStationCurrentCargo()

	--  count cu being moved
	local cu = 0
	for k,v in ipairs(cargolist) do
		cu = cu + (v.quantity * GetInventoryItemVolume(v.itemid))
	end

	if cu == 0 then return end

	local curtotalstorageavailable = (curmaxstationcargo-curstationstorage)
	if cu > curtotalstorageavailable then
		if cu <= (purchasablemaxcargo - curstationstorage) then
			-- not enough station storage available but enough space to rent
			-- find out how many increments are needed.
			local needed = cu - curtotalstorageavailable
			local chunksneeded = math.ceil(needed/purchaseincrement)
			
			local cost = chunksneeded*purchaseincrement*purchaseprice * GetStationFactionAppraisalModifier()
			local weeklycost = cost
			
			-- if the player says no, move as much as we can 
			QuestionDialog:SetMessage("Warning: Moving "..comma_value(needed).." cu will cost up and increase your rent by "..comma_value(weeklycost).." c.\nAre you sure you want to do this?",
				"Yes", function() RentStorage(needed) UnloadCargo(cargolist, callback_fn) HideDialog(QuestionDialog) end,
				"No", function() UnloadCargo(cargolist, callback_fn) HideDialog(QuestionDialog) end)
			ShowDialog(QuestionDialog, iup.CENTER, iup.CENTER)
		else
			if curtotalstorageavailable > 0 then
				-- we do this to move as much as we can for the convenience of the player
				UnloadCargo(cargolist, callback_fn)
			else
				ShowDialog(NotEnoughStorageDialog, iup.CENTER, iup.CENTER)
			end
		end
	else
		-- enough space available. do things normally.
		UnloadCargo(cargolist, callback_fn)
	end
end

function CreateStationWelcomeTab()
	local isvisible = false
	local reset = true
	local sortmode = 1
	local curselindex = nil
	local cargolist
	local refillallammoprice = 0
	local shiprepaircost = 0
	local update_matrix, set_sort_mode
	local stationnamelabel = iup.label{title="", expand="HORIZONTAL", wordwrap="NO", fgcolor=tabseltextcolor}
	local stats = iup.pdasubsubsubmultiline{readonly="YES", expand="YES",value="You have docked with the station. This area is under construction."}
	local desireditems = iup.pdasubsubsubmultiline{readonly="YES", expand="YES",value="Desired items"}
	local repairshipbutton = iup.stationbutton{title="Repair Ship", active="NO", font=Font.H4, hotkey=iup.K_r,
		action=function(self)
			self.active = "NO"
			local price = shiprepaircost
			RepairShip(GetActiveShipID(), 1,
				function(errid)
					if not errid then
						purchaseprint("Ship repaired for a total price of "..(comma_value(price) or "???").."c.")
					end
				end
				)
		end}
	local refillallammobutton = iup.stationbutton{title="Refill All Ammo", active="NO", font=Font.H4, hotkey=iup.K_e,
		action=function(self)
			self.active = "NO"
			local price = refillallammoprice
			ReplenishAll(GetActiveShipID(),
				function(errid)
					if not errid then
						purchaseprint("All ammo in active ship purchased for a total price of "..(comma_value(price) or "???").."c.")
					end
				end
				)
		end}
	local iteminfotab = iup.stationsubsubmultiline{expand="YES", readonly="YES",
		tabtitle = "Item Details",
		value="",
		OnShow=function(self) end,
		OnHide=function(self) end,
	}
	local stationcargotab = iup.stationsubsubtree{expand="YES", readonly="YES",
		addexpanded="NO",
		tabtitle = "Station Inventory",
		OnShow=function(self) end,
		OnHide=function(self) end,
	}
	local curseltab = iteminfotab
	local unloadsellitembutton = iup.stationbutton{title="Sell", active="NO", expand="HORIZONTAL", font=Font.H4,
		action=function(self)
			local itemid = cargolist[curselindex]
			if not itemid then return end
			local quantity = GetInventoryItemQuantity(itemid)
			local itemname = GetInventoryItemName(itemid) or "Some Item"
			local iteminfo = GetStationSellableInventoryInfoByID(itemid)
			local totalprice = iteminfo and GetStationSellableInventoryPriceByID(itemid,quantity) or 0
			local totalcost = iteminfo and iteminfo.unitcost*quantity or 0
			local previous_money = GetMoney()
			local cb_msg = function(errorid)
				if not errorid then
					totalprice = GetMoney() - previous_money
					PrintPurchaseTransaction(itemname, quantity, totalprice, totalcost)
				end
			end
			UnloadSellCargo({{itemid=itemid, quantity=quantity}}, cb_msg)
		end}
	local unloadsellallbutton = iup.stationbutton{title="Sell All", active="NO", expand="HORIZONTAL", font=Font.H4, hotkey=iup.K_a,
		action=function(self)
			local selllist = {}
			local totalprice = 0
			local totalcost = 0
			local quantity = 0
			for k,itemid in ipairs(cargolist) do
				local itemicon, itemname, itemquantity = GetInventoryItemInfo(itemid)
				if itemquantity then
					local iteminfo = GetStationSellableInventoryInfoByID(itemid)
					table.insert(selllist, {itemid=itemid, quantity=itemquantity})
					totalprice = totalprice + (GetStationSellableInventoryPriceByID(itemid,itemquantity) or 0)
					totalcost = totalcost + (iteminfo and iteminfo.unitcost or 0)*itemquantity
					quantity = quantity + itemquantity
				end
			end
			local previous_money = GetMoney()
			local cb_msg = function(errorid)
				if not errorid then
					totalprice = GetMoney() - previous_money
					PrintPurchaseTransaction("Cargo", quantity, totalprice, totalcost)
				end
			end




			if not ShowSellAllDialog then
				UnloadSellCargo(selllist, cb_msg)
			else
				-- dialog box here, yes/no
				QuestionWithCheckDialog:SetMessage('Are you sure you want to Sell All?',
					"Yes", function()
						ShowSellAllDialog = not QuestionWithCheckDialog:GetCheckState()
						gkini.WriteInt("Vendetta", "showsellallconfirmation", ShowSellAllDialog and 1 or 0)
						UnloadSellCargo(selllist, cb_msg)
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


		end}
	local unloaditembutton = iup.stationbutton{title="Unload", active="NO", expand="HORIZONTAL", font=Font.H4,
		action=function(self)
			local itemid = cargolist[curselindex]
			if not itemid then return end
			local quantity = GetInventoryItemQuantity(itemid)
			CheckStorageAndUnloadCargo({{itemid=itemid, quantity=quantity}})
		end}
	local unloadallbutton = iup.stationbutton{title="Unload All", active="NO", expand="HORIZONTAL", font=Font.H4, hotkey=iup.K_U,
		action=function(self)
			local unloadlist = {}
			for k,itemid in ipairs(cargolist) do
				local itemicon, itemname, itemquantity = GetInventoryItemInfo(itemid)
				if itemquantity then table.insert(unloadlist, {itemid=itemid, quantity=itemquantity}) end
			end
			CheckStorageAndUnloadCargo(unloadlist)
		end}
	local activeshipnamelabel = iup.label{title="stuff", size="1x", expand="HORIZONTAL", wordwrap="NO"}
	local hullintegritylabel = iup.label{title=" 100%", size="1x", expand="HORIZONTAL", wordwrap="NO", alignment="ARIGHT"}
	local repaircostlabel = iup.label{title="0c", size="1x", expand="HORIZONTAL", wordwrap="NO", alignment="ARIGHT"}
	local ammocostlabel = iup.label{title="stuff", size="1x", expand="HORIZONTAL", wordwrap="NO", alignment="ARIGHT"}
	local matrix = iup.pdasubsubsubmatrix{
		expand="HORIZONTAL",
		numcol = 4,
		NUMLIN_VISIBLE = 5,
		size="100x",
	}
	function matrix:fgcolor_cb(row, col)
		local c = curselindex == row and bg_numbers[2] or bg_numbers[math.fmod(row,2)]
		return c[1],c[2],c[3],c[4],iup.DEFAULT
	end
	matrix.bgcolor_cb = matrix.fgcolor_cb
	function matrix:edition_cb(line, col, mode)
		return iup.IGNORE
	end
	function matrix:leaveitem_cb(lin, col)
		matrix:setattribute("BGCOLOR", lin, 1, bg[math.fmod(lin,2)])
		matrix:setattribute("BGCOLOR", lin, 2, bg[math.fmod(lin,2)])
		matrix:setattribute("BGCOLOR", lin, 3, bg[math.fmod(lin,2)])
		matrix:setattribute("BGCOLOR", lin, 4, bg[math.fmod(lin,2)])
		curselindex = nil
		unloadsellitembutton.active = "NO"
		unloaditembutton.active = "NO"
	end
	function matrix:enteritem_cb(lin, col)
		curselindex = lin
		matrix:setattribute("BGCOLOR", lin, 1, bg[2])
		matrix:setattribute("BGCOLOR", lin, 2, bg[2])
		matrix:setattribute("BGCOLOR", lin, 3, bg[2])
		matrix:setattribute("BGCOLOR", lin, 4, bg[2])
		unloadsellitembutton.active = "YES"
		unloaditembutton.active = "YES"
		iteminfotab.value = GetItemFullDesc(GetStationSellableInventoryInfoByID(cargolist[curselindex])) -- "item info goes here."
		iteminfotab.scroll = "TOP"
	end
	function matrix:click_cb(row, col)
		if row == 0 then
			set_sort_mode(col)
			table.sort(cargolist, sortfuncs[sortmode])
			update_matrix()
		end
	end
	matrix.alignment1 = "ARIGHT"
	matrix.alignment2 = "ARIGHT"
	matrix.alignment3 = "ARIGHT"
	matrix.alignment4 = "ALEFT"
	matrix.width1 = "30"
	matrix.width2 = "30"
	matrix.width3 = "30"
	matrix.width4 = "30"
	matrix["0:1"] = "Q"
	matrix["0:2"] = "Sell Price"
	matrix["0:3"] = "Profit"
	matrix["0:4"] = "Active Ship's Cargo"

	update_matrix = function()
		for index,itemid in ipairs(cargolist) do
			local itemquantity = GetInventoryItemQuantity(itemid)
			local unitcost = GetInventoryItemUnitCost(itemid)
			matrix:setcell(index, 1, comma_value(itemquantity).."x")
			local totalworth = GetStationSellableInventoryPriceByID(itemid, itemquantity)
			matrix:setcell(index, 2, comma_value(totalworth).."c")
			local profit = totalworth-(unitcost*itemquantity)
			matrix:setcell(index, 3, comma_value(profit).."c")
			matrix:setcell(index, 4, " "..tostring(GetInventoryItemName(itemid)))
			local profitcolor
			if profit > 0 then
				profitcolor = "0 255 0 255"
			elseif profit < 0 then
				profitcolor = "255 0 0 255"
			else
				profitcolor = "255 255 255 255"
			end
			matrix:setattribute("FGCOLOR", index, 3, profitcolor)
		end
	end
	set_sort_mode = function(mode)
		-- clicked on title of column
		sortmode = mode
		-- color the text accordingly
		matrix:setattribute("FGCOLOR", 0, 1, mode == 1 and tabseltextcolor or tabunseltextcolor)
		matrix:setattribute("FGCOLOR", 0, 2, mode == 2 and tabseltextcolor or tabunseltextcolor)
		matrix:setattribute("FGCOLOR", 0, 3, mode == 3 and tabseltextcolor or tabunseltextcolor)
		matrix:setattribute("FGCOLOR", 0, 4, mode == 4 and tabseltextcolor or tabunseltextcolor)
	end
	set_sort_mode(sortmode)

	local container = iup.vbox{
		iup.pdasubframebg{
			iup.hbox{
				iup.stationbutton{title="Help", hotkey=iup.K_F1, action=HelpStationWelcome, tip="Help for this interface"},
				iup.fill{},
			},
		},
		iup.stationsubsubframe2{
			iup.hbox{
				iup.pdasubsubsubframe2{
					iup.vbox{
						iup.pdasubsubsubframebg{stationnamelabel},
						stats,
						desireditems,
					},
				},
				iup.stationsubsubframehdivider{size=4},
				iup.vbox{
					expand="VERTICAL",
					iup.pdasubsubsubframefull2{
						iup.vbox{
							iup.hbox{
								iup.vbox{
									iup.label{title="Active Ship", expand="HORIZONTAL", fgcolor=tabseltextcolor},
									activeshipnamelabel,
								},
								iup.vbox{
									iup.label{title="Hull Integrity", expand="HORIZONTAL", fgcolor=tabseltextcolor, alignment="ARIGHT"},
									hullintegritylabel,
									alignment="ARIGHT",
								},
								iup.vbox{
									iup.label{title="Repair Cost", expand="HORIZONTAL", fgcolor=tabseltextcolor, alignment="ARIGHT"},
									repaircostlabel,
									alignment="ARIGHT",
								},
								iup.vbox{
									iup.label{title="Ammo Cost", expand="HORIZONTAL", fgcolor=tabseltextcolor, alignment="ARIGHT"},
									ammocostlabel,
									alignment="ARIGHT",
								},
							},
							iup.hbox{
								repairshipbutton,
								iup.fill{},
								refillallammobutton,
							},
						},
					},
					iup.stationsubsubframevdivider{size=4},
					iup.pdasubsubsubframe2{
						iup.vbox{
							matrix,
							iup.pdasubsubsubframebg{
								iup.hbox{
									unloadsellitembutton,
									unloadsellallbutton,
									unloaditembutton,
									unloadallbutton,
								},
							},
						},
					},
					iup.stationsubsubframevdivider{size=4},
					iup.pdasubsubsubframe2{
						iup.subsubsubtabtemplate2{
							iteminfotab,
							{expand="HORIZONTAL", spacer=true},
							stationcargotab,
							tabchange_cb = function(self, newtab, oldtab)
								oldtab = curseltab
								curseltab = newtab
								if isvisible then
									oldtab:OnHide()
									curseltab:OnShow()
								end
							end,
						},
					},
				},
			},
		},
	}

	local function update_text()
		reset = false
		stationnamelabel.title = "Welcome to "..tostring(GetStationName())
		local str = "You have docked with "..tostring(GetStationName())..". Here, you can buy and sell commodities, ships, weapons, and other addons. You can also repair your ship, replenish weapons that use ammunition, and change your weapon configurations.\n"
		stats.value = str..tostring(faction_desc[GetStationFaction()] or "")
		stats.scroll = "TOP"
		local n = GetNumStationDesiredItems()
		local t = {}
		for i=1,n do
			local name = GetStationDesiredItem(i)
			if name then
				table.insert(t, name)
			end
		end
		if n > 0 then
			-- sort desired items list
			table.sort(t)
			table.insert(t,1,"Our reserves of the below items are running low.  We'll pay well for deliveries of any of these items.")
		else
			table.insert(t, "We are not currently running low on any items.")
		end
		desireditems.value = table.concat(t, "\n\t")
		desireditems.scroll = "TOP"
	end

	local function reset_matrix()
		local shipinv = GetShipInventory(GetActiveShipID())
		cargolist = shipinv.cargo
		table.sort(cargolist, sortfuncs[sortmode])

		matrix.dellin = "1--1"  -- one way of deleting all items in the matrix
		local numitems = (#cargolist)
		matrix.numlin = numitems
		if numitems > 0 then
			update_matrix()
			unloadsellallbutton.active = "YES"
			unloadallbutton.active = "YES"
			if curselindex and curselindex > numitems then
				curselindex = numitems
			end
		else
			unloadsellallbutton.active = "NO"
			unloadallbutton.active = "NO"
			curselindex = nil
		end
		iteminfotab.value = ""
		if curselindex and curselindex <= numitems then
			matrix:enteritem_cb(curselindex, 1)
		else
			unloadsellitembutton.active = "NO"
			unloaditembutton.active = "NO"
		end

		-- redo the station cargo list
		local index = 0
		stationcargotab:clear()
		local list = GetStationCargoList()

-- station inventory - welcome screen		
-- sorts the station cargo list by description
table.sort(list,function (a,b) return (GetInventoryItemName(a) or "") < (GetInventoryItemName(b) or "") end)
		
		for _,itemid in ipairs(list) do
			local itemicon, name, quantity = GetInventoryItemInfo(itemid)
			local itemname = quantity>1 and (comma_value(quantity).."x "..name) or name
			if index > 0 then
				stationcargotab:addleaf(index-1, itemname)
				stationcargotab:setdepth(index, 0)
				stationcargotab:setimage(index, itemicon)
			else
				stationcargotab:setname(0, itemname)
				stationcargotab:setimage(0, itemicon)
				stationcargotab:setimageexpanded(0, itemicon)
			end
			index = index + 1
		end
		if index == 0 then
			-- no local items
			stationcargotab:setname(0, "No items")
			stationcargotab:setimage(0, "")
			stationcargotab:setimageexpanded(0, "")
		end
	end

	local function update_ship_info()
		activeshipnamelabel.title = GetActiveShipName() or "No Ship"
		local activeshipid = GetActiveShipID()
		local ammoprices = GetShipAmmoPrices(activeshipid)
		if ammoprices.allammoprice and ammoprices.allammoprice <= GetMoney() then
			refillallammoprice = ammoprices.allammoprice
			refillallammobutton.active = "YES"
			ammocostlabel.title = comma_value(refillallammoprice).."c"
		else
			refillallammoprice = 0
			refillallammobutton.active = "NO"
			ammocostlabel.title = comma_value((ammoprices.allammoprice or 0)).."c"
		end
		-- ship health
		local shiprepairinfo
		local d1,d2,d3,d4,d5,d6,d7, maxhp, shieldstrength = GetActiveShipHealth()
		if d7 then
			hullintegritylabel.title = math.floor(100*(1-(d7/maxhp))+0.5).."%"
			-- ship repair
			if (d7 > 0) then
				shiprepairinfo = GetStationAmmoInfoByID(activeshipid)
			end
		else
			hullintegritylabel.title = '---'
		end
		shiprepaircost = shiprepairinfo and shiprepairinfo.price
		repaircostlabel.title = comma_value((shiprepaircost or 0)).."c"
		if shiprepaircost then
			repairshipbutton.active = "YES"
		else
			repairshipbutton.active = "NO"
		end
	end

	function container:OnShow()
		isvisible = true
		if reset then
			update_text()
		end
		curseltab:OnShow()

		-- these are just to get the column to be a minimum width while not knowing the font size.
		matrix:setcell(1, 2, "Sell Price")
		matrix:setcell(1, 3, "Profit")
		matrix:setcell(1, 4, "Active Ship's Cargo")

		reset_matrix()

		update_ship_info()
	end

	function container:OnHide()
		isvisible = false
		curseltab:OnHide()
	end

	function container:OnEvent(eventname, ...)
		if eventname == "STATION_UPDATE_DESIREDITEMS" or
			eventname == "ENTERING_STATION" then
			if isvisible then
				update_text()
			else
				reset = true
			end
		elseif eventname == "ENTERING_STATION" then
			if isvisible then
				update_text()
			else
				reset = true
			end
		elseif eventname == "INVENTORY_ADD" or
			eventname == "INVENTORY_REMOVE" or
			eventname == "INVENTORY_UPDATE" or
			eventname == "TRANSACTION_FAILED" or
			eventname == "TRANSACTION_COMPLETED" then
			if isvisible then
				reset_matrix()
				update_ship_info()
			else
				reset = true
			end
		elseif eventname == "PLAYER_UPDATE_STATS" then
			if isvisible then
				update_ship_info()
			else
				reset = true
			end
		end
	end

	RegisterEvent(container, "ENTERING_STATION")
	RegisterEvent(container, "PLAYER_UPDATE_STATS")
	RegisterEvent(container, "STATION_UPDATE_DESIREDITEMS")
	RegisterEvent(container, "INVENTORY_UPDATE")
	RegisterEvent(container, "INVENTORY_ADD")
	RegisterEvent(container, "INVENTORY_REMOVE")
	RegisterEvent(container, "TRANSACTION_COMPLETED")
	RegisterEvent(container, "TRANSACTION_FAILED")

	return container
end

function CreateStationCommoditiesTab()
	-- only show commodities in active ship
	StationCommoditiesSellTab = CreateStationCommoditiesSellTab(function(iteminfo)
			local classtype = GetInventoryItemClassType(iteminfo.itemid)
			if classtype == CLASSTYPE_GENERIC or classtype == CLASSTYPE_ADDON then
				local containerid = GetInventoryItemContainerID(iteminfo.itemid)
				local containertype = GetInventoryItemClassType(containerid)
				if containertype == CLASSTYPE_SHIP and containerid ~= GetActiveShipID() then
					return false
				end
				-- don't show addons connected to the ship. I guess we could, but then we'd have to show that they are connected or something.
				if classtype == CLASSTYPE_ADDON and GetActiveShipPortIDOfItem(iteminfo.itemid) then
					return false
				end
				return true
			end
		end, true, CommoditySellhelpfultext)
	StationCommoditiesBuyTab = CreateStationCommoditiesBuyTab(function(iteminfo) return iteminfo.type == "commodities" end, true, Commodityhelpfultext)

	StationCommoditiesSellTab.tabtitle = "Sell"
	StationCommoditiesSellTab.hotkey = iup.K_l
	StationCommoditiesBuyTab.tabtitle = "Buy"
	StationCommoditiesBuyTab.hotkey = iup.K_b

	StationCommoditiesSellTab.OnHelp = HelpSellCommodities
	StationCommoditiesBuyTab.OnHelp = HelpCommoditiesAction

	return iup.subsubtabtemplate{
		StationCommoditiesBuyTab,
		StationCommoditiesSellTab,
	}
end

function CreateStationEquipmentManageTab()
--	StationEquipmentManageShipStatusTab = CreateStationShipStatusTab()
	StationEquipmentManagePortConfigTab = CreateStationPortConfigTab()
	StationEquipmentManageShipSelectionTab = CreateStationShipSelectionTab()

--	StationEquipmentManageShipStatusTab.tabtitle = "Ship Status"
	StationEquipmentManageShipSelectionTab.tabtitle = "Select Ship"
	StationEquipmentManagePortConfigTab.tabtitle = "Configure Ship"
	StationEquipmentManageShipSelectionTab.hotkey = iup.K_i
	StationEquipmentManagePortConfigTab.hotkey = iup.K_f

--	StationEquipmentManageShipStatusTab.OnHelp = HelpShipStatus
	StationEquipmentManageShipSelectionTab.OnHelp = HelpShipSelect

	return iup.subsubtabtemplate{
--		StationEquipmentManageShipStatusTab,
		StationEquipmentManageShipSelectionTab,
		StationEquipmentManagePortConfigTab,
	}
end

function CreateStationEquipmentBuyTab()
	StationEquipmentBuyShipTab, StationEquipmentBuyShipPurchaseButton = CreateStationShipPurchaseTab()
	StationEquipmentBuySmallTab, StationEquipmentBuySmallPurchaseButton = CreateStationCommoditiesBuyTab(function(iteminfo) return iteminfo.type == "lightweapon" end, true, SmallAddonhelpfultext)
	StationEquipmentBuyLargeTab = CreateStationCommoditiesBuyTab(function(iteminfo) return iteminfo.type == "heavyweapon" end, true, LargeAddonhelpfultext)
	StationEquipmentBuyOtherTab, StationEquipmentBuyOtherPurchaseButton = CreateStationCommoditiesBuyTab(function(iteminfo) return iteminfo.type ~= "playerinv" and iteminfo.type ~= "commodities" and iteminfo.type ~= "lightweapon" and iteminfo.type ~= "heavyweapon" and iteminfo.type ~= "ship" end, true, OtherAddonhelpfultext)

	StationEquipmentBuyShipTab.tabtitle = "Buy Ship"
	StationEquipmentBuyShipTab.hotkey = iup.K_b
	StationEquipmentBuySmallTab.tabtitle = "Small Addons"
	StationEquipmentBuySmallTab.hotkey = iup.K_a
	StationEquipmentBuyLargeTab.tabtitle = "Large Addons"
	StationEquipmentBuyLargeTab.hotkey = iup.K_r
	StationEquipmentBuyOtherTab.tabtitle = "Other"
	StationEquipmentBuyOtherTab.hotkey = iup.K_o

	StationEquipmentBuyShipTab.OnHelp = HelpShipPurchase
	StationEquipmentBuySmallTab.OnHelp = HelpSmallAddonsAction
	StationEquipmentBuyLargeTab.OnHelp = HelpLargeAddonsAction
	StationEquipmentBuyOtherTab.OnHelp = HelpOtherAddonsAction

	return iup.subsubtabtemplate{
		StationEquipmentBuyShipTab,
		StationEquipmentBuySmallTab,
		StationEquipmentBuyLargeTab,
		StationEquipmentBuyOtherTab,
	}
end

function CreateStationEquipmentSellTab()
	StationEquipmentSellShipTab, StationEquipmentSellShipPurchaseButton = CreateStationCommoditiesSellTab(function(iteminfo)
			local classtype = GetInventoryItemClassType(iteminfo.itemid)
			if classtype == CLASSTYPE_SHIP then
				local shipinv = GetShipInventory(iteminfo.itemid)
				if next(shipinv.addons) or next(shipinv.cargo) then
					iteminfo.isnotempty = true
				else
					iteminfo.isnotempty = nil
				end
				return true
			end
		end, true, ShipSellhelpfultext)
	StationEquipmentSellSmallTab, StationEquipmentSellSmallPurchaseButton = CreateStationCommoditiesSellTab(function(iteminfo)
			local classtype = GetInventoryItemClassType(iteminfo.itemid)
			local containerclasstype = GetInventoryItemClassType(GetInventoryItemContainerID(iteminfo.itemid))
			if containerclasstype == CLASSTYPE_STORAGE and classtype == CLASSTYPE_ADDON and GetInventoryItemClassSubType(iteminfo.itemid) == 0 then
				return true
			end
		end, true, SmallAddonSellhelpfultext)
	StationEquipmentSellLargeTab = CreateStationCommoditiesSellTab(function(iteminfo)
			local classtype = GetInventoryItemClassType(iteminfo.itemid)
			local containerclasstype = GetInventoryItemClassType(GetInventoryItemContainerID(iteminfo.itemid))
			if containerclasstype == CLASSTYPE_STORAGE and classtype == CLASSTYPE_ADDON and GetInventoryItemClassSubType(iteminfo.itemid) == 1 then
				return true
			end
		end, true, LargeAddonSellhelpfultext)
	StationEquipmentSellOtherTab, StationEquipmentSellOtherPurchaseButton = CreateStationCommoditiesSellTab(function(iteminfo)
			local classtype = GetInventoryItemClassType(iteminfo.itemid)
			local subtype = GetInventoryItemClassSubType(iteminfo.itemid)
			local containerclasstype = GetInventoryItemClassType(GetInventoryItemContainerID(iteminfo.itemid))
			if containerclasstype == CLASSTYPE_STORAGE and classtype == CLASSTYPE_ADDON and subtype ~= 0 and subtype ~= 1 then
				return true
			end
		end, true, OtherAddonSellhelpfultext)

	StationEquipmentSellShipTab.tabtitle = "Ships"
	StationEquipmentSellSmallTab.tabtitle = "Small Addons"
	StationEquipmentSellLargeTab.tabtitle = "Large Addons"
	StationEquipmentSellOtherTab.tabtitle = "Other"

	StationEquipmentSellShipTab.OnHelp = HelpSellAddons
	StationEquipmentSellSmallTab.OnHelp = HelpSellAddons
	StationEquipmentSellLargeTab.OnHelp = HelpSellAddons
	StationEquipmentSellOtherTab.OnHelp = HelpSellAddons

	return iup.subsubtabtemplate{
		StationEquipmentSellShipTab,
		StationEquipmentSellSmallTab,
		StationEquipmentSellLargeTab,
		StationEquipmentSellOtherTab,
	}
--[[
	local container = CreateStationCommoditiesSellTab(
		function(iteminfo)
			local classtype = GetInventoryItemClassType(iteminfo.itemid)
			if classtype == CLASSTYPE_SHIP then
				local shipinv = GetShipInventory(iteminfo.itemid)
				if next(shipinv.addons) or next(shipinv.cargo) then
					iteminfo.isnotempty = true
				else
					iteminfo.isnotempty = nil
				end
				return true
			elseif classtype == CLASSTYPE_ADDON then
				local containerclasstype = GetInventoryItemClassType(GetInventoryItemContainerID(iteminfo.itemid))
				return containerclasstype == CLASSTYPE_STORAGE
			else
				return false
			end
		end, false)

	container.OnHelp = HelpSellAddons

	return container
--]]
end

function CreateStationCommerceTab()
	StationCommerceWelcomeTab = CreateStationWelcomeTab() StationCommerceWelcomeTab.tabtitle="Welcome"  StationCommerceWelcomeTab.hotkey = iup.K_w
	StationCommerceCommoditiesTab = CreateStationCommoditiesTab() StationCommerceCommoditiesTab.tabtitle="Commodities"  StationCommerceCommoditiesTab.hotkey = iup.K_d
	StationChatTab = CreateStationChatTab() StationChatTab.tabtitle = "The Bar"  StationChatTab.hotkey = iup.K_h
	StationCommoditiesLoadTab = CreateStationCommoditiesLoadTab()
	StationCommoditiesLoadTab.tabtitle = "Load/Unload"
	StationCommoditiesLoadTab.OnHelp = HelpShipCargo
	StationCommoditiesLoadTab.hotkey = iup.K_o

	return iup.roottabtemplate{
		StationCommerceWelcomeTab,
		StationCommoditiesLoadTab,
		StationCommerceCommoditiesTab,
		StationChatTab,
		secondary = iup.hbox{size="%14x"},
	}
end

function CreateStationEquipmentTab()
	StationEquipmentManageTab = CreateStationEquipmentManageTab() StationEquipmentManageTab.tabtitle="Manage"  StationEquipmentManageTab.hotkey = iup.K_e
	StationEquipmentBuyTab = CreateStationEquipmentBuyTab() StationEquipmentBuyTab.tabtitle="Buy"  StationEquipmentBuyTab.hotkey = iup.K_B
	StationEquipmentSellTab = create_char_inventory_tab(true, true, true) StationEquipmentSellTab.tabtitle="Sell"  StationEquipmentSellTab.hotkey = iup.K_l

	return iup.roottabtemplate{
		StationEquipmentManageTab,
		StationEquipmentBuyTab,
		StationEquipmentSellTab,
		secondary = iup.hbox{size="%14x"},
	}
end

function CreateStationPDATab()
	StationPDAMissionsTab, StationPDAMissionNotesTab, StationPDAMissionAdvancementTab, StationPDAMissionLogTab, StationPDAMissionBoardTab, StationPDAMissionBoardTabInfoButton = CreateMissionsPDATab() StationPDAMissionsTab.tabtitle="Missions"   StationPDAMissionsTab.hotkey = iup.K_m
	StationPDAShipTab, StationPDAShipNavigationTab = CreateShipPDATab(false) StationPDAShipTab.tabtitle="Navigation"   StationPDAShipTab.hotkey = iup.K_n
	StationPDASensorTab, StationPDASensorNearbyTab = CreateSensorPDATab(false) StationPDASensorTab.tabtitle="Sensor Log"   StationPDASensorTab.hotkey = iup.K_e
	StationPDACommTab = CreateCommPDATab() StationPDACommTab.tabtitle="Comm"   StationPDACommTab.hotkey = iup.K_o
	StationPDACharacterTab, StationPDACharacterStatsTab = CreateCharacterPDATab() StationPDACharacterTab.tabtitle="Character"   StationPDACharacterTab.hotkey = iup.K_r
	StationPDAInventoryTab, StationPDAInventoryInventoryTab, StationPDAInventoryJettisonTab = CreateInventoryPDATab(false) StationPDAInventoryTab.tabtitle="Inventory"   StationPDAInventoryTab.hotkey = iup.K_i

	return iup.roottabtemplate{
		StationPDAMissionsTab,
		StationPDAShipTab,
		StationPDASensorTab,
		StationPDACommTab,
		StationPDACharacterTab,
		StationPDAInventoryTab,
		secondary = iup.hbox{size="%14x"},
	}
end

function CreateStationFactionInfo()
	local container

--	StationFactionIcon = iup.label{title="Faction logo", wordwrap="YES", size="80x64", fgcolor=tabseltextcolor}
--	StationTypeIcon = iup.label{title="Station type logo", wordwrap="YES", size="80x64", fgcolor=tabseltextcolor}
	StationNameLabel = iup.label{title="", expand="HORIZONTAL", size="1x", wordwrap="NO", fgcolor=tabunseltextcolor}
	StationFactionLabel = iup.label{title="", expand="HORIZONTAL", size="1x", wordwrap="NO", fgcolor=tabunseltextcolor}
	container = iup.vbox{
--[[
		iup.hbox{
			iup.pdasubframe_nomargin{StationFactionIcon},
			iup.pdasubframe_nomargin{StationTypeIcon},
			gap="8",
		},
--]]
		StationNameLabel,
		StationFactionLabel,
	}

	function container:OnShow()
		StationNameLabel.title = "Welcome to "..tostring(GetStationName())
		local stationfaction = tostring(FactionName[GetStationFaction()])
		StationFactionLabel.title = Article(stationfaction).." station"
	end

	function container:OnHide()
	end

	return container
end



function CreateStationChatTab()
	local isvisible = false
	local stationlog
	local function logupdated()
		local color
		if isvisible then
			SetStationLogRead()
			color = tabseltextcolor
		else
			color = tabunseltextcolor
		end
		if ShowBarUpdateNotification then
			StationTabs:SetTabTextColor(StationCommerceTab, GetStationLogReadState() and color or "255 0 0")
			StationCommerceTab:SetTabTextColor(StationChatTab, GetStationLogReadState() and color or "255 0 0")
		end
	end

	stationlog = ChatLogTemplate("45 120 158 0 *", "100 0 0 178 *", logupdated, IMAGE_DIR.."commerce_tab_bgcolor.png", true)
	stationlog.chattext.indent = "YES"
	stationlog.chattext.border = "NO"
	stationlog.chattext.boxcolor = "45 120 158 128"
	stationlog.chattext.bgcolor = "45 120 158 128 *"
	stationlog.chattext.active = "YES"
	stationlog.chattext.expand = "YES"
	stationlog.chatentry.active = "YES"
	stationlog.chatentry.wanttab = "YES"
	stationlog.chatentry.visible = "YES"
	stationlog.chatentry.border = "YES"
	stationlog.chatentry.bgcolor = "49 90 110 128 *"
	stationlog.chatentry.bordercolor = "70 94 106"
	stationlog.chatentry.type = "STATION"

	StationLog = stationlog

	local container = iup.vbox{iup.pdarootframebg{stationlog.vbox}}
--[[
	local container = iup.hbox{
		stationlog.vbox,
		iup.pdarootframebg{
			iup.hbox{
				iup.fill{},
				iup.vbox{
					iup.fill{},
				},
			},
			expand="VERTICAL",
			size="%14x",
		},
	}
--]]

	function container:OnShow()
		isvisible = true
		SetStationLogRead()
		logupdated()
		iup.SetFocus(stationlog.chatentry)
	end

	function container:OnHide()
		isvisible = false
	end

	function container:OnEvent(eventname, ...)
	end

	return container
end

function CreateStation()
	local curtab
	local update_secondary_info
	local missiontimer
	local update_mission_timers
	local isvisible = false

--	StationChatTab = CreateStationChatTab() StationChatTab.tabtitle = "The Bar"

	StationTabPDA = CreateStationPDATab() StationTabPDA.tabtitle = "Your PDA"  StationTabPDA.hotkey = iup.K_y
	StationCommerceTab = CreateStationCommerceTab() StationCommerceTab.tabtitle = "Commerce"  StationCommerceTab.hotkey = iup.K_c
	StationEquipmentTab = CreateStationEquipmentTab() StationEquipmentTab.tabtitle = "Ship"  StationEquipmentTab.hotkey = iup.K_s
	StationChatArea = chatareatemplate2(false)
	StationFactionInfo = CreateStationFactionInfo()
	StationCurrentLocationInfo = iup.label{title="YOU ARE HERE", alignment="ACENTER", expand="HORIZONTAL", fgcolor=tabunseltextcolor, font=Font.H4}
	StationOptionsButton = iup.stationbutton{
			title="Options",
			tip="Config or logout",
			expand="HORIZONTAL",
			action=function(self)
				HideDialog(StationDialog)
				OptionsDialog:SetMenuMode(2, StationDialog)
				ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER)
			end,
		}
	StationLaunchButton = iup.stationbutton{
			title="L A U N C H",
			tip="Launch into space",
			expand="HORIZONTAL",
			action=function(self)
				local launchfailure = RequestLaunch()
				if not launchfailure then
					HideDialog(StationDialog)
					NotificationDialog:SetMessage("Launching...")
					ShowDialog(NotificationDialog, iup.CENTER, iup.CENTER)
				else
					if launchfailure == "noengine" then
						OpenAlarm("Unable to launch:", "You need an engine to launch.", "OK")
					elseif launchfailure == "nopowercell" then
						OpenAlarm("Unable to launch:", "You need a power cell to launch.", "OK")
					elseif launchfailure == "nogridpower" then
						OpenAlarm("Unable to launch:", "Your power cell does not have enough Grid Power\nto support the Grid Usage of the equipped addons.", "OK")
					elseif launchfailure == "noship" then
						OpenAlarm("Unable to launch:", "You need to select a ship to launch.", "OK")
					end
				end
			end,
		}
	StationHomeButton = iup.stationbutton{
			title="Set Home",
			tip="Respawn at this station",
			expand="HORIZONTAL",
			action = function(self)
				local s_name = tostring(GetStationName())
				if not ShowSetHomeDialog then
					SetHomeStation()
					purchaseprint("Home station set to "..s_name)
				else
					-- dialog box here, yes/no
					QuestionWithCheckDialog:SetMessage('Do you want to set your home station to '..s_name..'?',
						"Yes", function()
							ShowSetHomeDialog = not QuestionWithCheckDialog:GetCheckState()
							gkini.WriteInt("Vendetta", "showsethomeconfirmation", ShowSetHomeDialog and 1 or 0)
							SetHomeStation()
							purchaseprint("Home station set to "..s_name)
							HideDialog(QuestionWithCheckDialog)
						end,
						"No", function()
							ShowSetHomeDialog = not QuestionWithCheckDialog:GetCheckState()
							gkini.WriteInt("Vendetta", "showsethomeconfirmation", ShowSetHomeDialog and 1 or 0)
							HideDialog(QuestionWithCheckDialog)
						end,
						not ShowSetHomeDialog
						)
					ShowDialog(QuestionWithCheckDialog,iup.CENTER,iup.CENTER)
				end
			end
	}
	StationSecondaryInfo = iup.label{
		size="1x1",
		expand="YES",
		fgcolor=tabunseltextcolor,
		font=Font.H6,
		title="Credits: 10,001,100",
--		tip="Credits\nCurrent Ship\nCargo\nMass\nLicenses",
	}

	local secondary = iup.vbox{
		iup.pdasubframe_nomargin{
			iup.hbox{
			iup.vbox{
				StationSecondaryInfo,
				margin="5x5",
				size="x%18",
			},
			expand="NO",
			size="%13x",
			},
			expand="NO",
		},
		iup.pdasubframe_nomargin{
			iup.hbox{
			iup.vbox{
				StationHomeButton,
				StationLaunchButton,
				StationOptionsButton,
				gap=8,
				margin="5x5",
				alignment="ACENTER",
			},
			expand="NO",
			size="%13x",
			},
			expand="NO",
		},
		gap=5,
	}

	StationTabs = iup.pda_root_tabs{
			{expand="HORIZONTAL", spacer=true},
			StationCommerceTab,
			{size=5, spacer=true},
			StationEquipmentTab,
			{size=5, spacer=true},
			StationTabPDA,
--			{size=5, spacer=true},
--			StationChatTab,
			{size="%25", spacer=true},
			seltextcolor=tabseltextcolor,
			unseltextcolor=tabunseltextcolor,
			tabchange_cb = function(self, newtab, oldtab)
				curtab = newtab
				if isvisible then
					oldtab:OnHide()
					newtab:OnShow()
				end
			end,
		}
	curtab = StationCommerceTab

	local gap = -(Font.H4*1.5 - 4)
	local twentypercent = gkinterface.GetYResolution()*.20

	StationDialog = iup.dialog{
		iup.vbox{
			iup.hbox{
				iup.pdarootframe{
					StationChatArea,
					size="%74x%20",
					expand="NO",
				},
				iup.vbox{
					iup.pdarootframe{
						StationFactionInfo,
					},
					iup.pdarootframe{
						iup.vbox{
							iup.fill{},
							StationCurrentLocationInfo,
							iup.fill{},
						}
					},
					gap="4",
					size="%24x"..twentypercent - gap,
					expand="HORIZONTAL"
				},
				gap="4",
			},
			iup.zbox{
				StationTabs,
				iup.hbox{
					secondary,
					margin="5x5",
				},
				all="YES",
				alignment = "SE",
			},
			gap = gap+4,
			margin = "4x4",
		},
		bgcolor = "0 0 0 0 +",
		border="NO",
		resize="NO",
		menubox="NO",
		defaultesc=StationOptionsButton,
		fullscreen="YES",
		show_cb=function()
			isvisible = true
			curtab:OnShow()

			StationChatArea:OnShow()
			StationFactionInfo:OnShow()
			update_secondary_info()
			update_mission_timers()
			SetStationLogReceiver(StationLog)
			if ShouldTutorialRun() then
				RunTutorial()
			end
		end,
		k_any=function(self, ch)
			local keycommand = gkinterface.GetCommandForKeyboardBind(ch)
			if curtab.k_any and curtab:k_any(ch) ~= iup.CONTINUE then
				return iup.CONTINUE
			elseif keycommand == "say_sector" then
				StationChatArea:set_chatmode(2)
			elseif keycommand == "say_channel" then
				StationChatArea:set_chatmode(3)
			elseif keycommand == "say_group" then
				StationChatArea:set_chatmode(4)
			elseif keycommand == "say_guild" then
				StationChatArea:set_chatmode(5)
			elseif keycommand == "say_system" then
				StationChatArea:set_chatmode(6)
			elseif keycommand == "missionchat" then
				StationTabs:SetTab(StationTabPDA)
				StationTabPDA:SetTab(StationPDAMissionsTab)
				if GetNumActiveMissions() > 0 then
					StationPDAMissionsTab:SetTab(StationPDAMissionLogTab)
				else
					StationPDAMissionsTab:SetTab(StationPDAMissionBoardTab)
				end
			elseif keycommand == "+TopList" then
				StationTabs:SetTab(StationTabPDA)
				StationTabPDA:SetTab(StationPDASensorTab)
				StationPDASensorTab:SetTab(StationPDASensorNearbyTab)
			elseif keycommand == "nav" then
				StationTabs:SetTab(StationTabPDA)
				StationTabPDA:SetTab(StationPDAShipTab)
				StationPDAShipTab:SetTab(StationPDAShipNavigationTab)
			elseif keycommand == "Jettison" then
				StationTabs:SetTab(StationTabPDA)
				StationTabPDA:SetTab(StationPDAInventoryTab)
				StationPDAInventoryTab:SetTab(StationPDAInventoryJettisonTab)
			elseif keycommand == "CharInfo" then
				StationTabs:SetTab(StationTabPDA)
				StationTabPDA:SetTab(StationPDACharacterTab)
				StationPDACharacterTab:SetTab(StationPDACharacterStatsTab)
			elseif ch == iup.K_h or ch == iup.K_H then
				StationTabs:SetTab(StationCommerceTab)
				StationCommerceTab:SetTab(StationChatTab)
			end
			return iup.CONTINUE
		end,
	}

	function StationDialog:hide_cb()
		isvisible = false
		curtab:OnHide()
		StationChatArea:OnHide()
		StationFactionInfo:OnHide()
		missiontimer:Kill()
		SetStationLogReceiver(nil)
	end
	function StationDialog:map_cb()
		RegisterEvent(self, "SHOW_STATION")
		RegisterEvent(self, "ENTERING_STATION")
		RegisterEvent(self, "LEAVING_STATION")
		RegisterEvent(self, "CHAT_CANCELLED")
		RegisterEvent(self, "TRANSACTION_COMPLETED")
		RegisterEvent(self, "CHAT_MSG_SERVER_CHANNEL_ACTIVE")
		RegisterEvent(self, "MISSION_NOTIFICATION")
		RegisterEvent(self, "MISSION_REMOVED")
		RegisterEvent(self, "MISSION_TIMER_STOP")
		RegisterEvent(self, "MISSION_TIMER_START")
		RegisterEvent(self, "PLAYER_UPDATE_STATS")
		RegisterEvent(self, "INVENTORY_ADD")
		RegisterEvent(self, "INVENTORY_REMOVE")
		RegisterEvent(self, "INVENTORY_UPDATE")
		RegisterEvent(self, "TRANSACTION_FAILED")
		RegisterEvent(self, "PLAYER_HOME_CHANGED")
	end

	update_secondary_info = function()
		local curcargo, maxcargo, shipname, shipmass
		shipname = GetActiveShipName()
		if not shipname then
			curcargo = 0
			maxcargo = 0
			shipmass = 0
			shipname = "No active ship"
		else
			curcargo = GetActiveShipCargoCount() or 0
			maxcargo = GetActiveShipMaxCargo() or 0
			shipmass = GetActiveShipMass() or 0
		end
		local lic1 = GetLicenseLevel(1)
		local lic2 = GetLicenseLevel(2)
		local lic3 = GetLicenseLevel(3)
		local lic4 = GetLicenseLevel(4)
		local lic5 = GetLicenseLevel(5)
		local home = ShortLocationStr(GetHomeStation())
		StationSecondaryInfo.title = string.format(
			"Credits: %sc\nCurrent Ship:\n%s\nCargo: %u/%u cu\nMass: %skg\nLicenses: %s/%s/%s/%s/%s\nHome: %s\nStation: %s cu",
--			"%uc\n%s\n%u/%u cu\n%ukg\n%s/%s/%s/%s/%s",
			comma_value(GetMoney()), shipname, curcargo, maxcargo, comma_value((math.floor(1000*shipmass+0.5))),
			lic1>0 and lic1 or "-",
			lic2>0 and lic2 or "-",
			lic3>0 and lic3 or "-",
			lic4>0 and lic4 or "-",
			lic5>0 and lic5 or "-",
			home,
			comma_value(GetStationCurrentCargo())
--			,GetStationMaxCargo()
			)
		StationSecondaryInfo.size = "1x1"
	end

	missiontimer = Timer()
	update_mission_timers = function()
		local firsttimer = GetMissionTimers()
		if firsttimer and StationDialog.visible == "YES" then
			firsttimer = math.max(0, firsttimer)
			StationCurrentLocationInfo.title = "Mission Timer: "..format_time(firsttimer)
--			StationSecondaryMissionTimer.title = "Mission Timer: "..format_time(firsttimer)
			missiontimer:SetTimeout(50, function() update_mission_timers() end)
		else
--			StationSecondaryMissionTimer.title = ""
			StationCurrentLocationInfo.title = ShortLocationStr(GetCurrentSectorid() or 1)
			missiontimer:Kill()
		end
	end

	function StationDialog:OnEvent(eventname, ...)
		if GetCurrentStationType() ~= 0 then return end
		if eventname == "SHOW_STATION" then
			HideAllDialogs()
			HideDialog(HUD.dlg)
			StationCurrentLocationInfo.title = ShortLocationStr(GetCurrentSectorid() or 1)
			gkinterface.Draw3DScene(Game.GetCVar("rRenderStationInMenu") == 1)
			SetStationLogRead()
			if not HasActiveShip() and HasLastShipLoadout() then
				ShowDialog(BuybackQuestionPrompt, iup.CENTER, iup.CENTER)
			else
				ShowDialog(self)
			end
		elseif eventname == "ENTERING_STATION" then
			gkinterface.Draw3DScene(Game.GetCVar("rRenderStationInMenu") == 1)
			HideDialog(ConnectingDialog)
			NotificationDialog:SetMessage("Entering Station...")
			ShowDialog(NotificationDialog, iup.CENTER, iup.CENTER)
			HUD:SetMode("chat")
		elseif eventname == "LEAVING_STATION" then
			gkinterface.Draw3DScene(true)
			missiontimer:Kill()
			HideDialog(self)
			-- set up the Welcome tab as default every time player enters station.
			StationTabs:SetTab(StationCommerceTab)
			StationCommerceTab:SetTab(StationCommerceWelcomeTab)
			HUD:SetMode("chat")
			ShowDialog(HUD.dlg)
		elseif eventname == "CHAT_CANCELLED" then
			if self.visible == "YES" then
				iup.SetFocus(self)
			end
		elseif eventname == "CHAT_MSG_SERVER_CHANNEL_ACTIVE" then
			StationChatArea:update_channeltitle()
		elseif eventname == "TRANSACTION_COMPLETED" or
				eventname == "INVENTORY_ADD" or 
				eventname == "INVENTORY_REMOVE" or 
				eventname == "INVENTORY_UPDATE" or
				eventname == "PLAYER_HOME_CHANGED" then
			if self.visible == "YES" then
				update_secondary_info()
			end
		elseif eventname == "PLAYER_UPDATE_STATS" then
			local charid = ...
			if self.visible == "YES" and charid == GetCharacterID() then
				update_secondary_info()
			end
		elseif eventname == "MISSION_REMOVED" then
--[[  need to fix some missions before this can be used
				StationTabs:SetTab(StationTabPDA)
				StationTabPDA:SetTab(StationPDAMissionsTab)
				StationPDAMissionsTab:SetTab(StationPDAMissionBoardTab)
--]]
		elseif eventname == "MISSION_NOTIFICATION" then
--			if self.visible == "YES" then
				-- todo: flash the tab text or something.
--			else
				StationTabs:SetTab(StationTabPDA)
				StationTabPDA:SetTab(StationPDAMissionsTab)
				StationPDAMissionsTab:SetTab(StationPDAMissionLogTab)
--			end
		elseif eventname == "MISSION_TIMER_STOP" then
			if self.visible == "YES" then
				update_mission_timers()
				iup.Refresh(self)
			end
		elseif eventname == "MISSION_TIMER_START" then
			if self.visible == "YES" then
				update_mission_timers()
				iup.Refresh(self)
			end
		elseif eventname == "TRANSACTION_FAILED" then
			local errorstring, errorid = ...
			print("station error: "..tostring(errorstring))
			if errorid == 26 then -- 26 = failed to launch because your ship didn't have enough grid power.
				HideDialog(NotificationDialog)
				ShowDialog(StationDialog)
			end
		end
	end

	StationDialog:map()

	return StationDialog
end

CreateStation()
