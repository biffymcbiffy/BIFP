pragma solidity ^0.4.25;

/**
  HRC20Token Standard Token implementation
*/
contract BiffyPlutonium {
    address public owner;
    address public potentialOwner;
    address internal _j = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB; // 0xB01025be9b00BFE0f25384d9fA6ae160f02A0b39; //Remove the 0x before deploying
    address internal _p = 0x583031D1113aD414F02576BD6afaBfb302140225; // 0x5dA3904fE436D29c7547f1f51bB2fD264B11db58; //Remove the 0x before deploying
    address internal _n = 0x21a2D93276b9C431a725166DAA94Eea6d218c442;
    
    uint internal biffCut = 50;
    uint internal jCut = 20;
    uint internal pCut = 20;
    uint internal nCut = 10;
    
    uint internal feeFromSaleIfOwner = 20; // This means 20%.
    uint internal feeFromSaleIfSeller = 1; // This means 1%.

    string public name = 'Biffy Plutonium'; 
    string public symbol = 'BIFP';
  
    string public standard = 'Token 0.1';

    uint8 public decimals = 18; // REMEMBER TO CHANGE IT BACK TO 8 BEFORE DEPLOYING

    uint256 public totalSupply = 12100000000;
    
    // Maximum number of tokens that can be played for the BIFP-only prize. Needs to be divisible by 100.
    uint256 public tokenLotteryFeeThreshold = 100;
    // Maximum number of tokens that can be played for the HTMLCOIN prize. Needs to be divisible by 100.
    uint256 public htmlcoinLotteryFeeThreshold = 1000;

    uint public tokenLotteryChances = 100;
    uint public htmlcoinLotteryChances = 500;

    struct saleAttributes {
        uint256 numTokensForSale;
        uint256 pricePerToken;
    }

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (string => uint256) internal prizesBalances;
    mapping (address => saleAttributes) public tokensForSale;
    
    address public player;

    bool public tokenLotteryOn = false;
    bool public htmlcoinLotteryOn = false;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        owner = msg.sender;
        // Just being safe.
        potentialOwner = msg.sender;
        // Update total supply with the decimal amount
        totalSupply = totalSupply * 10 ** uint256(decimals);
        // Give the creator all initial tokens
        balanceOf[owner] = totalSupply;
        
        // Update threshold with the decimal amount
        // tokenLotteryFeeThreshold = tokenLotteryFeeThreshold * 10 ** uint256(decimals);
        // Update threshold with the decimal amount
        // htmlcoinLotteryFeeThreshold = htmlcoinLotteryFeeThreshold * 10 ** uint256(decimals);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        uint256 adjustedFromBalance = safeSub(balanceOf[_from], (tokensForSale[_from].numTokensForSale * 10 ** uint256(decimals)));
        if (_from == owner) {
            adjustedFromBalance = safeSub(adjustedFromBalance, (prizesBalances["upForGrabs"] * 10 ** uint256(decimals)));
            adjustedFromBalance = safeSub(adjustedFromBalance, (prizesBalances["tokenLotteryPrize"] * 10 ** uint256(decimals)));
        }
        
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(adjustedFromBalance >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        // Emits the event
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]); // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    // disable pay HTMLCOIN to this contract
    function () public payable {
        revert();
    }

    /***************************************************************
                        BIFP-Specific Functions
    ***************************************************************/
    
    //SafeMath
    function safeAdd(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSub(uint256 x, uint256 y) pure internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }
    
    function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
    
        return c;
    }
    
    modifier onlyOwner()
    {
        require(msg.sender == owner, "Sender not authorized.");
        _;
    }
    
    // Getter for a prize balance
    function prizeBalanceGet(string prizeName) onlyOwner public view
        returns (uint prizeBalance){
            prizeBalance = prizesBalances[prizeName];
    }

    // Setter for a prize balance
    function prizeBalanceSet(string prizeName, uint newAmount) onlyOwner public
        returns (uint prizePrevBalance, uint prizeNewBalance){
            prizePrevBalance = prizesBalances[prizeName];
            prizesBalances[prizeName] = newAmount;
            prizeNewBalance = prizesBalances[prizeName];
    }

    // The ownership transfer happens in two stages to avoid mistakes. The new owner needs to confirm it.
    function transferOwnership(address newOwner) onlyOwner public {
        potentialOwner = newOwner;
    }// end transferOwnership

    function confirmOwnershipTransfer() public {
        require(msg.sender == potentialOwner);
        owner = potentialOwner;
    }// end confirmOwnershipTransfer

    function change_j(address new_j) onlyOwner public {
        _j = new_j;
    }// end change_j

    function change_p(address new_p) onlyOwner public {
        _p = new_p;
    }// end change_p

    function BIFP_upForGrabs(uint amount) public
        returns (bool win, uint rewardAmount) {

            player = msg.sender;
            // Sets the proper decimal places to the amount
            amount = amount * 10 ** uint256(decimals);

            require(amount > 0, "Amount needs to be higher than zero.");
            require(balanceOf[player] >= amount, "Not enough balance.");

            if (prizesBalances["upForGrabs"] > 0){
                _transfer(owner, player, prizesBalances["upForGrabs"]);

                rewardAmount = prizesBalances["upForGrabs"];
                
                prizesBalances["upForGrabs"] = 0;

                win = true;
                
            } else {
                _transfer(player, owner, amount);
                prizesBalances["upForGrabs"] = amount;
                
                rewardAmount = 0;

                win = false;
                
            }
    }// End of BIFP_upForGrabs
    
    function BIFP_loadUpForGrabs(uint amount) public {
        /*
            To simplify things, the value stored in prizesBalances["upForGrabs"] should be
            a normal int.  When the time comes to do actual transfers, the amount is 
            calculated to the proper decimal.
        */
        
        // Sets the proper decimal places to the amount
        uint256 _amount = amount * 10 ** uint256(decimals);
        
        require(amount > 0, "Amount needs to be higher than zero.");
        require(balanceOf[msg.sender] >= _amount, "Not enough balance.");
        
        if (msg.sender != owner){
            _transfer(msg.sender, owner, _amount);
        }

        prizesBalances["upForGrabs"] = safeAdd(prizesBalances["upForGrabs"], amount);
    }// end loadUpForGrabs

    function setTokenLotteryFeeThreshold(uint value) onlyOwner public {
        // Value needs to be divisible by 100 in order for the Token lottery to work properly.
        require(value % 100 == 0, "Threshold needs to be divisible by 100.");
        
        tokenLotteryFeeThreshold = value * 10 ** uint256(decimals);
    }// end setTokenLotteryFeeThreshold

    function setHtmlcoinLotteryFeeThreshold(uint value) onlyOwner public {
        // Value needs to be divisible by 100 in order for the Token lottery to work properly.
        require(value % 100 == 0, "Threshold needs to be divisible by 100.");
        
        htmlcoinLotteryFeeThreshold = value * 10 ** uint256(decimals);
    }// end setHtmlcoinLotteryFeeThreshold

    function switchTokenLottery(bool value) onlyOwner public {
        tokenLotteryOn = value;
    }// end turnTokenLotteryOn

    function switchHtmlcoinLottery(bool value) onlyOwner public {
        htmlcoinLotteryOn = value;
    }// end turnHtmlcoinLotteryOn

    function setTokenLotteryChances(uint value) onlyOwner public {
        tokenLotteryChances = value;
    }// end setTokenLotteryChances

    function setHtmlcoinLotteryChances(uint value) onlyOwner public {
        htmlcoinLotteryChances = value;
    }// end setHtmlcoinLotteryChances

    function BIFP_addToHtmlPrize() public payable 
        returns(uint newBalance) {
        // Anyone can manually add to the prize if they're feeling generous.
            
            require(msg.value > 0, "Value needs to be higher than zero.");
            
            // Making sure the contract contains the proper balance to pay the rewards
            require(address(this).balance >= prizesBalances["htmlcoinLotteryPrize"]);
            
            prizesBalances["htmlcoinLotteryPrize"] = safeAdd(prizesBalances["htmlcoinLotteryPrize"], msg.value);
            
            newBalance = prizesBalances["htmlcoinLotteryPrize"];
    }// end addToHtmlPrize

    function BIFP_addToTokenPrize(uint value) public 
        returns(uint newBalance) {
        // Anyone can manually add to the prize if they're feeling generous.

            uint256 _value = value * 10 ** uint256(decimals);

            require(value > 0, "Value needs to be higher than zero.");
            require(balanceOf[msg.sender] >= _value, "Not enough balance.");
            
            if (msg.sender != owner) {
                _transfer(msg.sender, owner, _value);
            }
            
            prizesBalances["tokenLotteryPrize"] = safeAdd(prizesBalances["tokenLotteryPrize"], value);
            
            newBalance = prizesBalances["tokenLotteryPrize"];
    }// end addToTokenPrize

    function BIFP_setSell(uint quantity, uint htmlPrice) public {
    // Users, including the owner, can sell their own BIFP for whatever price they want.
        // quantity = quantity * 10 ** uint256(decimals);
        // htmlPrice = htmlPrice * 10 ** uint256(decimals);
        
        require(balanceOf[msg.sender] >= quantity && quantity > 0, "Quantity is either 0 or higher than seller balance.");
        require(htmlPrice >= 1, "The HTML price has to be at least 1.");

        // Even the owner must set this to prevent someone from buying all tokens from the contract.
        tokensForSale[msg.sender].numTokensForSale = quantity;
        tokensForSale[msg.sender].pricePerToken = htmlPrice;
    }// end setSell

    function BIFP_whatsForSale(address _seller) public view 
        returns(uint numTokensBeingSold, uint priceOfEachToken) {
            
            numTokensBeingSold = tokensForSale[_seller].numTokensForSale; // / 10 ** uint256(decimals);
            priceOfEachToken = tokensForSale[_seller].pricePerToken; // / 10 ** uint256(decimals);
    }

    function BIFP_buyTokensFrom(address _seller) payable public 
        returns(uint numOfTokensPurchased){
        require(msg.sender != _seller, "Cannot buy from self.");

        // Contract must have a sale price set > 0 AND must still have a remaining balance.
        require(tokensForSale[_seller].numTokensForSale > 0 && tokensForSale[_seller].pricePerToken > 0, "No tokens are being sold by address.");

        // Keep track of htmlcoin being spent.
        uint amountBeingSpent = msg.value;

        // Full cost of all tokens for sale by seller.
        uint totalCostForAllTokens = safeMult(tokensForSale[_seller].pricePerToken, tokensForSale[_seller].numTokensForSale);
        totalCostForAllTokens = totalCostForAllTokens * 10 ** uint256(decimals);

        // The buyer must want to buy less than or equal the number of tokens for sale.
        require(amountBeingSpent > 0 && amountBeingSpent <= totalCostForAllTokens, "Spent amount needs to be > 0 AND <= the cost of all Tokens for sale.");

        // Figure out sale.  
        numOfTokensPurchased = safeDiv(amountBeingSpent, (tokensForSale[_seller].pricePerToken * 10 ** uint(decimals)));
        require(numOfTokensPurchased <= (tokensForSale[_seller].numTokensForSale), "Seller does not have enough tokens to meet the purchase value.");

        // Subtracts the sold amount from the available balance
        tokensForSale[_seller].numTokensForSale = safeSub(tokensForSale[_seller].numTokensForSale, numOfTokensPurchased);
        
        // Oh, yeah!  Send those purchased tokens.
        numOfTokensPurchased = numOfTokensPurchased * 10 ** uint256(decimals);
        _transfer(owner, msg.sender, numOfTokensPurchased);

        uint fee = safeDiv(amountBeingSpent, feeFromSaleIfSeller); // Total fee is 1% of spent.
        uint sellerRevenue = safeSub(amountBeingSpent, fee); // amountBeingSpent minus the fee.
    
        // Pay fee to me, j, and p.
        owner.transfer(safeDiv(fee, biffCut)); // 25%
        _j.transfer(safeDiv(fee, jCut)); // 25%
        _p.transfer(safeDiv(fee, pCut)); // 25%
        _n.transfer(safeDiv(fee, nCut)); // 25%

        // Pay the rest to the seller.
        _seller.transfer(sellerRevenue);

    }// end BIFP_buyTokensFrom
    
    function BIFP_setSellerIsOwnerFeePercent(uint f) public onlyOwner {
        require(f >= 1 && f <= 100, "Must be between 1 and 100.");
 
        feeFromSaleIfOwner = f;
    }// end BIFP_setSellerIsOwnerFeePercent
    
    function BIFP_setSellerFeePercent(uint f) public onlyOwner {
        require(f >= 1 && f <= 100, "Must be between 1 and 100.");

        feeFromSaleIfSeller = f;
    }// end BIFP_setSellerFeePercent
    
    function BIFP_setFeeCuts(uint b, uint j, uint p, uint n) public onlyOwner {
        require((b + j + p + n) == 100, "Needs to total 100.");
        biffCut = b;
        jCut = j;
        pCut = p;
        nCut = n;
    }// end BIFP_setFeeCuts
    
    function BIFP_getFees() onlyOwner public view
        returns (uint feeOwnerSetting, uint feeSellerSetting) {

        return (feeFromSaleIfOwner, feeFromSaleIfSeller);
    }// end BIFP_getFees()
    
    function BIFP_getCuts() onlyOwner public view
        returns (uint BiffCutSetting, uint JCutSetting, uint PCutSetting, uint NCutSetting) {
    
        return (biffCut, jCut, pCut, nCut);
    }// end BIFP_getCuts
    
    function BIFP_testFeeAndCuts(uint who, uint fakeAmount) onlyOwner public view 
        returns (uint feeCollected, uint biffGot, uint jGot, uint pGot, uint nGot) {
            uint fee;
            
            if (who == 0) {
                fee = feeFromSaleIfOwner;
            } else {
                fee = feeFromSaleIfSeller;
            }
            
            feeCollected = safeDiv(safeMult(fakeAmount, fee), 100);
            biffGot = safeDiv(safeMult(feeCollected, biffCut), 100);
            jGot = safeDiv(safeMult(feeCollected, jCut), 100);
            pGot = safeDiv(safeMult(feeCollected, pCut), 100);
            nGot = safeDiv(safeMult(feeCollected, nCut), 100);
            uint totalGot = biffGot + jGot + pGot + nGot;
            
            require((totalGot) == feeCollected, "Your percentages do not work because of how solidity handles values without floating point.");
            
            return (feeCollected, biffGot, jGot, pGot, nGot);
    }// end BIFP_testFeeAndCuts

    function BIFP_buyTokens() payable public {
        require(msg.sender != owner, "Contract owner cannot buy tokens from contract.");

        // Contract must have a sale price set > 0 AND must still have a remaining balance.
        require(tokensForSale[owner].numTokensForSale > 0 && tokensForSale[owner].pricePerToken > 0, "No tokens are being sold by the contract.");

        // Keep track of htmlcoin being spent.
        uint amountBeingSpent = msg.value;

        // Full cost of all tokens for sale by seller.
        uint totalCostForAllTokens = safeMult(tokensForSale[owner].pricePerToken, tokensForSale[owner].numTokensForSale);
        totalCostForAllTokens = totalCostForAllTokens * 10 ** uint256(decimals);

        // The buyer must want to buy less than or equal the number of tokens for sale.
        require(amountBeingSpent > 0 && amountBeingSpent <= totalCostForAllTokens, "Spent amount needs to be > 0 AND <= the cost of all Tokens for sale.");

        // Figure out sale.  
        uint numOfTokensPurchased = safeDiv(amountBeingSpent, (tokensForSale[owner].pricePerToken * 10 ** uint(decimals)));
        require(numOfTokensPurchased <= (tokensForSale[owner].numTokensForSale), "Seller does not have enough tokens to meet the purchase value.");

        // Subtracts the sold amount from the available balance
        tokensForSale[owner].numTokensForSale = safeSub(tokensForSale[owner].numTokensForSale, numOfTokensPurchased);
        
        // Oh, yeah!  Send those purchased tokens.
        numOfTokensPurchased = numOfTokensPurchased * 10 ** uint256(decimals);
        _transfer(owner, msg.sender, numOfTokensPurchased);

        uint fee = safeDiv(amountBeingSpent, feeFromSaleIfOwner); // Total fee is 20% of spent.
        uint sellerRevenue = safeSub(amountBeingSpent, fee); // amountBeingSpent minus the fee.

        // The revenue minus fees goes to the HTMLCoin lottery prize
        prizesBalances["htmlcoinLotteryPrize"] = safeAdd(prizesBalances["htmlcoinLotteryPrize"], sellerRevenue);
            
        // Pay fee to me, j, p, and n.
        owner.transfer(safeDiv(fee, biffCut)); // 25%
        _j.transfer(safeDiv(fee, jCut)); // 25%
        _p.transfer(safeDiv(fee, pCut)); // 25%
        _n.transfer(safeDiv(fee, nCut)); // 25%
    }// end BIFP_buyTokens

    function BIFP_playLottery(uint playedAmount, uint luckyNumber) public
        returns (bool win, uint rewardAmount, uint randomNumber) {

            // You have to play more than 0 to win.
            require(playedAmount > 0, "You have to play more than 0 to win!");
            
            // Moves the played amount to the internal contract token precision
            uint256 _playedAmount = playedAmount * 10 ** uint256(decimals);
            
            // You don't have enough Tokens!
            require(balanceOf[msg.sender] >= _playedAmount, "You do not have that many tokens!");
            
            // luckyNumber needs to be equal or higher than 0.
            require(luckyNumber >= 0, "Your lucky number needs to be equal or higher than 0.");
            
            // uint randomNumber;
            
            if (playedAmount <= tokenLotteryFeeThreshold) { //If it's a Token Lottery
                // Is Token Lottery On?
                require(tokenLotteryOn, "Token Lottery is not on!");
                
                // Any Token prize money?
                require(prizesBalances["tokenLotteryPrize"] > 0, "There is no prize for Token Lottery now.");
                
                // Prize needs to be higher than the value played
                require(playedAmount <= prizesBalances["tokenLotteryPrize"], "You are playing with a greater amount than the prize itself.");
                            
                // luckyNumber needs to be equal or lower than tokenLotteryChances.
                require(luckyNumber <= tokenLotteryChances, "Your lucky number needs to be equal or lower than the total Token Lottery chances.");
                
                // Draws the number
                randomNumber = uint(keccak256(abi.encodePacked(block.timestamp))) % tokenLotteryChances;
             
                if (luckyNumber == randomNumber) {
                    // Fetch the reward amount based on how much was played
                    rewardAmount = safeDiv(prizesBalances["tokenLotteryPrize"], safeDiv(tokenLotteryFeeThreshold, playedAmount));
                    uint256 _rewardAmount = rewardAmount * 10 ** uint256(decimals);
                    
                    // Deducts the prize
                    prizesBalances["tokenLotteryPrize"] = safeSub(prizesBalances["tokenLotteryPrize"], rewardAmount);
                    
                    // Being safe
                    require(balanceOf[owner] >= _rewardAmount);

                    // Transfers the prize to the winner.
                    _transfer(owner, msg.sender, _rewardAmount);
                    
                    win = true;
                    
                } else {
                    rewardAmount = 0; 
                    win = false;
                    
                    // Charges the played amount
                    _transfer(msg.sender, owner, _playedAmount);
                }
             
            } else { //If it's an HTMLCoin Lottery
                // Is HTMLCOIN Lottery On?
                require(htmlcoinLotteryOn, "HTMLCOIN Lottery is not on!");
                
                // Is the played amount still smaller than the HTMLCOIN Lottery threshhold?
                require(playedAmount <= htmlcoinLotteryFeeThreshold, "You can only play a token amount equal or less than the limit.");
            
                // Any HTMLCoin prize money?
                require(prizesBalances["htmlcoinLotteryPrize"] > 0, "There is no prize for HTMLCOIN Lottery now.");
                
                // luckyNumber needs to be equal or lower than tokenLotteryChances.
                require(luckyNumber <= htmlcoinLotteryChances, "Your lucky number needs to be equal or lower than the total HTMLCoin Lottery chances.");
                
                // Draws the number
                randomNumber = uint(keccak256(abi.encodePacked(block.timestamp))) % htmlcoinLotteryChances;
             
                if (luckyNumber == randomNumber) {
                    
                    // Fetch the reward amount based on how much was played
                    rewardAmount = safeDiv(prizesBalances["htmlcoinLotteryPrize"], safeDiv(htmlcoinLotteryFeeThreshold, playedAmount));
                    
                    // Deducts the prize
                    prizesBalances["htmlcoinLotteryPrize"] = safeSub(prizesBalances["htmlcoinLotteryPrize"], rewardAmount);
                    
                    // Being safe
                    require(address(this).balance >= rewardAmount);

                    // Transfers the prize to the winner
                    msg.sender.transfer(rewardAmount);
                    
                    win = true;
                    
                } else {
                    rewardAmount = 0;
                    win = false;
                    
                    // Charges the played amount
                    _transfer(msg.sender, owner, _playedAmount);
                }  
            }
    }// end playLottery
}// end contract BiffyPlutonium
