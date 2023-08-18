// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Exchange{
    address public owner; 
    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => bool) public authorizedTokens;
    uint256 public fee = 0.1 ether;

    event Deposit(address indexed token, address indexed user, uint256 amount);
    event Withdraw(address indexed token, address indexed user, uint256 amount);
    event Trade(address indexed token, address indexed buyer, address indexed seller,uint256 price);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function deposit(address token, uint256 amount) public{
        require(authorizedTokens[token], "Token not authorized");
        require(amount > 0, "Amount must be greater than 0");
        balances[token][msg.sender] += amount;
        emit Deposit(token, msg.sender, amount);
    }

    function withdraw(address token, uint256 amount) public{
        require(balances[token][msg.sender] >= amount, "Balance not sufficient");
        balances[token][msg.sender] -= amount;
        emit Withdraw(token, msg.sender, amount);
    }

    function authorizeToken(address token) public onlyOwner{
        authorizedTokens[token] = true;
    }

    function unauthorizeToken(address token) public onlyOwner{
        authorizedTokens[token] = false;
    }

    function setFee(uint256 _fee) public onlyOwner{
        fee = _fee;
    }

    function trade(address token, address seller, uint256 amount, uint256 price) public payable{
        require(msg.value == fee, "Insufficient fee");
        require(balances[token][seller] >= amount, "Insufficient balance");
        require(balances[address(this)][msg.sender] >= amount * price, "Insufficient contract balance");

        balances[token][seller] -= amount;
        balances[token][msg.sender] += amount;
        balances[address(this)][msg.sender] -= amount * price;
        balances[address(this)][seller] += amount * price;

        emit Trade(token, msg.sender, seller, price);
    }


}