// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
import "./TRC21.sol";

contract ManageDocument{
    struct Document {
        uint timestamp;
        bytes ipfs_hash;
        address owner;
        address[] approve;
        address[] reject;
        bool isExist;
    }

    mapping(bytes32 => Document) public documents;

    event Add(bytes id, address indexed from, string comment);
    event Delete(bytes id, address indexed from, string comment);
    event Sign(bytes id, address indexed from, string comment);

    /**
	 * @dev Function to remove who approved this document
	 * @param id The security Hash of documents.
	 */
    function removeApprove(bytes memory id, address checkAddress) public returns(bool){
        bool result = false;
        if(documents[keccak256(id)].isExist){
            for(uint i = 0; i < documents[keccak256(id)].approve.length; i++){
                if(keccak256(abi.encodePacked(documents[keccak256(id)].approve[i])) == keccak256(abi.encodePacked(checkAddress))){
                    delete documents[keccak256(id)].approve[i];
                    result = true;
                }
            }
        } 
        return result;
    }

    /**
	 * @dev Function to remove who rejected this document
	 * @param id The security Hash of documents.
	 */
    function removeReject(bytes memory id, address checkAddress) public returns(bool){
        bool result = false;
        if(documents[keccak256(id)].isExist){
            for(uint i = 0; i < documents[keccak256(id)].reject.length; i++){
                if(keccak256(abi.encodePacked(documents[keccak256(id)].reject[i])) == keccak256(abi.encodePacked(checkAddress))){
                    delete documents[keccak256(id)].reject[i];
                    result = true;
                }
            }
        } 
        return result;
    }
}