RegisterServerEvent("Police-Panic:NewPanic")
AddEventHandler("Police-Panic:NewPanic", function(Officer) TriggerClientEvent("Pass-Alarm:Return:NewPanic", -1, source, Officer) end)
