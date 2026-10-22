local QBCore = exports['qb-core']:GetCoreObject()
local purgaAtiva = false
local emCooldown = false

local duracao = 300 -- 5 minutos
local cooldown = 900 -- 15 minutos

local sireneLoop = false

-- Criando o comando usando a estrutura nativa do framework
QBCore.Commands.Add("purga", "Inicia o evento global da Purga", {}, true, function(source, args)
    
    if purgaAtiva then
        if source ~= 0 then
            -- Envia notificação usando a estrutura nativa do ox_lib via evento
            TriggerClientEvent('ox_lib:notify', source, { title = 'Erro', description = 'A purga já está ativa.', type = 'error' })
        end
        return
    end

    if emCooldown then
        if source ~= 0 then
            TriggerClientEvent('ox_lib:notify', source, { title = 'Erro', description = 'O evento da Purga está em tempo de recarga.', type = 'error' })
        end
        return
    end

    purgaAtiva = true
    emCooldown = true

    -- Inicia o evento e avisa todos os jogadores simultaneamente
    TriggerClientEvent("purga:start", -1)
    IniciarSireneLoop()

    TriggerClientEvent('ox_lib:notify', -1, {
        title = '🚨 PURGA INICIADA',
        description = 'O expurgo anual começou. Assassinatos e crimes estão liberados por 5 minutos!',
        type = 'error',
        duration = 15000
    })

    -- Finaliza o evento após o tempo determinado
    SetTimeout(duracao * 1000, function()
        purgaAtiva = false
        TriggerClientEvent("purga:stop", -1)
        PararSireneLoop()

        TriggerClientEvent('ox_lib:notify', -1, {
            title = '🕊️ PURGA ENCERRADA',
            description = 'O período da purga acabou. Os serviços de emergência foram reestabelecidos.',
            type = 'success',
            duration = 10000
        })
    end)

    -- Libera o cooldown após o tempo determinado
    SetTimeout(cooldown * 1000, function()
        emCooldown = false
    end)
end, "admin") -- Restringe o comando apenas para Administradores

function IniciarSireneLoop()
    if sireneLoop then return end
    sireneLoop = true

    CreateThread(function()
        while sireneLoop do
            TriggerClientEvent("InteractSound_CL:PlayOnAll", -1, "airraid", 1.0)
            Wait(13800) -- Aguarda o tempo do áudio terminar
        end
    end)
end

function PararSireneLoop()
    sireneLoop = false
    TriggerClientEvent("InteractSound_CL:StopOnAll", -1)
end
