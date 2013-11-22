local tipindex = math.random(GetNumTips())


-- one message label and one button, 
function msgdlgtemplate1(msg, button1text, button1action, dlgsize, dlgposx, dlgposy, bgcolor)
	local dlg
	local infolabel = iup.label{font=Font.H4,title=msg or "Title", expand="YES", size="100x100"}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{size=dlgposx},
			iup.vbox{
				iup.fill{size=dlgposy},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
							},
						},
						expand="NO",
						size=dlgsize,
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button1,
		fullscreen="YES",
		bgcolor = bgcolor or "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(msg, button1text, callback1)
		infolabel.title = msg or ""
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end
		infolabel.size = nil
		dlg.size = nil
	end

	return dlg, button1, infolabel
end

--[[
listbox = dropdown listbox on top
infobo = bottom listbox, not dropable.

table format.  x/y/z is listbox values. 
[x] = {x1,x2,x3,x4....xN} or {'string_x'}
[y] = {y1,y2,y3,y4....yN} or {'string_y'}
[z] = {z1,z2,z3,z4....zN} or {'string_z'}
]]

--list box with two button
function multilistdlgtemplate(title1, title2, tbl, button1text, button1action, button2text, button2action)

	local dlg
	local sort_table = {}

	local infolabel = iup.label{readonly='YES',font=Font.H1,title=title1 or "Title",alignment='ACENTER'}
	local sublabel = iup.label{readonly='YES',title=title2 or "Title",alignment='ACENTER'}
	local listbox = iup.list{expand="HORIZONTAL", visible_items="10",dropdown = 'YES'}
	local infobox = iup.pdasubsublist{expand="HORIZONTAL", visible_items="25",dropdown = 'NO',size='%50x%50'}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}
	local button2 = iup.stationbutton{title=button2text or "Cancel", action=button2action}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							iup.hbox{iup.fill{},infolabel,iup.fill{},},
							iup.hbox{sublabel,iup.fill{gap=5},listbox,iup.fill{}},
							infobox,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
								button2,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button1,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(title1, title2, tbl, button1text, callback1, button2text, callback2)

		local msg = ''	
		local count = 1
		local tbl_count = 0
		local intro_tbl = {} -- summary default screen on startup. no items selected.

		infolabel.title = title1 or ""
		sublabel.title = title2 or ""
		infobox.value = 1
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end

		dlg.size = nil

		for k,v in pairs(tbl) do
			tbl_count = 0
			if type(v) == 'table' then
				for k1,v1 in pairs(v) do
					tbl_count = tbl_count + 1
				end
			end
			listbox[count] = k
			infobox[count] = k..' '..tbl_count
			count = count + 1
		end

		
		button2.title = button2text or "Plot"
		if callback2 then button2.action = callback2 end

		listbox.action = function(self,text,num,value)
			if value == 1 then
				if type(tbl[text]) == 'table' then
					for k,v in pairs(tbl[text]) do
						table.insert(sort_table,table.concat(v,' '))
					end
					table.sort(sort_table)
					
					for k,v in pairs(sort_table) do
						infobox[k] = v
					end
					infobox[#sort_table+1] = '\t\t\tTotal count: '..#sort_table
					
				elseif type(tbl[text]) == 'string' then infobox[count] = tbl[text]
				else infobox[count] = tbl[text] or 'bad data'					
				end
			end
		end
	end

	function dlg:GetSelection()
		if tonumber(infobox.value) <= #sort_table then
			return sort_table[tonumber(infobox.value)]
		end
	end
	
	return dlg
end

---same as msgdlgtemplate2 but uses a multiline instead of a text box
-- msg2 = multiline text
function multidlgtemplate1(msg1, msg2, button1text, button1action)
	local dlg
	local infolabel = iup.label{readonly='YES',font=Font.H1,title=msg1 or "Title",alignment='ACENTER'}
	local infobox = iup.multiline{readonly='YES',font=Font.H1,value=msg2 or "Value",size='%65x%50'}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							iup.hbox{iup.fill{},infolabel,iup.fill{},},
							infobox,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button1,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(msg1, msg2, button1text, callback1)
		infolabel.title = msg1 or ""
		infobox.value = msg2 or ""
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end
		dlg.size = nil
	end

	return dlg
end

---same as msgdlgtemplate2 but uses a multiline instead of a text box
function multidlgtemplate2(msg1, msg2, button1text, button1action, button2text, button2action)
	local dlg
	local infolabel = iup.label{readonly='YES',font=Font.H1,title=msg1 or "Title",alignment='ACENTER'}
	local infobox = iup.multiline{readonly='YES',font=Font.H1,value=msg2 or "Value",size='%35x%50'}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}
	local button2 = iup.stationbutton{title=button2text or "Cancel", action=button2action}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							iup.hbox{iup.fill{},infolabel,iup.fill{},},
							infobox,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
								button2,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button2,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(msg1, msg2, button1text, callback1, button2text, callback2)
		infolabel.title = msg1 or ""
		infobox.value = msg2 or ""
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end
		button2.title = button2text or "Cancel"
		if callback2 then button2.action = callback2 end
		dlg.size = nil
	end

	return dlg
end


-- 2 buttons, ok/cancel type 
function msgdlgtemplate2(msg, button1text, button1action, button2text, button2action, dlgbgcolor, alignment)
	local dlg
	local infolabel = iup.label{font=Font.H1,title=msg or "Title", alignment=alignment}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}
	local button2 = iup.stationbutton{title=button2text or "Cancel", action=button2action}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					bgcolor=dlgbgcolor,
					iup.stationhighopacityframebg{
						bgcolor=dlgbgcolor,
						iup.vbox{
							infolabel,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
								button2,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button2,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(msg, button1text, callback1, button2text, callback2, alignment)
		infolabel.alignment = alignment or "ALEFT"
		infolabel.title = msg or ""
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end
		button2.title = button2text or "Cancel"
		if callback2 then button2.action = callback2 end
		dlg.size = nil
	end

	return dlg
end

-- same as msgdlgtempalte2 but with 'remember this' type 
function msgdlgtemplate2withcheck(msg, button1text, button1action, button2text, button2action)
	local dlg
	local infolabel = iup.label{font=Font.H1,title=msg or "Title"}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}
	local button2 = iup.stationbutton{title=button2text or "Cancel", action=button2action}
	local check = iup.stationtoggle{title="Do not show this dialog again.", value = "OFF", tip="This setting can be changed\nin Options->Interface"}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
							check,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
								button2,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button2,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(msg, button1text, callback1, button2text, callback2, checkstate)
		check.value = checkstate and "ON" or "OFF"
		infolabel.title = msg or ""
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end
		button2.title = button2text or "Cancel"
		if callback2 then button2.action = callback2 end
		dlg.size = nil
	end

	function dlg:GetCheckState()
		return check.value == "ON"
	end

	return dlg
end

AskForgivenessDialog = msgdlgtemplate2("", "Yes", function() ForgiveKiller(true) HideDialog(AskForgivenessDialog) end, "No", function() ForgiveKiller(false) HideDialog(AskForgivenessDialog) end, "128 0 0 255 *", "ACENTER")
AskForgivenessDialog:map()
QuestionDialog = msgdlgtemplate2()
QuestionDialog:map()
ConfirmationDialog = msgdlgtemplate1()
ConfirmationDialog:map()
QuestionWithCheckDialog = msgdlgtemplate2withcheck()
QuestionWithCheckDialog:map()

local function openalarm_buttonaction() HideDialog(ConfirmationDialog) end
function OpenAlarm(title, text, buttontext)
	ConfirmationDialog:SetMessage(title.."\n"..text, buttontext or "Close", openalarm_buttonaction)
	PopupDialog(ConfirmationDialog, iup.CENTER, iup.CENTER)
end

function msgpromptdlgtemplate2lines(msg, msg2, button1text, button1action, button2text, button2action)
	local dlg
	local infolabel = iup.label{font=Font.H1,title=msg or "Title"}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}
	local button2 = iup.stationbutton{title=button2text or "Cancel", action=button2action}
	local input = iup.text{expand="HORIZONTAL"}
	local infolabel2 = iup.label{font=Font.H1,title=msg2 or "Title"}
	local input2 = iup.text{expand="HORIZONTAL"}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
							input,
							infolabel2,
							input2,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
								button2,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button2,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(msg, msg2, button1text, callback1, button2text, callback2)
		infolabel.title = msg or ""
		infolabel2.title = msg2 or ""
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end
		button2.title = button2text or "Cancel"
		if callback2 then button2.action = callback2 end
		dlg.size = nil
	end

	function dlg:GetString()
		return tostring(input.value)
	end

	function dlg:GetString2()
		return tostring(input2.value)
	end

	function dlg:SetString(str)
		input.value = tostring(str)
	end
	
	function dlg:SetString2(str)
		input2.value = tostring(str)
	end

	return dlg
end

-- ok/cancel with user input
function msgpromptdlgtemplate2(msg, button1text, button1action, button2text, button2action)
	local dlg
	local infolabel = iup.label{font=Font.H1,title=msg or "Title"}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}
	local button2 = iup.stationbutton{title=button2text or "Cancel", action=button2action}
	local input = iup.text{expand="HORIZONTAL"}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
							input,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
								button2,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button2,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(msg, button1text, callback1, button2text, callback2)
		infolabel.title = msg or ""
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end
		button2.title = button2text or "Cancel"
		if callback2 then button2.action = callback2 end
		dlg.size = nil
	end

	function dlg:GetString()
		return tostring(input.value)
	end

	function dlg:SetString(str)
		input.value = tostring(str)
	end

	return dlg
end

-- ok/cancel with user input, multiline
function msgpromptdlgtemplateml(msg, msg2, button1text, button1action, button2text, button2action)
	local dlg
	local infolabel = iup.label{font=Font.H1,title=msg or "Title"}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}
	local button2 = iup.stationbutton{title=button2text or "Cancel", action=button2action}
	local input = iup.multiline{readonly='NO',font=Font.H1,value=msg2 or "",size='%65x%50'}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
							input,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
								button2,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button2,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(msg, msg2, button1text, callback1, button2text, callback2)
		input.value = msg2 --or ""
		infolabel.title = msg or ""
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end
		button2.title = button2text or "Cancel"
		if callback2 then button2.action = callback2 end
		dlg.size = nil
	end

	function dlg:GetString()
		return tostring(input.value)
	end

	function dlg:SetString(str)
		input.value = tostring(str)
	end

	return dlg
end

-- ok/cancel with 3 user inputs: single line, single line, multiline
function emailpromptdlgtemplate(button1text, button1action, button2text, button2action)
	local dlg
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}
	local button2 = iup.stationbutton{title=button2text or "Cancel", action=button2action}
	local inputname = iup.text{nc=64,expand="HORIZONTAL"}
	local inputemail = iup.text{nc=255,expand="HORIZONTAL"}
	local inputtext = iup.multiline{nc=8192,readonly='NO',font=Font.H1,value="",size='%65x%50'}
	local yourname = iup.label{title="your name goes here", expand="HORIZONTAL"}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							iup.hbox{iup.label{title="Your Full Name: "}, yourname},
							iup.hbox{iup.label{title="Friend's Name: "}, inputname},
							iup.hbox{iup.label{title="Friend's Email: "}, inputemail},
							iup.label{title="Personalized message: "},
							inputtext,
							iup.label{title="(A good example is to tell them what your character's name is or what nation you are.)"},
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
								button2,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button2,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
		show_cb=function()
			inputname.value = ""
			inputemail.value = ""
			inputtext.value = ""
		end,
	}

	function dlg:GetString1()
		return strip_whitespace(tostring(inputname.value))
	end

	function dlg:GetString2()
		return strip_whitespace(tostring(inputemail.value))
	end

	function dlg:GetString3()
		return strip_whitespace(tostring(inputtext.value))
	end

	function dlg:SetYourName(str)
		yourname.title = tostring(str)
	end

	return dlg
end

-- ok/cancel with list box
function listpromptdlgtemplate(msg, button1text, button1action, button2text, button2action)
	local list = {}
	local dlg
	local infolabel = iup.label{font=Font.H1,title=msg or "Title"}
	local button1 = iup.stationbutton{title=button1text or "OK", action=button1action}
	local button2 = iup.stationbutton{title=button2text or "Cancel", action=button2action}
	local list_box = iup.stationsublist{
		dropdown = 'no',
		value = 1,
		editbox = 'NO',
		multiple = 'YES',
		SIZE = "%30x%30",
	}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							iup.hbox{
								iup.fill{},
								infolabel,
								iup.fill{},
							},
							list_box,
							iup.hbox{
								iup.fill{},
								button1,
								iup.fill{},
								button2,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultenter = button1,
		defaultesc = button2,
		fullscreen="YES",
		bgcolor = "0 0 0 128 *",
		topmost="YES",
	}

	function dlg:SetMessage(msg, button1text, callback1, button2text, callback2)
		infolabel.title = msg or ""
		button1.title = button1text or "OK"
		if callback1 then button1.action = callback1 end
		button2.title = button2text or "Cancel"
		if callback2 then button2.action = callback2 end
		dlg.size = nil
	end

	function dlg:SetList(list)
		local count = 1
		for k,v in pairs(list) do
			list_box[count] = v
			count = count + 1
			list_box[count] = nil
		end
	end

	function dlg:GetLine(list)
		return list_box.value
	end
	
	return dlg
end
-- end



local function msgdlgtemplate(msg, buttontext, buttonaction)
	local dlg
	local infolabel = iup.label{font=Font.H1,title=msg or "Title"}
	local cancelbutton = iup.stationbutton{title=buttontext or "OK", action=buttonaction}
	local focusgrabber = iup.canvas{size="1x1", border="NO"}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							infolabel,
							focusgrabber,
							iup.hbox{
								iup.fill{},
								cancelbutton,
								iup.fill{},
							},
						},
						expand="NO",
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultesc = cancelbutton,
		defaultfocus = focusgrabber,
		border="NO",
		resize="NO",
		menubox="NO",
		fullscreen="YES",
		bgcolor = "0 0 0 0 *",
		topmost="YES",
	}

	function dlg:show_cb()
		iup.SetFocus(focusgrabber)
	end

	function dlg:SetMessage(msg, button, callback)
		infolabel.title = msg or ""
		cancelbutton.title = button or "Cancel"
		if callback then cancelbutton.action = callback end
		dlg.size = nil
	end

	return dlg, cancelbutton, infolabel
end

local function notificationdlgtemplate(msg, want_progressbar)
	local dlg
	local infolabel = iup.label{font=Font.H1,title=msg or "Title", wordwrap="YES", alignment="ACENTER"}
	local progressbar
	if want_progressbar then
		progressbar = iup.progressbar{type="HORIZONTAL",
			LOWERCOLOR="0 0 170 255 *",
			UPPERCOLOR="0 0 0 128 *",
			minvalue=0, maxvalue=100,
			expand="HORIZONTAL", size="x12"}
	end

	dlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					infolabel,
					progressbar,
				},
			},
		},
		active="NO",
		border="NO",
		resize="NO",
		menubox="NO",
		bgcolor = "0 0 0 0 *",
	}

	function dlg:SetMessage(msg)
		infolabel.title = msg or ""
		dlg.size = nil
	end

	return dlg, infolabel, progressbar
end


function CreateConnectingMenu()
	local dlg, button = msgdlgtemplate("Connecting...", "Cancel")
	button.action = function()
		Logout()
	end

	RegisterEvent(dlg, "UPDATE_CHARACTER_LIST")
	function dlg:OnEvent(eventname, ...)
		if self.visible ~= "YES" then return end

		if eventname == "UPDATE_CHARACTER_LIST" then
			HideDialog(self)
			ShowDialog(CharSelectDialog, iup.CENTER, iup.CENTER)
		end
	end

	return dlg
end

ConnectingDialog = CreateConnectingMenu()
ConnectingDialog:map()

function CreateCharCreateFailedMenu()
	local dlg, button = msgdlgtemplate("Character creation failed.", "OK")
	button.action = function()
		HideDialog(dlg)
		ShowDialog(CharCreateDialog)
	end
	return dlg
end
CharCreateFailedDialog = CreateCharCreateFailedMenu()
CharCreateFailedDialog:map()

function CreateCharSelectFailedMenu()
	local dlg, button = msgdlgtemplate("Character selection failed.", "OK")
	button.action = function()
		HideDialog(dlg)
		ShowDialog(CharSelectDialog, iup.CENTER, iup.CENTER)
	end
	return dlg
end
CharSelectFailedDialog = CreateCharSelectFailedMenu()
CharSelectFailedDialog:map()

function CreateCancelLoadoutMenu()
	local dlg, button = msgdlgtemplate("Purchasing...", "Cancel")
	return dlg
end
CancelLoadoutPurchaseDialog = CreateCancelLoadoutMenu()
CancelLoadoutPurchaseDialog:map()

function CreateNotEnoughStorageMenu()
	local dlg, button, label = msgdlgtemplate1("Not enough space for all the items.", "OK")
	button.action = function()
		HideDialog(dlg)
	end
	label.size = "200x"
	return dlg
end
NotEnoughStorageDialog = CreateNotEnoughStorageMenu()
NotEnoughStorageDialog:map()

function CreateInvalidAmountMenu()
	local dlg, button, label = msgdlgtemplate1("Invalid amount.", "Close")
	button.action = function()
		HideDialog(dlg)
	end
	label.size = "100x"
	return dlg
end
InvalidAmountDialog = CreateInvalidAmountMenu()
InvalidAmountDialog:map()

function CreateEULAMenu()
	local dlg, nextdlg, eula_text
	local okbutton = iup.stationbutton{title="I Accept",
		action=function()
			HideDialog(dlg)
			ShowDialog(nextdlg, iup.CENTER, iup.CENTER)
		end}
	local cancelbutton = iup.stationbutton{title="I Decline",
		action=function()
			Logout()
		end}

	eula_text = iup.stationhighopacitysubmultiline{readonly="YES", expand="YES", value=GetEULA() }

	dlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.vbox{
				iup.stationhighopacityframebg{
					iup.label{title="End User License Agreement", alignment="ACENTER", expand="HORIZONTAL"},
				},
				eula_text,
				iup.stationhighopacityframebg{
					iup.vbox{
						iup.label{font=Font.H1,title="Do you accept the EULA?", expand="HORIZONTAL", alignment="ACENTER"},
						iup.hbox{
							iup.fill{},
							okbutton,
							iup.fill{},
							cancelbutton,
							iup.fill{},
						},
					},
				},
			},
		},
		defaultesc = cancelbutton,
		border="NO",
		resize="NO",
		menubox="NO",
		bgcolor = "0 0 0 0 *",
		size="THREEQUARTERxTHREEQUARTER",
	}

	function dlg:show_cb()
		nextdlg = ConnectingDialog
		eula_text.caret = 0
	end

	function dlg:map_cb()
		RegisterEvent(self, "UPDATE_CHARACTER_LIST")
		RegisterEvent(self, "OPEN_SURVEY")
	end

	function dlg:OnEvent(eventname, ...)
		if eventname == "UPDATE_CHARACTER_LIST" then
			nextdlg = CharSelectDialog
		elseif eventname == "OPEN_SURVEY" then
			nextdlg = SurveyDialog
		end
	end

	return dlg
end

EULADialog = CreateEULAMenu()
EULADialog:map()

function CreateLoginHelpDialog(logindialog)
local dlg
local loginhelpclosebutton = iup.stationbutton{title="Close",
	action=function()
		HideDialog(dlg)
		ShowDialog(logindialog)
	end}

local loginhelptext = iup.stationhighopacitysubmultiline{readonly="YES", expand="YES", value=
[[Welcome to Vendetta Online

This is the main login screen. From here you can enter your account login name and password. Your account name and password will be the same as what you use to log into our website. Usually, most people create an account before they download and install the game. If, for some reason, you have not yet created an account, you can do so on the game website:

http://www.vendetta-online.com

From there you may also recover a forgotten account password, as long as you can still access email sent to the address used in your account signup.

If you are installing from a retail CD, please follow the instructions
included in the box with the game.

[Help]

This button brings you here.

[Credits]

The people behind the making of Vendetta Online.

[Options]

The Options menu will allow you to change many game client settings:
graphics, input configuration (joysticks and keys) and other game options. You can access these settings at anywhere in the game. If you find the game is running slowly, you should be able to improve the game speed by using lower Visual Quality settings in the Video menu. Generally the Visual Quality settings are auto-configured to your computer the first time you run the game, but the auto-configuration is not perfect.

[Quit]

This exits from the game client.]]}

dlg = iup.dialog{
	iup.stationhighopacityframe{
		iup.vbox{
			loginhelptext,
			iup.stationhighopacityframebg{
			iup.hbox{
				iup.fill{},
				loginhelpclosebutton,
				iup.fill{},
			},
			},
		},
	},
	defaultesc = loginhelpclosebutton,
	border="NO",
	resize="NO",
	menubox="NO",
	bgcolor = "0 0 0 0 *",
	size="THREEQUARTERxTHREEQUARTER",
}

function dlg:show_cb()
	loginhelptext.caret = 0
end
return dlg
end

function CreateSurveyMenu()
	local dlg, nextdlg
	local radiolist
	local answer = 1
	local function clearchoices()
		if not radiolist then return end
		radiolist:destroy()
		radiolist = nil
	end

	local okbutton = iup.stationbutton{title="Submit", active="NO",
		action=function()
			SubmitSurvey(answer)
			HideDialog(dlg)
			clearchoices()
			nextdlg = nextdlg or ConnectingDialog
			ShowDialog(nextdlg, iup.CENTER, iup.CENTER)
		end}
	local function toggleactionfunc() okbutton.active="YES" end
	local questiontext = iup.label{title="Are you cool?",expand="VERTICAL",size="THREEQUARTERx"}

	local vbox = iup.vbox{}

	dlg = iup.dialog{
		iup.stationhighopacityframe{
		iup.stationhighopacityframebg{
			iup.vbox{
				questiontext,
				vbox,
				iup.hbox{iup.fill{},okbutton,iup.fill{}},
			},
		},
		},
--		title="Survey",
		border="NO",
		resize="NO",
		menubox="NO",
		bgcolor = "0 0 0 0 *",
	}

	local function SetQuestion(question, choices)
		clearchoices()
		questiontext.title = question
		if (#choices) > 1 then
			okbutton.active = "NO"
			okbutton.title = "Submit"
			local choicebuttons = {gap=5}
			for _,choicetext in ipairs(choices) do
				local choiceradiobutton = iup.stationradio{
					title=choicetext, value="OFF", action=toggleactionfunc,
					expand="VERTICAL",size="THREEQUARTERx"
				}
				table.insert(choicebuttons, choiceradiobutton)
			end
			radiolist = iup.radio{iup.vbox(choicebuttons)}
			vbox:append(radiolist)
			dlg:map()
			iup.Refresh(dlg)
		else
			-- no options. this is an informational display.
			okbutton.active = "YES"
			okbutton.title = "Continue"
		end
	end

	function dlg:show_cb()
		nextdlg = nil
	end

	function dlg:map_cb()
		RegisterEvent(self, "UPDATE_CHARACTER_LIST")
		RegisterEvent(self, "OPEN_SURVEY")
	end

	function dlg:OnEvent(eventname, ...)
		if eventname == "UPDATE_CHARACTER_LIST" then
			if nextdlg then
				HideDialog(ConnectingDialog)
				ShowDialog(CharSelectDialog, iup.CENTER, iup.CENTER)
				nextdlg = nil
			end
		elseif eventname == "OPEN_SURVEY" then
			local arg1, arg2 = ...
			SetQuestion(arg1, arg2)
			if EULADialog.visible ~= "YES" then
				HideDialog(ConnectingDialog)
				ShowDialog(dlg, iup.CENTER, iup.CENTER)
			end
		end
	end

	return dlg
end
SurveyDialog = CreateSurveyMenu()
SurveyDialog:map()

function testsurvey()
	ProcessEvent("OPEN_SURVEY",
[[
	This example illustrates the manner in which text in novels and other books are published. Note that each paragraph is indented and there is a single row space between paragraphs rather than the standard double-row spacing.
	Be careful with this method of text display in your web pages. It makes reading the text on a monitor difficult for some people.
	Although this style of text spacing looks pretty cool, and is made possible with the magic of CSS, something that looks cool is not always the best choice for an effective web site.
	It does play a significant role in drawing people's attention to a block of text that you want them to read. As long as that block of text isn't too long winded, you'll get their attention.
	"An example case scenario where you might wish to use this type of text formatting is when you are quoting something a person said. In which case you would use the beginning and ending quotation marks as I have done in this paragraph."



]],
		{
			"Answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 answer choice 1 ",
			"Answer choice 2",
		}
	)
end

function CreateNotificationMenu()
	return notificationdlgtemplate()
end

NotificationDialog = CreateNotificationMenu()
NotificationDialog:map()

function CreateLoadingMenu()
	local dlg, infolabel, progressbar, image
	local imgysize = gkinterface.GetYResolution()
	local imgxsize = gkinterface.GetXResolution()
	local aspect = imgysize/imgxsize
	imgysize = imgysize * 2/3
	imgxsize = imgxsize * aspect

	progressbar = iup.stationprogressbar{type="HORIZONTAL",
			LOWERCOLOR="100 149 237 255 *",
			UPPERCOLOR="0 0 0 128 *",
			minvalue=0, maxvalue=100,
			expand="NO", size=(imgxsize*0.7/(3/4)).."x12"}

	infolabel = iup.label{font=Font.H1,title="", wordwrap="YES", alignment="ACENTER", expand="HORIZONTAL"}
	image = iup.label{title="", image="images/int_loadscreen.jpg", size=imgxsize..'x'..imgysize}

	dlg = iup.dialog{
		iup.hbox{iup.fill{},
		iup.vbox{
			iup.fill{size="%16x%16"},
			iup.zbox{
				image,
				iup.vbox{iup.fill{},progressbar, iup.fill{size="%4"}},
				all="YES",
				alignment="ABOTTOM",
				expand="NO",
			},
			infolabel,
			iup.fill{},
			alignment="ACENTER",
			expand="VERTICAL",
		},iup.fill{}},
		fullscreen="YES",
		bgcolor="0 0 0",
	}

	function dlg:map_cb()
		RegisterEvent(self, "WARP_OUT_CINEMATIC_FINISHED")
		RegisterEvent(self, "JUMP_OUT_CINEMATIC_FINISHED")
		RegisterEvent(self, "SHIP_SPAWNED")
		RegisterEvent(self, "ENTERING_STATION")
		RegisterEvent(self, "SECTOR_CHANGED")
		RegisterEvent(self, "SECTOR_LOADING")
	end

	function dlg:OnEvent(eventname, ...)
		if eventname == "WARP_OUT_CINEMATIC_FINISHED" or eventname == "JUMP_OUT_CINEMATIC_FINISHED" or eventname == "SECTOR_CHANGED" then
			gkinterface.Draw3DScene(false)
			if ConnectingDialog.visible ~= "YES" and dlg.visible ~= "YES" then
				-- so both 'Entering Universe...' and this don't display at the same time
				infolabel.title = GetTip(tipindex)
				tipindex = tipindex + 1
				if tipindex > GetNumTips() then tipindex = 1 end
				infolabel.size = "HALF"
				ShowDialog(dlg, iup.CENTER, iup.CENTER)
				ShowDialog(HUD)
				progressbar.value = 0
			end
		elseif eventname == "SHIP_SPAWNED" or eventname == "ENTERING_STATION" then
			HideDialog(dlg)
		elseif eventname == "SECTOR_LOADING" then
			local percentcomplete = ...
			local v = math.floor(percentcomplete*100)
			progressbar.value = v
		end
	end

	return dlg
end

LoadingDialog = CreateLoadingMenu()
LoadingDialog:map()
