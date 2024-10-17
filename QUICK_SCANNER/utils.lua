-- utils.lua
-- Function to generate an item key from a given item ID
function GenerateItemKey(itemID)
    local itemKey = C_AuctionHouse.MakeItemKey(itemID)
    return itemKey
end

