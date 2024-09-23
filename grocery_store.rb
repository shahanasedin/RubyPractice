class GroceryStore

    VALID_NOTES = [2000, 500, 200, 100, 50, 20, 10, 5, 2, 1]
    def initialize
        @cash_register = Hash.new(0)
        cash_register_details
        denominations
    end

    def cash_register_details
        p "Please enter your cash register details"
        p "------------------------------------------------"
        VALID_NOTES.each do |amt|
            p "Please enter number of #{amt}rs notes you have :"
            val = gets.chomp.to_i
            @cash_register[amt] = val
        end
        p "-------------------------------------------------"
    end

    def total_amt
        @cash_register.sum {|amt, val| amt * val}
    end

    def denominations
        p "Cash register original #{@cash_register}"
        p "Total amount is #{total_amt}"
        p "Enter the total amount to be paid by the customer"
        bill = gets.chomp.to_i
        p "Enter the amount paid by customer(comma-separated)"
        amount_paid = gets.chomp
        amount_paid = amount_paid.split(",")
        user_denomination = Hash.new(0)
        user_total = 0

        amount_paid.each do |amt|
            if VALID_NOTES.include?(amt.to_i)
                user_denomination[amt.to_i] += 1
                user_total += amt.to_i
            else
                return if p "Invalid notes given, Please check your currency"
            end
        end

        return p "You have paid #{bill - user_total} less than the original cost. Transaction failed" if bill > user_total
        
        change_due = user_total - bill
        return p "Sorry, the cash register has insufficient amount to give your change.Please pay with appropriate change" if total_amt < change_due

        return p "User has provided the correct amount, No change needed" if change_due == 0

        change_denominations = Hash.new(0)
        @cash_register_original = @cash_register.dup
        @cash_register.sort_by {|key, val| key}.reverse
        @cash_register.each do |amt, count|
            next if(count == 0)
            if change_due >= (amt * count)
                @cash_register[amt] = 0
                change_due -= (amt * count)
                change_denominations[amt] += count
            else
                notes = change_due / amt
                @cash_register[amt] -= notes
                change_due -= ((notes * amt))
                change_denominations[amt] = notes
            end
        end

        if change_due == 0
            p "Change is provided successfully with the following denominations #{change_denominations}"
            p "Current cash register #{@cash_register}"
            user_denomination.each do |amt, count|
                @cash_register[amt] += count
            end
            p "Current total : #{total_amt}"

        else
            @cash_register = @cash_register_original
            p "Sorry we have a deficit of #{change_due} rs to give your change.Please pay with correct change the next time"
            p "Cash register updated to original #{@cash_register}"
            return
        end
    end
end

Shop1 = GroceryStore.new
