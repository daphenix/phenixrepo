					local http_send = HTTP.new()
					http_send.POST.add('data', newDataString)
					http_send.method = 'POST'
					http_send.AUTH.add(PASuite.settings.username, PASuite.settings.passkey)
					local function mycb(response)
			        
						if pName ~= nil then
						
							if (response.status == 200) then
								successUpdates1 = true
							else
								successUpdates1 = false
							end
							
						end
					end
					http_send.urlopen(PASpotter.settings.send_url, mycb)