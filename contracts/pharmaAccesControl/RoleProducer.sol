// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'producerRole' to manage this role - add, remove, check
contract RoleProducer {
  using Roles for Roles.Role;
  // Define 2 events, one for Adding, and other for Removing
  event producerAdded(address indexed account);
  event producerRemoved(address indexed account);

  // Define a struct 'producers' by inheriting from 'Roles' library, struct Role
  Roles.Role private producers;
  // In the constructor make the address that deploys this contract the 1st producer
  constructor() public {
    //_addConstructor(msg.sender);
    _addProducer(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyProducer() {
    require(isProducer(msg.sender));
    _;
  }

  // Define a function 'isProducer' to check this role
  function isProducer(address account) public view returns (bool) {
    return producers.has(account);
  }

  // Define a function 'addproducer' that adds this role
  function addProducer(address account) public onlyProducer {
    _addProducer(account);
  }

  // Define a function 'renounceProducer' to renounce this role
  function renounceProducer(address account) public {
    _removeProducer(account);
  }

  // Define an internal function '_addproducer' to add this role, called by 'addProducer'
  function _addProducer(address account) internal {
    producers.add(account);
    emit producerAdded(account);
  }

  // Define an internal function '_removeproducer' to remove this role, called by 'removeProducer'
  function _removeProducer(address account) internal {
    producers.remove(account);
    emit producerRemoved(account);
  }
}