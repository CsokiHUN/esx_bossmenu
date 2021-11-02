PlayerJob = {}
PlayerData = false
isLoggedIn = false

Keys = {
	["ESC"] = 322,
	["F1"] = 288,
	["F2"] = 289,
	["F3"] = 170,
	["F5"] = 166,
	["F6"] = 167,
	["F7"] = 168,
	["F8"] = 169,
	["F9"] = 56,
	["F10"] = 57,
	["~"] = 243,
	["1"] = 157,
	["2"] = 158,
	["3"] = 160,
	["4"] = 164,
	["5"] = 165,
	["6"] = 159,
	["7"] = 161,
	["8"] = 162,
	["9"] = 163,
	["-"] = 84,
	["="] = 83,
	["BACKSPACE"] = 177,
	["TAB"] = 37,
	["Q"] = 44,
	["W"] = 32,
	["E"] = 38,
	["R"] = 45,
	["T"] = 245,
	["Y"] = 246,
	["U"] = 303,
	["P"] = 199,
	["["] = 39,
	["]"] = 40,
	["ENTER"] = 18,
	["CAPS"] = 137,
	["A"] = 34,
	["S"] = 8,
	["D"] = 9,
	["F"] = 23,
	["G"] = 47,
	["H"] = 74,
	["K"] = 311,
	["L"] = 182,
	["LEFTSHIFT"] = 21,
	["Z"] = 20,
	["X"] = 73,
	["C"] = 26,
	["V"] = 0,
	["B"] = 29,
	["N"] = 249,
	["M"] = 244,
	[","] = 82,
	["."] = 81,
	["LEFTCTRL"] = 36,
	["LEFTALT"] = 19,
	["SPACE"] = 22,
	["RIGHTCTRL"] = 70,
	["HOME"] = 213,
	["PAGEUP"] = 10,
	["PAGEDOWN"] = 11,
	["DELETE"] = 178,
	["LEFT"] = 174,
	["RIGHT"] = 175,
	["TOP"] = 27,
	["DOWN"] = 173,
	["NENTER"] = 201,
	["N4"] = 108,
	["N5"] = 60,
	["N6"] = 107,
	["N+"] = 96,
	["N-"] = 97,
	["N7"] = 117,
	["N8"] = 61,
	["N9"] = 118,
}

local isInMenu = false

CreateThread(function()
	PlayerData = ESX.GetPlayerData()
	if PlayerData then
		PlayerJob = PlayerData.job
		isLoggedIn = true
	end
end)

RegisterNetEvent("esx:playerLoaded", function(data)
	Wait(1000)
	PlayerData = data
	PlayerJob = PlayerData.job
	isLoggedIn = true
end)

RegisterNetEvent("esx:setJob", function(job)
	Wait(500)
	PlayerJob = job
end)

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(true)
	AddTextComponentString(text)
	SetDrawOrigin(x, y, z, 0)
	DrawText(0.0, 0.0)
	local factor = (string.len(text)) / 370
	DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 20, 0, 0, 75)
	ClearDrawOrigin()
end

function getMenuData()
	local p1 = promise.new()
	local p2 = promise.new()

	ESX.TriggerServerCallback("esx_society:getJob", function(jobdata)
		p1:resolve(jobdata)
	end, PlayerJob.name)

	ESX.TriggerServerCallback("esx_society:getEmployees", function(employees)
		p2:resolve(employees)
	end, PlayerJob.name)

	local jobdata = Citizen.Await(p1)
	local employees = Citizen.Await(p2)

	return employees, jobdata
end

function updateFactionMoney()
	ESX.TriggerServerCallback("esx_society:getSocietyMoney", function(money)
		SendNUIMessage({
			open = true,
			class = "refresh-society",
			amount = money,
		})
	end, PlayerJob.name)
end

CreateThread(function()
	while true do
		Wait(5)
		if isLoggedIn then
			if PlayerJob and PlayerJob.name then
				local pos = GetEntityCoords(PlayerPedId())
				for jobName, markerCoords in pairs(Config.Jobs) do
					if jobName == PlayerJob.name and PlayerJob.grade_name == "boss" then
						local distance = #(pos - markerCoords)
						local text = "Boss Menu"

						if distance < 10 then
							if distance < 1 then
								text = "~g~E~w~ - Boss Menu"
								if IsControlJustPressed(0, Keys["E"]) then
									ESX.TriggerServerCallback("esx_society:isBoss", function(isBoss)
										if not isBoss then
											return
										end
										CreateThread(function()
											local employees, jobdata = getMenuData()
											TriggerEvent("qb-bossmenu:client:openMenu", employees, jobdata)
										end)
									end, jobName)
								end
							end

							DrawText3D(markerCoords.x, markerCoords.y, markerCoords.z, text)
							DrawMarker(
								25,
								markerCoords.x,
								markerCoords.y,
								markerCoords.z - 0.96,
								0,
								0,
								0,
								0,
								0,
								0,
								1.0,
								1.0,
								1.0,
								255,
								255,
								255,
								200,
								0,
								0,
								0,
								0
							)
						end
						break
					end
				end
			else
				Wait(7500)
			end
		end
	end
end)

RegisterNetEvent("qb-bossmenu:client:openMenu")
AddEventHandler("qb-bossmenu:client:openMenu", function(employees, jobdata)
	local employeesHTML, gradesHTML, recruitHTML = "", "", ""

	for _, player in pairs(employees) do
		if player.name and player.job then
			if player.job.grade and player.job.grade_name then
				if player.job.grade_name == "boss" then
					employeesHTML = employeesHTML
						.. [[<div class='player-box box-shadow option-enabled' id="player-]]
						.. player.identifier
						.. [["><span id='option-text'>]]
						.. player.name
						.. " ["
						.. player.job.grade_label
						.. [[]</span></div>]]
				else
					employeesHTML = employeesHTML
						.. [[<div class='player-box box-shadow' id="player-]]
						.. player.identifier
						.. [["><span class='hoster-options' id="playeroptions-]]
						.. player.identifier
						.. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]]
						.. player.identifier
						.. [[" class="fas fa-angle-double-up gradeschange"></i>  <i id="player-]]
						.. player.identifier
						.. [[" class="fas fa-user-slash fireemployee"></i></span></span><span id='option-text'>]]
						.. player.name
						.. " ["
						.. player.job.grade_label
						.. [[]</span></div>]]
				end
			end
		end
	end

	-- Grades sorted by esx_society
	-- local max = 0
	-- for k, v in pairs(jobdata.grades) do
	-- 	if tonumber(k) then
	-- 		if tonumber(k) > max then
	-- 			max = tonumber(k)
	-- 		end
	-- 	end
	-- end

	for level = 1, #jobdata.grades do
		local grade = jobdata.grades[level]

		if grade then
			if grade.name == "boss" then
				gradesHTML = gradesHTML
					.. [[<div class='grade-box box-shadow option-enabled' id="grade-]]
					.. tostring(grade.grade)
					.. [["><span id='option-text'>]]
					.. grade.label
					.. [[</span></div>]]
			else
				gradesHTML = gradesHTML
					.. [[<div class='grade-box box-shadow' id="grade-]]
					.. tostring(grade.grade)
					.. [["><span id='option-text'>]]
					.. grade.label
					.. [[</span></div>]]
			end
		end
	end

	isInMenu = true
	SetNuiFocus(true, true)
	SendNUIMessage({
		open = true,
		class = "open",
		employees = employeesHTML,
		grades = gradesHTML,
	})

	updateFactionMoney()
end)

RegisterNetEvent("qb-bossmenu:client:refreshPage")
AddEventHandler("qb-bossmenu:client:refreshPage", function(data, list)
	if data == "employee" then --Finished
		local employeesHTML = ""
		for _, player in pairs(list) do
			if player.name and player.job then
				if player.job.grade ~= nil and player.job.grade_name then
					if player.job.grade_name == "boss" then
						employeesHTML = employeesHTML
							.. [[<div class='player-box box-shadow option-enabled' id="player-]]
							.. player.identifier
							.. [["><span id='option-text'>]]
							.. player.name
							.. " ["
							.. player.job.grade_label
							.. [[]</span></div>]]
					else
						employeesHTML = employeesHTML
							.. [[<div class='player-box box-shadow' id="player-]]
							.. player.identifier
							.. [["><span class='hoster-options' id="playeroptions-]]
							.. player.identifier
							.. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]]
							.. player.identifier
							.. [[" class="fas fa-angle-double-up gradeschange"></i>  <i id="player-]]
							.. player.identifier
							.. [[" class="fas fa-user-slash fireemployee"></i></span></span><span id='option-text'>]]
							.. player.name
							.. " ["
							.. player.job.grade_label
							.. [[]</span></div>]]
					end
				end
			end
		end
		isInMenu = true
		SendNUIMessage({
			open = true,
			class = "refresh-players",
			employees = employeesHTML,
		})
	elseif data == "recruits" then --finished
		local recruitsHTML = ""

		if #list > 0 then
			for _, player in pairs(list) do
				recruitsHTML = recruitsHTML
					.. [[<div class='player-box box-shadow' id="player-]]
					.. player.source
					.. [["><span class='hoster-options' id="playeroptions-]]
					.. player.source
					.. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]]
					.. player.source
					.. [[" class="fas fa-user-tag givejob"></i></span></span><span id='option-text'>]]
					.. player.name
					.. "</span></div>"
			end
		else
			recruitsHTML =
				[[<div class='player-box box-shadow option-enabled'><span class='hoster-options'"><span style="position: relative; top: 15%; margin-left: 27%;"></span></span><span id='option-text'>There is no players nearby.</span></div>]]
		end

		isInMenu = true
		SendNUIMessage({
			open = true,
			class = "refresh-recruits",
			recruits = recruitsHTML,
		})
	end
end)

RegisterNUICallback("openStash", function(data)
	isInMenu = false
	SendNUIMessage({ open = false })
	SetNuiFocus(false, false)

	TriggerEvent("esx_inventoryhud:openStorageInventory", "society_" .. PlayerJob.name)
end)

-- RegisterNUICallback("outfit", function(data)
-- 	isInMenu = false
-- 	SendNUIMessage({ open = false })
-- 	SetNuiFocus(false, false)

-- 	print("outfit menu")
-- 	TriggerEvent("qb-clothes:client:openOutfitMenu")
-- end)

RegisterNUICallback("giveJob", function(data)
	TriggerServerEvent("qb-bossmenu:server:giveJob", data)
end)

RegisterNUICallback("openRecruit", function(data)
	CreateThread(function()
		local playerPed = PlayerPedId()
		local myCoords = GetEntityCoords(playerPed)
		local players = {}
		for k, v in pairs(GetActivePlayers()) do
			if v and v ~= PlayerId() then
				local ped = GetPlayerPed(v)
				if ped and #(GetEntityCoords(ped) - myCoords) < 20.0 then
					table.insert(players, GetPlayerServerId(v))
				end
			end
		end

		TriggerServerEvent("qb-bossmenu:server:updateNearbys", players)
	end)
end)

RegisterNUICallback("changeGrade", function(data)
	TriggerServerEvent("qb-bossmenu:server:updateGrade", data)

	Wait(1000)

	ESX.TriggerServerCallback("esx_society:getEmployees", function(employees)
		TriggerEvent("qb-bossmenu:client:refreshPage", "employee", employees)
	end, PlayerJob.name)
end)

RegisterNUICallback("fireEmployee", function(data)
	ESX.TriggerServerCallback("esx_society:setJob", function()
		Wait(500)
		ESX.TriggerServerCallback("esx_society:getEmployees", function(employees)
			TriggerEvent("qb-bossmenu:client:refreshPage", "employee", employees)
		end, PlayerJob.name)
	end, data.source, "unemployed", 0, "fire")
end)

RegisterNUICallback("closeNUI", function()
	isInMenu = false
	SetNuiFocus(false, false)
end)

RegisterNUICallback("withdraw", function(data)
	local amount = tonumber(data.amount)
	TriggerServerEvent("esx_society:withdrawMoney", PlayerJob.name, amount)

	Wait(1000)
	updateFactionMoney()
end)

RegisterNUICallback("deposit", function(data)
	local amount = tonumber(data.amount)
	TriggerServerEvent("esx_society:depositMoney", PlayerJob.name, amount)

	Wait(1000)
	updateFactionMoney()
end)

RegisterCommand("closeboss", function()
	isInMenu = false
	SendNUIMessage({
		open = false,
	})
	SetNuiFocus(false, false)
end)

function tprint(t)
	print(ESX.DumpTable(t))
end
