--[[
	Help Tab screen for Cargolist
]]

function cargolist.ui:CreateHelpTab ()
	local text = "Screens:\n\n" ..
		"Settings (/cargolist options):\n" ..
		"Options Tab\n" ..
		"Target Policy - Defines how CL will target drops once scanned.\n\tThere are 3 defined right now: Pre-scan, Initial Scan Set Item, and One Shot.\n\t" ..
		"Pre-scan will retarget whatever your original target was before scanning.\n\tInitial Scan Set Item will automatically target the first item in a scanned set\n\t" ..
		"dependent on CL's current Sort Policy.  (i.e. sorted by Name or by Distance)\n " ..
		"\tOne Shot will scan all drops in range until it finds one in the current scan set,\n\tadding that drop to its item list and stopping.  " ..
		"Repeating this method enough will\n\trecreate the same list as if performing a complete sector scan using\n\tanother target policy.\n" ..
		"Active Set - This is the currently active scan set CL will compare drops against while\n\tscanning.  This is always the active set for all scanning purposes until changed.\n" ..
		"Sort Policy - The main scan screen has always been able to sort by Name or by Distance.\n\tThis just makes it official without having to bring up the display screen first.\n\n" ..
		"Scan Set Tab\n" ..
		"This tab allows for the maintenance of scan sets, defined groups of cargo drops to be searched for and included in the final list during any scan.\n\n" ..
		"Scan Sets represent a subset of all the cargo drops present within visible radar range of the player's ship.  Setting an active scan set means Cargolist will scan and include " ..
		"any drop item which contains a substring matching a line in the active set.\n\n" ..
		"To create a new Set:\n" ..
		"\t1 .Open the Options screen\n" ..
		"\t2. Open the Scan Set tab\n" ..
		"\t3. Enter a new Scan Set name and click 'Create New' to create a blank set.\n\t\tThe active sets drop down in the options screen\n\t\tis automatically updated with the new list.\n" ..
		"\t4. Type in each cargo item you want CL to scan for or select a recently picked\n\t\tup cargo from the Pickups dropdown and click 'Add'\n" ..
		"\t5. Remove any items from the list by clicking on it and clicking 'Remove'\n" ..
		"\t6. Remove all items in the list with 'Remove All'\n" ..
		"\t7. If you really really don't like a set, you can click 'Remove Set' to remove it\n\t\tfrom the selection list.\n\t\tAll dependent drop downs are automatically updated.\n" ..
		"\t8. Once you're done, you can click 'Save' to save all your work, or click 'Cancel'\n\t\tand none of your changes will be saved.\n\n" ..
		"Item Display / Scan (/cargolist):\n" ..
		"This display is used for viewing the results of any cargo scan and for selecting a new active scan set as well as performing scans directly through the display.\n\n" ..
		"Commands (/cargolist help):\n" ..
		"\t/cargolist - Brings up the main scan screen. You can select the active scan set from\n\t\there before clicking the Refresh button to scan all cargo drops in radar\n\t\trange.\n" ..
		"\t/cargolist options - Brings up the options screen. Here you can select the active\n\t\tscan set, as well as target and sort policies, and define or edit scan sets.\n" ..
		"\t/cargolist scan [setName] - Performs a background scan against the current active\n\t\tscan set, sorting the data and targeting items based on the current targeting\n\t\tpolicy without bringing up the scan screen. If the scan screen\n\t\tis opened after a background scan is made, the targeted item\n\t\tis highlighted in the scan screen.\n" ..
		"\t/DropScan - Runs a background scan against the current active set." ..
		"\t/NextDropItem - Loops forward through scanned items whether in the main\n\t\tscan screen or if the list were generated in a background scan.\n" ..
		"\t/PreviousDropItem - Loops backwards through scanned items in the same way\n\t\tas /NextDropItem."

	local helpTab = iup.pdasubframe_nomargin {
		iup.hbox {
			iup.fill {size = 5},
			iup.vbox {
				iup.fill {size = 5},
				iup.label {title="Help", font=cargolist.ui.font, fgcolor=cargolist.ui.fgcolor, expand="HORIZONTAL"},
				iup.fill {size = 10},
				iup.pdasubmultiline {
					value = text,
					scrollbar = "YES",
					expand = "YES"
				},
				iup.fill {};
				expand = "YES"
			},
			iup.fill {size = 5};
			expand = "YES"
		};
		tabtitle="Help",
		font=cargolist.ui.fontSmall,
		expand = "YES"
	}
	
	return helpTab
end