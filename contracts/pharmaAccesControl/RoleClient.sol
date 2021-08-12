// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'ConsumerRole' to manage this role - add, remove, check
contract RoleClient {
  using Roles for Roles.Role;
  // Define 2 events, one for Adding, and other for Removing
  event ClientAdded(address indexed account);
  event ClientRemoved(address indexed account);

  // Define a struct 'clients' by inheriting from 'Roles' library, struct Role
  Roles.Role private clients;
  // In the constructor make the address that deploys this contract the 1st client
  constructor() public {
    //_addConstructor(msg.sender);
    _addClient(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyClient() {
    require(isClient(msg.sender));
    _;
  }

  // Define a function 'isClient' to check this role
  function isClient(address account) public view returns (bool) {
    return clients.has(account);
  }

  // Define a function 'addClient' that adds this role
  function addClient(address account) public onlyClient {
    _addClient(account);
  }

  // Define a function 'renounceClient' to renounce this role
  function renounceClient(address account) public {
    _removeClient(account);
  }

  // Define an internal function '_addConsumer' to add this role, called by 'addConsumer'
  function _addClient(address account) internal {
    clients.add(account);
    emit ClientAdded(account);
  }

  // Define an internal function '_removeClient' to remove this role, called by 'removeConsumer'
  function _removeClient(address account) internal {
    clients.remove(account);
    emit ClientRemoved(account);
  }
}