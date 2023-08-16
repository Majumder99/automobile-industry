// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OilAndGas{
  address public owner;
  struct OilWell{
      string name;
      address operator;
      uint256 production;
  }

//In the OilWellCreated event, the _wellName and _operator variables are both indexed. This means that when this event is emitted, the values of these variables will be stored in the event's log and can be used to filter events by well name or operator address.

//In the ProductionChanged event, only the _wellName variable is indexed. This means that when this event is emitted, the value of this variable will be stored in the event's log and can be used to filter events by well name.

  mapping(string => OilWell) public wells;
  event OilWellCreated(string indexed _wellName, address indexed _operator);
  event ProductionChanged(string indexed _wellName, uint256 indexed _production);

  constructor(){
      owner = msg.sender;
  }

  modifier owernCheck {
      require(msg.sender == owner, "Sender must be the owner of the contract");
      _;
  }

  function createOilWell(string memory _wellName) public{
      wells[_wellName] = OilWell(_wellName, msg.sender, 0);
      emit OilWellCreated(_wellName, msg.sender);
  }

  function changeOperator(string memory _wellName, address _newOperator) public owernCheck{
      wells[_wellName].operator = _newOperator;
  }

  function updateProduction(string memory _wellName, uint256 _production) public{
      require(msg.sender == wells[_wellName].operator, "Sender must be the operator of the well");
      wells[_wellName].production = _production;
      emit ProductionChanged(_wellName, _production);
  }

  function checkWell(string memory _wellName) public view returns(string memory, address, uint256){
      OilWell memory wellId = wells[_wellName];
      return (wellId.name, wellId.operator, wellId.production);
  }
}
