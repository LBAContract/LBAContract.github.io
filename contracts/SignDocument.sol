// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
import "./TRC21.sol";

contract SignDocument{
    struct Document {
        uint timestamp;
        bytes ipfs_hash;
        address[] signatures;
        bool isExist;
    }

    mapping(bytes32 => Document) public documents; 

    event Add(bytes id, address indexed from, string comment);
    event Sign(bytes id, address indexed from, string comment);
}