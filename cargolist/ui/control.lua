--[[
	Options Control UI
]]

dofile ("ui/optionsTab.lua")
dofile ("ui/scanSetsTab.lua")
dofile ("ui/helpTab.lua")

function cargolist.ui:CreatePdaUI ()
	local saveButton = iup.stationbutton { title="Save", font=cargolist.ui.font}
	local cancelButton = iup.stationbutton { title="Cancel", font=cargolist.ui.font}
	
	local optionsTab = cargolist.ui:CreateOptionsTab ()
	optionsTab:SetScanSets (cargolist.data.cargoSets)
	local scanSetsTab = cargolist.ui:CreateScanSetsTab (optionsTab)
	
	local helpTab = cargolist.ui:CreateHelpTab ()
	
	-- Assemble Tab Frame
	local tabframe = iup.roottabtemplate {
		optionsTab,
		scanSetsTab,
		helpTab;
		expand = "YES"
	}
	
	local pda = iup.vbox {
		iup.label {title = "Cargolist Settings v" .. cargolist.version, font=cargolist.ui.font},
		iup.fill {size = 15},
		tabframe,
		iup.fill {},
		iup.hbox {
			iup.fill {},
			saveButton,
			cancelButton; };
	}
	
	function pda:DoSave ()
		cargolist.data.targetPolicy = optionsTab:GetTargetPolicy ()
		cargolist.util:SetActiveSet (optionsTab:GetActiveSet ())
		cargolist.ui.sortColumn = optionsTab:GetSortColumn ()
		cargolist.data.maxScannableItems = optionsTab:GetMaxScannableItems ()
		cargolist.data.maxItemListSize = optionsTab:GetMaxItemListSize ()
		cargolist.data.autoAdvance = optionsTab:IsAutoAdvance ()
		
		-- Copy modified set back into primary set
		local set, data, item
		local sets = scanSetsTab:GetSets ()
		cargolist.data.cargoSets = {}
		for set, data in pairs (sets) do
			cargolist.data.cargoSets [set] = {}
			cargolist.data.cargoSets [set].type = data.type
			cargolist.data.cargoSets [set].items = {}
			for _, item in ipairs (data.items) do
				table.insert (cargolist.data.cargoSets [set].items, item)
			end
			cargolist.data.cargoSets [set].bind = data.bind
			cargolist.data.cargoSets [set].alias = data.alias
		end
		cargolist.data:Unbind (scanSetsTab:GetDeleteList ())
		optionsTab:SaveBinds ()
		cargolist.data:SaveOptions ()
	end
	
	function pda:DoCancel ()
		cargolist.data.scanner = nil
		cargolist.util:SetLocks (false)
	end
	
	function pda:GetSaveButton ()
		return saveButton
	end
	
	function pda:GetCancelButton ()
		return cancelButton
	end
	
	function saveButton.action ()
		pda:DoSave ()
	end
	
	function cancelButton.action ()
		pda:DoCancel ()
	end
	
	return pda
end

function cargolist.ui:CreateSettingsUI ()
	cargolist.data.scanner = nil
	
	local pda = cargolist.ui:CreatePdaUI ();
	
	local frame = iup.dialog {
		iup.pdarootframe {
			pda;
		},
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
		defaultesc = pda:GetCancelButton ()
	}
	
	pda:GetSaveButton ().action = function ()
		pda:DoSave ()
		HideDialog (frame)
		frame.active = "YES"
	end
	
	pda:GetCancelButton ().action = function ()
		pda:DoCancel ()
		HideDialog (frame)
		frame.active = "YES"
	end
	
	return frame
end