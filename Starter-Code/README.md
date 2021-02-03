## PupperCoin Contract.

This contract is to initialize our puppercoin token by importing ERC20, ERC20Detailed, & ERC20Mintable Token Standard contracts Version 2.5.0. 


## Multiple Inheritance:

Puppercoin Contract is derived from 3 different contracts ERC20, ERC20Detailed, & ERC20Mintable.

    contract PupperCoin is ERC20, ERC20Detailed, ERC20Mintable {      
    }


    


* **Calling Functions from parent contracts in child contract (Multi-inheritance)**
  
  If parent contracts have the same exact function , child contract will inherit functions based on the order of inheritance; for example:
    
        pragma solidity ^0.5.0;

        contract A {
            function mycat() public pure returns(string memory) {
                return "Leli";
            }
        }

        contract B {
            function mycat() public pure returns(string memory) {
                return "I only have one";
            }
        }

        contract C is A,B {
        }

        contract D is B.A {
        }


    * Parent Contracts A & B have the same `function mycat()`
    * Parent Contract A will return `Leli`
    * Parent Contract B will return `I only have one`
    * When Depolying `contract C`, it will return `I only have one`
    * When Depolying `contract D`, it will return `Leli`

#### Function from the most right parent contract will be executed first and return its value. Order of Inheritance determine which functions will be executed first.



* **Calling parent constructors in child contract (Multi-inheritance)**
  
  There are 3 different ways to call parent constructors, but in all 3 cases the order of parent constructors are called depends solely on the order of heritance regardless of the order in which parent constructors are called.


        contract A {
            string public name;
            constructor(string memory _name) public {
                name= _name;
            }
        }
        
        contract B {
            string public job;
            constructor(string memory _job) public {
                job= _job;
            }
        }

    ### First way to call parent constructor

        contract C is A("Sasha"), B("Developer"){
        }

    ### Second way to call parent constructor

        contract D is A,B{
            constructor() A("Sasha") B("Developer") public{
        }

    ### Third way to call parent constructor

        contract E is A,B{
            constructor(string memory _name, string memory _job) A(_name_) B(_job) public{
        }

Applying this to our `PupperCoin` Contract, we will call parent contracts from the base line to the derived line so we will start by `ERC20`, then `ERCDetailed`, and finally `ERC20Mintable`

* `PupperCoin` constructor will pass 3 arguments which is name, symbol and initial supply/

* Let's take a look at `ERC20Detailed` constructor:

        constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        }

Derived contract  `PupperCoin` has to indicate all of the constructor arguments from the base contract. Which is going to be `name` of token, `symbol` of token, and `decimals` which is 18 decimal on ethereum blockchain.



## Crowdsale Contract

* First Parent constructor is `Crowdsale` Constructor which must have 3 parameters **Token**, **Wallet**, & **Rate** as shown below: 

        constructor (uint256 rate, address payable wallet, IERC20 token) public {
            require(rate > 0, "Crowdsale: rate is 0");
            require(wallet != address(0), "Crowdsale: wallet is the zero address");
            require(address(token) != address(0), "Crowdsale: token is the zero address");
            _rate = rate;
            _wallet = wallet;
            _token = token;
        }




* Second Parent constructor is `CappedCrowdsale` Constructor which have 1 parameter as shown below: 

        constructor (uint256 cap) public {
            require(cap > 0, "CappedCrowdsale: cap is 0");
            _cap = cap;
        }

* Third Parent constructor is `TimedCrowdsale` Constructor which have 2 parameters **openingTime** &  **closingTime** as shown below: 

        constructor (uint256 openingTime, uint256 closingTime) public {
            require(openingTime >= block.timestamp, "TimedCrowdsale: opening time is before current time");
            require(closingTime > openingTime, "TimedCrowdsale: opening time is not before closing time");
            _openingTime = openingTime;
            _closingTime = closingTime;
        }

* Fourth Parent constructor is `RefundablePostDeliveryCrowdsale` Constructor which is as follows:
  
        contract RefundablePostDeliveryCrowdsale is RefundableCrowdsale, PostDeliveryCrowdsale {
            function withdrawTokens(address beneficiary) public {
                require(finalized(), "RefundablePostDeliveryCrowdsale: not finalized");
                require(goalReached(), "RefundablePostDeliveryCrowdsale: goal not reached")
                super.withdrawTokens(beneficiary);
            }
        }

    * In this contract, the magic word `spuer` is called to inherit all parent contracts on `withdrawTokens` function, conquently the parent contracts of `RefundablePostDeliveryCrowdsale` are `RefundableCrowdsale.sol` & `PostDeliveryCrowdsale.sol` from crowdsale distribution docs. Looking at `RefundableCrowdsale` to inherit its contractor, which is:

            constructor (uint256 goal) public {
                require(goal > 0, "RefundableCrowdsale: goal is 0");
                _escrow = new RefundEscrow(wallet());
                _goal = goal;
            }


### `PupperCoinSale` Constructor will be:

        contract PupperCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale,RefundablePostDeliveryCrowdsale {
            constructor(
                uint rate,
                address payable wallet, 
                PupperCoin token, 
                uint fakenow,
                uint close,
                uint goal
            )
        Crowdsale(rate, wallet, token)
        CappedCrowdsale(goal)
        TimedCrowdsale(now, now + 24 weeks)
        RefundableCrowdsale(goal) public {
            // constructor can stay empty
            }
        }








