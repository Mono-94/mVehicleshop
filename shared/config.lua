Conce = {}

Conce.Carkeys = true

Conce.SitOnCar = false

Conce.userLang = 'ES'

Conce.MonoGarage = true -- SpawnVehicle, SetOwner, etc...


Conce.Commands = {
    edit = 'vehedit',

}



Conce.Conces = {
    ['Premium Deluxe MotorSport'] = {
        license = false,                                                              -- string License // false no License
        coords = vec4(-56.031845092773, -1098.484375, 25.880451202393, 10.0),         -- Coords point
        showCoords = vec4(-44.881465911865, -1097.3280029297, 25.422344207764, 40.0), -- ShowVehicle inside distance
        buySpawn = vec4(-44.881465911865, -1097.3280029297, 25.422344207764, 40.0),   -- Spawn on Buy
        type = 'car',                                                                 -- 'air', 'boat', 'car' //  DB Save Vehicle type
        job = nil,                                                                    -- nil = unemployed //  DB Save Vehicle job
        parking = 'Pillbox Hill',                                                     -- Default Parking //  DB Save Vehicle default prking
        blip = 225,                                                                   -- number = Blip Sprite // false = no blip
        npcSit = true,                                                                -- Ped Anim Sit
        npcHash = 'g_m_y_salvagoon_03',                                               -- Ped Hash
        filter = { 'boats', 'helicopters', 'planes', 'cycles' }                       -- Filter categories that you do not want in this dealership

    },

    ['La Puerta BoatShop'] = {
        license = false,                                                           -- string License // false no License
        coords = vec4(-716.49450683594, -1362.5163574219, 1.220413684845, -170.0), -- Coords point
        showCoords = vec4(-721.2480, -1361.3671, 1, 317.9164),                     -- ShowVehicle inside distance
        buySpawn = vec4(-734.0715, -1378.7393, -0.0830, 144.2663),                 -- Spawn on Buy
        type = 'boat',                                                             -- 'air', 'boat', 'car' //  DB Save Vehicle type
        job = nil,                                                                 -- nil = unemployed //  DB Save Vehicle job
        parking = 'La Puerta Boat',                                                -- Default Parking //  DB Save Vehicle default prking
        blip = 371,                                                                -- number = Blip Sprite // false = no blip
        npcSit = true,                                                             -- Ped Anim Sit
        npcHash = 'mp_m_waremech_01',                                              -- Ped Hash
        filter = {
            'compacts', 'sedans', 'suvs', 'coupes',
            'muscle', 'sportsclassics', 'sports', 'super',
            'motorcycles', 'offroads', 'vans', 'cycles',
            'helicopters', 'planes', 'offroad', 'mono'
        } -- Filter categories that you do not want in this dealership
    },

    ['Air Shop'] = {
        license = false,                                                               -- string License // false no License
        coords = vec4(-961.27099609375, -2972.8488769531, 13.945072174072, 0.0),       -- Coords point
        showCoords = vec4(-961.66583251953, -2965.4174804688, 12.945072174072, 150.0), -- ShowVehicle inside distance
        buySpawn = vec4(-966.42852783203, -2981.2946777344, 12.945072174072, 65.0),    -- Spawn on Buy
        type = 'air',                                                                  -- 'air', 'boat', 'car' //  DB Save Vehicle type
        job = nil,                                                                     -- nil = unemployed //  DB Save Vehicle job
        parking = 'Aeropuerto INYL. de los Santos Air',                                -- Default Parking //  DB Save Vehicle default prking
        blip = 372,                                                                    -- number = Blip Sprite // false = no blip
        npcSit = false,                                                                -- Ped Anim Sit
        npcHash = 'g_m_y_salvagoon_03',                                                -- Ped Hash
        filter = {
            'compacts', 'sedans', 'suvs', 'coupes',
            'muscle', 'sportsclassics', 'sports',
            'super', 'motorcycles', 'offroad', 'vans',
            'cycles', 'boats', 'mono'
        } -- Filter categories that you do not want in this dealership
    },
}
