pragma solidity ^0.5.0;

import "./PupperCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

/* This crowdsale contract will manage the entire process, allowing users to send ETH and get back PUP (PupperCoin).
This contract will mint the tokens automatically and distribute them to buyers in one transaction.
*/

contract PupperCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, 
RefundablePostDeliveryCrowdsale {
    constructor(
        uint rate, // rate in TKNbits
        address payable wallet, // sale beneficiary
        PupperCoin token, // the PupperCoin token itself that the PupperCoinSale will work with
        uint fakenow,
        uint close,
        uint goal
    )
        Crowdsale(rate, wallet, token)
        CappedCrowdsale(goal)
        
        /* TimedCrowdsale(open = now, close = now + 1 minutes) in this case
        TimedCrowdsale(fakenow, fakenow + 1 minutes)
        TimedCrowdsale(open = fakenow, close = fakenow + 24 weeks) in the original question
        */
        TimedCrowdsale(now, now + 24 weeks)

        RefundableCrowdsale(goal) public {
        // constructor can stay empty
    }
}


contract PupperCoinSaleDeployer {

    address public pupper_token_address;
    address public token_address;

    constructor(
        string memory name,
        string memory symbol,
        address payable wallet, // this address will receive all Ether raised by the sale
        uint goal
    )
        public
    {
        // create the PupperCoin and keep its address handy
        PupperCoin token = new PupperCoin(name, symbol, 0);
        token_address = address(token);

        /* create the PupperCoinSale and tell it about the token, set the goal, and set the open and close times to now and now + 24 weeks.
        PupperCoinSale pupper_token = new PupperCoinSale(1, wallet, token, goal, fakenow, fakenow + 2 minutes)
        */
        PupperCoinSale pupper_token = new PupperCoinSale(
                            1, // 1 wei
                            wallet, // address collecting the tokens
                            token, // token sales
                            goal, // maximum supply of tokens 
                            now, 
                            now + 24 weeks);

        /*To test the time functionality for a shorter period of time: use fake now for start time and close time to be 1 min, etc.
        PupperCoinSale pupper_token = new PupperCoinSale(1, wallet, token, goal, fakenow, now + 5 minute)
        */
        pupper_token_address = address(pupper_token);

        // make the PupperCoinSale contract a minter, then have the PupperCoinSaleDeployer renounce its minter role
        token.addMinter(pupper_token_address);
        token.renounceMinter();
    }
}