// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Insurance{
    address[] public policyholders;
    mapping(address => uint256) public policies;
    mapping(address => uint256) public claims;
    address payable owner;
    uint256 public totalPremium;

    constructor(){
        owner = payable(msg.sender);
    }

    function purchasePolicy(uint256 premium) public payable{
        require(msg.value == premium, "Please pay the premium amount");
        require(premium > 0, "Premium should be greater than 0");
        policyholders.push(msg.sender);
        policies[msg.sender] = premium;
        totalPremium += premium;
    }

    function fileClaim(uint256 amount) public{
        require(policies[msg.sender] > 0, "You don't have any policy");
        require(amount > 0, "Claim amount should be greater than 0");
        require(amount <= policies[msg.sender], "Claim amount should be less than or equal to the policy amount");
        claims[msg.sender] += amount;
    }

    function approveClaim(address policyholder) public{
        require(msg.sender == owner, "Only owner can approve the claim");
        require(claims[policyholder] > 0, "No claim to approve");
        payable(policyholder).transfer(claims[policyholder]);
        claims[policyholder] = 0;
    }

    function getPolicy(address policyholder) public view returns(uint256){
        return policies[policyholder];
    }

    function getClaim(address policyholder) public view returns(uint256){
        return claims[policyholder];
    }

    function getTotalPremium() public view returns(uint256){
        return totalPremium;
    }

    function grantAccess(address payable user) public{
        require(msg.sender == owner, "Only owner can grant access");
        owner = user;
    }

    function revokeAccess(address payable user) public{
        require(msg.sender == owner, "Only owner can revoke access");
        require(user != owner, "Owner cannot revoke access from himself");
        owner = payable(msg.sender);
    }

    function destroy() public{
        require(msg.sender == owner, "Only owner can destroy the contract");
        selfdestruct(owner);
    }
} 

