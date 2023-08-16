// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LockFund{
  address public owner; 
  constructor(){
      owner = payable(msg.sender);
  }

  mapping(address => uint) public lockedFunds;
  mapping(address => uint) public lockedTimestamps; 
  uint public lockDuration = 2 days;

  function lockFund(uint _value) public payable{
      require(msg.value >= _value);
      lockedFunds[msg.sender] = _value;
      lockedTimestamps[msg.sender] = block.timestamp;
  }

  function releaseFund() public{
      require(block.timestamp >= lockedTimestamps[msg.sender], "Can not withdraw before the lock time");
      payable(owner).transfer(lockedFunds[msg.sender]);
      delete lockedFunds[msg.sender];
      delete lockedTimestamps[msg.sender];
  }

  function withdraw() public{
      require(msg.sender == owner, "Only onwer can withdraw the funds");
      require(address(this).balance > 0, "No funds available to withdraw");
      payable(owner).transfer(address(this).balance);
  }
  function balanceOfcontract() public view returns(uint){
      return address(this).balance;
  }
}
