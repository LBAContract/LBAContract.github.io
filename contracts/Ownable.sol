// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

contract Ownable {
    address public owner;
    constructor() {
      owner = msg.sender;
      }

    modifier onlyOwner() {
      require(msg.sender == owner, "This function is only use by Owner");  
      _;
    }

    modifier onlyUser() {  
      require(msg.sender != owner, "This function is only use by user"); 
      _;
    }
} 