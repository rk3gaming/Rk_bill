RegisterCommand('bill', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    local type = args[3]

    if not targetId or not amount or (type ~= 'cash' and type ~= 'bank') then
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "Error", "Usage: /bill [id] [amount] [cash|bank]" }
        })
        return
    end

    TriggerServerEvent('billing:sendBill', targetId, amount, type)
end, false)

TriggerEvent('chat:addSuggestion', '/bill', 'Bill a player for an amount', {
    { name = 'id', help = 'ID of the player to bill' },
    { name = 'amount', help = 'Amount to bill' },
    { name = 'type', help = 'Type of transaction (cash or bank)' }
})
