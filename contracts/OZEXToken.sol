pragma solidity ^0.4.20;

import '../token/Burnable.sol';
import '../token/FreezableMintableToken.sol';
import '../token/Pausable.sol';





contract Consts {
    uint constant TOKEN_DECIMALS = 18;
    uint8 constant TOKEN_DECIMALS_UINT8 = 18;
    uint constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;

    string constant TOKEN_NAME = "OZEX";
    string constant TOKEN_SYMBOL = "OZX";
    bool constant PAUSED = false;
    address constant TARGET_USER = 0xa493ee5874fb35ae2a1afce5cf130ff2fd103b6a;
    
    uint constant START_TIME = 1528799276;
    
    bool constant CONTINUE_MINTING = true;
}



contract MainToken is Consts, FreezableMintableToken, BurnableToken, Pausable
    
{
    

    function name() pure public returns (string _name) {
        return TOKEN_NAME;
    }

    function symbol() pure public returns (string _symbol) {
        return TOKEN_SYMBOL;
    }

    function decimals() pure public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {
        require(!paused);
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool _success) {
        require(!paused);
        return super.transfer(_to, _value);
    }
}


