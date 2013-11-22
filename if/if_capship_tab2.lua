function CreateCapShipRepairTab()
	local isvisible = false
	local reset = true
	local refillallammoprice = 0
	local shiprepaircost = 0
	local repairshipbutton = iup.stationbutton{title="Repair Ship", active="NO", font=Font.H4, hotkey=iup.K_r,
		action=function(self)
			self.active = "NO"
			local price = shiprepaircost
			RepairShip(GetActiveShipID(), 1,
				function(errid)
					if not errid then
						purchaseprint("Ship repaired for a total price of "..comma_value((price or "???")).."c.")
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
						purchaseprint("All ammo in active ship purchased for a total price of "..comma_value((price or "???")).."c.")
					end
				end
				)
		end}
	local activeshipnamelabel = iup.label{title="stuff", size="1x", expand="HORIZONTAL", wordwrap="NO"}
	local hullintegritylabel = iup.label{title=" 100%", size="1x", expand="HORIZONTAL", wordwrap="NO", alignment="ARIGHT"}
	local repaircostlabel = iup.label{title="0c", size="1x", expand="HORIZONTAL", wordwrap="NO", alignment="ARIGHT"}
	local ammocostlabel = iup.label{title="stuff", size="1x", expand="HORIZONTAL", wordwrap="NO", alignment="ARIGHT"}

	local container = iup.vbox{
		iup.stationsubframebg{
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
				iup.fill{},
			},
		},
	}
	container=iup.frame{
		bgcolor="0 0 0 0 *",
		segmented="0 0 1 1",
		container
	}

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

		update_ship_info()
	end

	function container:OnHide()
		isvisible = false
	end

	function container:OnEvent(eventname, ...)
		if eventname == "STATION_UPDATE_DESIREDITEMS" or
			eventname == "ENTERING_STATION" then
			if isvisible then
			else
				reset = true
			end
		elseif eventname == "ENTERING_STATION" then
			if isvisible then
			else
				reset = true
			end
		elseif eventname == "INVENTORY_ADD" or
			eventname == "INVENTORY_REMOVE" or
			eventname == "INVENTORY_UPDATE" then
			if isvisible then
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

	return container
end
