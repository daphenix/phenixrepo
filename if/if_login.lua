local bunch_of_stations = {
	"lua/uni/station_corp_4_01.lua",
	"lua/uni/station_corp_4_02.lua",
	"lua/uni/station_corp_4_03.lua",
	"lua/uni/station_itani_4_01.lua",
	"lua/uni/station_itani_4_02.lua",
	"lua/uni/station_itani_4_03.lua",
	"lua/uni/station_itani_4_04.lua",
	"lua/uni/station_nt_4_01.lua",
	"lua/uni/station_nt_4_02.lua",
	"lua/uni/station_nt_4_03.lua",
	"lua/uni/station_serco_4_01.lua",
	"lua/uni/station_serco_4_02.lua",
	"lua/uni/station_serco_4_03.lua",
}
	
local cinematic_on = false

local function close_cinematic()
	cinematic_on = false
	Game.StopLoginCinematic()
	clearscene()
end

local function start_cinematic()
	if not cinematic_on then
		Game.StartLoginCinematic()
--		loadscene(bunch_of_stations[math.random((#bunch_of_stations))], 200)
		loadscene(bunch_of_stations[3], 200)
		cinematic_on = true
	end
end

function CreateLoginDialog()
	local dlg
	local initialloginname = gkini.ReadString("Vendetta", "Username", "")
	local username = iup.text{value=initialloginname, size="354",font=22,nc=32,border="NO",image=IMAGE_DIR.."text_input_mouseover.png",marginx=4,marginy=4,MOUSEOVERBOXCOLOR="255 255 255 255 *",BOXCOLOR="192 192 192 255 *",blendmode="ALPHA"}
	local password = iup.text{password="YES",size="354",font=22,border="NO",image=IMAGE_DIR.."text_input_mouseover.png",marginx=4,marginy=4,MOUSEOVERBOXCOLOR="255 255 255 255 *",BOXCOLOR="192 192 192 255 *",blendmode="ALPHA"}
	local loginbutton = iup.stationbutton{title="C o n n e c t",size="100",font=26,
		fgcolor="255 255 255",
		cx=612-209,
		cy=329-51,
		size="162x41",
		action=function()
			if username.value == "" then
				iup.SetFocus(username)
				return
			elseif password.value == "" then
				iup.SetFocus(password)
				return
			end
			gkini.WriteString("Vendetta", "Username", username.value)
			local pword = password.value
			password.value = ""
			Login(username.value, pword)
			HideDialog(dlg)
			ConnectingDialog:SetMessage("Connecting...", "Cancel", function() Logout() end)
			ShowDialog(ConnectingDialog, iup.CENTER, iup.CENTER)
			dlg.startfocus = password
		end}
	local infobutton = iup.stationbutton{title="Credits",size="100",font=18,
		hotkey=iup.K_c,
		action=function()
			HideDialog(dlg)
			ShowDialog(CreditsDialog, iup.CENTER, iup.CENTER)
		end}
	local helpbutton = iup.stationbutton{title="Help",size="100",font=18,
		hotkey=iup.K_h,
		action=function()
			HideDialog(dlg)
			ShowDialog(LoginHelpDialog, iup.CENTER, iup.CENTER)
		end}
	local optionsbutton = iup.stationbutton{title="Options",size="100",font=18,
		hotkey=iup.K_o,
		action=function()
			HideDialog(dlg)
			OptionsDialog:SetMenuMode(1, dlg)
			ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER)
		end}
	local quitbutton = iup.stationbutton{title="Quit",size="100",font=18,
		hotkey=iup.K_q,
		action = function()
			close_cinematic()
			HideDialog(dlg)
			Game.Quit()
		end }
	
	local startfocus
	if initialloginname == "" then
		startfocus = username
	else
		startfocus = password
	end
	dlg = iup.dialog{
		iup.vbox{
			iup.hbox{
				iup.fill{},
				iup.label{title="", image="images/new/guild_logo.png", size="256x64"},
			},
			iup.fill{},
			iup.hbox{
				iup.fill{},
				iup.cbox{
					iup.label{
						title="",
						image=IMAGE_DIR.."main.login.panel.png",
						size="560x290",
						segmented=".5 .5625 .5 .5625",
						cx=52,
						cy=39,
					},
					iup.label{
						title="",
						image="images/new/vendetta_logo.png",
						size="256x128",
						cx=0,
						cy=0,
					},
					iup.vbox{
						cx=82,
						cy=131,
						gap=14,
						helpbutton,
						infobutton,
						optionsbutton,
						quitbutton,
					},
					iup.vbox{
						cx=52+178,
						cy=131+5,
						size="354x",
						iup.label{title="U s e r  N a m e:", font=22},
						username,
						iup.fill{size="16"},
						iup.label{title="P a s s w o r d:", font=22},
						password,
					},
					loginbutton,
					size="612x329",
				},
				iup.fill{},
				margin="93x93",
			},
			margin="0x15",
		},
		fullscreen="YES",
		startfocus = startfocus,
		defaultesc = quitbutton,
		defaultenter = loginbutton,
		bgcolor = "0 0 0 0 *",
	}
	

	function dlg:show_cb()
		gkini.WriteInt("Vendetta", "firsttime", 0)
		start_cinematic()
		gkinterface.Draw3DScene(Game.GetCVar("rRenderStationInMenu") == 1)
		iup.SetFocus(password)
	end
	dlg.close_cinematic = close_cinematic
	
	function dlg:map_cb()
		RegisterEvent(self, "LOGIN_FAILED")
		RegisterEvent(self, "LOGIN_SUCCESSFUL")
	end
	
	function dlg:OnEvent(eventname, ...)
		if eventname == "LOGIN_FAILED" then
			-- dumb, this event is multiplexed.
			if CharSelectDialog.visible ~= "YES" and
				CharCreateDialog.visible ~= "YES" and
				CharCreateFailedDialog.visible ~= "YES" then
				HideDialog(ConnectingDialog)
				local failstring = ...
				ConnectingDialog:SetMessage(failstring, "OK", function() HideDialog(ConnectingDialog) ShowDialog(dlg, iup.CENTER, iup.CENTER) end)
				ShowDialog(ConnectingDialog, iup.CENTER, iup.CENTER)
			end
		elseif eventname == "LOGIN_SUCCESSFUL" then
			HideDialog(dlg)
			ConnectingDialog:SetMessage("Getting characters...", "Cancel", function() Logout() end)
			HideDialog(ConnectingDialog)
			ShowDialog(EULADialog, iup.CENTER, iup.CENTER)
		end
	end
	
	dlg:map()
	
	return dlg
end


function CreateFirstTimeNewAccountDialog(loginDialog)
	local dlg
	
	local msg = "This appears to be the first time you have run Vendetta Online on this computer. Vendetta Online requires a game account to be created before you can play. A trial account is completely free and requires no billing information. Would you like to create an account now?"
	local msg2 = "Note: Vendetta will minimize and a web browser will open. When you are finished, click on the Vendetta task in the Windows Task Bar."
	
	local newaccountbutton = iup.stationbutton{title="Create New Account",
		action=function()
			-- minimize and open a web browser to https://www.vendetta-online.com/x/newacct
			Game.OpenWebBrowser("https://www.vendetta-online.com/x/newacct")
			HideDialog(dlg)
			ShowDialog(loginDialog)
		end}
	local alreadyhavebutton = iup.stationbutton{title="I Already Have an Account",
		action=function()
			HideDialog(dlg)
			ShowDialog(loginDialog)
		end}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						expand="NO",
						iup.vbox{
							iup.label{title="Welcome to Vendetta Online!", wordwrap="YES", size="%50x"},
							iup.label{title=msg, wordwrap="YES", size="%50x"},
							iup.label{title=msg2, wordwrap="YES", size="%50x"},
							iup.fill{},
							iup.hbox{
								iup.fill{},
								newaccountbutton,
								iup.fill{},
								alreadyhavebutton,
								iup.fill{},
							},
							gap="15",
							margin="15x15",
						},
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		fullscreen="YES",
		bgcolor = "0 0 0 0 *",
	}
	

	function dlg:show_cb()
		start_cinematic()
		gkinterface.Draw3DScene(Game.GetCVar("rRenderStationInMenu") == 1)
	end
	
	function dlg:map_cb()
	end
	
	function dlg:OnEvent(eventname, ...)
	end
	
	dlg:map()
	
	return dlg
end

function CreateFirstTimeAndroidModeDialog(loginDialog)
	local dlg
	
	local msg = "This appears to be the first time you have run Vendetta Online on this device. Please choose the type of device."
	local msg2 = "Note: You can change this setting in the Input section of the Options menu."
	
	local tabletbutton = iup.stationbutton{title="Tablet",
		action=function()
			-- bind accelerometer
			gkinterface.BindCommand(1 + 2147483648, "Turn")
			gkinterface.BindCommand(2 + 2147483648, "Pitch")
			-- turn off mouselook
			gkinterface.SetMouseLookMode(false)
			-- enable touch mode
			gkinterface.EnableTouchMode(true)
			HUD:Reload()
			HideDialog(dlg)
			ShowDialog(loginDialog)
		end}
	local netbookbutton = iup.stationbutton{title="Netbook",
		action=function()
			-- unbind accelerometer
			gkinterface.BindCommand(1 + 2147483648, "")
			gkinterface.BindCommand(2 + 2147483648, "")
			-- turn on mouselook
			gkinterface.SetMouseLookMode(true)
			-- disable touch mode
			gkinterface.EnableTouchMode(false)
			HUD:Reload()
			HideDialog(dlg)
			ShowDialog(loginDialog)
		end}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						expand="NO",
						iup.vbox{
							iup.label{title="Welcome to Vendetta Online!", wordwrap="YES", size="%50x"},
							iup.label{title=msg, wordwrap="YES", size="%50x"},
							iup.label{title=msg2, wordwrap="YES", size="%50x"},
							iup.fill{},
							iup.hbox{
								iup.fill{},
								tabletbutton,
								iup.fill{},
								netbookbutton,
								iup.fill{},
							},
							gap="15",
							margin="15x15",
						},
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		fullscreen="YES",
		bgcolor = "0 0 0 0 *",
	}
	

	function dlg:show_cb()
		start_cinematic()
		gkinterface.Draw3DScene(Game.GetCVar("rRenderStationInMenu") == 1)
	end
	
	function dlg:map_cb()
	end
	
	function dlg:OnEvent(eventname, ...)
	end
	
	dlg:map()
	
	return dlg
end

