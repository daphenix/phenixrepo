declare('helloworld', {})
helloworld.ui = {}


helloworld.ui.dlg = hwdlg



mainbox = iup.vbox{
					iup.hbox{iup.fill{},iup.label{title="\127ff6600Hello World"}, size="450x450",iup.fill{}}
				}
						
button = iup.vbox{
					iup.hbox{iup.fill{},
						iup.stationbutton{title="Close",  action=function() 
								HideDialog(helloworld.ui.dlg)
								
								
							end},
						iup.fill{} 
						   }, 
						
					}
						

function OpenHelloworldDlg()
	ShowDialog(helloworld.ui.dlg, iup.CENTER, iup.CENTER)
end



function CreateHelloworldDlg()

	iup.Append(mainbox, button)
	
	hwdlg = iup.dialog{  --everytime I see dialog I think of two people talking....now Im just rambling..
		iup.stationhighopacityframe{  --better than clear or else it gets kinda weird...now, where is my drink..ah, there it is....
			iup.stationhighopacityframebg{ 
					mainbox,
                                        button
    
			}
		},

		active = "YES",
		topmost = "YES",
		resize = "NO",
		title = "Hello World"
		
		
	}
	
    return hwdlg

end

helloworld.ui.dlg = CreateHelloworldDlg()




RegisterUserCommand('hello', OpenHelloworldDlg)
