local INITIAL_CHARCREATE_TEXT = [[	Here you can select the Nation to which your character will belong.  There are three major nations, shown at left. You can click on each nation to see more information about their history and culture. The nation you select has impact on what sort of gameplay options will initially be available.
	For instance, the Serco are the most warlike, and are at war with the Itani, and each have unique technology. The UIT are neutral in the conflict and are welcome in both Serco and Itani space. The UIT are the best traders, but cannot join the Serco or Itani militaries. They can choose a side and take part in the conflict (which can negate their neutrality), but they cannot hold command positions on either side.
	Selection of a nation does not necessarily determine what your character can and cannot do, but it does impact what's "easier" to do.]]
--'
local itanidesc = dofile("help/itanidesc.lua")
local sercodesc = dofile("help/sercodesc.lua")
local uitdesc = dofile("help/uitdesc.lua")

local itanidesc2 = dofile("help/itanidesc2.lua")
local sercodesc2 = dofile("help/sercodesc2.lua")
local uitdesc2 = dofile("help/uitdesc2.lua")

local nationnames = {
	{name="The Itani Nation", image="images/new/itani.png", desc=itanidesc, desc2=itanidesc2, namegen="ItaniNames1"},
	{name="The Serco Dominion", image="images/new/serco.png", desc=sercodesc, desc2=sercodesc2, namegen="SercoNames1"},
	{name="The UIT", image="images/new/uit.png", desc=uitdesc, desc2=uitdesc2, namegen="UITNames1"},
}

local function nationnametemplate(name, image)
	local button = iup.stationbutton{title=name, expand="HORIZONTAL", font=Font.H2}
--	local text = iup.label{title="<image will go here>",alignment="ACENTER", expand="NO"}
	local text = iup.label{title="",image=image,alignment="ACENTER", expand="NO", size="128x100", uv="0 0.0549 1 0.9451"}
	return iup.stationsubframe{
		iup.vbox{
			iup.zbox{all="YES", alignment="ACENTER", text, iup.canvas{border="NO",button_cb=function() button:action() end}},
			button,
			margin="-5x-5",
			alignment="ACENTER",
		},
	}, button, text
end

local function nationlisttemplate()
	local buttoninfo = {}
	local vbox = iup.vbox{}
	for i=1,3 do
		local nationnamecontainer, button, text = nationnametemplate(nationnames[i].name, nationnames[i].image)
		vbox:append(nationnamecontainer)
		table.insert(buttoninfo, button)
	end
	local backbutton = iup.stationbutton{title="<< Back to Character Select", font=Font.H2}

	return iup.vbox{
			iup.stationsubhollowframe{vbox},
			iup.stationmainframebg{iup.hbox{iup.fill{}}, size="x5"},
			iup.stationsubhollowframe{
				iup.stationsubframebg{
					iup.vbox{
						iup.fill{},
						iup.hbox{iup.fill{}, backbutton, iup.fill{}},
						iup.fill{},
						alignment="ACENTER",
					},
				},
			},
			expand="VERTICAL",
		}, backbutton, buttoninfo
end

local function nationinfotemplate()
	local nextbutton = iup.stationbutton{title="Select This Nation >>",font=Font.H2, active="NO"}
	local textcontrol = iup.label{title=INITIAL_CHARCREATE_TEXT, expand="YES"}
	local vbox = iup.vbox{
		iup.stationsubframe{
			textcontrol,
		},
	}
	return iup.vbox{
			iup.stationsubhollowframe{vbox},
			iup.stationmainframebg{iup.hbox{iup.fill{}}, size="x5"},
			iup.stationsubhollowframe{
				iup.stationsubframebg{
					iup.hbox{
						iup.fill{},
						nextbutton,
					},
				},
			},
		}, textcontrol, nextbutton
end

function CreateCharCreateMenu()
	local dlg
	local selected_nation = 0

	local container1, cancelbutton, nationbuttons = nationlisttemplate()
	local container2, nationinforegion, nextbutton = nationinfotemplate()
	local part1 = iup.hbox{
			singletab_template("Nation Selection", container1),
			singletab_template("Nation Information", container2),
			margin="9x9",
			gap=9,
		}
	local createcharacterbutton, newname, backbutton, nationsymbol, gettingstarted
	local startinglocation = iup.list{dropdown="YES", value=1, visible_items=5, expand="HORIZONTAL"}
	local startinglocationlabel = iup.label{title="Select your starting location: "}
	backbutton = iup.stationbutton{title="<< Back to Nation Selection", font=Font.H2}
	createcharacterbutton = iup.stationbutton{title="Create this Character >>", active="NO", font=Font.H2,
		action=function(self)
			local request_sent = CreateCharacter(newname.value, selected_nation, GetStartingSectors(selected_nation)[tonumber(startinglocation.value)])
			if request_sent then
				self.active = "NO"
			else
				OpenAlarm("Invalid character name:", "You have entered an invalid charater name.", "Go Back")
			end
		end}
	newname = iup.text{nc=32,border="NO",expand="HORIZONTAL",image=IMAGE_DIR.."text_input_mouseover.png",marginx=4,marginy=4,MOUSEOVERBOXCOLOR="255 255 255 255 *",BOXCOLOR="192 192 192 255 *",blendmode="ALPHA",
		action=function(self, key, after)
			local newname = strip_whitespace(after)
			if newname and (newname ~= "") and (string.len(newname) > 2) then
				createcharacterbutton.active = "YES" 
			else
				createcharacterbutton.active = "NO" 
			end
		end}
	nationsymbol = iup.label{title="",image=nationnames[1].image,alignment="ACENTER", expand="NO"} -- , size="64x64"}
--	nationsymbol = iup.label{title="<image goes here>",alignment="ACENTER", expand="NO"}
	gettingstarted = iup.stationsubmultiline{value=INITIAL_CHARCREATE_TEXT, readonly="YES", expand="YES", font=Font.H3}
	local part2 = iup.hbox{
		margin="9x9",
		iup.stationmainframe{
			iup.vbox{
				iup.hbox{
					iup.stationsubhollowframe{
						iup.stationsubframebg{
							iup.vbox{
								iup.label{title="Name Your Character (Minimum of 3 letters)", font=Font.H3},
								newname,
								iup.hbox{
									iup.label{title="Enter your desired name above."},
									iup.fill{},
									iup.stationbutton{title="Make a Random Name", action=function() newname.value = MakeBotName(nationnames[selected_nation] and nationnames[selected_nation].namegen or"PirateNames1", os.time()) createcharacterbutton.active = "YES" end},
								},
								iup.fill{},
								iup.hbox{startinglocationlabel,startinglocation},
								gap=2,
								margin="2x2",
							},
						},
					},
					iup.stationmainframebg{iup.vbox{iup.fill{}}, size="5"},
					iup.stationsubhollowframe{
						iup.stationsubframe{
							nationsymbol,
						},
					},
				},
				iup.stationmainframebg{iup.hbox{iup.fill{}}, size="x5"},
				iup.stationsubhollowframe{
					gettingstarted,
				},
				iup.stationmainframebg{iup.hbox{iup.fill{}}, size="x5"},
				iup.hbox{
					iup.stationsubhollowframe{
						iup.stationsubframebg{
							iup.vbox{
								iup.fill{},
								iup.hbox{iup.fill{}, backbutton, iup.fill{}, size="THIRD"},
								iup.fill{},
								alignment="ACENTER",
							},
						},
					},
					iup.stationmainframebg{iup.vbox{iup.fill{}}, size="5"},
					iup.stationsubhollowframe{
						iup.stationsubframebg{
							iup.vbox{
								iup.fill{},
								iup.hbox{iup.fill{}, createcharacterbutton, iup.fill{}, size="THIRD"},
								iup.fill{},
								alignment="ACENTER",
							},
						},
					},
				},
			}
		}
	}
	local zbox = iup.zbox{
		part1, part2,
	}

	for k=1,3 do
		local index = k
		nationbuttons[k].action = function()
			nextbutton.active = "YES"
			selected_nation = index
			nationinforegion.title = nationnames[index].desc
			nationsymbol.image = nationnames[index].image
			gettingstarted.value = nationnames[index].desc2
			gettingstarted.scroll = "TOP"
		end
	end
	
	function cancelbutton:action()
		HideDialog(dlg)
		ShowDialog(CharSelectDialog)	
	end

	function nextbutton:action()
		zbox.value = part2

		local startingsectorlist = GetStartingSectors(selected_nation)
		-- don't bother to show the list if there is only one item in the list.
		if #startingsectorlist <= 1 then
			startinglocationlabel.visible = "NO"
			startinglocation.visible = "NO"
		else
			startinglocationlabel.visible = "YES"
			startinglocation.visible = "YES"
		end

		for k,v in ipairs(startingsectorlist) do
			startinglocation[k] = (v==0) and "Random" or LocationStr(v)
		end
		startinglocation[(#startingsectorlist)+1] = nil
	end

	function backbutton:action()
		zbox.value = part1
	end

	dlg = iup.dialog{
		zbox,
		fullscreen="YES",
		defaultesc = cancelbutton,
		bgcolor = "0 0 0 0 *",
		shrink = "YES",
	}

	function dlg:Clear()
		nextbutton.active = "NO"
		createcharacterbutton.active = "NO"
		selected_nation = 0
		zbox.value = part1
		nationinforegion.title = INITIAL_CHARCREATE_TEXT
		newname.value=""
	end

	function dlg:map_cb()
		RegisterEvent(self, "UPDATE_CHARACTER_LIST")
		RegisterEvent(self, "LOGIN_FAILED")
	end

	function dlg:OnEvent(event, ...)
		if dlg.visible ~= "YES" then return end

		if event == "UPDATE_CHARACTER_LIST" then
			HideDialog(dlg)
			ShowDialog(CharSelectDialog, iup.CENTER, iup.CENTER)
		elseif event == "LOGIN_FAILED" then
			local arg1 = ...
			HideDialog(dlg)
			CharCreateFailedDialog:SetMessage("Character creation failed.\n"..arg1, "OK")
			ShowDialog(CharCreateFailedDialog, iup.CENTER, iup.CENTER)
		end
	end

	return dlg
end

CharCreateDialog = CreateCharCreateMenu()
CharCreateDialog:map()
