function isBoss(xPlayer)
	if xPlayer and xPlayer.job and xPlayer.job.grade_name then
		return xPlayer.job.grade_name == "boss"
	end
	return false
end

RegisterServerEvent("qb-bossmenu:server:giveJob")
AddEventHandler("qb-bossmenu:server:giveJob", function(data) --* Finished
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromIdentifier(data.source)

	if isBoss(xPlayer) then
		if xTarget and xTarget.setJob(xPlayer.job.name, 0) then
			xPlayer.showNotification("You recruit " .. xTarget.getName() .. " to " .. xPlayer.job.label .. ".")
			xTarget.showNotification("You've been recruited to " .. xPlayer.job.label .. ".")
		else
			xPlayer.showNotification("Target player not found!")
		end
	else
		xPlayer.showNotification("You are not the boss, how did you reach here bitch?!")
	end
end)

RegisterServerEvent("qb-bossmenu:server:updateGrade")
AddEventHandler("qb-bossmenu:server:updateGrade", function(data)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xEmployee = ESX.GetPlayerFromIdentifier(data.source)
	local gradeId = tonumber(data.grade)

	if xEmployee then
		xEmployee.setJob(xPlayer.job.name, gradeId)

		xPlayer.showNotification("Promoted successfully!")
		xEmployee.showNotification("You just got promoted [" .. data.grade .. "].")
	else
		MySQL.Async.execute("UPDATE users SET job = @job, job_grade = @job_grade WHERE identifier = @identifier", {
			["@job"] = xPlayer.job.name,
			["@job_grade"] = gradeId,
			["@identifier"] = data.source,
		})

		xPlayer.showNotification("Promoted successfully!")
	end
end)

RegisterServerEvent("qb-bossmenu:server:updateNearbys")
AddEventHandler("qb-bossmenu:server:updateNearbys", function(data)
	local xPlayer = ESX.GetPlayerFromId(source)
	local players = {}
	for _, player in pairs(data) do
		local xTarget = ESX.GetPlayerFromId(player)
		if xTarget and xTarget.job.name ~= xPlayer.job.name then
			table.insert(players, {
				source = xTarget.identifier,
				name = xTarget.getName(),
			})
		end
	end

	TriggerClientEvent("qb-bossmenu:client:refreshPage", source, "recruits", players)
end)

function tprint(t)
	print(ESX.DumpTable(t))
end
