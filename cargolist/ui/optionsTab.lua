--[[
	Options Tab screen for Cargolist
]]

function cargolist.ui:CreateOptionsTab ()
	local targetingSelection = iup.pdasublist  {
		font = cargolist.ui.font,
		dropdown = "YES",
		visible_items = 10,
		expand = "HORIZONTAL"
	}
	targetingSelection [1] = "Prescan Object"
	targetingSelection [2] = "Initial Set Object"
	targetingSelection [3] = "One Shot"
	targetingSelection.value = cargolist.data.targetPolicy
	
	local activeSetSelection = iup.pdasublist  {
		font = cargolist.ui.font,
		dropdown = "YES",
		visible_items = 10,
		expand = "HORIZONTAL"
	}
	activeSetSelection [1] = "All"
	local activeSet = cargolist.data.activeSet
	
	function activeSetSelection:action (text, index, state)
		activeSet = text
	end

	local sortSelection = iup.pdasublist {
		font = cargolist.ui.font,
		dropdown = "YES",
		visible_items = 10,
		expand = "HORIZONTAL"
	}
	sortSelection [1] = "None"
	sortSelection [2] = "Name"
	sortSelection [3] = "Distance"
	sortSelection.value = cargolist.ui.sortColumn + 1
	
	function targetingSelection:action (text, index, state)
		sortSelection.active = "YES"
		--if state == 1 and text == "Incremental" then
		if state == 1 and index == 3 then
			sortSelection.value = 1
			sortSelection.active = "NO"
			iup.Refresh (sortSelection)
		end
	end
	
	local autoAdvanceToggle = iup.stationtoggle {title="  Auto Advance?", fgcolor=cargolist.ui.fgcolor, value=cargolist.ui:GetOnOffSetting (cargolist.data.autoAdvance)}
	
	local maxScannableItems = iup.text {value = tostring (cargolist.data.maxScannableItems), size = "50x"}
	local maxItemListSize = iup.text {value = tostring (cargolist.data.maxItemListSize), size = "50x"}
	
	local scanScreenBind = iup.text {value = "", size = "150x"}
	local scanBind= iup.text {value = "", size = "150x"}
	local scanAllBind = iup.text {value = "", size = "150x"}
	local nextDropBind = iup.text {value = "", size = "150x"}
	local previousDropBind = iup.text {value = "", size = "150x"}
	scanScreenBind.value = gkini.ReadString (cargolist.config, "scanScreenBind", "")
	scanBind.value = gkini.ReadString (cargolist.config, "scanBind", "")
	nextDropBind.value = gkini.ReadString (cargolist.config, "nextDropBind", "")
	previousDropBind.value = gkini.ReadString (cargolist.config, "previousDropBind", "")
	scanAllBind.value = gkini.ReadString (cargolist.config, "scanAllBind", "")
	
	local optionsTab = iup.pdasubframe_nomargin {
		iup.hbox {
			iup.fill {size = 5},
			iup.vbox {
				iup.fill {size = 25},
				iup.hbox {
					iup.label {title="Target Policy: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor},
					targetingSelection;
				},
				iup.fill {size=10},
				iup.hbox {
					iup.label {title="Active Scan Set: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor},
					activeSetSelection;
				},
				iup.fill {size=10},
				iup.hbox {
					iup.label {title="Sort By: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor},
					sortSelection;
				},
				iup.fill {size=10},
				autoAdvanceToggle,
				iup.fill {size=15},
				iup.hbox {
					iup.label {title="Max Scannable Items: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="175x"},
					maxScannableItems;
				},
				iup.hbox {
					iup.label {title="Max Items to Display: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="175x"},
					maxItemListSize;
				},
				iup.fill {size=50},
				iup.label {title="Binds", font=cargolist.ui.font},
				iup.fill {size=5},
				iup.hbox {
					iup.label {title="Main Screen: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="150x"},
					scanScreenBind;
				},
				iup.hbox {
					iup.label {title="Background Scan: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="150x"},
					scanBind;
				},
				iup.hbox {
					iup.label {title="Scan All Items: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="150x"},
					scanAllBind;
				},
				iup.hbox {
					iup.label {title="Next Drop: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="150x"},
					nextDropBind;
				},
				iup.hbox {
					iup.label {title="Previous Drop: ", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="150x"},
					previousDropBind;
				},
				iup.fill {};
				expand = "YES"
			};
			expand = "YES"
		};
		tabtitle="Options",
		font=cargolist.ui.font,
		expand = "YES"
	}
	
	function optionsTab:SetScanSets (list)
		activeSetSelection [2] = nil
		local set
		local index = 2
		local activeRow = 1
		for set,_ in pairs (list) do
			activeSetSelection [index] = set
			if set == activeSet then
				activeRow = index
			end
			index = index + 1
		end
		activeSetSelection.value = activeRow
		iup.Refresh (activeSetSelection)
	end
	
	function optionsTab:GetTargetPolicy ()
		return tonumber (targetingSelection.value)
	end
	
	function optionsTab:GetActiveSet ()
		return activeSet
	end
	
	function optionsTab:SetActiveSet (set)
		activeSet = set
	end
	
	function optionsTab:GetSortColumn ()
		if targetingSelection.value == 3 then
			return 0
		end
		return tonumber (sortSelection.value - 1)
	end
	
	function optionsTab:IsAutoAdvance ()
		return autoAdvanceToggle.value == "ON"
	end
	
	function optionsTab:GetMaxScannableItems ()
		return tonumber (maxScannableItems.value)
	end
	
	function optionsTab:GetMaxItemListSize ()
		return tonumber (maxItemListSize.value)
	end
	
	function optionsTab:SaveBinds ()
		cargolist.data:SaveBinds ({scanScreenBind.value, scanBind.value, nextDropBind.value, previousDropBind.value, scanAllBind.value})
	end
	
	if cargolist.data.targetPolicy == 3 then
		sortSelection.active = "NO"
	else
		sortSelection.active = "YES"
	end
	
	return optionsTab
end