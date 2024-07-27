local ESX = nil

local function InitializeESX()
    ESX = exports['es_extended']:getSharedObject()
    if ESX == nil then
        print("Error: ESX could not be retrieved.")
    else
        print("ESX Initialized") 
    end
end

Citizen.CreateThread(function()
    InitializeESX()
    while ESX == nil do
        Citizen.Wait(100)
    end
end)

RegisterServerEvent('billing:sendBill')
AddEventHandler('billing:sendBill', function(targetId, amount, type)
    if ESX == nil then
        print("Error: ESX is not initialized")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    local job = xPlayer.getJob().name

    if not IsApprovedJob(job) then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "Error", "You are not allowed to use this command." }
        })
        return
    end

    if xTarget then
        local targetName = xTarget.getName()
        local playerName = xPlayer.getName()

        if tonumber(amount) <= 0 then
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 }, 
                multiline = true,
                args = { "Error", "Invalid amount specified." }
            })
            return
        end

        if type == 'cash' then
            if xPlayer.getMoney() >= tonumber(amount) then
                xPlayer.removeMoney(tonumber(amount))

                TriggerClientEvent('chat:addMessage', source, {
                    color = { 50, 205, 50 },
                    multiline = true,
                    args = { "Success", "You have successfully billed " .. targetName .. " for $" .. amount }
                })

                TriggerClientEvent('chat:addMessage', targetId, {
                    color = { 255, 165, 0 }, 
                    multiline = true,
                    args = { "Notification", "You have been fined by " .. playerName .. " for $" .. amount }
                })
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = { 255, 0, 0 }, 
                    multiline = true,
                    args = { "Error", "Failed to deduct money. Ensure you have enough funds." }
                })
            end
        elseif type == 'bank' then
            local playerBankMoney = getBankBalance(source)
            if playerBankMoney >= tonumber(amount) then
                setBankBalance(source, playerBankMoney - tonumber(amount))

                TriggerClientEvent('chat:addMessage', source, {
                    color = { 50, 205, 50 }, 
                    multiline = true,
                    args = { "Success", "You have successfully billed " .. targetName .. " for $" .. amount }
                })

                TriggerClientEvent('chat:addMessage', targetId, {
                    color = { 255, 165, 0 },
                    multiline = true,
                    args = { "Notification", "You have been fined by " .. playerName .. " for $" .. amount }
                })
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = { 255, 0, 0 },
                    multiline = true,
                    args = { "Error", "Failed to deduct money. Ensure you have enough funds." }
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                multiline = true,
                args = { "Error", "Invalid type specified. Use 'cash' or 'bank'." }
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "Error", "Player not found." }
        })
    end
end)

function IsApprovedJob(job)
    for _, approvedJob in ipairs(Config.ApprovedJobs) do
        if job == approvedJob then
            return true
        end
    end
    return false
end

function getBankBalance(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer.getAccount('bank').money
end

function setBankBalance(playerId, amount)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.setAccountMoney('bank', amount)
end

RegisterCommand('bank', function(source, args, rawCommand)
    if ESX == nil then
        print("Error: ESX is not initialized")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerBankMoney = getBankBalance(source)
        local color = playerBankMoney >= 0 and {0, 255, 0} or {255, 0, 0}

        TriggerClientEvent('chat:addMessage', source, {
            color = color,
            multiline = true,
            args = { "Bank Balance", "Your current balance is $" .. playerBankMoney }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "Error", "Unable to retrieve your balance." }
        })
    end
end, false)

TriggerEvent('chat:addSuggestion', '/bank', 'Check your current bank balance', {})
