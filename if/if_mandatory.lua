-- this is the initial tutorial.

local INITIAL_STATION_TEXT = [[	Welcome to Vendetta Online! Because this is a new character that you've made on this account, we're going to take you through a brief tutorial. It'll only take a minute, and you'll be ready to start flying.]]

local tutorial_text = {
[10] = [[	Great! You are currently located in a space station. Most of the game occurs out in space, but you'll need to dock with stations like this one to buy equipment upgrades, repair your ship, buy and sell goods, and so on.
	The first thing we're going to do is get you set up with your first space ship. Because you're a new recruit, the government provides you with a very basic ship at no cost.

	Click on the Ship tab in the upper middle of the screen.]],
[20] = [[	This menu allows you to purchase ships and equipment upgrades. The major categories are listed on the right, the sub-categories to the left of them. We want to buy a new ship, so click on "Buy".]],
[30] = [[	Now you see the Buy Ship menu, with the EC-89 selected on the right, and a spinning view of it on the left. Most stations offer a wide variety of ships, with different benefits, costs, and License requirements. You are currently in a Training station that only offers the free ship to new recruits.]],
[31] = [[	Now, with the EC-89 selected, click on the color swatch under the spinning ship display to set how you would like your ship to be colored. You can click on different colors until you find one you like. You can also click on the ship and move the mouse to view it from different angles. To get a larger view of the ship, click on the "Maximize" button in the upper left corner of the ship display. Once you've settled on a color you like, click on the Purchase Selected button.]],
[40] = [[	Congratulations! You've purchased your first ship. Every ship is just an empty hull and engine. Now you need to purchase the other equipment you'll need in space.

	Click on the Small Addons to the right of Buy Ship.]],
[50] = [[	This is where you purchase Small Port addons. Small ports may be equipped with Small addons, Large ports with Large addons, and so on. Different ship types will have various numbers of ports.]],
--[51] = [[	If you click on any item in the list, you'll see stats for that item on the right-hand side. Don't worry too much about the stats for now, but at least be aware of the Mass. Everything you can put on a ship has Mass, and the more Mass you add the more sluggishly your ship will handle. The current total mass of your ship is displayed on the bottom right-hand area of the screen, above the Launch and Set Home buttons.]],
[52] = [[	Your new EC-89 has only one small port, and for now it would be best to equip with a weapon. The galaxy is a dangerous place, and it's most important to learn the basics of combat.

	Click on the Training Blaster, and then click on the Purchase Selected button.]],
[60] = [[	Excellent. Now, we need one more thing to get you started. Every ship requires a Power Cell to store energy. This energy is used by your weapons, engines, jump system, and other addons.

	Click on the Other Addons button to the right of Small Addons.]],
[70] = [[	Most stations will show a list of Power Cells here, with different recharge rates, capacities, masses and costs. Again, however, this Training Station only has the single Free Power Cell.

	Select the Free Power Cell and click the Purchase Selected button.]],
[80] = [[	Great! Now you're ready to launch from the station and pilot your new ship for the first time, and we'll do that in just a second. Before we do, let's briefly cover a couple of important things. First, take a look at the bottom right corner of the screen. There you'll see buttons for "Set Home", "Launch" and "Options".
	Set Home is used to define which station you will return to if your ship is destroyed. Be careful where you Set Home, as the cost and availability of ships and addons differs between stations. Your favorite ship may not be available everywhere.
	Launch will launch your currently active ship from the station. The ship must be equipped with a power cell, otherwise the station docking authority won't permit you to leave.
	Options will let you access all the graphics and interface options, as well as letting you log out of the game. Logging out and quitting the game this way is best, as it makes certain any configuration changes you have made are saved on exit.

	Next, click on the "Your PDA" tab near the top of the interface.]],
--[[
[90] = [ [	This is your Personal Data Assistant, it goes everywhere with you. All the information here can be accessed at any time. Everything else in the station interface (except for the Chat at the top) can only be accessed while docked with a station.] ],
[91] = [ [	The Missions category is shown by default, with the Mission Board display selected, as that's most commonly used. If you already had a mission, then Mission Logs would be open to show you the latest mission updates.
	Right now, however, you have no active mission, and we want to set you up with one.] ],
--]]
[90] = [[	This is your Personal Data Assistant, it goes everywhere with you. All the information here can be accessed at any time. Everything else in the station interface (except for the Chat at the top) can only be accessed while docked with a station.
	The Missions category is shown by default, with the Mission Board display selected, as that's most commonly used. If you already had a mission, then Mission Logs would be open to show you the latest mission updates.
	Right now, however, you have no active mission, and we want to set you up with one.]],
[100] = [[	The Missions category is shown by default, with the Mission Board display selected, as that's most commonly used. If you already had a mission, then Mission Logs would be open to show you the latest mission updates.
	Right now, however, you have no active mission, and we want to set you up with one.]],
[110] = [[	This is the list of available missions at this station. Because you are a raw recruit, you will only see Training type missions. When you pass your Basic Flight Status and leave for other stations, many new missions will become available.]],
[111] = [[	Missions are the main way that work is done in the galaxy. A client, such as a nation or corporation, will post the work they need to a mission. Pilots can then examine the mission here and decide if they want to take it. As you take different missions and work with different clients, they may begin to trust you with a wider variety of work.]],
[112] = [[	Successfully completing missions will generally improve your relationship with the client, failing missions may do the opposite. Building a good relationship with a client can impact a lot of things, from the trade item and equipment prices you get at their station(s) to special ship and mission availability. Trust is the most valued commodity in the galaxy.

	Click on the "Training I: Basic Flight and Combat" mission, and then click on the Info button.]],
[120] = [[	Here you see the description of the Basic Flight mission, and the options to Accept or Decline the mission.
	At this point, we strongly recommend that you Accept the mission and proceed. You may optionally Decline, and poke around in the interface, but you MUST do these first few training missions before you'll be allowed into the greater galaxy. They only take a few minutes each, and give you a substantial experience bonus towards your first Licenses, as well as some funds to start you out.]],
[121] = [[	This marks the end of the tutorial. Welcome on board, pilot. Now get out there and fly!]],
[130] = [[]],
[140] = [[]],
}

defaulttutorialbgcolor = gkini.ReadString("Vendetta", "tutorialbgcolor", "0 0 0 64 *")

local function blackbox(width, height, bgcolor, maindlg)
	local function cb(self)
		HideDialog(maindlg)
		ShowDialog(maindlg)
	end
	return iup.dialog{
		iup.canvas{expand="YES", border="NO", button_cb=cb},
		border="NO",
		menubox="NO",
		bgcolor=bgcolor or defaulttutorialbgcolor,
		topmost="YES",
		size=width.."x"..height,
		resize="NO",
	}
end

function msgdlgtemplate1a(msg, dlgsize, dlgposx, dlgposy, visible_control, bgcolor)
	local dlg
	local infolabel = iup.label{font=Font.H4,title=msg or "Title", expand="YES", size="100x50"}

	dlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					infolabel,
				},
				expand="NO",
				size=dlgsize,
			},
		},
		border="NO",
		bgcolor = "255 0 0 128 *",
		topmost="YES",
		menubox="NO",
		resize="NO",
	}

	local xres = gkinterface.GetXResolution()
	local yres = gkinterface.GetYResolution()

	-- numbers less than 1 shall mean percentage of screen res.
	if dlgposx and dlgposx < 1 then dlgposx = dlgposx*xres end
	if dlgposy and dlgposy < 1 then dlgposy = dlgposy*yres end

	local part1, part2, part3, part4
	local x,y,w,h
	if visible_control then
		x = tonumber(visible_control.x)
		y = tonumber(visible_control.y)
		w = tonumber(visible_control.w)
		h = tonumber(visible_control.h)
		part1 = blackbox("FULL", y, bgcolor, dlg)
		part4 = blackbox("FULL", yres-(y+h), bgcolor, dlg)
		part2 = blackbox(x, h, bgcolor, dlg)
		part3 = blackbox(xres-(x+w), h, bgcolor, dlg)

		function part1:hide_cb()
			HideDialog(part2)
			HideDialog(part3)
			HideDialog(part4)
			HideDialog(dlg)
		end

		function part1:show_all()
			ShowDialog(part1, 0, 0)
			ShowDialog(part2, 0, y)
			ShowDialog(part3, x+w, y)
			ShowDialog(part4, 0, y+h)
			ShowDialog(dlg, dlgposx or iup.CENTER, dlgposy or iup.CENTER)
		end
	end

	return part1 or dlg
end

function msgdlgtemplate1aNext(next_cb, msg, dlgsize, dlgposx, dlgposy, visible_control, bgcolor)
	local dlg
	local infolabel = iup.label{font=Font.H4,title=msg or "Title", expand="YES", size="100x50"}

	dlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
--[[
				iup.vbox{
					infolabel,
					iup.hbox{iup.fill{}, iup.stationbutton{title="Next ->", action=next_cb}},
				},
--]]
				iup.zbox{
					all="YES",
					expand="YES",
					alignment="SE",
					infolabel,
					iup.stationbutton{title="Next ->", action=next_cb},
				},

				expand="NO",
				size=dlgsize,
			},
		},
		border="NO",
		bgcolor = "255 0 0 128 *",
		topmost="YES",
		menubox="NO",
		resize="NO",
	}

	local xres = gkinterface.GetXResolution()
	local yres = gkinterface.GetYResolution()

	-- numbers less than 1 shall mean percentage of screen res.
	if dlgposx and dlgposx < 1 then dlgposx = dlgposx*xres end
	if dlgposy and dlgposy < 1 then dlgposy = dlgposy*yres end

	local part1, part2, part3, part4
	local x,y,w,h
	if visible_control then
		x = tonumber(visible_control.x)
		y = tonumber(visible_control.y)
		w = tonumber(visible_control.w)
		h = tonumber(visible_control.h)
		part1 = blackbox("FULL", y, bgcolor, dlg)
		part4 = blackbox("FULL", yres-(y+h), bgcolor, dlg)
		part2 = blackbox(x, h, bgcolor, dlg)
		part3 = blackbox(xres-(x+w), h, bgcolor, dlg)

		function part1:hide_cb()
			HideDialog(part2)
			HideDialog(part3)
			HideDialog(part4)
			HideDialog(dlg)
		end

		function part1:show_all()
			ShowDialog(part1, 0, 0)
			ShowDialog(part2, 0, y)
			ShowDialog(part3, x+w, y)
			ShowDialog(part4, 0, y+h)
			ShowDialog(dlg, dlgposx or iup.CENTER, dlgposy or iup.CENTER)
		end
	end

	return part1 or dlg
end

function msgdlgtemplate1aDone(next_cb, msg, dlgsize, dlgposx, dlgposy, visible_control, bgcolor)
	local dlg
	local infolabel = iup.label{font=Font.H4,title=msg or "Title", expand="YES", size="100x50"}

	dlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					infolabel,
					iup.hbox{iup.fill{}, iup.stationbutton{title="Close", action=next_cb}, iup.fill{}},
				},
				expand="NO",
				size=dlgsize,
			},
		},
		border="NO",
		bgcolor = "255 0 0 128 *",
		topmost="YES",
		menubox="NO",
		resize="NO",
	}

	local xres = gkinterface.GetXResolution()
	local yres = gkinterface.GetYResolution()

	-- numbers less than 1 shall mean percentage of screen res.
	if dlgposx and dlgposx < 1 then dlgposx = dlgposx*xres end
	if dlgposy and dlgposy < 1 then dlgposy = dlgposy*yres end

	local part1, part2, part3, part4
	local x,y,w,h
	if visible_control then
		x = tonumber(visible_control.x)
		y = tonumber(visible_control.y)
		w = tonumber(visible_control.w)
		h = tonumber(visible_control.h)
		part1 = blackbox("FULL", y, bgcolor, dlg)
		part4 = blackbox("FULL", yres-(y+h), bgcolor, dlg)
		part2 = blackbox(x, h, bgcolor, dlg)
		part3 = blackbox(xres-(x+w), h, bgcolor, dlg)

		function part1:hide_cb()
			HideDialog(part2)
			HideDialog(part3)
			HideDialog(part4)
			HideDialog(dlg)
		end

		function part1:show_all()
			ShowDialog(part1, 0, 0)
			ShowDialog(part2, 0, y)
			ShowDialog(part3, x+w, y)
			ShowDialog(part4, 0, y+h)
			ShowDialog(dlg, dlgposx or iup.CENTER, dlgposy or iup.CENTER)
		end
	end

	return part1 or dlg
end

function TutorialPart1()
	RunTutorial = TutorialPart1
	local oldhide = StationDialog.hide_cb
	-- need to reset all tabs to their default tabs.
	StationTabs:SetTab(StationCommerceTab)
	StationTabPDA:SetTab(StationPDAMissionsTab)
	StationPDAMissionsTab:SetTab(StationPDAMissionBoardTab)
	StationCommerceTab:SetTab(StationCommerceWelcomeTab)
	StationEquipmentTab:SetTab(StationEquipmentManageTab)
	StationEquipmentBuyTab:SetTab(StationEquipmentBuyShipTab)
	local dlg
	local function action()
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		TutorialPart2()
	end
	dlg = msgdlgtemplate1(INITIAL_STATION_TEXT, "OK", action, "HALFx", nil, nil, defaulttutorialbgcolor)

	ShowDialog(dlg, iup.CENTER, iup.CENTER)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		self.hide_cb = oldhide
		oldhide(self)
	end
	return dlg
end

function TutorialPart2()
	RunTutorial = TutorialPart2
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationTabs:GetTabButton(StationEquipmentTab)
	local oldaction = control.action
	control.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart3()
	end
	dlg = msgdlgtemplate1a(tutorial_text[10], "HALFxTHIRD", nil, .333, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		control.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart3()
	RunTutorial = TutorialPart3
	local oldhide = StationDialog.hide_cb
	local dlg
	StationEquipmentBuyTab:SetTab(StationEquipmentBuyShipTab)
	local control = StationEquipmentTab:GetTabButton(StationEquipmentBuyTab)
	local oldaction = control.action
	control.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart4()
	end
	dlg = msgdlgtemplate1a(tutorial_text[20], "HALFxQUARTER", .25, .333, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		control.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

local part4_subpart
function TutorialPart4()
	RunTutorial = TutorialPart4
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationEquipmentBuyShipTab
	local waitcontrol = StationEquipmentBuyShipPurchaseButton
	local oldaction = waitcontrol.action
	waitcontrol.action = function(self)
		part4_subpart = nil
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart5()
	end
	if part4_subpart == 2 then
		dlg = msgdlgtemplate1a(tutorial_text[31], "%95x%18", nil, 5, control)
	else
		dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1a(tutorial_text[31], "%95x%18", nil, 5, control) dlg:show_all() part4_subpart=2 end, tutorial_text[30], "%95x%18", nil, 5, control)
	end
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		waitcontrol.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart5()
	RunTutorial = TutorialPart5
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationEquipmentBuyTab:GetTabButton(StationEquipmentBuySmallTab)
	local oldaction = control.action
	control.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart6()
	end
	dlg = msgdlgtemplate1a(tutorial_text[40], "%95x%18", nil, 5, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		control.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart6()
	RunTutorial = TutorialPart6
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationEquipmentBuySmallTab
	local waitcontrol = StationEquipmentBuySmallPurchaseButton
	local oldaction = waitcontrol.action
	waitcontrol.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart7()
	end
	dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1a(tutorial_text[52], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[51], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[50], "%95x%18", nil, 5, control)
	dlg = msgdlgtemplate1aNext(
		function()
			HideDialog(dlg)
			dlg = msgdlgtemplate1a(tutorial_text[52], "%95x%18", nil, 5, control)
			dlg:show_all()
		end, tutorial_text[50], "%95x%18", nil, 5, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		waitcontrol.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart7()
	RunTutorial = TutorialPart7
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationEquipmentBuyTab:GetTabButton(StationEquipmentBuyOtherTab)
	local oldaction = control.action
	control.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart8()
	end
	dlg = msgdlgtemplate1a(tutorial_text[60], "%95x%18", nil, 5, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		control.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart8()
	RunTutorial = TutorialPart8
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationEquipmentBuyOtherTab
	local waitcontrol = StationEquipmentBuyOtherPurchaseButton
	local oldaction = waitcontrol.action
	waitcontrol.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart9()
	end
	dlg = msgdlgtemplate1a(tutorial_text[70], "%95x%18", nil, 5, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		waitcontrol.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart9()
	RunTutorial = TutorialPart9
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationTabs:GetTabButton(StationTabPDA)
	local oldaction = control.action
	control.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart12()
	end
	dlg = msgdlgtemplate1a(tutorial_text[80], "TWOTHIRDxHALF", nil, .333, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		control.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart10()
	RunTutorial = TutorialPart10
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationTabPDA:GetTabButton(StationPDAMissionsTab)
	local waitcontrol = StationTabPDA:GetTabButton(StationPDAMissionsTab)
	local oldaction = waitcontrol.action
	waitcontrol.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart11()
	end
	dlg = msgdlgtemplate1a(tutorial_text[90], "%95x%18", nil, 5, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		waitcontrol.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart11()
	RunTutorial = TutorialPart11
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationPDAMissionsTab:GetTabButton(StationPDAMissionBoardTab)
	local waitcontrol = StationPDAMissionsTab:GetTabButton(StationPDAMissionBoardTab)
	local oldaction = waitcontrol.action
	waitcontrol.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart12()
	end
	dlg = msgdlgtemplate1a(tutorial_text[100], "%95x%18", nil, 5, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		waitcontrol.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart12()
	RunTutorial = TutorialPart12
	local oldhide = StationDialog.hide_cb
	local dlg
	local control = StationPDAMissionBoardTab
	local waitcontrol = StationPDAMissionBoardTabInfoButton
	local oldaction = waitcontrol.action
	waitcontrol.action = function(self)
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		self.action = oldaction
		oldaction(self)
		TutorialPart13()
	end
	dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1a(tutorial_text[112], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[111], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[110], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[90], "%95x%18", nil, 5, control)
--	dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1a(tutorial_text[112], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[111], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[110], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[91], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[90], "%95x%18", nil, 5, control)
--	dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1a(tutorial_text[112], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[111], "%95x%18", nil, 5, control) dlg:show_all() end, tutorial_text[110], "%95x%18", nil, 5, control)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		waitcontrol.action = oldaction
		self.hide_cb = oldhide
		oldhide(self)
	end
	dlg:show_all()
end

function TutorialPart13()
	RunTutorial = TutorialPart13
	local oldhide = StationDialog.hide_cb
	local dlg
	local function action()
		StationDialog.hide_cb = oldhide
		HideDialog(dlg)
		TutorialEnd()
	end
--	dlg = msgdlgtemplate1(tutorial_text[120], "OK", action, "%95x%18", nil, 5)
	dlg = msgdlgtemplate1aNext(function() HideDialog(dlg) dlg = msgdlgtemplate1aDone(action, tutorial_text[121], "%95x%18", nil, 5, nil) ShowDialog(dlg, iup.CENTER, 5) end, tutorial_text[120], "%95x%18", nil, 5, nil)
	StationDialog.hide_cb = function(self)
		HideDialog(dlg)
		self.hide_cb = oldhide
		oldhide(self)
	end
	ShowDialog(dlg, iup.CENTER, 5)
end

function TutorialEnd()
	StopTutorial()
	RunTutorial = TutorialPart1
end

-- need to handle connection terminated to re-set the buttons' actions.

RunTutorial = TutorialPart1
