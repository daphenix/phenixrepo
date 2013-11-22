function CreateStationHelpMenu()
	local cancelbutton = iup.stationbutton{title="Close",
		action=function()
			return iup.CLOSE
		end}

	local text = iup.stationhighopacitysubmultiline{readonly="YES", expand="YES", value=""}

	local dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.vbox{
						text,
						iup.stationhighopacityframebg{
						iup.hbox{
							iup.fill{},
							cancelbutton,
							iup.fill{},
						},
						},
					},
					size="THREEQUARTERxTHREEQUARTER",
					expand="NO",
				},
				iup.fill{},
			},
			iup.fill{},
		},
		topmost = "YES",
		defaultesc = cancelbutton,
		border="NO",
		resize="NO",
		menubox="NO",
		bgcolor="0 0 0 128 *",
		fullscreen = "YES",
	}
	function dlg:show_cb()
		text.caret = 0
	end
	function dlg:Open(helptext)
		text.value = helptext
		text.scroll = "TOP"
		PopupDialog(dlg, iup.CENTER, iup.CENTER)
	end
	return dlg
end

StationHelpDialog = CreateStationHelpMenu()
StationHelpDialog:map()


function HelpSellAction()
	StationHelpDialog:Open(
[[On this window you can sell ships, ship addons and commodities.
The menu on the left displays the name, a short description, and the selling price of the objects listed. Commodities will have an additional number under the sell value that indicates how many crates of the commodity you have in the station storage container. The panel on the left displays detailed information about the selected object, such as its mass, volume in cubic units, and a more specific description of the object in question. Commodities display a short description and the mass and volume of one crate. Ship addons display the specifications of the object in question; mass, energy usage, velocity and range are all common values to see. Ships display a short blurb about the origin of the selected ship as well as a green message stating that the selected ship is the one currently in use and/or that the ship contains something, be it cargo or other addons.
To sell an object, click on it and then move your cursor down to the area just above the top of the chat panel. If you are selling a commodity and you have more than one crate, should you wish to sell all of them you can do so by pressing the "Max" button then the "Sell" button. If you have another specific number you would like to sell, simply click in the text field and enter the number, then click on the "Sell" button. The "Max" button does not work with ships or ship addons, so you must click on each object individually and press the "Sell" button. When you make a sale, you will be notified in your chat panel of the number of objects you sold, and what the total sale was.]])
end


function HelpShipAmmo()
	StationHelpDialog:Open(
[[This is where you can replenish your ammunition-based weapons.
The main window lists the ships you have at the current station, your active ship first, that contain ammunition-based weaponry. These weapons are listed with the ship carrying them with the current number of rounds loaded and the maximum capacity.
The three buttons on the bottom of the panel do exactly what they say: purchase one round of ammo for the selected weapon, fill the selected weapon to capacity, and fill all ammunition-based weapons on your active ship. When you have a weapon selected, the first button displays the price per round of ammunition, the second displays the cost to replenish just that weapon, and the third the whole ship.]])
end

function HelpShipEquip()
	StationHelpDialog:Open(
[[This is where you can add and remove weapons, power cells and other addons to/from your ship.
The left panel shows a top-down image of your active ship along with where the ports are located. Small ports contain a brown square, large ports contain a green square, and power cell ports contain a purple square. The top-right contains a list of purchased addons located at this station. The bottom right panel shows information on the addon currently in the selected port. (You can also hover your mouse over the port in question to get the name of the addon equipped there.)
To equip an item, select first either the port location on the ship or an addon in the top-right panel, then the other. If the port you want to put an addon into glows red, you are unable to fit that addon into that port. Finally, click "Equip".
To unequip an item, click on the port on the ship that you want to empty, then on the "Unequip" button. Should you want to fully empty your ship of equipment, click the "Unequip All" button.
Alternatively, you can click and drag items from the list to the ship port to equip them, and from the ship port to the list to unequip them.]])
end

function HelpShipGroup()
	StationHelpDialog:Open(
[[This is where you set what weapons are in your primary, secondary and tertiary groupings.
To change the weapon grouping on a ship, first select the group you would like to edit. The addon ports activated by that group will be highlighted. Click on them to remove them from the group, or on unhighlighted ones to add them to the group. Last, hit the "Apply" button. No changes you have made will take place unless you have clicked the "Apply" button.]])
end

function HelpStationWelcome()
	StationHelpDialog:Open(
[[This is where you can learn about the station you are located in.
The left panel displays a general welcome message. The right panel has frequently used actions.
On the bottom, the large button labeled "Set Home Station" provides you with the option to set this station as the place you respawn when you die. Click on it to set this station as your respawn location. You will recieve a notification in the chat window confirming this action.]])
end

function HelpStationAddonEquip()
	StationHelpDialog:Open(
[[Addon Equipping

This interface is used to equip addons from your local station inventory onto your ship. "Local station inventory" means equipment that has been purchased or offloaded onto this particular station. Begin by selecting a port on your ship (the left-side display). There are three major types of ports: Small, Large, and Power Cell. The Small and Large ports are generic and may be used by any type of device that is designed for a "Small" or "Large" port interface. The Power cell port is exclusive to power cell (aka battery) use.

After selecting a port on your ship, you may then choose addons from the available list on the right-hand side. Items that are in red are not compatible with the port you currently have selected. Items not in red can be double-clicked to be loaded onto the selected port, or you can click the addon and then the Equip button. You can also drag and drop items from the list into the appropriate ports to equip them to your ship.

Attaching addons to your ship increases the mass of the ship. You can see the mass and other addon stats by single-clicking on the item in the list, or if already loaded, clicking on the port with the equipped addon. Equipping addons only increases the total mass of the ship, you don't have to be concerned about balancing the locations of equipped ports. Mass does, however, have a dramatic impact on the flight performance and maneuverability of a given ship, so be aware of that and other stats when purchasing equipment.

Once you have completed loading the addons onto your ship, go to the Group interface to define how those addons should be triggered while in flight.


Power Distribution Grid

Each ship has a power distribution grid, used to provide energy to the equipped addons. The power for this grid is supplied by the powercell. Each powercell has a certain maximum "Grid Power" that it can provide, and each addon has a specific "Grid Usage". For instance, if a given powercell has a "Grid Power" of 20, and your selected addons have a "Usage" of 4, then you could only equip 5 of the addons onto a ship using that powercell. If you selected a powercell that provided more "Grid Power", then more addons could be equipped. Similarly, if you chose addons with less "Grid Usage", then you would also have more power to spare. If you have too much Usage for the available Power, none of your addons will function.

For the most part, Grid Power does not become an issue until the later stages of the game, when highly powerful addons and unusual ship configurations become available.]])
end

function HelpStationAddonGroups()
	StationHelpDialog:Open(
[[Addon Grouping

This is the Group interface. Here you can define how addons are triggered while you're flying. Vendetta Online has three major triggers: Primary, Secondary and Tertiary. By default, Primary is bound to the left mouse button, Secondary is bound to the right mouse button and "c", Tertiary to the middle mouse button and "v" (you can redefine all these to other keys or joysticks under Options->Controls). From here you can set any or all of your ship's ports to "fire" on any of the triggers. In addition, you have six possible "Groups" which allow you to switch between separate definitions. The "Key" buttons display the bound key after them, usually 1 through 6. The default group is always the first one (usually "Key 1"). You must click Apply to save any changes to a Key, each Key must be Applied individually.

Example: Your ship has an energy weapon, two rocket weapons, and a mining beam. You only have three major "trigger" buttons, so you could set your default group (Key 1) to fire the energy weapon with Primary, both rockets with Secondary, and the mining beam with Tertiary. That would give you the minimum needed to use all your loaded equipment in flight.
However, you might want, under certain circumstances, to be able to trigger the rockets individually rather than together. Thus, under the second group (Key 2) you would define your energy weapon as Primary, first rocket as Secondary, and second rocket as Tertiary. Then, while in-flight, you could hit the "2" key to switch to that configuration from your default, perhaps allowing you to defend yourself against a more threatening enemy. Then you could later hit "1" again to allow you to use your mining beam with the tertiary button, instead of the rocket.


Power Distribution Grid

Each ship has a power distribution grid, used to provide energy to the equipped addons. The power for this grid is supplied by the powercell. Each powercell has a certain maximum "Grid Power" that it can provide, and each addon has a specific "Grid Usage". For instance, if a given powercell has a "Grid Power" of 20, and your selected addons have a "Usage" of 4, then you could only equip 5 of the addons onto a ship using that powercell. If you selected a powercell that provided more "Grid Power", then more addons could be equipped. Similarly, if you chose addons with less "Grid Usage", then you would also have more power to spare. If you have too much Usage for the available Power, none of your addons will function.

For the most part, Grid Power does not become an issue until the later stages of the game, when highly powerful addons and unusual ship configurations become available.]])
end

-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------


function HelpSellCommodities()
	StationHelpDialog:Open(
[[On this window you can sell commodities.
The menu on the left displays the name, a short description, and the selling price of the commodities listed. Commodities will have a number under the sell value that indicates how many crates of the commodity you have in the station storage container. The panel on the left displays detailed information about the selected object.
The commodities for sale are either in the station storage or your ship cargo.
To sell a commodity, click on it. If you have more than one crate to sell click in the text field and enter the number, then click on the "Sell" button. The "Max" button will sell all crates of that commodity.  When you make a sale, you will be notified in your chat panel of the number of objects you sold, and what the total sale was.]])
end

function HelpSellAddons()
	StationHelpDialog:Open(
[[On this window you can sell weapons and ships.
The menu on the left displays the name, a short description, and the selling price of the addons listed.  Ships that have cargo or addons equiped will be labeled "Not Empty" but the entire ship and contents can be sold at one time.
Individual equipped Addons in have to be unequipped before they can be sold, so only addons in the station storage or ship cargo are visible.
To sell an addon or ship, select it and then click on the "Sell" button. When you make a sale, you will be notified in your chat panel of the number of objects you sold, and what the total sale was.]])
end

function HelpCommoditiesAction()
	StationHelpDialog:Open(
[[Here you can purchase trade goods.
On the left, each commodity has a small icon and the cost to buy one crate. On the right, you can get detailed information on a commodity. 
To buy a specific number of crates, first click on the icon of the commodity next type in the number in the text field, then click "Purchase". If you click on the "Max" button the text field will automatically display the maximum number of crates of that commodity that your ship can currently hold. Clicking on the "Purchase" button without entering a number will purchase a single crate of the selected commodity.
What you buy will automatically be placed into your ship's hold as long as it will fit. After that, purchases will be placed in the station's storage container.]])
end

function HelpSmallAddonsAction()
	StationHelpDialog:Open(
[[You can purchase small-port addons for your ship here.
Small-port addons include a large variety of energy weapons, rocket launchers and homing missiles as well as mineral scanners and some mining beams.
On the left, each addon is accompanied by a small icon, a quick description of the addon and the cost. On the right, you can get detailed information about an addon. 
To buy a specific number of the addon, select the addon, then click in the text field and type in the number, next click "Purchase". If you click on the "Max" button with an addon selected, the text field will automatically display the maximum number of that addon that your ship can currently hold. You can then click on the "Purchase" button to buy those addons. Clicking on the "Purchase" button without entering a number will purchase a single addon.
What you buy will automatically be equiped into your ship's addon ports as long as it will fit. After that, purchases will be placed in the station's storage container.]])
end

function HelpLargeAddonsAction()
	StationHelpDialog:Open(
[[You can purchase large-port addons for your ship here.
Large-port addons include various energy weapons, rocket and mine launchers, homing missiles as well as a variety of mining beams.
On the left, each addon is accompanied by a small icon, a quick description of the addon and the cost. On the right, you can get detailed information about an addon. 
To buy a specific number of the addon, select the addon, then click in the text field and type in the number, next click "Purchase". If you click on the "Max" button with an addon selected, the text field will automatically display the maximum number of that addon that your ship can currently hold. You can then click on the "Purchase" button to buy those addons. Clicking on the "Purchase" button without entering a number will purchase a single addon.
What you buy will automatically be equipped into your ship's addon ports as long as it will fit. After that, purchases will be placed in the station's storage container.]])
end

function HelpOtherAddonsAction()
	StationHelpDialog:Open(
[[You can purchase other addons for your ship here.
These addons only include batteries at the moment.
On the left, each addon is accompanied by a small icon, a quick description of the addon and the cost. On the right, you can get detailed information about an addon. 
To buy a specific number of the addon, select the addon, then click in the text field and type in the number, next click "Purchase". If you click on the "Max" button with an addon selected, the text field will automatically display the maximum number of that addon that your ship can currently hold. You can then click on the "Purchase" button to buy those addons. Clicking on the "Purchase" button without entering a number will purchase a single addon.
What you buy will automatically be equipped into your ship's addon ports as long as it will fit. After that, purchases will be placed in the station's storage container.]])
end

function HelpShipCargo()
	StationHelpDialog:Open(
[[This is where you manage the cargo on your ship and in the station's storage container.
The left panel lists what cargo is in your ship with the number of crates and the going price per crate. The right pannel is a list of what is in the station storage container and the number of crates.
You can move cargo to and from your active ship by selecting commodities on one side of the window and then clicking on the appropriate button and/or typing in a number of crates in the appropriate text field.
You can also unload everything in your hold by clicking on the "Unload All" button, or sell everything in your hold by clicking the "Unload and Sell All" button.]])
end

function HelpShipPurchase()
	StationHelpDialog:Open(
[[This is where you buy a new ship.
On the left is a view of the selected ship. You can enlarge the image by clicking on the small magnifying glass in the top-left corner. The panel on the top-right lists all the ships that the station currently has available for you to buy along with the purchase price. Keep in mind that your license levels and faction standing with the owners of the station help determine what is available. The lower-right panel displays statistics about the selected ship and a short blurb about the origin of the ship.
Under the left panel is a 256-color swatch that you can click on to change the color of the highlights on the selected ship. To the right, the "Purchase Ship" button will buy the current ship with the color you had selected. The "Purchase Preset" buttons require you to have defined preset ship layouts in the "Your Ships" tab, but they do exactly what they say they do: they buy a ship that is a duplicate of whatever you have set to that preset. Presets will display the name of the ship hull used when they were set, e.g., "Vulture MkIII" or "TPG Raptor".]])
end

function HelpShipStatus()
	StationHelpDialog:Open(
[[This is where you can check out the health of your ship and replenish your ammunition-based weapons.
The upper right window displays the addons you have connected to your active ship and how much ammunition they have left. 
The three buttons under the addon list purchase one round of ammo for the selected weapon, fill the selected weapon to capacity, or fill all ammunition-based weapons on your active ship. When you have a weapon selected, the first button displays the price per round of ammunition, the second displays the cost to replenish just that weapon, and the third the whole ship.]])
end

function HelpShipSelect()
	StationHelpDialog:Open(
[[This is where you can view a list of the ships you have at this station as well as set universal ship purchase presets.
On the left there is a rotating image of your active ship. You may enlarge this by clicking on the magnifying glass in the top-left corner or look at another ship by clicking on the one you want (or one of its addons) in the menu on the right. To make the viewed ship your active ship, click on the "Select Ship" button.
To set a purchase preset, click on one of the ships in the list and then click the preset number you wish to save it to. You can purchase these presets either from the "Purchase Ship" tab or when you die. The name of the ship hull selected will be used as the label for the preset. Be careful, though! What you might have set as a preset at one station may not be purchasable at another! (Not all stations sell the same addons or even ships!)]])
end

function HelpCharStats()
	StationHelpDialog:Open(
[[This is where you can view various numerical statistics about your character.
The left panel shows your name and alignment, kills and deaths, missions completed, total number of credits available, your license levels down to the individual experience points, basic guild status, information regarding medals and awards, and your duel rating.
The right panel is currently not being used.]])
end

function HelpCharFaction()
	StationHelpDialog:Open(
[[This is where you can see how much a particular faction likes you.
On the left side there is a list of all the factions in the game, each accompanied by a colored bar. The more full the bar, the more the faction likes you. You can hover your mouse over the bar to get a numerical value for your standing with that faction. Here is a quick guide to the different standing levels, from highest to lowest:
- Pillar of Society (yellow) +1000
- Admire (green) +601 to +999
- Respect (light green) +201 to +600
- Neutral (grey) -199 to +200
- Disliked (light red) -600 to -200
- Hated (red) -999 to -601
- Kill on Sight (empty) -1000
The right-hand panel will display background information on the individual factions.]])
end

function HelpCharAccom()
	StationHelpDialog:Open(
[[This is where you can view the medals and awards you have been given.
On the left, there is a list of badges that you have been given. If you hover your cursor over a badge, you can see the name of it. Clicking on the badge will display its name in the text area to the right, which eventually should be used to give more detailed information about the badge.
Note that some badges are impossible for some players to receive, and that some are relatively easy to get.]])
end

function HelpCharGuild()
	StationHelpDialog:Open(
[[This is where you can view information about your guild, should you be a member of one.
The left panel displays the name of your guild (but not currently your rank).
Currently, neither panel shows much information, but it is foreseeable that the left panel might show a guild roster and the right panel the guild description and possibly the logo.]])
end

function HelpIgnore()
	StationHelpDialog:Open(
[[This is where you can manage your ignore lists.
Select a username then choose a duration: Always, untill you logout or a set time period.
]])
end

function HelpFriendKeys()
	StationHelpDialog:Open(
[[This is where you can give promotional keys to your friends and family.
Your friend will receive an email with the promotional key attached, along with instructions on how to use it.  You receive one new key to give out every month you are subscribed, with a maximum of 5 keys available to give out at any time.
The key you give out is good for 2 weeks of play and can be applied to any trial account.
]])
end

function HelpCharInventory()
	StationHelpDialog:Open(
[[This is where you can see where all of the items you own are located.
The left-hand panel displays all your station storage containers in alphabetical order.  The station you are currently in is listed first. Double-clicking on the icon next to a station name will collapse (or expand) the directory for that station.
Clicking on an icon will provide more detailed information in the right panel; ships display their empty statistics (i.e, just after purchase) and their background information, station directories display the station name, type, faction and location, and everything else displays a short description.]])
end

function HelpCharKeychain()
	StationHelpDialog:Open(
[[This is where you can see all the keys you have.
The left-hand panel displays all your keys in alphabetical order and in Owner/User hierarchy.  Double-clicking on the icon next to an Owner Key will collapse (or expand) the User Keys for that Owner Key. Double-clicking on the name of any key will show who owns that key and give you the ability to give and revoke keys. You cannot revoke Owner Keys and you cannot revoke User Keys for which you do not have the corresponding Owner Key. If you do not have the corresponding Owner Key, you cannot see who else has a given User Key.
Clicking on a key will provide more information in the right panel; The name of the key and the date at which it was created is shown.]])
end

function HelpStationMission()
	StationHelpDialog:Open(
[[This is where you can sign up for missions to increase your license levels and gain standing with the local faction.
There are a variety of different mission types. You can select a mission and then click on the "Info" button to learn more about it. Click on the "Accept" button if you wish to take the mission, or "Cancel" if you do not.
If you currently have a mission active, only that mission will be displayed. Select it, then the "Info" button to see the same information that you saw when you took the mission. If you want to abort the mission, simply click on the "Abort" button. If you don't, click "Cancel."
Keep in mind that different missions are available for those who are in groups.]])
end

function HelpPDAMissionNotes()
	StationHelpDialog:Open(
[[This is where you can type in notes that you want to save.
The notes will automatically be saved when you log out.
]])
end

function HelpPDAAdvancementLog()
	StationHelpDialog:Open(
[[This is where you can see updates to your skill points and license levels. This also shows credits you have earned through trading or completing missions.
Whenever you acquire enough skill points in a license, you will automatically advance to the next level in that license.
]])
end

function HelpPDAMissionLog()
	StationHelpDialog:Open(
[[This is where you can see updates to your skill points and license levels. This also shows credits earned through trading or completing missions.
Whenever you acquire enough skill points in a license, you will automatically advance to the next level in that license.
]])
end

function HelpStationNews()
	StationHelpDialog:Open(
[[This is where you can keep up to date on current events in the universe.
News items are listed in chronological order, newest at the top, oldest at the bottom. The date that the news item was posted is followed by the title of the article. To read an article, click on the one you want and then the "Read Article" button. To read another article, click on the "Back to Headlines" button and repeat the process.]])
end

function HelpStationBuddies()
	StationHelpDialog:Open(
[[This is where you can keep track of your buddies.
It shows you if they are logged on and where they are.
The checkmark before each buddy's name shows whether they are notified of your position. You can change it by toggling the checkmark.]])
end


function HelpStationNav()
	StationHelpDialog:Open(
[[This is where you set up routes to travel to other sectors or systems.  Sectors with stations are marked with an "S" on the map and wormholes are marked with a blue circle. 

To go to a sector, select the sector you wish to go to and activate your jump engines when you are 3000 meters away from asteroids.  

There is an bar indicator on the lower center of your HUD that shows the ship's distance from asteriods. 

To go to a different system use the "Zoom to Universe" to see the Universe map.  Select the system you want to go to and then click on the "Zoom to Sector" button.  Click on the sector where you want to go. To go to a different system your navigation route takes you through a wormhole.  

When you enter a sector with a wormhole an indicator shows you where the wormhole is and how far away.


]]..'\127AAAA00::Sector Notes usage::\127FFFFFF'..[[

-- move the mouse over a sector shows 'notes' in the right hand window.
-- commands available:
']]..'\127FFFF00A\127FFFFFF'..[[' will Add a note for the sector/system the mouse is over
']]..'\127FFFF00D\127FFFFFF'..[[' will delete the existing note
']]..'\127FFFF00L\127FFFFFF'..[[' will list the all notes.]])
end

function HelpPDANearbyShips()
	StationHelpDialog:Open(
[[This is where you view a list of other ships in your sector. You can target ships that are within 5000 meters by clicking on the name of the ship. To target a ship double-click on the ship name. The display will go away and return control of your ship if you are flying. Information about the targeted ship will be shown in the upper-right corner of the HUD. Double-clicking does nothing if you are in the station.]])
end

function HelpPDAStationVisitsList()
	StationHelpDialog:Open(
[[This is where you view a list of the last 20 stations you docked with.]])
end

function HelpPDAKilledList()
	StationHelpDialog:Open(
[[This is where you view a list of the last 20 people you killed and what sector you were in when it happened.]])
end

function HelpPDAKilledByList()
	StationHelpDialog:Open(
[[This is where you view a list of the last 20 people who killed you and what sector you were in when it happened.]])
end

function HelpPDAPVPList()
	StationHelpDialog:Open(
[[This is where you view a list of the player -vs- player stats.]])
end

function HelpPDAJettison()
	StationHelpDialog:Open(
[[This is where you view the cargo that is in your ship. If in a station this gives you information about the cargo in your hold.
If in space, you can also jettison cargo while flying. To jettison crates, select the commodities and then click on "jettison selected". To jettison specific numbers of crates, click on the text field and type in the number, then click on "jettison selected"]])
end

function HelpGridPower()
	StationHelpDialog:Open(
[[Power Distribution Grid

Each ship has a power distribution grid, used to provide energy to the equipped addons. The power for this grid is supplied by the powercell. Each powercell has a certain maximum "Grid Power" that it can provide, and each addon has a specific "Grid Usage". For instance, if a given powercell has a "Grid Power" of 20, and your selected addons have a "Usage" of 4, then you could only equip 5 of the addons onto a ship using that powercell. If you selected a powercell that provided more "Grid Power", then more addons could be equipped. Similarly, if you chose addons with less "Grid Usage", then you would also have more power to spare. If you have too much Usage for the available Power, none of your addons will function.

For the most part, Grid Power does not become an issue until the later stages of the game, when highly powerful addons and unusual ship configurations become available.]])
end

function HelpVoiceChat()
	StationHelpDialog:Open(
[[[Enable Voice Chat]

This checkbox enables or disables the Voice Chat feature of the game. Voice Chat allows you to talk to other players in the game, using a properly configured microphone. Even without a microphone, Voice Chat can be used to listen to group conversations, allowing for more rapid and effective communication during intensive battles and other game situations. To disable voice chat, uncheck the box and then click OK.

It is generally best to make sure your microphone is recording properly in your operating system, before attempting to use it with Vendetta Online's Voice Chat.

[Mic Level]

This is a graph that displays the strength of the signal received from your microphone. This signal strength is shown via a green bar, going from left (weakest) to right (strongest), overlaid on the blue-gray shaded area in the background. If you are not seeing a flickering green bar when you speak or lightly tap your microphone, your mic recording is not working properly with Vendetta Online. You may need to use your Operating System mixer to tweak the levels of your mic input to get an acceptable result. Ideally, most of your "average" speech should make the green bar reach roughly half way across the shaded background region. Having it reach completely across will often result in "clipping", which negatively impacts recording quality and creates noisy pops for anyone else listening.

Linux users may encounter more mic input issues than people on other Operating Systems. See the Linux Forum on our main website for various caveats and solutions.

[Transmission Level]

This scrollbar allows you to define a point on the Mic Level input graph where you define the loudness of a sound that will trigger transmission over the network. In other words, if you wish to speak to other players, but not inundate them with slight background noises from your surroundings, find the level of your normal voice, and then set the Transmission Level arrow just to the left of that. Then, anything of that "loudness" or higher will trigger transmission over the network.

[Enable Push-To-Talk]

Push to Talk allows you to bind a particular key as a "mic button", where you will only transmit while that button is held down. For those who desire more privacy, and wish to make sure their background noises are not transmitted to the rest of their group, this is a useful feature. By default, PTT is bound to "p", so this key can be pressed if the "enable" box is checked in Options. However, you can also bind this to any other key (or mouse/joystick button) using the input device configuration options, or using the console to:

/bind p +ptt

Where "p" is the chosen key in this example.

[Enable Microphone Automatic Gain Control]

Automatic Gain Control is a software feature that boosts quiet sounds, and decreases the volume of very loud sounds, so a more uniform signal strength is sent to other players. However, it can also result in some artifacts: a very loud sound can cause a volume dropout that makes successive quiet speech difficult to discern. If you experience problems with this, or complaints from other users, you might try toggling AGC.

[Quality: High/Low]

This is an experimental feature intended for players on older, slower computers. Voice Chat is spawned as a separate thread, so any multicore machine should have zero performance impact from speech encoding. However, on single core machines that are a bit slower, the encoding process could be intensive enough to result in a decrease in game framerate. If this should happen, you can try setting the transmission quality to "Low". This only impacts the quality you are sending to other players, not the quality you will hear. However, since encoding tends to use far more CPU resources than decoding, this is the only area where a quality setting is relevant.

[Sound Ducking]

Sound Ducking lets you configure a reduction in game music and sound effects volume during the time when someone is speaking. Both music and sound effects can be quite distracting during voice chat conversation, and Sound Ducking permits them to be automatically and temporarily "quieted", so the speaker can be heard more clearly, with the volume restored after the speaker is finished. The "amount" of ducking is controlled via the slider. On the left hand side, there is no impact on the volume of sound or music, the "Ducking" effect is increased as one slides to the right. On the right hand side, the sound and music are completely disabled when inbound speech is detected.

[Note: Voice does not transmit while this window is open]

This note simply means that you will not transmit over the network while the Options window is open. Other people will not be able to hear you doing voice testing. On the other hand, you should be able to hear yourself, and from this get a good idea of what they will be hearing, and if your settings are working well. If you were already grouped or speaking in another voice-chat-enabled scenario when you opened the Options interface, closing Options will immediately allow you to begin transmitting speech once again.]])
end

function HelpSystemNotes()
	StationHelpDialog:Open(
[[[System Notes]

System notes allows you to add custom notes for each sector and system on the navmap.  It will save and load notes between sessions.  You can add a variety of things to the list like storms, hive locations, roid locations, etc..

[To add a note or edit a note]
Goto the sector you wish to add a note and with the mouse pointing over the sector press the ']]
..'\127AAAA00a\127FFFFFF'..[[
' key (a for Add) then enter the note in the prompt.

[To delete a note]
Hove over the sector and press the ']]
..'\127AAAA00d\127FFFFFF'..[[
' key (d for delete).

[To list notes]
With the navmap window open press the ']]
..'\127AAAA00l\127FFFFFF'..[[
' key (l for List), this will show a chart with all of the current notes, here you can edit and delete notes.

[Using the 'search' feature]
Since regexp expressions are allowed certain keys will need to have a % added, i.e. [(%-
Errors will *ALWAYS* show regardless of search pattern used.

using multiple words will search each word in both system/sector and notes. 
i.e. 'bractus arklan' would search for all bractus systems/sectors with arklan in the notes.
also 'bractus "devus d3" would search for 'devus d3' as a single word. note to exclude put the - inside the "" or ''
you can use - to exclude certain words as well, i.e. -bractus will exclude all of bractus from the search.
]])

end

