local VehicleList = {}           -- vehicle List
local CategoryIndex = 1          -- index categoria
local CategoryCount = 0          -- Category counts
local VehicleIndex = 1           -- index vehicle
local Vehicle = nil              -- vehicle entity spaw
local DilayChange = false        -- on DilayChange
local action = false             -- on action
local CamEntity                  -- id CamEntity
local coords                     -- coords CamEntity
local Zoom = 0                   -- Zoom
local ZoomIncrement = 0.1        -- Ajusta el incremento de zoom según tus necesidades
local r1, g1, b1 = 255, 255, 255 -- Vehicle  Color1
local r2, g2, b2 = 0, 0, 0       -- Vehicle  Color2


function ResetValues()
    SendNUIMessage({ action = 'display', display = false })
    DeleteCurrentVehicle()
    SetNuiFocus(false, false)
    RenderScriptCams(false, false, 0, 1000, 0)
    DestroyCam(CamEntity, false)
    VehicleList = {}
    CategoryCount = 0
    CategoryIndex = 1
    Zoom = 0
    r1, g1, b1 = 255, 255, 255
    r2, g2, b2 = 0, 0, 0
    Vehicle = nil
end

function CreateConce(data)
    local vehiculos, categorias = lib.callback.await('mono_conce:Vehicles')
    for _, cat in pairs(categorias) do
        local addToVehicleList = true

        for _, f in pairs(data.filter) do
            if f == cat.name then
                addToVehicleList = false
                break
            end
        end

        if addToVehicleList then
            VehicleList[cat.name] = {}
        end
    end

    for _, vehicle in pairs(vehiculos) do
        for k, v in pairs(VehicleList) do
            if vehicle.category == k then
                vehicle.buySpawn = data.buySpawn
                vehicle.conceName = data.name
                vehicle.type = data.type
                vehicle.job = data.job
                vehicle.parking = data.parking
                vehicle.showCoords = data.showCoords

                if VehicleList[vehicle.category] then
                    table.insert(VehicleList[vehicle.category], vehicle)
                end
            end
        end
    end

    for _, vehiclesInCategory in pairs(VehicleList) do
        if #vehiclesInCategory == 0 then
            VehicleList[_] = nil
        else
            CategoryCount = CategoryCount + 1
        end
    end
    CamEntity = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    coords = vec3(data.showCoords.x - 4.0, data.showCoords.y - 4.0, data.showCoords.z + 2.5)
    SetCamCoord(CamEntity, data.showCoords.x - 4.0, data.showCoords.y - 4.0, data.showCoords.z + 2.5)
    PointCamAtCoord(CamEntity, data.showCoords.x + 1.0, data.showCoords.y, data.showCoords.z)
    SetCamActive(CamEntity, true)
    RenderScriptCams(true, true, 1000, true, true)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'display', display = true, title = data.name })

    Vehicle = SpawnVehicleFromCategory(GetKeyByIndex(VehicleList, CategoryIndex))
end

function GetKeyByIndex(tbl, index)
    local i = 1
    for key, _ in pairs(tbl) do
        if i == index then
            return key
        end
        i = i + 1
    end
end

function SpawnVehicleFromCategory(category)
    if next(VehicleList[category]) ~= nil then
        local firstVehicle = VehicleList[category][1]
        SendNUIMessage({ action = 'update-cat', cate = category })
        return SpawnVehicle(firstVehicle)
    end
end

function SpawnVehicle(data)
    DilayChange = false

    RequestModel(data.model)

    while not HasModelLoaded(data.model) do
        Citizen.Wait(500)
    end
    local vehicle = CreateVehicle(data.model, data.showCoords, false, false)

    data.seats = GetVehicleMaxNumberOfPassengers(vehicle) + 1
    data.maxsped = math.floor(GetVehicleModelEstimatedMaxSpeed(data.model) * 3.7 / 10) * 10
    data.marca = GetMakeNameFromVehicleModel(data.model)

    SetVehicleLivery(vehicle, -1)
    SetVehicleDoorsLocked(vehicle, 2)
    SetVehicleCustomPrimaryColour(vehicle, r1, g1, b1)
    SetVehicleCustomSecondaryColour(vehicle, r2, g2, b2)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleNumberPlateText(vehicle, data.marca)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleLights(vehicle, 2)
    FreezeEntityPosition(vehicle, true)
    SetEntityCollision(vehicle, false, true)
    SendNUIMessage({ action = 'update', data = data })

    DilayChange = true

    return vehicle
end

Citizen.CreateThread(function()
    for k, conce in pairs(Conce.Conces) do
        conce.name = k
        local entityPed = CreateNPC(conce.npcHash, conce.coords, conce.npcSit)
        if conce.blip then
            CreateBlip(conce.coords, conce.blip, 0.8, 0, k)
        end
        exports.ox_target:addLocalEntity(entityPed, {
            {
                distance = 5,
                icon = 'fas fa-car',
                label = k,
                canInteract = function()
                    return not action
                end,
                onSelect = function()
                    CreateConce(conce)
                end
            }
        })
    end
end)

RegisterNUICallback('focus_conce', function(data, cb)
    if not data then return cb(false) end
    if data.action == 'up' and DoesEntityExist(Vehicle) then
        Zoom = 0
        SetCamCoord(CamEntity, coords.x + Zoom, coords.y + Zoom, coords.z)
        Arriba()
    elseif data.action == 'down' and DoesEntityExist(Vehicle) then
        Zoom = 0
        SetCamCoord(CamEntity, coords.x + Zoom, coords.y + Zoom, coords.z)
        Abajo()
    elseif data.action == 'right' and DoesEntityExist(Vehicle) then
        Zoom = 0
        SetCamCoord(CamEntity, coords.x + Zoom, coords.y + Zoom, coords.z)
        Derecha()
    elseif data.action == 'left' and DoesEntityExist(Vehicle) then
        Zoom = 0
        SetCamCoord(CamEntity, coords.x + Zoom, coords.y + Zoom, coords.z)
        Izquierda()
    end

    if DoesEntityExist(Vehicle) then
        if data.action == 'rotate-left' and DoesEntityExist(Vehicle) then
            SetEntityHeading(Vehicle, GetEntityHeading(Vehicle) - 3)
        elseif data.action == 'rotate-right' and DoesEntityExist(Vehicle) then
            SetEntityHeading(Vehicle, GetEntityHeading(Vehicle) + 3)
        elseif data.action == 'close' and DoesEntityExist(Vehicle) then
            ResetValues()
        elseif data.action == 'color1' and DoesEntityExist(Vehicle) then
            r1, g1, b1 = data.color.r, data.color.g, data.color.b
            SetVehicleCustomPrimaryColour(Vehicle, r1, g1, b1)
        elseif data.action == 'color2' and DoesEntityExist(Vehicle) then
            r2, g2, b2 = data.color.r, data.color.g, data.color.b
            SetVehicleCustomSecondaryColour(Vehicle, r2, g2, b2)
        elseif data.action == 'zoom-' and DoesEntityExist(Vehicle) then
            Zoom = math.max(Zoom - ZoomIncrement, -5.0)
            SetCamCoord(CamEntity, coords.x + Zoom, coords.y + Zoom, coords.z)
        elseif data.action == 'zoom+' and DoesEntityExist(Vehicle) then
            Zoom = math.min(Zoom + ZoomIncrement, 2.0)
            SetCamCoord(CamEntity, coords.x + Zoom, coords.y + Zoom, coords.z)
        elseif data.action == 'acelerar' and DoesEntityExist(Vehicle) then
            SetVehicleCurrentRpm(Vehicle, 2.0)
        end
    end

    cb(true)
end)



RegisterNUICallback('buy_Vehicle', function(data, cb)
    if not data then return cb(false) end

    local alert = lib.alertDialog({
        header = data.vehicle.conceName,
        content = ('Detalles del vehículo:\nNombre: %s\nMarca: %s\nPrecio: %s\nModelo: %s\nCategoría: %s\nTipo: %s \n \n ¿Seguro que deseas comprar este vehículo? ')
            :format(data.vehicle.name, data.vehicle.marca, data.vehicle.price, data.vehicle.model, data.vehicle.category,
                data.vehicle.type),
        centered = true,
        cancel = true
    })

    print(json.encode(data))
    local color1 = data.color1
    local color2 = data.color2
    print(alert)
    if alert then
        data.vehicle.color1 = { color1.r, color1.g, color1.b }
        data.vehicle.color2 = { color2.r, color2.g, color2.b }
        lib.callback('mono_conce:ConceOptions', false, function(success, info)
            if success then
                ResetValues()
            end
        end, data.vehicle)

        cb(true)
    end
end)



function DeleteCurrentVehicle()
    if DoesEntityExist(Vehicle) then
        DeleteEntity(Vehicle)
    end
end

function Izquierda()
    if DilayChange then
        if next(VehicleList) ~= nil then
            local currentCategory = GetKeyByIndex(VehicleList, CategoryIndex)
            VehicleIndex = VehicleIndex % #VehicleList[currentCategory] + 1
            local currentVehicle = VehicleList[currentCategory][VehicleIndex]
            DeleteCurrentVehicle()
            Vehicle = SpawnVehicle(currentVehicle)
        end
    end
end

function Derecha()
    if DilayChange then
        if next(VehicleList) ~= nil then
            local currentCategory = GetKeyByIndex(VehicleList, CategoryIndex)
            VehicleIndex = (VehicleIndex - 2 + #VehicleList[currentCategory]) %
                #VehicleList[currentCategory] +
                1
            local currentVehicle = VehicleList[currentCategory][VehicleIndex]
            DeleteCurrentVehicle()
            Vehicle = SpawnVehicle(currentVehicle)
        end
    end
end

function Arriba()
    if DilayChange then
        if next(VehicleList) ~= nil then
            CategoryIndex = CategoryIndex % CategoryCount + 1
            local newCategory = GetKeyByIndex(VehicleList, CategoryIndex)
            SendNUIMessage({ action = 'update-cat', cate = newCategory })
            DeleteCurrentVehicle()
            Vehicle = SpawnVehicleFromCategory(newCategory)
        end
    end
end

function Abajo()
    if DilayChange then
        if next(VehicleList) ~= nil then
            CategoryIndex = (CategoryIndex - 2 + CategoryCount) % CategoryCount + 1
            local newCategory = GetKeyByIndex(VehicleList, CategoryIndex)
            SendNUIMessage({ action = 'update-cat', cate = newCategory })
            DeleteCurrentVehicle()
            Vehicle = SpawnVehicleFromCategory(newCategory)
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then ResetValues() end
end)
