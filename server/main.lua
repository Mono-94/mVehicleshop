local Event = TriggerClientEvent

local SelectVehicles = "SELECT * FROM `vehicles`"
local SelectCategories = "SELECT * FROM `vehicle_categories`"

lib.callback.register('mono_conce:Vehicles', function(source)
    local vehicles = MySQL.query.await(SelectVehicles)
    local category = MySQL.query.await(SelectCategories)
    return vehicles, category
end)

lib.addCommand('veh', {
    help = 'Mono VehicleShop: Edit',
    restricted = 'group.admin'
}, function(source, args, raw)
    local data = {}
    data.vehiculos = MySQL.query.await(SelectVehicles)
    data.categorias = MySQL.query.await(SelectCategories)
    TriggerClientEvent('mono_conce:AdminsConce', source, data)
end)


lib.callback.register('mono_conce:ConceOptions', function(source, data, color1, color2)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        local bank = xPlayer.getAccount('bank')

        if bank.money >= data.price then
            local plate = Vehicles.GeneratePlate()

            local vehData = {
                coords = data.buySpawn,
                setOwner = true,
                plate = plate,
                owner = xPlayer.identifier,
                parking = data.parking,
                job = data.job,
                vehicle = {
                    plate = plate,
                    model = data.model,
                    color1 = data.color1,
                    color2 = data.color2,
                    dirtLevel = 0,
                }

            }

            Vehicles.CreateVehicle(vehData, function(retval, vehicle)
                if DoesEntityExist(vehicle.entity) then
                    data.owner = xPlayer.identifier
                    bank.money = bank.money - data.price
                    xPlayer.setAccountMoney('bank', bank.money)
                    xPlayer.showNotification(('Vehiculo %s adquirido por %s $. \n Aquí tienes las llaves, que disfrutes!'):format(
                        data.name,
                        data.price), true, false, '#cccc')
                    Event('mono:Notify', source, {
                        title = data.conceName,
                        texto = ('Vehiculo %s adquirido por %s $. \n Aquí tienes las llaves, que disfrutes!'):format(
                            data.name,
                            data.price),
                        icon = 'car-side',
                        iconColor = '#dbae60'
                    })
                end
            end)



            return true
        else
            Event('mono:Notify', source, {
                title = data.conceName,
                texto = 'No tienes suficiente dinero para comprar.',
                icon = 'comment-dollar',
                iconColor = '#db6083'
            })
            return false
        end
    end
end)



AddEventHandler('onServerResourceStart', function(resource)
    local resourcename = GetCurrentResourceName()
    if resourcename == resource then
        local result = MySQL.single.await('SHOW TABLES LIKE "mono_conce"', {})
        if not result then
            MySQL.update([[
                CREATE TABLE IF NOT EXISTS `mono_conce` (
                    `id` int(11) NOT NULL AUTO_INCREMENT,
                    `name` varchar(250) DEFAULT NULL,
                    `coords` longtext DEFAULT NULL,
                    `categories` longtext DEFAULT NULL,
                    PRIMARY KEY (`id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci ROW_FORMAT=DYNAMIC
                AUTO_INCREMENT=3;
            ]], {}, function(success)
                if success then
                    print('^4[' .. resourcename .. ']^0 Table: `mono_conce` - Successfully created')
                end
            end)
        end
    end
end)



local queryCategoriaExist = 'SELECT 1 FROM vehicle_categories WHERE name = ?  LIMIT 1'

local function categoriaExists(name)
    local result = MySQL.scalar.await(queryCategoriaExist, { name })
    return result ~= nil
end

local queryVehicleExist = 'SELECT 1 FROM vehicles WHERE model = ? AND model = ? AND price = ? AND category = ? LIMIT 1'

local function vehicleExists(data)
    local result = MySQL.scalar.await(queryVehicleExist, { data.model, data.price, data.category })
    return result ~= nil
end

local queryInsertCategories = 'INSERT INTO `vehicle_categories` (name, label) VALUES (?, ?)'
local queryDeleteCategories = 'DELETE FROM vehicle_categories  WHERE name = ? AND label = ?'
local queryInsertVehicles = 'INSERT INTO `vehicles` (name, model,price, category) VALUES (?, ?, ?, ?)'
local queryDeleteVehicles = 'DELETE FROM vehicles  WHERE name = ? AND model = ? AND price = ? AND category = ?'
local queryUpdateVehicle = 'UPDATE vehicles SET price = ?, category = ? WHERE name = ? AND category = ? AND price = ?'

local InsertAwait = MySQL.insert.await
local UpdateAwait = MySQL.update.await

lib.callback.register('mono_conce:admin', function(source, action, db, data)
    if data then
        if action == 'categoria' then
            if db == 'add' then
                if not categoriaExists(data.name, data.label) then
                    if InsertAwait(queryInsertCategories, { data.name, data.label }) then return true else return false end
                else
                    return false
                end
            elseif db == 'delete' then
                if UpdateAwait(queryDeleteCategories, { data.name, data.label }) then return true else return false end
            end
        elseif action == 'vehiculo' then
            if db == 'add' then
                if not vehicleExists(data.name, data.label) then
                    if InsertAwait(queryInsertVehicles, { data.label, data.name, data.price, data.categoria }) then return true else return false end
                else
                    return false
                end
            elseif db == 'delete' then
                if UpdateAwait(queryDeleteVehicles, { data.label, data.name, data.price, data.categoria }) then return true else return false end
            elseif db == 'update' then
                if UpdateAwait(queryUpdateVehicle, { data.neWprice, data.neWcategoria, data.label, data.category, data.price }) then return true else return false end
            end
        end
    end
end)
