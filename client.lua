local purgaAtiva = false

-- Lista de armas para distribuir para a população da rua
local listaArmas = {
    "WEAPON_PISTOL",
    "WEAPON_MICROSMG",
    "WEAPON_PUMPSHOTGUN",
    "WEAPON_BAT",
    "WEAPON_KNIFE",
    "WEAPON_GOLFCLUB"
}

RegisterNetEvent("purga:start", function()
    if purgaAtiva then return end
    purgaAtiva = true

    -- 1. ATIVA O MODO REVOLTA NATIVO DA ROCKSTAR
    -- Isso faz os motoristas acelerarem, baterem os carros e inicia brigas espontâneas
    SetRiotModeEnabled(true)

    -- 2. CONFIGURAÇÃO DOS GRUPOS DE ÓDIO (O segredo do Pandemônio)
    -- Criamos dois grupos civis rivais para a Purga
    AddRelationshipGroup('PURGA_FACCOES_A')
    AddRelationshipGroup('PURGA_FACCOES_B')

    -- Faz o Grupo A odiar o Grupo B e vice-versa (5 = HATE/ÓDIO)
    SetRelationshipBetweenGroups(5, GetHashKey('PURGA_FACCOES_A'), GetHashKey('PURGA_FACCOES_B'))
    SetRelationshipBetweenGroups(5, GetHashKey('PURGA_FACCOES_B'), GetHashKey('PURGA_FACCOES_A'))

    -- Faz ambos os grupos odiarem os jogadores do servidor
    SetRelationshipBetweenGroups(5, GetHashKey('PURGA_FACCOES_A'), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(5, GetHashKey('PURGA_FACCOES_B'), GetHashKey('PLAYER'))

    -- Modificadores visuais (Clima de tempestade e noite)
    SetTimecycleModifier("scanline_cam_cheap")
    SetTimecycleModifierStrength(1.0)
    TriggerEvent('qb-weathersync:client:EnableSync', false) 
    NetworkOverrideClockTime(23, 50, 0)
    SetWeatherTypeOvertimePersist("THUNDER")
    SetWeatherTypeNowPersist("THUNDER")

    -- Relâmpagos frequentes
    CreateThread(function()
        while purgaAtiva do
            Wait(math.random(2000, 4000))
            ForceLightningFlash()
        end
    end)

    -- 3. LOOP DE CORRUPÇÃO DA IA DOS NPCS NATIVOS
    CreateThread(function()
        while purgaAtiva do
            local playerPed = PlayerPedId()
            local handle, ped = FindFirstPed()
            local success
            
            repeat
                -- Verifica se o NPC existe, não é um jogador e está vivo
                if DoesEntityExist(ped) and ped ~= playerPed and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then 
                    
                    -- Pegamos o grupo atual do NPC
                    local grupoAtual = GetPedRelationshipGroupHash(ped)

                    -- Se ele ainda for um civil pacífico, nós corrompemos a IA dele
                    if grupoAtual ~= GetHashKey('PURGA_FACCOES_A') and grupoAtual ~= GetHashKey('PURGA_FACCOES_B') then
                        
                        -- Divide a população nativa da rua aleatoriamente entre os dois grupos rivais
                        if math.random(1, 2) == 1 then
                            SetPedRelationshipGroupHash(ped, GetHashKey('PURGA_FACCOES_A'))
                        else
                            SetPedRelationshipGroupHash(ped, GetHashKey('PURGA_FACCOES_B'))
                        end

                        -- Remove o medo do NPC e força ele a lutar
                        SetPedAlertness(ped, 3)               -- Alerta máximo
                        SetPedCombatAttributes(ped, 46, true) -- Luta contra alvos armados
                        SetPedCombatAttributes(ped, 5, true)  -- Luta sem armas se necessário
                        SetPedCombatAttributes(ped, 1, true)  -- Força o uso de armas de fogo
                        SetPedCombatAttributes(ped, 2, false) -- Proíbe o NPC de fugir
                        SetPedFleeAttributes(ped, 0, false)   -- Remove o instinto de fuga do GTA
                        SetPedCombatAbility(ped, 2)           -- Habilidade profissional
                        SetPedCombatMovement(ped, 3)          -- Avança de forma agressiva
                        SetPedAsEnemy(ped, true)
                        SetPedKeepTask(ped, true)

                        -- Entrega uma arma aleatória para o cidadão comum
                        if not HasPedGotWeapon(ped, GetHashKey("WEAPON_PISTOL"), false) then
                            local armaSorteada = listaArmas[math.random(#listaArmas)]
                            GiveWeaponToPed(ped, GetHashKey(armaSorteada), 9999, false, true)
                            SetCurrentPedWeapon(ped, GetHashKey(armaSorteada), true) -- Puxa a arma na mão
                        end

                        -- Comportamento caso ele esteja dentro de um veículo nativo
                        if IsPedInAnyVehicle(ped, false) then
                            local veh = GetVehiclePedIsIn(ped, false)
                            if GetPedInVehicleSeat(veh, -1) == ped then
                                SetDriveTaskDrivingStyle(ped, 2883621) -- Estilo de direção destrutivo/insano
                                TaskVehicleDriveWander(ped, veh, 80.0, 2883621)
                            end
                        else
                            -- Comandamos a IA a caçar os inimigos do grupo rival ao redor dele
                            TaskCombatHatedTargetsAroundPed(ped, 200.0, 0)
                        end
                    end
                end
                success, ped = FindNextPed(handle)
            until not success
            EndFindPed(handle)

            Wait(1500) -- Varre a área a cada 1.5 segundos para pegar novos NPCs que surgirem na rua
        end
    end)
end)

RegisterNetEvent("purga:stop", function()
    purgaAtiva = false
    SetRiotModeEnabled(false)
    ClearTimecycleModifier()
    NetworkClearClockTimeOverride()
    ClearWeatherTypePersist()
    TriggerEvent('qb-weathersync:client:EnableSync', true) 

    -- Restaura a paz para todos os NPCs sobreviventes na rua
    local playerPed = PlayerPedId()
    local handle, ped = FindFirstPed()
    local success
    repeat
        if DoesEntityExist(ped) and ped ~= playerPed and not IsPedAPlayer(ped) then
            ClearPedTasksImmediately(ped)
            RemoveAllPedWeapons(ped, true) -- Remove as armas distribuídas
            SetPedRelationshipGroupHash(ped, GetHashKey('CIVMALE')) -- Volta ao grupo civil padrão
        end
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
end)
