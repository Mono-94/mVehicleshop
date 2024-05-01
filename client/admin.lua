local focus = false

local format = function(string, ...)
    return (string):format(...)
end

AddEventHandler('esx:onPlayerDeath', function(data)
    if focus then
        NuiData()
        ResetValues()
    end
end)


function NuiData(data)
    if not focus and data then
        focus = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'conce_admin', vehiculos = data.vehiculos, categorias = data.categorias, display = true })
    else
        focus = false
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'conce_admin', display = false })
    end
end

RegisterNetEvent('mono_conce:AdminsConce', NuiData)

function RefreshData(data)
    print(data)
    SendNUIMessage({ action = 'conce_admin', vehiculos = data.vehiculos, categorias = data.categorias })
end

RegisterNUICallback('conce_admin', function(data, cb)
    if not data then return cb(false) end
    if data.action == 'close' then
        NuiData()
        cb(true)
    elseif data.action == 'categoria' then
        lib.callback('mono_conce:admin', false, function(retval)
            if retval then
                if data.db == 'add' then
                    Noti(
                        format('Categoria **%s**.\nAgregado a la **Base de Datos** correctamente!', data.value.label),
                        '#6fba4e')
                else
                    Noti(
                        format('Categoria **%s**.\nEliminada de la **Base de Datos** correctamente!', data.value.label),
                        '#f59b42')
                end
                 cb(retval)
            else
                Noti('No se pudo crear la categoria, al parecer el name/identificador coincide con otro ya creado.',
                    '#ba4e60')
                 cb(retval)
            end
        end, data.action, data.db, data.value)
    elseif data.action == 'vehiculo' then
        lib.callback('mono_conce:admin', false, function(retval)
            if retval then
                if data.db == 'add' then
                    Noti(format('Vehículo **%s**.\nAgregado a la **Base de Datos** correctamente!', data.value.name),
                        '#6fba4e')
                elseif data.db == 'delete' then
                    Noti(format('Vehículo **%s**.\nEliminada de la **Basse de Datos** correctamente!', data.value.name),
                        '#f59b42')
                elseif data.db == 'update' then
                    Noti(format('Vehículo **%s**.\nEliminada de la **Basse de Datos** correctamente!', data.value.name),
                        '#f59b42')
                end
                 cb(retval)
            else
                Noti(
                    'No se pudo agregar a la base de datos, verifica que no este introduciendo algun dato ya existente.',
                    '#ba4e60')
                 cb(retval)
            end
        end, data.action, data.db, data.value)
    elseif data.action == 'noti' then
        Noti(data.text)
        cb(true)
    elseif data.action == 'get_vehicles' then
        local vehiculos, categorias = lib.callback.await('mono_conce:Vehicles')
        cb({ vehiculos = vehiculos, categorias = categorias })
    end
end)


--RegisterCommand('conce', function()
--    local vehiculos, categorias = lib.callback.await('mono_conce:Vehicles')
--    NuiData({ vehiculos = vehiculos, categorias = categorias })
--end)

function Noti(texto, color)
   ESX.ShowNotification(texto)
    --[[ mono.Noti({
        title = 'Conce Admin',
        texto = texto,
        icon = 'database',
        colorIcon = color or '#ba4e60',
        time = 5000,
    })]]
end
