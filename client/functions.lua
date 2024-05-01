

function CreateBlip(pos, sprite, scale, colorblip, blipName)
    local entity = AddBlipForCoord(pos)
    SetBlipSprite(entity, sprite)
    SetBlipDisplay(entity, 4)
    SetBlipScale(entity, scale)
    SetBlipColour(entity, colorblip)
    SetBlipAsShortRange(entity, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipName)
    EndTextCommandSetBlipName(entity)
    return entity
end

function CreateNPC(hash, coords, sit)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(1)
    end
    local entity = CreatePed(2, hash, coords.x, coords.y, coords.z, coords.w, false, false)
    SetPedFleeAttributes(entity, 0, 0)
    SetPedDiesWhenInjured(entity, false)
    TaskStartScenarioInPlace(entity, "missheistdockssetup1clipboard@base", 0, true)
    SetPedKeepTask(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)
    SetEntityInvincible(entity, true)
    FreezeEntityPosition(entity, true)

    return entity
end

