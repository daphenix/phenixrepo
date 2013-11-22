function CreateMissionAbortMenu()
	local dlg
	local yes_cb, no_cb

	yes_cb = function(loadout)
		if dlg.yes_fn then dlg.yes_fn() end
		HideDialog(dlg)
	end

	no_cb = function()
		if dlg.no_fn then dlg.no_fn() end
		HideDialog(dlg)
	end

	local button1 = iup.stationbutton{title="Yes",action=yes_cb}
	local button2 = iup.stationbutton{title="No",action=no_cb}

	dlg = iup.dialog{
		iup.stationhighopacityframe{
			iup.stationhighopacityframebg{
				iup.vbox{
					iup.hbox{
						iup.label{font=Font.H1,title="Are you sure you want to abort this mission?"},
						button1,
						button2,
						gap=6,
					},
					gap=6,
					alignment="ACENTER",
				},
			},
		},
		defaultenter = button1,
		defaultesc = button2,
		border="NO",
		resize="NO",
		menubox="NO",
		bgcolor = "0 0 0 0 *",
		topmost="YES",
	}

	return dlg
end

MissionAbortDialog = CreateMissionAbortMenu()
MissionAbortDialog:map()

function CreateMissionPromptMenu()
	local dlg
	local body
	local button1, button2
	local wait_for_MISSION_ADDED = false

	body = iup.stationhighopacitysubmultiline{
		readonly="YES",
		expand="YES",
	}
	button1 = iup.stationbutton{title="",
		action=function(self)
			if button1.title == "Abort" then
				function MissionAbortDialog.yes_fn()
					SendMissionQuestionResponse(1)
					HideDialog(MissionPromptDialog)
				end
				MissionAbortDialog.no_fn = nil
				ShowDialog(MissionAbortDialog, iup.CENTER, iup.CENTER)
				return
			else
				wait_for_MISSION_ADDED = true
			end
			SendMissionQuestionResponse(1)
			HideDialog(MissionPromptDialog)
		end,
	}
	button2 = iup.stationbutton{title="",
		action=function(self)
			SendMissionQuestionResponse(0)
			HideDialog(MissionPromptDialog)
		end,
	}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.vbox{
						body,
						iup.stationhighopacityframebg{
							iup.hbox{iup.fill{},button1,iup.fill{},button2,iup.fill{}},
						},
					},
					size = "HALFxHALF",
					expand="NO",
				},
				iup.fill{},
			},
			iup.fill{},
		},
		fullscreen="YES",
		bgcolor="0 0 0 128 *",
	}

	function dlg:map_cb()
		RegisterEvent(self, "MISSION_QUESTION_OPEN")
	end

	function dlg:OnEvent(eventname, ...)
		if eventname == "MISSION_QUESTION_OPEN" then
			local arg1, arg2, arg3 = ...
			button1.title = arg2
			button2.title = arg3
			ShowDialog(dlg, iup.CENTER, iup.CENTER)
			body.value = arg1
			body.scroll = "TOP"
		end
	end

	return dlg
end

MissionPromptDialog = CreateMissionPromptMenu()
MissionPromptDialog:map()
