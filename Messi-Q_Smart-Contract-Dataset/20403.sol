pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract StandardToken is ERC20, BasicToken {
  using SafeMath for uint256;
  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
   @title ERC827 interface, an extension of ERC20 token standard
   Interface of a ERC827 token, following the ERC20 standard with extra
   methods to transfer value and data and execute calls in transfers and
   approvals.
 */
contract ERC827 is ERC20 {

  function approve( address _spender, uint256 _value, bytes _data ) public returns (bool);
  function transfer( address _to, uint256 _value, bytes _data ) public returns (bool);
  function transferFrom( address _from, address _to, uint256 _value, bytes _data ) public returns (bool);

}

/**
   @title ERC827, an extension of ERC20 token standard
   Implementation the ERC827, following the ERC20 standard with extra
   methods to transfer value and data and execute calls in transfers and
   approvals.
   Uses OpenZeppelin StandardToken.
 */
contract ERC827Token is ERC827, StandardToken {

  /**
     @dev Addition to ERC20 token methods. It allows to
     approve the transfer of value and execute a call with the sent data.
     Beware that changing an allowance with this method brings the risk that
     someone may use both the old and the new allowance by unfortunate
     transaction ordering. One possible solution to mitigate this race condition
     is to first reduce the spender's allowance to 0 and set the desired value
     afterwards:
     https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     @param _spender The address that will spend the funds.
     @param _value The amount of tokens to be spent.
     @param _data ABI-encoded contract call to call `_to` address.
     @return true if the call function was executed successfully
   */
  function approve(address _spender, uint256 _value, bytes _data) public returns (bool) {
    require(_spender != address(this));

    super.approve(_spender, _value);

    require(_spender.call(_data));

    return true;
  }

  /**
     @dev Addition to ERC20 token methods. Transfer tokens to a specified
     address and execute a call with the sent data on the same transaction
     @param _to address The address which you want to transfer to
     @param _value uint256 the amout of tokens to be transfered
     @param _data ABI-encoded contract call to call `_to` address.
     @return true if the call function was executed successfully
   */
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));

    super.transfer(_to, _value);

    require(_to.call(_data));
    return true;
  }

  /**
     @dev Addition to ERC20 token methods. Transfer tokens from one address to
     another and make a contract call on the same transaction
     @param _from The address which you want to send tokens from
     @param _to The address which you want to transfer to
     @param _value The amout of tokens to be transferred
     @param _data ABI-encoded contract call to call `_to` address.
     @return true if the call function was executed successfully
   */
  function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));

    super.transferFrom(_from, _to, _value);

    require(_to.call(_data));
    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Increase the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function increaseApproval(address _spender, uint _addedValue, bytes _data) public returns (bool) {
    require(_spender != address(this));

    super.increaseApproval(_spender, _addedValue);

    require(_spender.call(_data));

    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Decrease the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function decreaseApproval(address _spender, uint _subtractedValue, bytes _data) public returns (bool) {
    require(_spender != address(this));

    super.decreaseApproval(_spender, _subtractedValue);

    require(_spender.call(_data));

    return true;
  }

}


/**
 * @title Pausable token
 * @dev ERC827Token modified with pausable transfers.
 **/
contract PausableToken is ERC827Token, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
  
  function approve( address _spender, uint256 _value, bytes _data ) public whenNotPaused returns (bool){
      return super.approve(_spender, _value, _data);
  }
  
  function transfer( address _to, uint256 _value, bytes _data ) public whenNotPaused returns (bool){
      return super.transfer(_to, _value, _data);
  }
  function transferFrom( address _from, address _to, uint256 _value, bytes _data ) public whenNotPaused returns (bool){
      return super.transferFrom(_from, _to, _value, _data);
  }
}


contract PlanEX is PausableToken {
    string public constant name = "PlanEX Token";
    string public constant symbol = "XPX";
    uint8 public constant decimals = 18;
    
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));
    
    address public tokenWallet;
    
    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    function PlanEX() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
        tokenWallet = msg.sender;
    }
    
    function sendTokens(address _to, uint _value) public onlyOwner {
        require(_to != address(0));
        require(_value <= balances[tokenWallet]);
        balances[tokenWallet] = balances[tokenWallet].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(tokenWallet, _to, _value);
    }
    
}