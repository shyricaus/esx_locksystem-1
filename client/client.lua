-- FIXME: Re-enable Sound
-- TODO: Clean up code
-- TODO: Add distance check thread to update UI "Battery Levels" < Will have to have a slight delay between updates for performance reasons. Wait(0) for running code is bad.

-----------------------------------------------------------------------------------------
---                                        INIT                                       ---
-----------------------------------------------------------------------------------------
local vehicles 	= {}
ESX				= nil
localVehId		= 0
savedVehicle	= 0
engine			= nil
times			= 0
owner			= false
sent			= false
lockStatus		= 0

-----------------------------------------------------------------------------------------
---                                        EVENTS                                     ---
-----------------------------------------------------------------------------------------

-- Add Vehicle To vehicles{} table
RegisterNetEvent("esx_locksystem:newVehicle")
AddEventHandler("esx_locksystem:newVehicle", function(plate, id, lockStatus)
	if(plate)then
		local plate = string.lower(plate)
				if(not id)then id = nil end
				if(not lockStatus)then lockStatus = nil end
				vehicles[plate] = newVehicle()
		vehicles[plate].__construct(plate, id, lockStatus)
		else
				print("Could not create the vehicle. Plate was missing.")
		end
end)

-----------------------------------------------------------------------------------------
---                                        NUI                                        ---
-----------------------------------------------------------------------------------------

-- NUICallback for Turning The Menu Off
RegisterNUICallback('NUIFocusOff', function()
	SetNuiFocus(false, false)
end)

-- NUICallback For Locking Vehicle
RegisterNUICallback('NUILock', function()
	SendNUIMessage({type = 'disableButtons'})
	time = 0

	if owner then
		lockStatus = GetVehicleDoorLockStatus(savedVehicle)
		if lockStatus < 2 then
			lockVehicle()
			lockVehicleUI()
		else
			ESX.ShowNotification('This vehicle is already locked.') 
		end
	else
		ESX.ShowNotification('You don\'t own this vehicle or the vehicle wasn\'t found.')
	end

	Wait((Config.lockTimer - time) * 1000)
	SendNUIMessage({type = 'enableButtons'})
end)

-- NUICallback for Unlocking Vehicle
RegisterNUICallback('NUIUnlock', function()
	SendNUIMessage({type = 'disableButtons'})
	time = 0

	if owner then
		lockStatus = GetVehicleDoorLockStatus(savedVehicle)
		if lockStatus >= 2 then
			unlockVehicle()
			unlockVehicleUI()
		else
			ESX.ShowNotification('This vehicle is already unlocked.') 
		end
	else
		ESX.ShowNotification('You don\'t own this vehicle or the vehicle wasn\'t found.')
	end

	Wait((Config.lockTimer - time) * 1000)
	SendNUIMessage({type = 'enableButtons'})
end)

-- NUICallback for Toggling Engines On Or Off
RegisterNUICallback('NUIToggleEngine', function()
	SendNUIMessage({type = 'disableButtons'})
	time = 0

	if owner then
		toggleEngines()
		toggleEnginesUI()
	else
		ESX.ShowNotification('You don\'t own this vehicle or the vehicle wasn\'t found.')
	end

	Wait((Config.lockTimer - time) * 1000)
	SendNUIMessage({type = 'enableButtons'})
end)

-----------------------------------------------------------------------------------------
---                                     FUNCTIONS                                     ---
-----------------------------------------------------------------------------------------

-- Change Engine Image In UI To On Or Off
function toggleEnginesUI()
	local ply = GetPlayerPed(-1)
	if ((engine == true) or (engine == 1)) then
		SendNUIMessage({type = 'engineOff'})
		engine = false
	else
		SendNUIMessage({type = 'engineOn'})
		engine = true
	end
end

-- Change Lock Image In UI To Unlocked
function unlockVehicleUI()
	SendNUIMessage({type = 'unlocked'})
end

-- Change Lock Image In UI To Locked
function lockVehicleUI()
	SendNUIMessage({type = 'locked'})
end

-- Toggle Engines On Or Off
function toggleEngines()
	local ply = GetPlayerPed(-1)
	if(IsPedInAnyVehicle(ply, true))then
		if ((engine == true) or (engine == 1)) then
			ESX.ShowNotification('Engine is now off.') 
			SetVehicleEngineOn(localVehId, false, false, false)
		else
			SetVehicleEngineOn(localVehId, true, true, false)
			ESX.ShowNotification('Engine is now on.') 
		end
	else
		if (engine ~= nil) and (engine == true or engine == 1) then
			time = 0
			ClearPedTasks(ply)
			playAnimation()
			Wait(250)

			ESX.ShowNotification('Engine is now off.') 
			SetVehicleEngineOn(localVehId, false, false, false)
		else
			time = 0
			ClearPedTasks(ply)
			playAnimation()
			Wait(250)

			SetVehicleEngineOn(localVehId, true, true, false)
			ESX.ShowNotification('Engine is now on.') 
		end
	end
end

-- Unlock The Vehicle
function unlockVehicle()
	local ply = GetPlayerPed(-1)
	if(IsPedInAnyVehicle(ply, true))then
		SetVehicleDoorsLocked(localVehId, 1)
		SetVehicleDoorsLockedForAllPlayers(localVehId, 0)
		RollUpWindow(localVehId, 0)
		RollUpWindow(localVehId, 1)
		RollUpWindow(localVehId, 2)
		RollUpWindow(localVehId, 3)
		local vehicleNetId = getVehicleNetId(localVehId)
		ESX.ShowNotification('This vehicle was unlocked.')
		-- TODO: TriggerServerEvent("InteractSound_SV:PlayWithinDistanceToVehicle", Config.maxAlarmDist, "lock2", Config.maxAlarmVol, vehicleNetId)
	else
		playAnimation()
		Wait(250)

		SetVehicleDoorsLocked(localVehId, 1)
		SetVehicleDoorsLockedForAllPlayers(localVehId, 0)
		RollUpWindow(localVehId, 0)
		RollUpWindow(localVehId, 1)
		RollUpWindow(localVehId, 2)
		RollUpWindow(localVehId, 3)
		ESX.ShowNotification('This vehicle was unlocked.') 
		local vehicleNetId = getVehicleNetId(localVehId)
		-- TODO: TriggerServerEvent("InteractSound_SV:PlayWithinDistanceToVehicle", Config.maxAlarmDist, "lock2", Config.maxAlarmVol, vehicleNetId)
	end
end

-- Lock The Vehicle
function lockVehicle()
	local ply = GetPlayerPed(-1)
	if(IsPedInAnyVehicle(ply, true))then
		SetVehicleDoorsLocked(localVehId, 4)
		SetVehicleDoorsLockedForAllPlayers(localVehId, 1)
		RollUpWindow(localVehId, 0)
		RollUpWindow(localVehId, 1)
		RollUpWindow(localVehId, 2)
		RollUpWindow(localVehId, 3)
		local vehicleNetId = getVehicleNetId(localVehId)
		ESX.ShowNotification('This vehicle was locked.')
		-- TODO: TriggerServerEvent("InteractSound_SV:PlayWithinDistanceToVehicle", Config.maxAlarmDist, "lock2", Config.maxAlarmVol, vehicleNetId)
	else
		playAnimation()
		Wait(250)

		SetVehicleDoorsLocked(localVehId, 4)
		SetVehicleDoorsLockedForAllPlayers(localVehId, 1)
		RollUpWindow(localVehId, 0)
		RollUpWindow(localVehId, 1)
		RollUpWindow(localVehId, 2)
		RollUpWindow(localVehId, 3)
		ESX.ShowNotification('This vehicle was locked.') 
		local vehicleNetId = getVehicleNetId(localVehId)
		-- TODO: TriggerServerEvent("InteractSound_SV:PlayWithinDistanceToVehicle", Config.maxAlarmDist, "lock2", Config.maxAlarmVol, vehicleNetId)
	end
end

-- Get Vehicle's Net Id
function getVehicleNetId(vehID)
	return NetToVeh(NetworkGetNetworkIdFromEntity(vehID))
end

-- Get Vehicle In The Direction You Are Looking
function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

-- Vehicle Manager
function newVehicle()
		local self = {}

		self.id = nil
		self.plate = nil
		self.lockStatus = 1

		rTable = {}

		rTable.__construct = function(id, plate, lockStatus)
						self.id = id
						self.plate = plate
						self.lockStatus = 1
		end

		return rTable
end

function checkOwner()
	local ply = GetPlayerPed(-1)
	local coordA = GetEntityCoords(ply, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(ply, 0.0, 5.0, 0.0)
	local vehicle = getVehicleInDirection(coordA, coordB)
	local myID = GetPlayerServerId(PlayerId())
	isInside = false
	
	if(IsPedInAnyVehicle(ply, true))then
		localVehId = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	else
		if (vehicle ~= 0) then	
			localVehId = vehicle
			savedVehicle = vehicle
		elseif (vehicle ~= 0) and (savedVehicle == vehicle) then
			localVehId = vehicle
		elseif (vehicle ~= 0) and (savedVehicle ~= vehicle) then
			localVehId = vehicle			
		elseif (vehicle == 0) then
			localVehId = savedVehicle
		end
	end

	if localVehId and localVehId ~= 0 then
		local localVehPlateTest = GetVehicleNumberPlateText(localVehId)

		if localVehPlateTest ~= nil then
			local localVehPlate = string.lower(localVehPlateTest)
			local localVehLockStatus = GetVehicleDoorLockStatus(localVehId)

			for plate, vehicle in pairs(vehicles) do
				Wait(100)
				local plateCheck = string.gsub(tostring(plate), "%s", "")
				local localVehPlateCheck = string.gsub(tostring(localVehPlate), "%s", "")
				if plateCheck == localVehPlateCheck then
					owner = true
					break 
				end
			end

			if owner then
			else
				savedVehicle = 0
			end
		else
			ESX.ShowNotification('Could not find the plates.') 
		end
	end
end

function playAnimation()
	local ply = GetPlayerPed(-1)
	local lib = "anim@mp_player_intmenu@key_fob@"
	local anim = "fob_click"

	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(ply, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
	end)
end
-----------------------------------------------------------------------------------------
---                                      THREADS                                      ---
-----------------------------------------------------------------------------------------

-- Timer 
Citizen.CreateThread(function()
		timer = Config.lockTimer
		time = 0
	while true do
		Wait(1000)
		time = time + 1
	end
end)

-- Disable Stealing NPC Cars
if(Config.disableCar_NPC)then
		Citizen.CreateThread(function()
				while true do
						Wait(0)
						local ped = GetPlayerPed(-1)
						if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId(ped))) then
								local veh = GetVehiclePedIsTryingToEnter(PlayerPedId(ped))
								local lock = GetVehicleDoorLockStatus(veh)
								if lock == 7 then
										SetVehicleDoorsLocked(veh, 2)
								end
								local pedd = GetPedInVehicleSeat(veh, -1)
								if pedd then
										SetPedCanBeDraggedOut(pedd, false)
								end
						end
				end
		end)
end

-- BUG PREVENTION THREAD (Prevents spam F bugs where player could break windows even if the configs were set to block it)
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local ped = GetPlayerPed(-1)
				if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId(ped))) then
					local veh = GetVehiclePedIsTryingToEnter(PlayerPedId(ped))
					local lock = GetVehicleDoorLockStatus(veh)
					if lock == 4 then
						ClearPedTasks(ped)
					end
				end
	end
end)

-- MAIN THREAD 1 (Change Second Wait To However Often You Would Like The Vehicles List To Update)
-- WARNING: This executes SQL, it will be network heavy if used too often
Citizen.CreateThread(function()
	while true do
		TriggerServerEvent("esx_locksystem:retrieveVehiclesOnconnect")
		Wait(30000)
	end
end)

-- MAIN THREAD 2 (Only one thread is enabled depending on whether Config.useKeyFob is set to true or false)
if Config.useKeyFob then
	Citizen.CreateThread(function()

		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end

		while true do
			Wait(0)

			if(IsControlJustPressed(1, Config.hotkey))then
				checkOwner()
				Wait(800)
					if savedVehicle ~= 0 then
						SendNUIMessage({type = 'carConnected'})
						engine = GetIsVehicleEngineRunning(savedVehicle)

							if ((engine == true) or (engine == 1)) then
								SendNUIMessage({type = 'engineOn'})
							else
								SendNUIMessage({type = 'engineOff'})
							end

						local lock = GetVehicleDoorLockStatus(savedVehicle)

						if lock ~= nil then
							if lock < 2 then
								SendNUIMessage({type = 'unlocked'})
							else
								SendNUIMessage({type = 'locked'})
							end
						else
							SendNUIMessage({type = 'unlocked'})
						end
					else
						SendNUIMessage({type = 'carDisconnected'})
						SendNUIMessage({type = 'unlocked'})
						SendNUIMessage({type = 'engineOff'})
					end

					Wait(100)
					SetNuiFocus(true, true)
					SendNUIMessage({type = 'enableButtons'})
					SendNUIMessage({type = 'openKeyFob'})

			end
		end
	end)
else
	Citizen.CreateThread(function()

		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end

		while true do
			Wait(0)

			if(IsControlJustPressed(1, Config.hotkey))then
				checkOwner()
				Wait(800)	
				if owner then	
					lockStatus = GetVehicleDoorLockStatus(localVehId)
					if lockStatus < 2 then
						lockVehicle()
					else
						unlockVehicle()
					end
				else
					ESX.ShowNotification('You don\'t own this vehicle or the vehicle wasn\'t found.')
				end
			end
			


			if(IsControlJustPressed(1, Config.hotkey2))then
				checkOwner()
				Wait(800)	
				if owner then
					engine = GetIsVehicleEngineRunning(localVehId)
					toggleEngines()
				else
					ESX.ShowNotification('You don\'t own this vehicle or the vehicle wasn\'t found.')
				end
			end
		end
	end)
end

-- MAIN THREAD 3
-- TODO: Insert Distance-Based "Battery Level" code here
Citizen.CreateThread(function()
	while true do
		Wait(1000)
		-- TODO: INSERT CODE HERE
	end
end)


-- -----------------------------------------------------------------------------------------
-- ---                                       AUDIO                                       ---
-- -----------------------------------------------------------------------------------------

RegisterNetEvent('InteractSound_CL:PlayWithinDistanceToVehicle')
AddEventHandler('InteractSound_CL:PlayWithinDistanceToVehicle', function(playerNetId, maxDistance, soundFile, maxVolume, sourceEntity)
	local distPerc = nil
	local volume = maxVolume
	local lCoords = GetEntityCoords(GetPlayerPed(-1))
	local eCoords = GetEntityCoords(sourceEntity, true)
	local distIs  = tonumber(string.format("%.1f", GetDistanceBetweenCoords(lCoords.x, lCoords.y, lCoords.z, eCoords.x, eCoords.y, eCoords.z, true)))
	if (distIs <= maxDistance) then
		distPerc = distIs / maxDistance
		volume = (1-distPerc) * maxVolume
		ESX.ShowNotification('Volume:' .. volume .. ' Distance: '.. distIs .. ' Percentage: '.. distPer * 100 .. '%')
				SendNUIMessage({
						transactionType     = 'playSound',
						transactionFile     = soundFile,
						transactionVolume   = volume
		})
	else
		SendNUIMessage({
			transactionType     = 'playSound',
			transactionFile     = soundFile,
			transactionVolume   = maxVolume
		})
		end
end)








-- FIXME: Everything below is commented as it was not required for getting the callbacks to function.
-- FIXME: This is the best chance to only add what we have to have and put everything inside of
-- FIXME: optimized functions.

-- function toggleLocksInVehicle(ply, localVehLockStatus, localVehId)
-- 	if localVehLockStatus <= 2 then
-- 		lockVehicleInside()
-- 	elseif localVehLockStatus > 2 then
-- 		unlockVehicleInside()
-- 	end
-- end

-- function toggleLocksOutsideVehicle(ply, localVehLockStatus)
-- 	if localVehLockStatus <= 2 then

-- 		local test = data
	
-- 		local lib = "anim@mp_player_intmenu@key_fob@"
-- 		local anim = "fob_click"

-- 		ESX.Streaming.RequestAnimDict(lib, function()
-- 			TaskPlayAnim(ply, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
-- 		end)

-- 		Wait(250)
-- 		lockVehicleOutside(localVehId)
-- 	elseif localVehLockStatus > 2 then
	
-- 		local lib = "anim@mp_player_intmenu@key_fob@"
-- 		local anim = "fob_click"

-- 		ESX.Streaming.RequestAnimDict(lib, function()
-- 			TaskPlayAnim(ply, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
-- 		end)

-- 		Wait(250)
-- 		unlockVehicleOutside(localVehId)
-- 	end
-- end

-- function lockVehicleInside(localVehId)
-- 	SetVehicleDoorsLocked(localVehId, 4)
-- 	SetVehicleDoorsLockedForAllPlayers(localVehId, 1)
-- 	RollUpWindow(localVehId, 0)
-- 	RollUpWindow(localVehId, 1)
-- 	RollUpWindow(localVehId, 2)
-- 	RollUpWindow(localVehId, 3)
-- 	local vehicleNetId = getVehicleNetId(localVehId)
-- 	TriggerEvent("esx_locksystem:notify", _U("vehicle_locked"))
-- 	if time > timer then
-- 		TriggerServerEvent("InteractSound_SV:PlayWithinDistanceToVehicle", Config.maxAlarmDist, "lock2", Config.maxAlarmVol, vehicleNetId)
-- 	end
-- 	time = 0
-- end

-- function unlockVehicleInside(localVehId)
-- 	SetVehicleDoorsLocked(localVehId, 1)
-- 	SetVehicleDoorsLockedForAllPlayers(localVehId, false)
-- 	local vehicleNetId = getVehicleNetId(localVehId)
-- 	TriggerEvent("esx_locksystem:notify", _U("vehicle_unlocked"))
-- 	if time > timer then
-- 		TriggerServerEvent("InteractSound_SV:PlayWithinDistanceToVehicle", Config.maxAlarmDist, "lock2", Config.maxAlarmVol, vehicleNetId)
-- 	end
-- 	time = 0
-- end

-- function setVehicleLockStatus(vehID, status)
-- 	local vehicleNetId = getVehicleNetId(vehId)
-- 	local sound = nil
	
-- 	if (not IsPedInAnyVehicle and status == 'lock') then 
-- 		sound = 'lock1'
-- 	elseif (not IsPedInAnyVehicle and status == 'unlock') then 
-- 		sound = 'unlock1'
-- 	elseif (IsPedInAnyVehicle and status == 'lock') then 
-- 		sound = 'lock2'
-- 	elseif (IsPedInAnyVehicle and status == 'unlock') then 
-- 		sound = 'unlock2'
-- 	end
	
-- 	if (status == 'lock') then
-- 		SetVehicleDoorsLocked(localVehId, 4)
-- 		SetVehicleDoorsLockedForAllPlayers(localVehId, false)
-- 		RollUpWindow(localVehId, 0)
-- 		RollUpWindow(localVehId, 1)
-- 		RollUpWindow(localVehId, 2)
-- 		RollUpWindow(localVehId, 3)
-- 		TriggerEvent("esx_locksystem:notify", _U("vehicle_locked"))
-- 	elseif (status == 'unlock') then
-- 		SetVehicleDoorsLocked(localVehId, 1)
-- 		SetVehicleDoorsLockedForAllPlayers(localVehId, false)
-- 		TriggerEvent("esx_locksystem:notify", _U("vehicle_unlocked"))
-- 	end

-- 	if (not IsPedInAnyVehicle) then
-- 		local lib = "anim@mp_player_intmenu@key_fob@"
-- 		local anim = "fob_click"
-- 		ESX.Streaming.RequestAnimDict(lib, function()
-- 			TaskPlayAnim(ply, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
-- 		end)
-- 	end
	
-- 	TriggerServerEvent("InteractSound_SV:PlayWithinDistanceToVehicle", Config.maxAlarmDist, sound, Config.maxAlarmVol, vehId)
-- end

-- function lockVehicleOutside(localVehId)
-- 	SetVehicleDoorsLocked(localVehId, 4)
-- 	SetVehicleDoorsLockedForAllPlayers(localVehId, 1)
-- 	RollUpWindow(localVehId, 0)
-- 	RollUpWindow(localVehId, 1)
-- 	RollUpWindow(localVehId, 2)
-- 	RollUpWindow(localVehId, 3)
-- 	TriggerEvent("esx_locksystem:notify", _U("vehicle_locked"))
-- 	local vehicleNetId = getVehicleNetId(localVehId)
-- 	if time > timer then
-- 		TriggerServerEvent("InteractSound_SV:PlayWithinDistanceToVehicle", Config.maxAlarmDist, "lock2", Config.maxAlarmVol, vehicleNetId)
-- 	end
-- 	time = 0
-- end

-- function unlockVehicleOutside(localVehId)
-- 	SetVehicleDoorsLocked(localVehId, 1)
-- 	SetVehicleDoorsLockedForAllPlayers(localVehId, false)
-- 	TriggerEvent("esx_locksystem:notify", _U("vehicle_unlocked"))
-- 	local vehicleNetId = getVehicleNetId(localVehId)
-- 	if time > timer then
-- 		TriggerServerEvent("InteractSound_SV:PlayWithinDistanceToVehicle", Config.maxAlarmDist, "lock2", Config.maxAlarmVol, vehicleNetId)
-- 	end
-- 	time = 0
-- end

-- -----------------------------------------------------------------------------------------
-- ---                                      THREADS                                      ---
-- -----------------------------------------------------------------------------------------

-- Citizen.CreateThread(function()

-- 	while ESX == nil do
-- 		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- 		Citizen.Wait(0)
-- 	end
	
-- 	while true do
-- 		Wait(0)
		
-- 		if(IsControlJustPressed(1, Config.hotkey))then
-- 			doLockSystemToggleLocks()
-- 		end
-- 		-- Reports vehicle status to the key fob
-- 		-- if (Config.useKeyFob) then		
-- 		-- 	-- if (isTheCarOwner) then
-- 		-- 		SendNUIMessage({type = 'carConnected'})
				
-- 		-- 		-- if ((GetIsVehicleEngineRunning(localVehId) ~= nil) and (GetIsVehicleEngineRunning(localVehId))) then
-- 		-- 		-- 	SendNUIMessage({type = 'engineOn'})
-- 		-- 		-- else
-- 		-- 		-- 	SendNUIMessage({type = 'engineOff'})
-- 		-- 		-- end

-- 		-- 		-- if ((GetVehicleDoorLockStatus(localVehId) ~= nil and GetVehicleDoorLockStatus(localVehId) > 2)) then
-- 		-- 		-- 	SendNUIMessage({type = 'locked'})
-- 		-- 		-- else
-- 		-- 		-- 	SendNUIMessage({type = 'unlocked'})
-- 		-- 		-- end

-- 		-- 	-- else
-- 		-- 		SendNUIMessage({type = 'carDisconnected'})
-- 		-- 		SendNUIMessage({type = 'engineOff'})
-- 		-- 		SendNUIMessage({type = 'unlocked'})
-- 		-- 	-- end
		
-- 		-- 	if(IsControlJustPressed(1, Config.hotkey))then
-- 		-- 		-- if not keyFobOpen then
-- 		-- 		-- 	SetNuiFocus(true, true)
-- 		-- 		-- 	SendNUIMessage({type = 'openKeyFob'})
-- 		-- 		-- 	keyFobOpen = true
-- 		-- 		-- end
-- 		-- end
-- 	end
-- end)

-- -- Citizen.CreateThread(function()

-- -- 	while ESX == nil do
-- -- 		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- -- 		Citizen.Wait(0)
-- -- 	end
	
-- -- 	while true do
-- -- 		Wait(0)
		
-- -- 		-- Reports vehicle status to the key fob
-- -- 		if (not Config.useKeyFob) then	
-- -- 			if (true) then
-- -- 				SendNUIMessage({type = 'carConnected'})
				
-- -- 				if ((GetIsVehicleEngineRunning(localVehId) ~= nil) and (GetIsVehicleEngineRunning(localVehId))) then
-- -- 					SendNUIMessage({type = 'engineOn'})
-- -- 				else
-- -- 					SendNUIMessage({type = 'engineOff'})
-- -- 				end

-- -- 				if ((GetVehicleDoorLockStatus(localVehId) ~= nil and GetVehicleDoorLockStatus(localVehId) > 2)) then
-- -- 					SendNUIMessage({type = 'locked'})
-- -- 				else
-- -- 					SendNUIMessage({type = 'unlocked'})
-- -- 				end

-- -- 			else
-- -- 				SendNUIMessage({type = 'carDisconnected'})
-- -- 				SendNUIMessage({type = 'engineOff'})
-- -- 				SendNUIMessage({type = 'unlocked'})
-- -- 			end
		
-- --  			if(IsControlJustPressed(1, Config.hotkey))then
-- --  				if not keyFobOpen then
-- --  					SetNuiFocus(true, true)
-- --  					SendNUIMessage({type = 'openKeyFob'})
-- --  					keyFobOpen = true
-- --  				end
-- --  			end
-- --  		end
-- --  	end
-- -- end)

-- RegisterNUICallback('NUIFocusOff', function()
-- 	SetNuiFocus(false, false)
-- end)

-- RegisterNUICallback('NUILock', function()
-- 	doLockSystemToggleLocks()
-- end)





-- TODO: DO NOT REMOVE BELOW UNTIL EVERYTHING IS CONFIRMED WORKING.

--     -- elseif ((distIs > 5.0) and (distIs <= 10.0)) then
-- 	-- 	maxVolume = 0.20
--     --     SendNUIMessage({
--     --         transactionType     = 'playSound',
--     --         transactionFile     = soundFile,
--     --         transactionVolume   = newVolume
--     --     })
--     -- elseif ((distIs > 10.0) and (distIs <= 15.0)) then
-- 	-- 	newVolume = 0.15
--     --     SendNUIMessage({
--     --         transactionType     = 'playSound',
--     --         transactionFile     = soundFile,
--     --         transactionVolume   = newVolume
--     --     })
--     -- elseif ((distIs > 15.0) and (distIs <= 20.0)) then
-- 	-- 	newVolume = 0.10
--     --     SendNUIMessage({
--     --         transactionType     = 'playSound',
--     --         transactionFile     = soundFile,
--     --         transactionVolume   = newVolume
--     --     })
--     -- elseif ((distIs > 20.0) and (distIs <= 25.0)) then
-- 	-- 	newVolume = 0.05
--     --     SendNUIMessage({
--     --         transactionType     = 'playSound',
--     --         transactionFile     = soundFile,
--     --         transactionVolume   = newVolume
--     --     })
--     -- elseif ((distIs > 25.0) and (distIs <= 30.0)) then
-- 	-- 	newVolume = 0.03
--     --     SendNUIMessage({
--     --         transactionType     = 'playSound',
--     --         transactionFile     = soundFile,
--     --         transactionVolume   = newVolume
--     --     })
--     -- elseif ((distIs > 30.0) and (distIs <= 35.0)) then
-- 	-- 	newVolume = 0.02
--     --     SendNUIMessage({
--     --         transactionType     = 'playSound',
--     --         transactionFile     = soundFile,
--     --         transactionVolume   = newVolume
--     --     })