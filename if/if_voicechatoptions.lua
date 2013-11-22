-- interface for configuring voice chat.

local VADmin = -50
local VADmax = 50
local VADoffsetbias = (VADmax-VADmin)/2

function CreateVoiceChatOptions()
	local dlg, container
	local enablevoicechat
	local okbutton, cancelbutton, helpbutton
	local voicelevel, voiceactivationlevel, volume
	local push_to_talk_mode
	local sound_ducking_level
	local agc_mode
	local apply
	local loadsettings
	local enumeratedevicesifenabled
	local enabledeviceselection
	
	local saved_vad = 0
	local saved_agc = 0
	local saved_ptt_mode = false
	local saved_enable_mode = false
	local saved_sound_ducking_level = 0
	local saved_volume_level = 100

	local saved_playback_mode
	local saved_playback_device
	local saved_capture_mode
	local saved_capture_device

	-- begin device selection

	local capture_dropdown_modes = {}
	local playback_dropdown_modes = {}
	local fill_devices_dropdown
	local playback_devs = {} --VoiceChat.GetPlaybackDevices()
	local kludge_playback_mode = 1
	local playback_modes_by_dropdown_index = {}
	local capture_devs = {} --VoiceChat.GetCaptureDevices()
	local kludge_capture_mode = 1
	local capture_modes_by_dropdown_index = {}

	-- ts 'devices' = channels
	local playback_dropdown_devices = iup.list{dropdown="YES", value = 1, expand="HORIZONTAL",
		visible_items=16,
		action=function(self, str, i, v)
--				   print("playback_dropdown_devices action cb: i: "..tostring(i).." str: "..tostring(str))
--				   print("setting playback mode to:"..tostring(kludge_playback_mode).." and device to:"..tostring(str))
				   local retcode = VoiceChat.SetPlaybackDevice(kludge_playback_mode,str)
--				   print("set returned:"..tostring(retcode))
			   end}
	-- ts 'modes' = devices (or pseudo-devices)
	local playback_dropdown_modes = iup.list{dropdown="YES", value = 1, expand="HORIZONTAL",
		visible_items=16,
		action=function(self, str, i, v)
--				   print("playback_dropdown_modes action cb: i: "..tostring(i).." str: "..tostring(str))
				   kludge_playback_mode = playback_modes_by_dropdown_index[i]
				   local defdeviceofmode = VoiceChat.GetDefaultPlaybackDeviceOfMode(kludge_capture_mode)
				   fill_devices_dropdown(playback_dropdown_devices, playback_devs, str, defdeviceofmode)
				   local retcode = VoiceChat.SetPlaybackDevice(kludge_playback_mode,defdeviceofmode)
--				   print("set returned:"..tostring(retcode))
			   end}
	local playback_device_label = iup.label{title="Playback Device: ", fgcolor=tabunseltextcolor}
	local playback_device_control = iup.hbox{playback_device_label,
		iup.vbox{playback_dropdown_modes,playback_dropdown_devices}
	}

	local capture_dropdown_devices = iup.list{dropdown="YES", value = 1, expand="HORIZONTAL",
		visible_items=16,
		action=function(self, str, i, v)
--				   print("capture_dropdown_devices action cb: i: "..tostring(i).." str: "..tostring(str))
--				   print("setting capture mode to:"..tostring(kludge_capture_mode).." and device to:"..tostring(str))
				   local retcode = VoiceChat.SetCaptureDevice(kludge_capture_mode,str)
--				   print("set returned:"..tostring(retcode))
			   end}
	local capture_dropdown_modes = iup.list{dropdown="YES", value = 1, expand="HORIZONTAL",
		visible_items=16,
		action=function(self, str, i, v)
--				   print("capture_dropdown_modes action cb: i: "..tostring(i).." str: "..tostring(str))
				   kludge_capture_mode = capture_modes_by_dropdown_index[i]
				   local defdeviceofmode = VoiceChat.GetDefaultCaptureDeviceOfMode(kludge_capture_mode)
				   fill_devices_dropdown(capture_dropdown_devices, capture_devs, str, defdeviceofmode)
				   local retcode = VoiceChat.SetCaptureDevice(kludge_capture_mode,defdeviceofmode)
--				   print("set returned:"..tostring(retcode))
			   end}
	local capture_device_label = iup.label{title="Capture Device: ", fgcolor=tabunseltextcolor}
	local capture_device_control = iup.hbox{capture_device_label,
		iup.vbox{capture_dropdown_modes,capture_dropdown_devices}
	}

	fill_devices_dropdown = function(dropdown, devs, mode, current_device)
								local devicelist = devicesByMode(devs, mode)
								local current_device_index = 1
								for j,device in ipairs(devicelist) do
									if device == current_device then
										current_device_index = j
									end
									dropdown[j] = device
								end
								dropdown[#devicelist+1] = nil
--								print("fill_devices_dropdown about to set value to: "..tostring(current_device_index))
								dropdown.value = current_device_index
							end

	-- end device selection


	okbutton = iup.stationbutton{title="OK",
		action=function() apply() HideDialog(dlg) ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER) end}
	cancelbutton = iup.stationbutton{title="Cancel",
		action=function() HideDialog(dlg) ShowDialog(OptionsDialog, iup.CENTER, iup.CENTER) end}
	helpbutton = iup.stationbutton{title="Help",
		action=function() HelpVoiceChat() end}

	push_to_talk_mode = iup.stationtoggle{title="Enable Push-To-Talk", value="OFF", expand="HORIZONTAL",
		action=function(self, state)
		end}
	enabledeviceselection = iup.stationtoggle{title="Enable Device Selection", value="OFF",
		action=function(self, state)
			enumeratedevicesifenabled()
		end}
	enablevoicechat = iup.stationtoggle{title="Enable Voice Chat", value="OFF",
		action=function(self, state)
			EnableVoiceChat(state == 1)
			loadsettings()
			local isenabled = IsVoiceChatEnabled()
			self.value = isenabled and "ON" or "OFF"
			if (not isenabled) and (state==1) then
				OpenAlarm("Unable to enable Voice Chat.", "Voice Chat Initialization failed.", "OK")
			end
		end}
	sound_ducking_level = iup.canvas{
		scrollbar="HORIZONTAL", size="200x", border="NO",
		expand="NO",
		xmin = 0, xmax=100, dx=7, posx=0,
		xstyle=1,
		scroll_cb=function(self, op, posx, posy)
			gksound.SetSoundDuckingLevel(1 - (tonumber(posx)/100))
		end,
	}
	agc_mode = iup.stationtoggle{title="Enable Microphone Automatic Gain Control", value="ON",
		action=function(self, state)
			VoiceChat.SetPreProcessorConfigValue("agc", (state==1) and "true" or "false")
		end}
	voicelevel = iup.stationprogressbar{title="(none)", active="NO", size="200x20", expand="NO", TYPE="HORIZONTAL"}
	voicelevel.minvalue = VADmin
	voicelevel.maxvalue = VADmax
	voicelevel.uppercolor = "128 128 128 128 *"
	voicelevel.lowercolor = "64 255 64 128 *"
	voicelevel.value = 0

	voiceactivationlevel = iup.canvas{
		scrollbar="HORIZONTAL", size="200x", border="NO",
		expand="NO",
		xmin = 0, xmax=(VADmax-VADmin), dx=8, posx=0,
		IMAGESCROLLTHUMB = "images/int_scrollhandlearrow.png",
		xstyle=1,
		scroll_cb=function(self, op, posx, posy)
			VoiceChat.SetPreProcessorConfigValue("voiceactivation_level", tonumber(posx)-VADoffsetbias)
		end,
	}

	volume = iup.canvas{
		scrollbar="HORIZONTAL", size="200x", border="NO",
		expand="NO",
		xmin = 0, xmax=200, dx=20, posx=saved_volume_level,
		xstyle=1,
		scroll_cb=function()
			VoiceChat.SetPlaybackConfigValue("volume_modifier", (volume.posx-100)/3.3334)
		end,
	}

	local mic_label = iup.label{title="Mic Level:", size="125x", fgcolor=tabunseltextcolor}
	local transmit_label = iup.label{title="Transmission Level:", size="125x", fgcolor=tabunseltextcolor}
	local playbackvolume_label = iup.label{title="Playback Volume:", size="125x", fgcolor=tabunseltextcolor}
	local soundducking_label = iup.label{title="Sound Ducking:", size="125x", fgcolor=tabunseltextcolor}
	container = iup.stationhighopacityframe{
		iup.stationhighopacityframebg{
			iup.vbox{
				iup.hbox{
					iup.fill{},
					iup.label{title="",image="images/teamspeak.png", size="%24x%16",expand="NO",FILTER="MIPMAPLINEAR"},
					iup.fill{},
				},
				enablevoicechat,
				iup.hbox{
					mic_label,
					voicelevel,
				},
				iup.hbox{
					transmit_label,
					voiceactivationlevel,
				},
				iup.hbox{
					playbackvolume_label,
					volume,
				},
				push_to_talk_mode,
				agc_mode,
				iup.hbox{
					soundducking_label,
					sound_ducking_level,
				},
				enabledeviceselection,
				playback_device_control,
				capture_device_control,

				iup.fill{},
				iup.label{title="Note: Voice does not transmit while this window is open."},
				iup.hbox{
					iup.fill{},
					okbutton, cancelbutton, helpbutton; gap="15"
				},
				gap=5,
			},
		},
	}

	apply = function()
		saved_volume_level = volume.posx
		saved_vad = tonumber(voiceactivationlevel.posx)-VADoffsetbias
		saved_ptt_mode = push_to_talk_mode.value == "ON"
		saved_agc = agc_mode.value == "ON"
		saved_sound_ducking_level = 1-(tonumber(sound_ducking_level.posx)/100)
		saved_enable_mode = enablevoicechat.value == "ON"

		gkini.WriteString("Vendetta", "enabledeviceselection", (enabledeviceselection.value == "ON") and 1 or 0)

		saved_playback_mode = playback_modes_by_dropdown_index[tonumber(playback_dropdown_modes.value)]
		saved_playback_device = playback_dropdown_devices[tonumber(playback_dropdown_devices.value)]
		saved_capture_mode = capture_modes_by_dropdown_index[tonumber(capture_dropdown_modes.value)]
		saved_capture_device = capture_dropdown_devices[tonumber(capture_dropdown_devices.value)]

		gkini.WriteString("Vendetta", "ptt", saved_ptt_mode and 1 or 0)
		gkini.WriteString("Vendetta", "voicechatagc", agc_mode and 1 or 0)
		gkini.WriteString("Vendetta", "voicechatVAD", saved_vad)
		gkini.WriteString("Vendetta", "enablevoicechat", saved_enable_mode and 1 or 0)
		gkini.WriteString("Vendetta", "soundduckinglevel", saved_sound_ducking_level)
		gkini.WriteString("Vendetta", "voicechatVolume", saved_volume_level)

		gkini.WriteString("Vendetta", "playbackmode", saved_playback_mode)
		gkini.WriteString("Vendetta", "playbackdevice", saved_playback_device)
		gkini.WriteString("Vendetta", "capturemode", saved_capture_mode)
		gkini.WriteString("Vendetta", "capturedevice", saved_capture_device)

	end

	dlg = iup.dialog{
		container,
		bgcolor="0 0 0 0 *",
		border="NO",menubox="NO",resize="NO",
--		size="%55x",
		defaultesc=cancelbutton,
	}

	local updatetimer = Timer()

	function dlg:show_cb()
		saved_enable_mode = IsVoiceChatEnabled()
		enablevoicechat.value = saved_enable_mode and "ON" or "OFF"

		enabledeviceselection.value = (tonumber(gkini.ReadString('Vendetta', 'enabledeviceselection', 0)) == 1) and "ON" or "OFF"

		loadsettings()
	end

	enumeratedevicesifenabled = function()
		if IsVoiceChatEnabled() and (enabledeviceselection.value == "ON") then
			playback_devs = VoiceChat.GetPlaybackDevices()
--			print(".1 - got playback devs")
			saved_playback_mode, saved_playback_device = VoiceChat.GetCurrentPlaybackModeAndDevice()
--			print(".2 - got saved_playback_mode:"..tostring(saved_playback_mode).." and saved_playback_device:"..tostring(saved_playback_device).." type: "..type(saved_playback_device))
			fillModesDropdown(playback_devs,playback_dropdown_modes,saved_playback_mode,playback_modes_by_dropdown_index)
--			print(".3 - filled playback modes dropdown")
			fill_devices_dropdown(playback_dropdown_devices, playback_devs, saved_playback_mode, saved_playback_device)
--			print(".4 - filled playback devices dropdown")
			capture_devs = VoiceChat.GetCaptureDevices()
--			print(".5 - got capture devs")
			saved_capture_mode, saved_capture_device = VoiceChat.GetCurrentCaptureModeAndDevice()
--			print(".6 - got saved_capture_mode:"..tostring(saved_capture_mode).." and saved_capture_device:"..tostring(saved_capture_device))
			fillModesDropdown(capture_devs,capture_dropdown_modes,saved_capture_mode,capture_modes_by_dropdown_index)
--			print(".7 - filled capture modes dropdown")
			fill_devices_dropdown(capture_dropdown_devices, capture_devs, saved_capture_mode, saved_capture_device)
--			print(".8 - filled capture devices dropdown")

			playback_dropdown_devices.active = "YES"
			playback_dropdown_modes.active = "YES"
			capture_dropdown_devices.active = "YES"
			capture_dropdown_modes.active = "YES"

			playback_device_label.fgcolor = tabunseltextcolor
			capture_device_label.fgcolor = tabunseltextcolor
			playback_dropdown_devices.fgcolor = "255 255 255"
			playback_dropdown_modes.fgcolor = "255 255 255"
			capture_dropdown_devices.fgcolor = "255 255 255"
			capture_dropdown_modes.fgcolor = "255 255 255"
		else
			saved_playback_mode, saved_playback_device = VoiceChat.GetDefaultPlaybackModeAndDevice()
			saved_capture_mode, saved_capture_device = VoiceChat.GetDefaultCaptureModeAndDevice()

			playback_dropdown_devices.active = "NO"
			playback_dropdown_modes.active = "NO"
			capture_dropdown_devices.active = "NO"
			capture_dropdown_modes.active = "NO"

			playback_device_label.fgcolor = "128 128 128"
			capture_device_label.fgcolor = "128 128 128"
			playback_dropdown_devices.fgcolor = "128 128 128"
			playback_dropdown_modes.fgcolor = "128 128 128"
			capture_dropdown_devices.fgcolor = "128 128 128"
			capture_dropdown_modes.fgcolor = "128 128 128"
		end
	end

	loadsettings = function()
		local keys = gkinterface.GetBindsForCommand("+ptt")
		push_to_talk_mode.title = "Enable Push-To-Talk (currently bound to "..((#keys>0) and table.concat(keys, ",") or "nothing")..")"

		if not IsVoiceChatEnabled() then
			voicelevel.active = "NO"
			voiceactivationlevel.active = "NO"
			volume.active = "NO"
			push_to_talk_mode.active = "NO"
			agc_mode.active = "NO"
			sound_ducking_level.active = "NO"
			enabledeviceselection.active = "NO"
			playback_dropdown_devices.active = "NO"
			playback_dropdown_modes.active = "NO"
			capture_dropdown_devices.active = "NO"
			capture_dropdown_modes.active = "NO"

			mic_label.fgcolor = "128 128 128"
			transmit_label.fgcolor = "128 128 128"
			playbackvolume_label.fgcolor = "128 128 128"
			soundducking_label.fgcolor = "128 128 128"
			playback_device_label.fgcolor = "128 128 128"
			capture_device_label.fgcolor = "128 128 128"
			playback_dropdown_devices.fgcolor = "128 128 128"
			playback_dropdown_modes.fgcolor = "128 128 128"
			capture_dropdown_devices.fgcolor = "128 128 128"
			capture_dropdown_modes.fgcolor = "128 128 128"
			
			voiceactivationlevel.posx = (VoiceChat.GetPreProcessorConfigValue("voiceactivation_level") or 0) + VADoffsetbias
			return
		else
			voicelevel.active = "YES"
			voiceactivationlevel.active = "YES"
			volume.active = "YES"
			push_to_talk_mode.active = "YES"
			agc_mode.active = "YES"
			sound_ducking_level.active = "YES"
			enabledeviceselection.active = "YES"
			playback_dropdown_devices.active = "YES"
			playback_dropdown_modes.active = "YES"
			capture_dropdown_devices.active = "YES"
			capture_dropdown_modes.active = "YES"

			mic_label.fgcolor = tabunseltextcolor
			transmit_label.fgcolor = tabunseltextcolor
			playbackvolume_label.fgcolor = tabunseltextcolor
			soundducking_label.fgcolor = tabunseltextcolor
			playback_device_label.fgcolor = tabunseltextcolor
			capture_device_label.fgcolor = tabunseltextcolor
			playback_dropdown_devices.fgcolor = "255 255 255"
			playback_dropdown_modes.fgcolor = "255 255 255"
			capture_dropdown_devices.fgcolor = "255 255 255"
			capture_dropdown_modes.fgcolor = "255 255 255"
		end

		if VoiceChat.IsInitialized() then
			VoiceChat.SetLocalTestMode(true)
		end

		enumeratedevicesifenabled()

		updatetimer:SetTimeout(50, function()
				local level = VoiceChat.GetPreProcessorInfoValueFloat("decibel_last_period") or -20
				voicelevel.value = tonumber(level)
				
				updatetimer:SetTimeout(50)
			end)

		saved_volume_level = ((VoiceChat.GetPlaybackConfigValueAsFloat("volume_modifier", volume.posx) or 0)*3.3334) + 100
		volume.posx = saved_volume_level

		saved_sound_ducking_level = gksound.GetSoundDuckingLevel()
		sound_ducking_level.posx = (1-saved_sound_ducking_level)*100

		saved_ptt_mode = VoiceChat.GetPreProcessorConfigValue("vad") == "false"
		push_to_talk_mode.value = saved_ptt_mode and "ON" or "OFF"

		-- force VAD to on so level meter works. do this after reading it to see if ptt is on. it will be re-set in SetPTTMode in hide_cb
		VoiceChat.SetPreProcessorConfigValue("vad", "true")

		saved_agc = VoiceChat.GetPreProcessorConfigValue("agc") == "true"
		agc_mode.value = saved_agc and "ON" or "OFF"

		saved_vad = VoiceChat.GetPreProcessorConfigValue("voiceactivation_level") or 0
		voiceactivationlevel.posx = tonumber(saved_vad) + VADoffsetbias
	end

	function dlg:hide_cb()
		updatetimer:Kill()

		if saved_playback_mode and saved_playback_device then
			VoiceChat.SetPlaybackDevice(saved_playback_mode, saved_playback_device)
			saved_playback_mode, saved_playback_device = VoiceChat.GetCurrentPlaybackModeAndDevice()
			if (not saved_playback_mode) or (saved_playback_mode == -1) then
				saved_playback_mode, saved_playback_device = VoiceChat.GetDefaultPlaybackModeAndDevice()
				if saved_playback_mode and saved_playback_device then
					VoiceChat.SetPlaybackDevice(saved_playback_mode, saved_playback_device)
					gkini.WriteString("Vendetta", "playbackmode", saved_playback_mode)
					gkini.WriteString("Vendetta", "playbackdevice", saved_playback_device)
				end
			end
		end
		if saved_capture_mode and saved_capture_device then
			VoiceChat.SetCaptureDevice(saved_capture_mode, saved_capture_device)
			saved_capture_mode, saved_capture_device = VoiceChat.GetCurrentCaptureModeAndDevice()
			if (not saved_capture_mode) or (saved_capture_mode == -1) then
				saved_capture_mode, saved_capture_device = VoiceChat.GetDefaultCaptureModeAndDevice()
				if saved_capture_mode and saved_capture_device then
					VoiceChat.SetCaptureDevice(saved_capture_mode, saved_capture_device)
					gkini.WriteString("Vendetta", "capturemode", saved_capture_mode)
					gkini.WriteString("Vendetta", "capturedevice", saved_capture_device)
				end
			end
		end

		VoiceChat.SetLocalTestMode(false)

		VoiceChat.SetPlaybackConfigValue("volume_modifier", (saved_volume_level-100)/3.3334)
		VoiceChat.SetPreProcessorConfigValue("voiceactivation_level", saved_vad)
		VoiceChat.SetPreProcessorConfigValue("agc", saved_agc and "true" or "false")
		VoiceChat.SetPTTMode(saved_ptt_mode)
		EnableVoiceChat(saved_enable_mode)
		gksound.SetSoundDuckingLevel(saved_sound_ducking_level)
	end

	dlg:map()

	return dlg
end

VoiceChatOptions = CreateVoiceChatOptions()

function fillModesDropdown(devs,dropdown,default_dev,mode_id_lookup)
	local default_dev_index
	for i,modetab in ipairs(devs) do
--		print("fillmodesdropdown: def:"..tostring(default_dev).." modetab[1]: "..tostring(modetab[1]).." modetable[2]:"..tostring(modetab[2]))
		if modetab[2] == default_dev then
			default_dev_index = i
		end
		dropdown[i] = modetab[1]
		mode_id_lookup[i] = modetab[2]
	end
	dropdown.value = default_dev_index or 1
end

function devicesByMode(devs, mode)
	for _,modetab in ipairs(devs) do
		-- silly, but it makes it work for the string or number form- ie the value get-default returns and the value of the dropdown
		if modetab[1] == mode or modetab[2] == mode then
--			print("devicesByMode found matching table: "..StrTable(modetab))
			local rtab = {}
			for _,dtup in ipairs(modetab[3]) do
				table.insert(rtab,dtup[1])
			end
			return rtab
		end
	end
--	print("devicesByMode didnt find a matching mode! mode: "..tostring(mode).." devs: "..StrTable(devs))
--	printtable(devs)
	return {"devicesByMode failed"}
end