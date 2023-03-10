pragma solidity ^0.4.24;

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
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
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Erc20 {
    function balanceOf(address _owner) view public returns(uint256);
    function transfer(address _to, uint256 _value) public returns(bool);
    function approve(address _spender, uint256 _value) public returns(bool);
}

contract CErc20 is Erc20 {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
}

contract Exchange {
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) public payable returns (uint256);
}

contract cDaiGateway is Ownable {
    Exchange DaiEx = Exchange(0x2a1530C4C41db0B0b2bB646CB5Eb1A67b7158667);

    Erc20 dai = Erc20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    CErc20 cDai = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);

    constructor() public {
        dai.approve(address(cDai), uint256(-1));
    }

    function () public payable {
        etherTocDai(msg.sender);
    }

    function etherTocDai(address to) public payable returns(uint256 outAmount){
        uint256 amount = DaiEx.ethToTokenSwapInput.value(msg.value * 993 / 1000)(1, now);
        cDai.mint(amount);
        outAmount = cDai.balanceOf(address(this));
        cDai.transfer(to, outAmount);
    }

    function makeprofit() public {
        owner.transfer(address(this).balance);
    }

}