ShipPresets = {}

function LoadShipPresets()
	local section = GetPlayerName()
	for k=1,4 do
		local str = gkini.ReadString(section, "shippreset"..k, "")
		if str == "" then
			ShipPresets[k] = nil
            preset_buttons[k].title = "No Preset"
		else
			ShipPresets[k] = unspickle(tostring(str))
            local shipname = InvManager.GetInventoryItemParameter(ShipPresets[k]['ship'],"Name") or "???"
            if string.len(shipname) > 20 then shipname = string.sub(shipname,0,18).."..." end
            --shipname = shipname:gsub('Serco ','')
            --shipname = shipname:gsub('Type ','')
            --shipname = shipname:gsub('Mineral ','')
            --shipname = shipname:gsub('Tunguska ','Tung ')
            --shipname = shipname:gsub(' Rev B','')
            --shipname = shipname:gsub('Marauder','Maraud')
            --shipname = shipname:gsub('Centurion Superlight','Superlight')
            preset_buttons[k].title = shipname
		end
        preset_buttons[k].expand = 'HORIZONTAL'
	end

	BuybackQuestionPrompt = MakeBuyBackQuestionDlg()
	BuybackQuestionPrompt:map()
end

function SaveShipPresets(index)
	local section = GetPlayerName()
	if index and index >= 1 and index <= 4 then
		local preset = ShipPresets[index]
		if preset then
			local str = spickle(preset)
			gkini.WriteString(section, "shippreset"..index, str)
		end
	else
		for k=1,4 do
			local preset = ShipPresets[k]
			gkini.WriteString(section, "shippreset"..k, preset and spickle(preset) or "")
		end
	end
    LoadShipPresets()
end

local function buybackdone_cb(success)
	purchaseprint(success and "Items purchased." or "Items purchase failed. Not all items were purchased because not all items are available at this station.")
	purchaseprint("Total cost of purchase is "..comma_value(GetLastShipLoadoutPurchaseCost()).." credits")
	ClearLastShipLoadout()
	HideDialog(CancelLoadoutPurchaseDialog)
	ShowDialog(StationDialog)
end

function MakeBuyBackQuestionDlg()
	local dlg
	local yes_cb, no_cb

	yes_cb = function(loadout)
		HideDialog(dlg)
		CancelLoadoutPurchaseDialog:SetMessage("Purchasing...", "Cancel", function() CancelPurchaseShipLoadout() buybackdone_cb(false) end)
		ShowDialog(CancelLoadoutPurchaseDialog, iup.CENTER, iup.CENTER)
		PurchaseShipLoadout(buybackdone_cb, loadout)
	end

	no_cb = function()
		HideDialog(dlg)
		ShowDialog(StationDialog)
	end

	local button1 = iup.stationbutton{title="Yes",action=function() return yes_cb(nil) end}
	local button2 = iup.stationbutton{title="No",action=no_cb}
	local preset_buttons = {gap=6}
	for k=1,4 do
		local section = GetPlayerName()
		local str = gkini.ReadString(section, "shippreset"..k, "")
		if str == "" then
            local index = k
			preset_buttons[index] = iup.stationbutton{title="No Preset",
				hotkey = (iup.K_1 + (index-1)),
				active = "no",
				action=function()
					return yes_cb(ShipPresets[index])
				end}
		else
			ShipPresets[k] = unspickle(tostring(str))
            local shipname = InvManager.GetInventoryItemParameter(ShipPresets[k]['ship'],"Name")
            if string.len(shipname) > 20 then shipname = string.sub(shipname,0,18).."..." end
			local index = k
			preset_buttons[index] = iup.stationbutton{title=shipname,
				hotkey = (iup.K_1 + (index-1)),
				action=function()
					return yes_cb(ShipPresets[index])
				end}
		end
	end

	dlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					iup.hbox{
						iup.label{font=Font.H1,title="Buy back last ship?"},
						button1,
						button2,
						gap=6,
					},
					iup.label{font=Font.H1,title="Or Buy Preset:"},
					iup.hbox(preset_buttons),
					gap=6,
					alignment="ACENTER",
				},
			},
		},
		defaultenter = button1,
		defaultesc = button2,
		border="NO",
		resize="NO",
		menubox="NO",
		bgcolor = "0 0 0 0 *",
		topmost="YES",
	}

	return dlg
end

BuybackQuestionPrompt = MakeBuyBackQuestionDlg()
BuybackQuestionPrompt:map()
