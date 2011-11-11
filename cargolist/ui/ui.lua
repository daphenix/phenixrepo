--[[
	GUI Elements for Cargolist
]]

cargolist.ui = {}
cargolist.ui.font = 14 * (gkinterface.GetYResolution () / 600)
cargolist.ui.fontSmall = 10 * (gkinterface.GetYResolution () / 600)
cargolist.ui.fgcolor = "200 200 50"
dofile ("ui/control.lua")
cargolist.ui.sortColumn = 1
cargolist.ui.controlWidth = 60

function cargolist.ui:GetOnOffSetting (flag)
	if (flag) then
		return "ON"
	else
		return "OFF"
	end
end

function cargolist.ui:CreateUI ()
	local refreshButton = iup.stationbutton { title="Refresh", font=cargolist.ui.font}
	local closeButton = iup.stationbutton { title="Close", font=cargolist.ui.font}
	
	-- Active Set Selection
	local activeSetSelection = iup.pdasublist  {
		font = cargolist.ui.font,
		dropdown = "YES",
		visible_items = 10,
		expand = "HORIZONTAL"
	}
	activeSetSelection [1] = "All"
	local set
	local index = 2
	for set,_ in pairs (cargolist.data.cargoSets) do
		activeSetSelection [index] = set
		if set == cargolist.data.activeSet then
			activeSetSelection.value = index
		end
		index = index + 1
	end
	
	function activeSetSelection:action (text, index, state)
		if state == 1 then
			cargolist.util:SetActiveSet (text)
			cargolist.data:SaveOptions ()
		end
	end
	
	-- Build Cargo Display Matrix
	local l
	local matrix = iup.pdasubsubmatrix {
		numcol = 4,
		numlin = 0,
		numlin_visible = 10,
		heightdef = 15,
		expand = "YES",
		font = cargolist.ui.font,
		bgcolor = "255 10 10 10 *",
		redraw = "ALL",
		width1 = 250,
		width2 = 100,
		width3 = 0,
		width4 = 0
	}
	
	-- Set Headers
	matrix:setcell (0, 1, "Cargo")
	matrix:setcell (0, 2, "Distance")
	
	local pda = iup.pdarootframe {
		iup.vbox {
			iup.hbox {
				iup.fill {size=5},
				iup.label {title="Set:", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor},
				iup.fill {size=10},
				activeSetSelection;
			},
			matrix,
			iup.fill {},
			iup.hbox {
				iup.fill {},
				refreshButton,
				closeButton; };
		};
	}
	local frame = iup.dialog {
		pda,
	    title = "Cargo Scan",
	    font = cargolist.ui.font,
		border = 'YES',
		topmost = 'YES',
		resize = 'YES',
		maxbox = 'NO',
		minbox = 'NO',
		modal = 'NO',
		fullscreen = 'NO',
		expand = 'YES',
		active = 'NO',
		menubox = 'NO',
		bgcolor = "255 10 10 10 *",
		defaultenter = refreshButton,
		defaultesc = closeButton
	}
	
	function frame:SetSelectedMatrixRow (row)
		for l=1,matrix.numlin do
			if l == row then
				matrix ["bgcolor"..l..":*"] = "255 150 150 150 *"
			else
				matrix ["bgcolor"..l..":*"] = "255 10 10 10 *"
			end
		end
	end
	
	function frame:ClearData ()
		local i
		for i=1, tonumber (matrix.numlin) do
			matrix.dellin = 1
		end
	end
	
	function frame:ReloadData ()
		local list = cargolist.data.itemList
		cargolist.util:SortDrops (list)
		frame:ClearData ()
		local row = 0
		matrix.heightdef = 15
		matrix.redraw = "ALL"
		local item, v
		for _,v in ipairs (list) do
			matrix.addlin = row
			matrix.font = cargolist.ui.font
			row = row + 1
			matrix:setcell (row, 1, tostring (v.name))
			matrix:setcell (row, 2, tostring (math.floor (v.dist)) .. "m  ")
			matrix:setcell (row, 3, tostring (v.id))
			matrix:setcell (row, 4, tostring (v.type))
			matrix.alignment1 = "ALEFT"
			matrix.alignment2 = "ARIGHT"
			matrix.width1 = 250
			matrix.width2 = 100
			matrix.width3 = 0
			matrix.width4 = 0
			cargolist:Yield ()
		end
		matrix.numlin = row
		if #list > 0 then
			frame:SetSelectedMatrixRow (cargolist.data.currentDrop)
		end
		iup.Refresh (frame)
	end
	
	matrix.click_cb = function (self, row, col)
		-- Set all bgcolors
		cargolist.data.currentDrop = row
		frame:SetSelectedMatrixRow (row)
		
		if row == 0 then
			cargolist.ui.sortColumn = col
			frame:ReloadData ()
		else
			-- Set Target to row element
			local id = cargolist.data.itemList [row].id
			local type = cargolist.data.itemList [row].type
			radar.SetRadarSelection (type, id)
		end
	end
	
	refreshButton.action = function ()
		-- Scan for all cargo and reload matrix
		if not cargolist.data.scanner then
			cargolist.data.scanner = coroutine.create (function ()
				print ("\12700ff00Scanning...\127o")
				cargolist.util:ScanCargo ()
				frame:ReloadData ()
				print ("\12700ff00Done\127o")
				cargolist.util:SetLocks (false)
				cargolist:KillThread ()
			end)
			return cargolist:RunScan ()
		end
	end

	closeButton.action = function ()
		HideDialog (frame)
		frame.active = "NO"
		gkini.WriteInt (cargolist.config, "showXPos", frame.x)
		gkini.WriteInt (cargolist.config, "showYPos", frame.y)
		cargolist.data.scanner = nil
		cargolist.util:SetLocks (false)
	end
	
	-- Display dialog at stored coordinates
	local x = gkini.ReadInt (cargolist.config, "showXPos", iup.CENTER)
	local y = gkini.ReadInt (cargolist.config, "showYPos", iup.CENTER)
	ShowDialog (frame, x, y)
	frame:ReloadData ()
	frame.active = "YES"
	
	return frame
end

function cargolist.ui:CreateAlertUI (msg)
	local okButton = iup.stationbutton {title="Ok", focus="YES"}
	
	local pda = iup.pdasubsubframebg {
		iup.hbox {
			iup.fill {size=10},
			iup.vbox {
				iup.fill {size=5},
				iup.label {title=msg, fgcolor=cargolist.ui.fgcolor, alignment="ACENTER", expand="HORIZONTAL"},
				iup.fill {size=15},
				iup.hbox {
					iup.fill {},
					okButton;
					expand="HORIZONTAL"
				},
				iup.fill {size=5};
				expand="YES"
			},
			iup.fill {size=10};
			expand="YES"
		};
		expand="YES"
	}
	
	local frame = iup.dialog {
		pda,
	    font = cargolist.ui.font,
		border = 'YES',
		topmost = 'YES',
		resize = 'YES',
		maxbox = 'NO',
		minbox = 'NO',
		modal = 'YES',
		fullscreen = 'NO',
		expand = "YES",
		active = 'YES',
		menubox = 'NO',
		bgcolor = "255 10 10 10 *",
		defaultesc = okButton,
		defaultenter = okButton
	}
	
	okButton.action = function ()
		HideDialog (frame)
		frame.active = "NO"
	end
	
	return frame
end