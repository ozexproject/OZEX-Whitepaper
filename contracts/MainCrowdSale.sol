pragma solidity ^0.4.20;

import './LegalBlockToken.sol';
import './Crowdsale/FinalizableCrowdsale.sol';
import './Crowdsale/crowdsale.sol';



contract MainCrowdsale is Consts, FinalizableCrowdsale {
    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }

    function finalization() internal {
        super.finalization();

        if (PAUSED) {
            MainToken(token).unpause();
        }

        if (!CONTINUE_MINTING) {
            token.finishMinting();
        }

        token.transferOwnership(TARGET_USER);
    }

    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate).div(1 ether);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }
}


contract Checkable {
    address private serviceAccount;
    /**
     * Flag means that contract accident already occurs.
     */
    bool private triggered = false;

    /**
     * Occurs when accident happened.
     */
    event Triggered(uint balance);
    /**
     * Occurs when check finished.
     */
    event Checked(bool isAccident);

    function Checkable() public {
        serviceAccount = msg.sender;
    }

    /**
     * @dev Replace service account with new one.
     * @param _account Valid service account address.
     */
    function changeServiceAccount(address _account) onlyService public {
        assert(_account != 0);
        serviceAccount = _account;
    }

    /**
     * @dev Is caller (sender) service account.
     */
    function isServiceAccount() view public returns (bool) {
        return msg.sender == serviceAccount;
    }

    /**
     * Public check method.
     */
    function check() onlyService notTriggered payable public {
        if (internalCheck()) {
            Triggered(this.balance);
            triggered = true;
            internalAction();
        }
    }

    /**
     * @dev Do inner check.
     * @return bool true of accident triggered, false otherwise.
     */
    function internalCheck() internal returns (bool);

    /**
     * @dev Do inner action if check was success.
     */
    function internalAction() internal;

    modifier onlyService {
        require(msg.sender == serviceAccount);
        _;
    }

    modifier notTriggered() {
        require(!triggered);
        _;
    }
}


contract BonusableCrowdsale is Consts, Crowdsale {

    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 bonusRate = getBonusRate(weiAmount);
        uint256 tokens = weiAmount.mul(bonusRate).div(1 ether);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    function getBonusRate(uint256 weiAmount) internal view returns (uint256) {
        uint256 bonusRate = rate;

        

        
        // apply amount
        uint[5] memory weiAmountBoundaries = [uint(100000000000000000000),uint(50000000000000000000),uint(20000000000000000000),uint(20000000000000000000),uint(10000000000000000000)];
        uint[5] memory weiAmountRates = [uint(100),uint(50),uint(30),uint(0),uint(20)];

        for (uint j = 0; j < 5; j++) {
            if (weiAmount >= weiAmountBoundaries[j]) {
                bonusRate += bonusRate * weiAmountRates[j] / 1000;
                break;
            }
        }
        

        return bonusRate;
    }
}



contract TemplateCrowdsale is Consts, MainCrowdsale
    
    , BonusableCrowdsale
    
    
    , CappedCrowdsale
    
{
    event Initialized();
    bool public initialized = false;

    function TemplateCrowdsale(MintableToken _token) public
        Crowdsale(START_TIME > now ? START_TIME : now, 1528189200, 212793 * TOKEN_DECIMAL_MULTIPLIER, 0xDf11c1D51c10Fd13c1673831faB6dB1976ca886C)
        CappedCrowdsale(46994027059160780664778)
        
    {
        token = _token;
    }

    function init() public onlyOwner {
        require(!initialized);
        initialized = true;

        if (PAUSED) {
            MainToken(token).pause();
        }

        
        address[4] memory addresses = [address(0x0b545bd555a6d4e385f5690a1f9cb6c3d2ecb12c),address(0x42eb35c5a40478784704b86349d23f7342e88a8e),address(0xf597781495f23ba5e7f6c7096685dc691b29e9b2),address(0x74c2019365634f9c7af8c9136ac013819bdc0322)];
        uint[4] memory amounts = [uint(1500000000000000000000000000),uint(1000000000000000000000000000),uint(1000000000000000000000000000),uint(1500000000000000000000000000)];
        uint64[4] memory freezes = [uint64(0),uint64(0),uint64(0),uint64(0)];

        for (uint i = 0; i < addresses.length; i++) {
            if (freezes[i] == 0) {
                MainToken(token).mint(addresses[i], amounts[i]);
            } else {
                MainToken(token).mintAndFreeze(addresses[i], amounts[i], freezes[i]);
            }
        }
        

        transferOwnership(TARGET_USER);

        Initialized();
    }

    /**
     * @dev override token creation to set token address in constructor.
     */
    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(0);
    }

    

    
    /**
     * @dev override purchase validation to add extra value logic.
     * @return true if sended more than minimal value
     */
    function validPurchase() internal view returns (bool) {
        
        bool minValue = msg.value >= 5000000000000000000;
        
        
        bool maxValue = msg.value <= 3000000000000000000000;
        

        return
        
            minValue &&
        
        
            maxValue &&
        
            super.validPurchase();
    }
    

    
    /**
     * @dev override hasEnded to add minimal value logic
     * @return true if remained to achieve less than minimal
     */
    function hasEnded() public view returns (bool) {
        bool remainValue = cap.sub(weiRaised) < 5000000000000000000;
        return super.hasEnded() || remainValue;
    }
    

}


