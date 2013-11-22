-- StorageRentalDialog

function CreateStorageRentalDialog()
	local currentstorageindex
	local cu_delta
	local curmaxstationcargo, purchasablemaxcargo, purchaseincrement, purchaseprice
	local dlg
	local titlelabel = iup.label{title="Storage Rental\n\n", alignment="ACENTER", expand="YES", font=Font.H2}
	local infolabel = iup.label{font=Font.H4,title="Title\n\n\n", expand="YES", size="300x"}
	local choices = iup.list{dropdown="YES", value=1, expand="HORIZONTAL", visible_items="10"}
	local buttonCancel = iup.stationbutton{title="Cancel", action=function() HideDialog(dlg) end}
	local buttonOK = iup.stationbutton{title="Apply", active="NO", action=function()
	 		local curstationstorage = GetStationCurrentCargo()
	 		if ((curmaxstationcargo+cu_delta) < curstationstorage) and (curstationstorage <= purchasablemaxcargo) then
	 			OpenAlarm("Action Not Allowed\n", "You won't have enough\nstorage if you do this.")
		 	else
				if cu_delta < 0 then
					UnrentStorage(-cu_delta, nil, function(err) if not err then
							purchaseprint(comma_value(-cu_delta).." cu of storage rental discontinued.")
							end end)
				elseif cu_delta > 0 then
					RentStorage(cu_delta, nil, function(err) if not err then
							purchaseprint(comma_value(cu_delta).." cu of additional storage rented.")
							end end)
				end
				HideDialog(dlg)
			end
		end}

	choices.action=function(self, str, i, v)
		cu_delta = (i-currentstorageindex)*purchaseincrement
		if currentstorageindex == i then
			buttonOK.active = "NO"
		else
			buttonOK.active = "YES"
		end
	end

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{size=dlgposx},
			iup.vbox{
				iup.fill{size=dlgposy},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							titlelabel,
							infolabel,
							iup.hbox{iup.label{title="Change rent (cost): "},choices},
							iup.hbox{
								iup.fill{},
								buttonOK,
								iup.fill{},
								buttonCancel,
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
		defaultenter = buttonOK,
		defaultesc = buttonCancel,
		fullscreen="YES",
		bgcolor = bgcolor or "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:show_cb()
		local locationid, mincargo, rent
		curmaxstationcargo, purchasablemaxcargo, purchaseincrement, purchaseprice, mincargo, rent = GetStationMaxCargo(locationid)
		local curstationstorage = GetStationCurrentCargo()
		local start = 10000
		local price = 0
		local currentcost = (curmaxstationcargo-start)*purchaseprice
		local i=1

		titlelabel.title = tostring(GetStationName()).."\nStorage Rental\n"

		currentstorageindex = nil

		local recurrencetime = "week"
		while start <= purchasablemaxcargo do
			local modifiedpurchaseprice = math.ceil((price-currentcost)*GetStationFactionAppraisalModifier(locationid))
			if modifiedpurchaseprice >= 0 then
				modifiedpurchaseprice = "+"..comma_value(modifiedpurchaseprice)
			else
				modifiedpurchaseprice = comma_value(modifiedpurchaseprice)
			end
			choices[i] = comma_value(start).." ("..modifiedpurchaseprice.." c/"..recurrencetime..")"
			price = price + (purchaseincrement*purchaseprice)
			start = start + purchaseincrement
			if (not currentstorageindex) and (start > curmaxstationcargo) then
				currentstorageindex = i
			end
			i=i+1
		end
		currentstorageindex = currentstorageindex or 1
		choices[i] = nil
		choices.value = currentstorageindex
		
		buttonOK.active = "NO"
		
		infolabel.title = string.format("Currently used: %s / %s cu\nCurrently rented: %s cu @ %s c/"..recurrencetime.."\nMaximum rentable space available: %s cu\n",
				comma_value(curstationstorage),
				comma_value(curmaxstationcargo),
				comma_value(curmaxstationcargo-mincargo),
				comma_value(rent),
				comma_value(purchasablemaxcargo) )
	end

	dlg:map()

	return dlg
end

StorageRentalDialog = CreateStorageRentalDialog()
