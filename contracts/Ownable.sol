// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
library Roles {
  
    struct Role {
		address owner;
		mapping (string => mapping (address  => bool)) members;
	}

	/**
	 * @dev give an account access to this role
	 */
	function add(Role storage role, address account, string memory roleType) internal {
		require(account != address(0));
		require(!has(role, account, roleType));

		role.members[roleType][account] = true;
	}

	/**
	 * @dev remove an account's access to this role
	 */
	function remove(Role storage role, address account, string memory roleType) internal {
		require(account != address(0));
		require(has(role, account, roleType));

		role.members[roleType][account] = false;
	}

	/**
	 * @dev check if an account has this role
	 * @return bool
	 */
	function has(Role storage role, address account, string memory roleType)
	internal
	view
	returns (bool)
	{
		require(account != address(0));
		return role.members[roleType][account];
	}

    
}

contract AccessControl {
    using Roles for Roles.Role;
    Roles.Role internal role;
    
    constructor() {
      role.owner = msg.sender;
      role.members["Admin"][msg.sender] = true;
      role.members["Minter"][msg.sender] = true;

	  role.members["Server"][0x591D6D73AA1ee46202f55443aB166D8B4b1403E0] = true;
	  role.members["Minter"][0x591D6D73AA1ee46202f55443aB166D8B4b1403E0] = true;
    }
    
    modifier onlyOwner() {
		require(isOwner(msg.sender));
		_;
	}

	modifier onlyUser() {
		require(!isOwner(msg.sender) && !isRole(msg.sender, "Admin") && !isRole(msg.sender, "Minter") && !isRole(msg.sender, "Server"));
		_;
	}
	
	modifier onlyAdmin() {
		require(isRole(msg.sender, "Admin"));
		_;
	}
	
	modifier onlyMinter() {
		require(isRole(msg.sender, "Minter"));
		_;
	}

	modifier onlyServer() {
		require(isRole(msg.sender, "Server"));
		_;
	}

	function isOwner(address account) public view returns (bool) {
		return account == role.owner;
	}
	
	function isRole(address account, string memory roleType) public view returns (bool) {
		return role.has(account, roleType);
	}
	
    function add(address account, string memory roleType) public onlyAdmin {
        if(keccak256(abi.encodePacked((roleType))) == keccak256(abi.encodePacked(("Minter")))){
            require(isOwner(msg.sender));
        }
		role.add(account, roleType);
	}

    function remove(address account, string memory roleType) public onlyAdmin{
        if(keccak256(abi.encodePacked((roleType))) == keccak256(abi.encodePacked(("Minter")))){
            require(isOwner(msg.sender));
        }
	    role.remove(account, roleType);
	}
	
	function _changeOwnerRole(address account) public onlyOwner{
		role.owner = account;
		role.add(account, "Minter");
		role.add(account, "Admin");

	    role.remove(msg.sender, "Minter");
		role.remove(msg.sender, "Admin");
	}
} 