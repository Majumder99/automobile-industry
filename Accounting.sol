// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Accounting{
    struct Transaction{
        uint256 amount;
        address sender;
        address receiver;
        uint256 timestamp;
        string description;
    }

    mapping(address => uint256) public balances;
    Transaction[] public transactions;
    address public owner;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event TransactionAdded(address indexed id, uint256 amount, address indexed sender, address indexed receiver, uint256 timestamp, string description);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function deposit() public payable{
        require(msg.value > 0, "You need to send some ether");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public{
        require(amount > 0, "You need to withdraw some ether");
        require(balances[msg.sender] >= amount, "You don't have enough ether");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function addTransaction(address receiver, uint256 amount, string memory description) public{
        require(amount > 0, "You need to send some ether");
        require(balances[msg.sender] >= amount, "You don't have enough ether");
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        transactions.push(Transaction(amount, msg.sender, receiver, block.timestamp, description));
        emit TransactionAdded(msg.sender, amount, msg.sender, receiver, block.timestamp, description);
    }

    function getTransactionsCount() public view returns(uint256){
        return transactions.length;
    }

    function getTRansactionById(uint256 id) public view returns(uint256, address, address, uint256, string memory){
        require(id < transactions.length, "Transaction with this id doesn't exist");
        Transaction memory transaction = transactions[id];
        return (transaction.amount, transaction.sender, transaction.receiver, transaction.timestamp, transaction.description);
    }

}