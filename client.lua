local QBCore = exports['qb-core']:GetCoreObject()
local playerJob = nil
local Panic = {}
Panic.Cooling = 0

AddEventHandler("onClientMapStart", function()
	TriggerEvent("chat:addSuggestion", "/panic", "Activate your Panic Button!")
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    playerJob = QBCore.Functions.GetPlayerData().job
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        playerJob = QBCore.Functions.GetPlayerData().job
    end
end)

RegisterCommand("panic", function()
	if playerJob.name == "police" then
		if Panic.Cooling == 0 then
			local Officer = {}
			Officer.Ped = PlayerPedId()
			Officer.Name = GetPlayerName(PlayerId())
			Officer.Coords = GetEntityCoords(Officer.Ped)
			Officer.Location = {}
			Officer.Location.Street, Officer.Location.CrossStreet = GetStreetNameAtCoord(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z)
			Officer.Location.Street = GetStreetNameFromHashKey(Officer.Location.Street)
			if Officer.Location.CrossStreet ~= 0 then
				Officer.Location.CrossStreet = GetStreetNameFromHashKey(Officer.Location.CrossStreet)
				Officer.Location = Officer.Location.Street .. " X " .. Officer.Location.CrossStreet
			else
				Officer.Location = Officer.Location.Street
			end

			TriggerServerEvent("Police-Panic:NewPanic", Officer)

			Panic.Cooling = Config.PanicCooldown * 1000
		else
			NewNoti("~r~Panic Button still in cooling down.", true)
		end
	else
		NewNoti("~r~You are not a police officer.", true)
	end
end)

RegisterNetEvent("Pass-Alarm:Return:NewPanic")
AddEventHandler("Pass-Alarm:Return:NewPanic", function(source, Officer)
	if playerJob.name == "police" then
		if Officer.Ped == PlayerPedId() then
			SendNUIMessage({
				PayloadType	= {"Panic", "LocalPanic"},
				Payload	= source
			})
		else
			SendNUIMessage({
				PayloadType	= {"Panic", "ExternalPanic"},
				Payload	= source
			})
		end

    	FirstName = QBCore.Functions.GetPlayerData().charinfo.firstname
    	LastName = QBCore.Functions.GetPlayerData().charinfo.lastname

		TriggerEvent("chat:addMessage", {
			color = {255, 0, 0},
			multiline = true,
			args = {"Dispatch: Attention all units, Officer in distress! - " .. FirstName .. " " .. LastName .. --[[" (" .. source .. ")" .. .. ]]" - " .. Officer.Location}
		})-- Uncoment the source section if you want the players id to show in the alert

		Citizen.CreateThread(function()
			local Blip = AddBlipForRadius(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z, 50.0)

			SetBlipRoute(Blip, true)

			Citizen.CreateThread(function()
				while Blip do
					SetBlipRouteColour(Blip, 1)
					Citizen.Wait(150)
					SetBlipRouteColour(Blip, 6)
					Citizen.Wait(150)
					SetBlipRouteColour(Blip, 35)
					Citizen.Wait(150)
					SetBlipRouteColour(Blip, 6)
				end
			end)

			SetBlipAlpha(Blip, 60)
			SetBlipColour(Blip, 1)
			SetBlipFlashes(Blip, true)
			SetBlipFlashInterval(Blip, 200)

			Citizen.Wait(Config.AlertTime * 1000)

			RemoveBlip(Blip)
			Blip = nil
		end)
	end
end)

function NewNoti(Text, Flash)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(Text)
	DrawNotification(Flash, true)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if Panic.Cooling ~= 0 then
			Citizen.Wait(1000)
			Panic.Cooling = Panic.Cooling - 1
		end
	end
end)
