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

    function addDocument(bytes memory id) public {
        if(!documents[keccak256(id)].isExist){
            emit Add(id, msg.sender, "Document is Exist");
            revert("Document is Exist");
        } 
        address[] memory sender = new address[](1);
        documents[keccak256(id)] = Document(block.timestamp, abi.encodePacked(block.timestamp, id, msg.sender), sender, true);
        emit Add(id, msg.sender, "Document Added");
    }

    function signDocument(bytes memory id) public {
        require(documents[keccak256(id)].isExist, "Document is not Exist");
        bool checkDulicate = false;
        for(uint i = 0; i < documents[keccak256(id)].signatures.length; i++){
            if(keccak256(abi.encodePacked(documents[keccak256(id)].signatures[i])) == keccak256(abi.encodePacked(msg.sender))){
                checkDulicate = true;
                break;
            }
        }
        if(!checkDulicate){
            documents[keccak256(id)].signatures.push(msg.sender);
            emit Sign(id, msg.sender, "Document Signed");
        }
        emit Sign(id, msg.sender, "Document already Signed");
    }
    
    function getSignatures(bytes memory id) public view returns (address[] memory) {
        return documents[keccak256(id)].signatures;
    }
}