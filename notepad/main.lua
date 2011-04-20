---Written by Interstellar
---Thanks go to xXxDSMer for helping me test it



declare('notepad', {})
notepad.ui = {}
textbox1 = iup.multiline{Value="", size = "400x400"}
loadbutton = iup.stationbutton{title = "Load"}
savebutton = iup.stationbutton{title = "Save"}
notepad.ui.dlg = npdlg



textbox = iup.vbox{
					iup.hbox{iup.fill{},textbox1, size="450x450",iup.fill{}}
				}

						
buttons = iup.vbox{
					iup.hbox{
						iup.stationbutton{title="Close",  action=function() 
								HideDialog(notepad.ui.dlg)
								
								
							end}, loadbutton, savebutton
						   }
					}
						

function OpenNotePadDlg()


	ShowDialog(notepad.ui.dlg, iup.CENTER, iup.CENTER)


end



function CreateNotePadDlg()

	textbox1.value = ""
	iup.Append(textbox, buttons)

	
	npdlg = iup.dialog{  --everytime I see dialog I think of two people talking....now Im just rambling..
		iup.stationhighopacityframe{  --better than clear or else it gets kinda weird...now, where is my drink..ah, there it is....
			iup.stationhighopacityframebg{ 
					textbox,
					buttons,

			}
		},

		active = "YES",
		topmost = "YES",
		resize = "NO",
		title = "NotePad v. 1"
		
		
	}
	
    return npdlg

end

notepad.ui.dlg = CreateNotePadDlg()

function loadbutton:action()
	local notes1 = LoadSystemNotes(1800)
    textbox1.value = notes1
end

function savebutton:action()
    local notes2 = iup.GetAttribute(textbox1, "Value")
	SaveSystemNotes(notes2, 1800)
end



RegisterUserCommand('notepad', OpenNotePadDlg)