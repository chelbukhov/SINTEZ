pragma solidity ^0.4.23;


contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}



contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }


  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }


  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }


  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }


  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract CRYPTToken is StandardToken {
  string public constant name = "CRYPT Token";
  string public constant symbol = "CRTT";
  uint32 public constant decimals = 18;
  uint256 public INITIAL_SUPPLY = 1000000000 * 1 ether;
  address public CrowdsaleAddress;
  bool public lockTransfers = false;

  constructor(address _CrowdsaleAddress) public {
    
    CrowdsaleAddress = _CrowdsaleAddress;
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;      
  }
  
    modifier onlyOwner() {
        // only Crowdsale contract
    require(msg.sender == CrowdsaleAddress);
    _;
  }

     // Override
     function transfer(address _to, uint256 _value) public returns(bool){
        if (msg.sender != CrowdsaleAddress){
            require(!lockTransfers, 'Transfers are prohibited in ICO and Crowdsale period');
        }
        return super.transfer(_to,_value);
     }

     // Override
     function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
        if (msg.sender != CrowdsaleAddress){
            require(!lockTransfers, 'Transfers are prohibited in ICO and Crowdsale period');
        }
        return super.transferFrom(_from,_to,_value);
     }
     
    function acceptTokens(address _from, uint256 _value) public onlyOwner returns (bool){
        require (balances[_from]>= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[CrowdsaleAddress] = balances[CrowdsaleAddress].add(_value);
        emit Transfer(_from, CrowdsaleAddress, _value);
        return true;
    }

    function lockTransfer(bool _lock) public onlyOwner {
        lockTransfers = _lock;
    }



  function() external payable {
      // The token contract don`t receive ether
        revert();
  }  
}


 contract Ownable {
  address public owner;
  address candidate;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    candidate = newOwner;
  }

  function confirmOwnership() public {
    require(candidate == msg.sender);
    owner = candidate;
    delete candidate;
  }

}

contract HoldProgectAddress {
    //Address where stored command tokens- 50%
    //Withdraw tokens allowed only after 1 year
    function() external payable {
        // The contract don`t receive ether
        revert();
    } 
}

contract HoldBountyAddress {
    //Address where stored bounty tokens- 1%
    //Withdraw tokens allowed only after 40 days
    function() external payable {
        // The contract don`t receive ether
        revert();
    } 
}

contract HoldAdvisorsAddress {
    //Address where stored advisors tokens- 1%
    //Withdraw tokens allowed only after 40 days
    function() external payable {
        // The contract don`t receive ether
        revert();
    } 
}

contract HoldAdditionalAddress {
    //Address where stored additional tokens- 8%
    function() external payable {
        // The contract don`t receive ether
        revert();
    } 
}

contract Crowdsale is Ownable {
    using SafeMath for uint; 
    event LogStateSwitch(State newState);
    event Withdraw(address indexed from, address indexed to, uint256 amount);
    event Refunding(address indexed to, uint256 amount);
    mapping(address => uint) public crowdsaleBalances;

    address myAddress = this;
    uint64 preSaleStartTime = 0;
    uint64 preICOStartTime = 0;
    uint64 crowdSaleStartTime = 0;
    uint public  saleRate = 5000;  //tokens for 1 ether
    uint256 public soldTokens = 0;

    // 50 000 000 sold tokens limit for Pre-Sale
    uint public constant RPESALE_TOKEN_SUPPLY_LIMIT = 50000000 * 1 ether;
    // 100 000 000 sold tokens limit for Pre-ICO
    uint public constant RPEICO_TOKEN_SUPPLY_LIMIT = 100000000 * 1 ether;

    // 40 000 000 tokens soft cap (otherwise - refund)
    uint public constant TOKEN_SOFT_CAP = 40000000 * 1 ether;

    
    
    CRYPTToken public token = new CRYPTToken(myAddress);
    
    // New address for hold tokens
    HoldProgectAddress public holdAddress1 = new HoldProgectAddress();
    HoldBountyAddress public holdAddress2 = new HoldBountyAddress();
    HoldAdvisorsAddress public holdAddress3 = new HoldAdvisorsAddress();
    HoldAdditionalAddress public holdAddress4 = new HoldAdditionalAddress();

    // Create state of contract
    enum State { 
        Init,    
        PreSale, 
        PreICO,  
        CrowdSale,
        Refunding,
        WorkTime}
        
    State public currentState = State.Init;

    modifier onlyInState(State state){ 
        require(state==currentState); 
        _; 
    }

    constructor() public {
        uint256 TotalTokens = token.INITIAL_SUPPLY().div(1 ether);
        // distribute tokens
        // Transer tokens to project address.  (50%)
        giveTokensWithoutBonus(address(holdAddress1), TotalTokens.div(2));
        // Transer tokens to bounty address.  (1%)
        giveTokensWithoutBonus(address(holdAddress2), TotalTokens.div(100));
        // Transer tokens to advisors address. (1%)
        giveTokensWithoutBonus(address(holdAddress3), TotalTokens.div(100));
        // Transer tokens to additional address. (8%)
        giveTokensWithoutBonus(address(holdAddress4), TotalTokens.div(100).mul(8));


    }

    function returnTokensFromHoldProgectAddress(uint256 _value) public onlyOwner {
        // the function take tokens from HoldProgectAddress to contract
        // only after 1 year
        // the sum is entered in whole tokens (1 = 1 token)
        require (currentState != State.Init, 'Init stage');
        require (_value >= 1);
        _value = _value.mul(1 ether);
        
        require (now >= preSaleStartTime + 365 days, 'only after 1 year');
        token.acceptTokens(address(holdAddress1), _value);    
    } 

    function returnTokensFromHoldBountyAddress(uint256 _value) public onlyOwner {
        // the function take tokens from HoldBountyAddress to contract
        // only after 40 days
        // the sum is entered in whole tokens (1 = 1 token)
        require (currentState != State.Init, 'Init stage');
        require (_value >= 1);
        _value = _value.mul(1 ether);
        require (now >= preSaleStartTime + 40 days, 'only after 40 days');
        token.acceptTokens(address(holdAddress2), _value);    
    } 
    
    function returnTokensFromHoldAdvisorsAddress(uint256 _value) public onlyOwner {
        // the function take tokens from HoldAdvisorsAddress to contract
        // only after 40 days
        // the sum is entered in whole tokens (1 = 1 token)
        require (currentState != State.Init, 'Init stage');
        require (_value >= 1);
        _value = _value.mul(1 ether);
        require (now >= preSaleStartTime + 40 days, 'only after 40 days');
        token.acceptTokens(address(holdAddress3), _value);    
    } 
    
    function returnTokensFromHoldAdditionalAddress(uint256 _value) public onlyOwner {
        // the function take tokens from HoldAdditionalAddress to contract
        // the sum is entered in whole tokens (1 = 1 token)
        require (currentState != State.Init, 'Init stage');
        require (_value >= 1);
        _value = _value.mul(1 ether);
        token.acceptTokens(address(holdAddress4), _value);    
    }     
    
    function setState(State _state) internal {
        currentState = _state;
        emit LogStateSwitch(_state);
    }

    function startPreSale() public onlyOwner onlyInState(State.Init) {
        setState(State.PreSale);
        preSaleStartTime = uint64(now);
        token.lockTransfer(true);
    }

    function startPreICO() public onlyOwner onlyInState(State.PreSale) {
        // PreSale minimum 10 days
        require (now >= preSaleStartTime + 10 days, 'Mimimum period Pre-Sale is 10 days');
        setState(State.PreICO);
        preICOStartTime = uint64(now);
    }
     
    function startCrowdSale() public onlyOwner onlyInState(State.PreICO) {
        // Pre-ICO minimum 15 days
        require (now >= preICOStartTime + 15 days, 'Mimimum period Pre-ICO is 15 days');
        setState(State.CrowdSale);
        crowdSaleStartTime = uint64(now);
    }
    
    function finishCrowdSale() public onlyOwner onlyInState(State.CrowdSale) {
        // CrowdSale minimum 30 days - function does not have reverse!!!

        require (now >= crowdSaleStartTime + 30 days, 'Mimimum period CrowdSale is 30 days');
        // проверка на достижение софткапа, т.е. распроданы все токены или нет
        if (soldTokens < TOKEN_SOFT_CAP) {
            // softcap don't accessable - refunding
            setState(State.Refunding);
        } else {
            // All right! CrowdSale is passed. WithdrawProfit is accessable
            setState(State.WorkTime);
            token.lockTransfer(false);
        }
    }


    function calcBonus () public view returns(uint256) {
        // расчет бонуса
        uint256 actualBonus = 0;
        if (currentState == State.PreSale){
            actualBonus = 20;
        }
        if (currentState == State.PreICO){
            actualBonus = 10;
        }
        return actualBonus;
    }

    function giveTokensWithBonus(address _newInvestor, uint256 _value) public onlyOwner {
        // the function give tokens to new investors with calculated bonuses
        // the sum is entered in whole tokens (1 = 1 token)
        // Add Bonus
        _value = _value.add(_value.mul(calcBonus()).div(100));            
        giveTokensWithoutBonus(_newInvestor, _value);
    }  

    function giveTokensWithoutBonus(address _newInvestor, uint256 _value) public onlyOwner {
        // the function give tokens to new investors without bonuses
        // the sum is entered in whole tokens (1 = 1 token)
        require (_newInvestor!= address(0));
        require (_value >= 1);
        _value = _value.mul(1 ether);
        token.transfer(_newInvestor, _value);
    }  
    
    function saleTokens() internal {
        require(currentState != State.Init, 'Contract is init, do not accept ether.'); 
        require(currentState != State.Refunding, 'Contract is refunding, do not accept ether.'); // in Refunding stage contract don't sale tokens
        
        if (currentState == State.PreSale) {
            require (RPESALE_TOKEN_SUPPLY_LIMIT > soldTokens, 'HardCap of Pre-Sale is passed.'); 
            require (msg.value >= 20 ether, 'Minimum 20 ether for transaction all Pre-Sale period');  //minimum 20 ether for all Pre-Sale period
        }
        if (currentState == State.PreICO) {
            require (RPEICO_TOKEN_SUPPLY_LIMIT > soldTokens, 'HardCap of Pre-ICO is passed.'); //limit not yet aceessable
            if (now < preICOStartTime + 1 days){
                require (msg.value <= 20 ether, 'Maximum is 20 ether for transaction in first day of Pre-ICO');  //maximum 20 ether first day of Pre-ICO
            }
        }
        crowdsaleBalances[msg.sender] = crowdsaleBalances[msg.sender].add(msg.value);
        uint tokens = saleRate.mul(msg.value);
        tokens = tokens.add(tokens.mul(calcBonus()).div(100));
        token.transfer(msg.sender, tokens);
        soldTokens = soldTokens.add(tokens);
    }
 
    function refund() public payable{
        require(currentState == State.Refunding, 'Only for Refunding stage.');
        // refund ether to investors
        uint value = crowdsaleBalances[msg.sender]; 
        crowdsaleBalances[msg.sender] = 0; 
        msg.sender.transfer(value);
        emit Refunding(msg.sender, value);
    }
    
    function withdrawProfit (address _to, uint256 _value) public onlyOwner payable {
    // withdrawProfit - only if coftcap passed
        require (currentState == State.WorkTime, 'Contract is not at WorkTime stage. Access denied.');
        require (myAddress.balance >= _value);
        require(_to != address(0));
        _to.transfer(_value);
        emit Withdraw(msg.sender, _to, _value);
    }


    function() external payable {
        saleTokens();
    }    
 
}