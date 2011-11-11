--[[
	Scan Sets Tab screen for Cargolist
]]

function cargolist.ui:CreateScanSetsTab (optionsTab)
	local createSetButton = iup.stationbutton {title="Create Set", font=cargolist.ui.font}
	local removeSetButton = iup.stationbutton {title="Remove Set", font=cargolist.ui.font, active="NO"}
	local addButton = iup.stationbutton { title="Add", font=cargolist.ui.font, expand="HORIZONTAL", active="NO"}
	local removeButton = iup.stationbutton { title="Remove", font=cargolist.ui.font, expand="HORIZONTAL", active="NO"}
	local removeAllButton = iup.stationbutton { title="Remove All", font=cargolist.ui.font, expand="HORIZONTAL", active="NO"}
	local editSet = " "
	local selectedRow = 0
	local set, data, item
	local deleteList = {}
	local sets = {}
	for set, data in pairs (cargolist.data.cargoSets) do
		sets [set] = {}
		sets [set].type = data.type
		sets [set].items = {}
		for _, item in ipairs (data.items) do
			table.insert (sets [set].items, item)
		end
		sets [set].bind = data.bind or ""
		sets [set].alias = (data.alias or set):gsub (" ", "_")
	end
	
	local name = iup.text {value = "", expand = "HORIZONTAL"}
	local cargo = iup.text {value = "", expand = "HORIZONTAL"}
	local bind = iup.text {value = "", expand = "HORIZONTAL"}
	
	local buttonPanel = iup.vbox {
		addButton,
		removeButton,
		iup.fill {size=15},
		removeAllButton,
		iup.fill {},
		removeSetButton;
	}
	
	local setSelection = iup.pdasublist  {
		font = cargolist.ui.font,
		dropdown = "YES",
		visible_items = 10,
		expand = "HORIZONTAL"
	}
	setSelection [1] = " "
	
	function setSelection:SetList ()
		setSelection [2] = nil
		local row = 2
		for set,_ in pairs (sets) do
			setSelection [row] = set
			row = row + 1
		end
	end
	setSelection:SetList ()
	
	local pickupSelection = iup.pdasublist {
		font = cargolist.ui.font,
		dropdown = "YES",
		visible_items = 10,
		expand = "HORIZONTAL"
	}
	pickupSelection [1] = " "
	
	function pickupSelection:SetList ()
		pickupSelection [2] = nil
		local row = 2
		for item,_ in pairs (cargolist.data.pickups) do
			pickupSelection [row] = item
			row = row + 1
		end
	end
	pickupSelection:SetList ()

	local matrix = iup.pdasubmatrix {
		numcol = 1,
		numlin = 1,
		numlin_visible = 10,
		heightdef = 15,
		expand = "YES",
		scrollbar = "YES",
		usetitlewidth = "YES",
		widthdef = 120,
		font = cargolist.ui.font,
		bgcolor = "255 10 10 10 *"
	}
	
	-- Set Headers
	matrix:setcell (0, 1, "Cargo Name")
	matrix:setcell (1, 1, string.rep (" ", cargolist.ui.controlWidth))
	matrix.numlin = 0
	
	matrix.click_cb = function (self, row, col)
		-- Set all bgcolors
		for l=1,self.numlin do
			if l == row then
				self ["bgcolor"..l..":*"] = "255 150 150 150 *"
			else
				self ["bgcolor"..l..":*"] = "255 10 10 10 *"
			end
		end
		
		selectedRow = row
		cargo.value = sets [editSet].items [row]
		return buttonPanel:SetButtonState ()
	end
	
	local scanSetsTab = iup.pdasubframe_nomargin {
		iup.hbox {
			iup.fill {size = 5},
			iup.vbox {
				iup.fill {size = 5},
				iup.hbox {
					createSetButton,
					iup.fill {size = 5},
					name;
				},
				iup.fill {size=5},
				iup.hbox {
					iup.label {title="Set:", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="75x"},
					iup.fill {size = 5},
					setSelection;
				},
				iup.fill {size = 5},
				iup.hbox {
					iup.label {title="Pickups:", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="75x"},
					iup.fill {size = 5},
					pickupSelection;
				},
				iup.fill {size=5},
				iup.hbox {
					iup.label {title="Cargo:", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="75x"},
					iup.fill {size = 5},
					cargo;
				},
				iup.fill {size=5},
				iup.hbox {
					iup.label {title="Bind:", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, size="75x"},
					iup.fill {size = 5},
					bind;
				},
				iup.fill {size = 15},
				iup.hbox {
					matrix,
					buttonPanel;
				},
				iup.fill {};
				expand = "YES"
			};
			expand = "YES"
		};
		tabtitle="Scan Sets",
		font=cargolist.ui.font,
		expand = "YES"
	}
	
	function scanSetsTab:GetSets ()
		if sets [editSet] then
			sets [editSet].bind = bind.value
		end
		return sets
	end
	
	function scanSetsTab:GetDeleteList ()
		return deleteList
	end

	function scanSetsTab:ClearData ()
		local i
		for i=1, tonumber (matrix.numlin) do
			matrix.dellin = 1
		end
		bind.value = ""
	end
	
	function scanSetsTab:ReloadData (setName)
		scanSetsTab:ClearData ()
		local k, v
		local row = 0
		matrix.expand = "YES"
		matrix.alignment1 = "ALEFT"
		matrix.heightdef = 15
		matrix.widthdef = cargolist.ui.controlWidth
		if setName ~= " " then
			--for _,v in ipairs (scanSetsTab:GetSets () [setName].items) do
			for _,v in ipairs (sets [setName].items) do
				matrix.addlin = row
				matrix.font = cargolist.ui.font
				row = row + 1
				matrix:setcell (row, 1, v)
			end
		end
		matrix.numlin = row
		matrix.redraw = "ALL"
		if sets [setName] then
			bind.value = sets [setName].bind
		end
		iup.Refresh (matrix)
	end
	
	function buttonPanel:SetButtonState ()
		addButton.active = "NO"
		removeButton.active = "NO"
		removeAllButton.active = "NO"
		removeSetButton.active = "NO"
		if editSet ~= " " then
			addButton.active = "YES"
		end
		if selectedRow > 0 then
			removeButton.active = "YES"
		end
		if editSet ~= " " and sets [editSet] and #sets [editSet] > 0 then
			removeAllButton.active = "YES"
		end
		if editSet ~= " " then
			removeSetButton.active = "YES"
		end
	end
	
	function createSetButton:action ()
		if name.value:len () > 0 then
			editSet = name.value
			name.value = ""
		end
		if not sets [editSet] then
			sets [editSet] = {type = "Name", items = {}, bind = "", alias = string.gsub (editSet, " ", "_")}
		end
		selectedRow = 0
		setSelection:SetList ()
		local k
		local row = 2
		for k,_ in pairs (sets) do
			if k == editSet then
				setSelection.value = row
			else
				row = row + 1
			end
		end
		scanSetsTab:ReloadData (editSet)
		optionsTab:SetScanSets (sets)
		return buttonPanel:SetButtonState ()
	end
	
	function removeSetButton:action ()
		if sets [editSet] and optionsTab:GetActiveSet () == editSet then
			optionsTab:SetActiveSet ("All")
		end
		table.insert (deleteList, sets [editSet])
		sets [editSet] = nil
		editSet = " "
		setSelection:SetList ()
		setSelection.value = 0
		scanSetsTab:ReloadData (editSet)
		optionsTab:SetScanSets (sets)
	end
	
	function setSelection:action (text, index, state)
		if state == 1 then
			-- Save previous bind if set
			if editSet ~= " " then sets [editSet].bind = bind.value end
			editSet = text
			selectedRow = 0
			scanSetsTab:ReloadData (editSet)
		end
		return buttonPanel:SetButtonState ()
	end
	
	function pickupSelection:action (text, index, state)
		if index > 1 then
			cargo.value = text
		end
	end
	
	function addButton:action ()
		if cargo.value:len () > 0 then
			selectedRow = 0
			table.insert (sets [editSet].items, cargo.value)
			scanSetsTab:ReloadData (editSet)
		end
		cargo.value = ""
		return buttonPanel:SetButtonState ()
	end
	
	function removeButton:action ()
		local last = #sets [editSet].items
		local index = selectedRow
		while index < last do
			sets [editSet].items [index] = sets [editSet].items [index+1]
			index = index + 1
		end
		sets [editSet].items[last] = nil
		selectedRow = 0
		scanSetsTab:ReloadData (editSet)
		cargo.value = ""
		return buttonPanel:SetButtonState ()
	end
	
	function removeAllButton:action ()
		sets [editSet].items = {}
		scanSetsTab:ReloadData (editSet)
		return buttonPanel:SetButtonState ()
	end
	
	return scanSetsTab
end