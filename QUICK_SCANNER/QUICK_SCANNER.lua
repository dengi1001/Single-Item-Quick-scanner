-- Replace 'itemID' with your specific commodity item ID
local itemID = 212665
local itemKey = GenerateItemKey(itemID)

print(itemKey)

local maxPrice = 13 * 10000  -- 13 gold converted to copper


-- Create a scan button
local scanButton = CreateFrame("Button", "CommodityScanButton", UIParent, "UIPanelButtonTemplate")
scanButton:SetSize(120, 30)
scanButton:SetText("Scan Now")
scanButton:SetPoint("TOPLEFT", 20, -20)
scanButton:Show()

-- Function to process commodity results
function ProcessCommodityResults()
    local numResults = C_AuctionHouse.GetNumCommoditySearchResults(itemID)
    if numResults > 0 then
        local foundAuctions = false
        for index = 1, numResults do
            local resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, index)
            local unitPrice = resultInfo.unitPrice
            local quantity = resultInfo.quantity

            -- Check if the unit price is below or equal to 13 gold
            if unitPrice <= maxPrice then
                foundAuctions = true
                -- Display the auction details
                print("Found Auction:")
                print("  Unit Price:", GetMoneyString(unitPrice))
                print("  Quantity Available:", quantity)
                -- Optionally, prompt the user to purchase
                PromptPurchase(resultInfo)
            else
                -- Since results are sorted by price, we can break early
                break
            end
        end
        if not foundAuctions then
            print("No auctions found below 13 gold for item ID:", itemID)
        end
    else
        print("No auctions found for item ID:", itemID)
    end
end

-- Function to scan the commodity
local function ScanCommodity()
    -- Query the server for fresh data
    C_AuctionHouse.SendSearchQuery(itemKey, {}, false)

end

-- Event handling for server responses
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
        ProcessCommodityResults()
    end
end)

-- Connect the button to the scan function
scanButton:SetScript("OnClick", function()
    -- Start the scan
    ScanCommodity()
end)

-- Function to prompt the user for purchase
function PromptPurchase(resultInfo)
    -- Create a confirmation dialog
    StaticPopupDialogs["CONFIRM_PURCHASE"] = {
        text = "Purchase " .. resultInfo.quantity .. " units at " .. GetMoneyString(resultInfo.unitPrice) .. " each?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            -- Proceed with the purchase
            C_AuctionHouse.StartCommoditiesPurchase(itemID, resultInfo.quantity)
	        C_Timer.After(.5, function() C_AuctionHouse.ConfirmCommoditiesPurchase(itemID, resultInfo.quantity) end)
            print("Purchase order placed.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    -- Show the confirmation dialog
    StaticPopup_Show("CONFIRM_PURCHASE")
end