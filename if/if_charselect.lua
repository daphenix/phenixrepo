local INITIAL_CHARSELECT_TEXT = [[	Welcome to Vendetta Online. Here you can create your first character. Select a character slot by pressing the "Create A New Character" button to the left. You may have up to six different characters.]]

CharDeleteVerifierConfirmButton = iup.stationbutton{
		title = "Continue",
	}
CharDeleteVerifierEditbox = iup.text{expand="HORIZONTAL"}
CharDeleteVerifierDialog = iup.dialog{
	iup.vbox{
		iup.label{title="Are you sure you want to delete this character?"},
		iup.label{title="If so, please type in the character name and then press 'Continue'."},
		CharDeleteVerifierEditbox,
		iup.hbox{
			iup.fill{},
			CharDeleteVerifierConfirmButton,
			iup.fill{},
			iup.stationbutton{title="Cancel",action=function() return iup.CLOSE end},
			iup.fill{}
		},
		margin="10x10",
		gap="5",
	},
	title="Character Delete Verification",
	resize="NO"
}

local function chardeleteverifier(charname)
	local delete_it = false
	CharDeleteVerifierConfirmButton.action = 
		function(self)
			if string.lower(CharDeleteVerifierEditbox.value)==string.lower(charname) then
				delete_it = true
				return iup.CLOSE
			end
		end

	CharDeleteVerifierEditbox.value = ""
	PopupDialog(CharDeleteVerifierDialog, iup.CENTER,iup.CENTER)
	return delete_it
end

local function setcharinfo(textcontrol, index)
	local name, nation, money, kills, deaths, location, home_location, l1,l2,l3,l4,l5 = GetCharacterInfo(index)
	if name then
		local ratio
		if deaths < 1 then ratio = kills
		else ratio = math.floor(100*kills/deaths)/100 end
		
		textcontrol.title = string.format(
			"Name: %s\nNation: %s\nLocation: %s\nHome Location: %s\nCredits: %sc\nKills: %s\nDeaths: %s\nRatio: %.2f\nLicense: %u/%u/%u/%u/%u",
			name or "***",
			nation or "***",
			(location and ShortLocationStr(location)) or "***",
			(home_location and ShortLocationStr(home_location)) or "***",
			comma_value(money) or "***",
			comma_value(kills), comma_value(deaths), ratio,
			l1 or 0,l2 or 0,l3 or 0,l4 or 0,l5 or 0)
	else
		textcontrol.title = INITIAL_CHARSELECT_TEXT
	end
end

local function charnametemplate()
	local button = iup.stationbutton{title="Create A New Character", expand="HORIZONTAL", font=Font.H2}
	local text = iup.label{title="temporary info",alignment="ACENTER", expand="HORIZONTAL", font=Font.H2}
	return iup.stationsubframe{
		iup.vbox{
			button,
			iup.hbox{margin="5x5",text},
			margin="-5x-5",
		},
	}, button, text
end

local function charlisttemplate()
	local buttoninfo = {}
	local vbox = iup.vbox{expand="VERTICAL", iup.hbox{size="THIRD"}}
	for i=1,6 do
		local charname, button, text = charnametemplate()
		vbox:append(charname)
		table.insert(buttoninfo, {button, text})
	end

	return iup.stationsubhollowframe{vbox, expand="VERTICAL"}, buttoninfo
end

local function charinfotemplate()
	local deletebutton = iup.stationbutton{title="Delete Character", active="NO"}
	local playbutton = iup.stationbutton{title="Play",font=Font.Huge, active="NO"}
	local textcontrol = iup.label{title=INITIAL_CHARSELECT_TEXT, expand="YES", size="100x100"}
	local vbox = iup.vbox{
		iup.stationsubframe{
			textcontrol,
--			iup.hbox{iup.fill{},iup.vbox{iup.fill{}}},
		},
		iup.stationsubframebg{
			iup.hbox{
				deletebutton,
				iup.fill{},
				playbutton,
			},
		},
	}
	return iup.stationsubhollowframe{vbox}, textcontrol, deletebutton, playbutton
end

function singletab_template(title, tabstuff)
	local middle = iup.zbox{all="YES",
		iup.frame{
			iup.hbox{expand="YES",iup.vbox{iup.fill{}},iup.fill{}},
			expand="YES",
			image=IMAGE_DIR.."root_tab_sel.png",
			segmented="0.375 0.46875 0.53125 0.46875", -- 11 16 19 16  -> 12 15 17 15
		},
		iup.hbox{margin="5x5",iup.label{title=title, alignment="ACENTER", expand="HORIZONTAL",font=Font.Tab, fgcolor=tabunseltextcolor}},
	}
	local upperleftimage = iup.label{title="", image=IMAGE_DIR.."root_tab_left.png", segmented="1 0 1 0", size="16", expand="VERTICAL", bgcolor="255 255 255 255 +"}
	local upperrightimage = iup.label{title="", image=IMAGE_DIR.."root_tab_right.png", segmented="0 0 .5 0", size="16", expand="VERTICAL", bgcolor="255 255 255 255 +"}


	return iup.vbox{
		iup.hbox{
			upperleftimage, middle, upperrightimage,
			expand="HORIZONTAL",
		},
		iup.frame{tabstuff, image=IMAGE_DIR.."root_tab_border.png", segmented="0.265625 0 0.734375 0.46875", expand="YES"},  -- 8.5 0 23.5 17.5
		expand=tabstuff.expand,
	}
end

function CreateCharSelectMenu(logindialog)
	local dlg, updatecharlist
	local numchars = 0

	local NewspostListDialog

	local function newcharacter()
		HideDialog(dlg)
		CharCreateDialog:Clear()
		ShowDialog(CharCreateDialog)
	end
	local container1, charbuttons = charlisttemplate()
	local container2, chartext, deletebutton, playbutton = charinfotemplate()

	local disconnectbutton = iup.stationbutton{title="Disconnect", font=Font.H2}
	local readnewsbutton1 = iup.stationbutton{title="Events and News", font=Font.H2}
	local readnewsbutton2 = iup.stationbutton{title="Events and News", font=Font.H2,
			glowborder=4,
			image=IMAGE_DIR.."tab.button_selected.png",
			immouseover=IMAGE_DIR.."tab.button_mouseover.png",
			centeruv=string.format("%f %f %f %f", 10/32, 10/32, 10/32, 10/32),
			uv=string.format("0 0 %f %f", 21/32, 21/32),
			}
	local newsbuttonzbox = iup.zbox{
		readnewsbutton1,
		readnewsbutton2,
		value=readnewsbutton1,
	}
	local stuffvbox = iup.vbox{expand="VERTICAL",
		iup.stationsubframebg{
			iup.vbox{
				iup.fill{},
				iup.hbox{iup.fill{}, iup.zbox{alignment="ACENTER",all="YES",expand="NO",newsbuttonzbox,iup.canvas{border="NO",button_cb = function() ShowDialog(NewspostListDialog) end, expand="YES"}}, iup.fill{}, size="THIRD"},
				iup.fill{},
				iup.hbox{iup.fill{}, disconnectbutton, iup.fill{}, size="THIRD"},
				iup.fill{},
				alignment="ACENTER",
			},
		},
	}
	local stuffframe = iup.stationsubhollowframe{stuffvbox, expand="VERTICAL"}

	local current_index = 0
	local function select_char(index)
		current_index = index
		setcharinfo(chartext, index)
		if index > 0 and index <= GetNumCharacters() then
			deletebutton.active = "YES"
			playbutton.active = "YES"
			for i=1,6 do
				charbuttons[i][2].fgcolor = "192 192 192"
				charbuttons[i][1].fgcolor = tabunseltextcolor
			end
			charbuttons[index][2].fgcolor = "255 255 255"
			charbuttons[index][1].fgcolor = tabseltextcolor
		else
			deletebutton.active = "NO"
			playbutton.active = "NO"
		end
	end

	for k,v in ipairs(charbuttons) do
		local index = k
		v[1].hotkey = iup.K_1 + (index-1)
		v[1].action=function()
			if index <= GetNumCharacters() then
				select_char(index)
			else
				gkini.WriteInt(GetUserName(), "lastcharindex", index)
				newcharacter()
			end
		end
	end

	playbutton.hotkey = iup.K_p
	playbutton.action=function()
		SelectCharacter(current_index)
		gkini.WriteInt(GetUserName(), "lastcharindex", current_index)
		HideDialog(dlg)
		ConnectingDialog:SetMessage("Entering Universe...", "Cancel", function() Logout() end)
		ShowDialog(ConnectingDialog, iup.CENTER, iup.CENTER)
		logindialog.close_cinematic()
	end

	deletebutton.hotkey = iup.K_d
	deletebutton.action=function()
		-- "Are you sure you want to delete this character?"
		local name = GetCharacterInfo(current_index)
		local result = chardeleteverifier(name)
		if result then
			DeleteCharacter(current_index)
			select_char((GetNumCharacters() > 0) and 1 or 0)
			ShowDialog(dlg)
		end
	end

	disconnectbutton.action=function()
		Logout()
		HideDialog(dlg)
		ShowDialog(logindialog)
	end

	readnewsbutton1.action=function()
		ShowDialog(NewspostListDialog)
	end
	readnewsbutton2.action=readnewsbutton1.action

	local newstimer = Timer()
	local shouldshowlatestnews = false
	local showbuttonalertanimation = false
	
	local flip = false
	local function buttonnotificationanimation() newsbuttonzbox.value=flip and readnewsbutton2 or readnewsbutton1  flip = not flip newstimer:SetTimeout(1000) end
	
	updatecharlist = function()
		local numchars = GetNumCharacters()
		if numchars > 6 then numchars = 6 end
		for k=1,numchars do
			local name, nation, money, kills, deaths, location, home_location = GetCharacterInfo(k)
			charbuttons[k][1].title = name
			charbuttons[k][2].title = nation..' - '..ShortLocationStr(location)
		end
		select_char(gkini.ReadInt(GetUserName(), "lastcharindex", 1))
		
		local showdlg, numnew = NewspostListDialog:PopulateLists()
		if showdlg then
			shouldshowlatestnews = true
		else
			shouldshowlatestnews = false
		end
		local newstitle = "Events and News"..((numnew>0) and (" ("..numnew..")") or "")
		readnewsbutton1.title = newstitle
		readnewsbutton2.title = newstitle

		if numnew > 0 then
			flip = false
			newsbuttonzbox.value = readnewsbutton1
			showbuttonalertanimation = true
			newstimer:SetTimeout(1000, buttonnotificationanimation)
		else
			showbuttonalertanimation = false
		end
	end

	dlg = iup.dialog{
		iup.hbox{
			iup.vbox{
				singletab_template("Character Selection", container1),
				iup.stationmainframe{stuffframe},
				gap=9,
			},
			singletab_template("Character Information", container2),
			margin="9x9",
			gap=9,
		},
		title="Character Selection",
		fullscreen="YES",
		bgcolor="0 0 0 0 +",
		defaultesc=disconnectbutton,
		defaultenter=playbutton,
		startfocus=playbutton,
	}

	function dlg:hide_cb()
		newstimer:Kill()
	end

	function dlg:show_cb()
		if shouldshowlatestnews then
			shouldshowlatestnews = false
			ShowDialog(NewspostListDialog)
			return iup.CLOSE
		end
		if showbuttonalertanimation then
			newstimer:SetTimeout(1000, buttonnotificationanimation)
		end
	end

	function dlg:map_cb()
		RegisterEvent(self, "UPDATE_CHARACTER_LIST")
		RegisterEvent(self, "LOGIN_FAILED")
	end

	function dlg:OnEvent(event, ...)
		if event == "UPDATE_CHARACTER_LIST" then
			dlg:ClearCharacters()
			updatecharlist()
		elseif event == "LOGIN_FAILED" then
			if dlg.visible == "YES" then
				HideDialog(dlg)
				ShowDialog(CharSelectFailedDialog)
			end
		end
	end

	function dlg:ClearCharacters()
		numchars = 0
		for k,v in ipairs(charbuttons) do
			v[1].title = "Create A New Character"
			v[2].title = ""
		end
	end

	dlg:map()

	NewspostListDialog = MakeNewspostListDlg(dlg)
	NewspostListDialog:map()


	return dlg
end

