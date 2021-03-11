// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.7.0 <0.8.0;
import "./TRC21.sol";
import "./SignDocument.sol";
import './SafeMath.sol';
import './Ownable.sol';
import './CampaignDetail.sol';

contract Support is MyTRC21Mintable("Adverising2","LBA2", 0, uint256(0) * uint256(10)**18, uint256(0) * uint256(10)**18), SignDocument, CampaignDetail, AccessControl{
    using SafeMath for uint;

    /* BEGIN: Document function*/
    function addDocument(bytes memory id) public {
        if(documents[keccak256(id)].isExist){
            emit Add(id, msg.sender, "Document is Exist");
            revert("Document is Exist");
        } 
        address[] memory sender = new address[](0);
        documents[keccak256(id)] = Document(block.timestamp, abi.encodePacked(block.timestamp, id, msg.sender), sender, true);
        emit Add(id, msg.sender, "Document Added");
    }

    function signDocument(bytes memory id) public {
        if(!documents[keccak256(id)].isExist){
            emit Sign(id, msg.sender, "Document is not Exist"); 
            revert("Document is not Exist");
        }
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

    function checkAdminSigned(bytes memory id) public view returns (bool) {
        for(uint i = 0; i < documents[keccak256(id)].signatures.length; i++){
            if(isRole(documents[keccak256(id)].signatures[i], "Admin")){
                return true;
            }
        }
        return false;
    }
    /*END: Document function*/

    /*BEGIN: Campaign Detail */
    function createCampaign (string memory campaignId, uint totalWithFee, uint totalBudget, uint remainBudget, uint feeCancel) public{
        //check money amount
        require(totalWithFee <= _allowed[msg.sender][address(this)],"Not Enough Money");
        //check campaign
        if(!campaigns[campaignId].isExist){
            //send money to server wallet
            _transfer(msg.sender, address(this), totalWithFee);
            _allowed[msg.sender][address(this)].sub(totalWithFee);
            //create campaign
            campaigns[campaignId] = Campaign(campaignId, msg.sender, totalBudget, remainBudget, feeCancel, true, true);
        }
        emit CreateCampaign(msg.sender, campaignId, totalBudget);
    }

    function checkOutCampaign(string memory campaignId, uint redudant) public onlyAdmin{
        require(campaigns[campaignId].isExist,"Campaign is not Exist");
        require(campaigns[campaignId].isActive,"Campaign is not Active");
        require(campaigns[campaignId].remainBudget > redudant, "Redudant is wrong");

        transfer(campaigns[campaignId].advertiser, redudant);
        campaigns[campaignId].isActive = false;
        campaigns[campaignId].remainBudget = campaigns[campaignId].remainBudget.sub(redudant);
    }

    /**
	 * @dev Function to change OwnerOfContract
	 * @param campaignId The string Identifier of Campaign
	 * @param supplier The address of suppiler to transfer money
	 * @param value The value of money to transfer to supplier
	 * @return A boolean that indicates if the operation was successful.
	 */
    function payToSupplier(string memory campaignId, address supplier, uint256 value) public onlyAdmin returns (bool) {
        require(supplier != address(0));
        require(value <= campaigns[campaignId].remainBudget);

        campaigns[campaignId].remainBudget = campaigns[campaignId].remainBudget.sub(value);
        _transfer(address(this), campaigns[campaignId].advertiser, value);
        return true;
    }

    /**
	 * @dev Function to change OwnerOfContract
	 * @param campaignId The string Identifier of Campaign
	 */
    function cancelCampaign(string memory campaignId) public onlyUser{
        require(campaigns[campaignId].isExist,"Campaign is not Exist");
        require(campaigns[campaignId].isActive,"Campaign is not Active");
        require(campaigns[campaignId].advertiser == msg.sender);

        transfer(campaigns[campaignId].advertiser, 
                            campaigns[campaignId].totalBudget.sub(campaigns[campaignId].feeCancel));

        
        campaigns[campaignId].isActive = false;
        campaigns[campaignId].remainBudget = 0;
    }

    /**
	 * @dev Function to change OwnerOfContract
	 * @param campaignId The string Identifier of Campaign
	 * @return A Campaign will return if there are campaignId 
	 */
    function getCampaignById(string memory campaignId) public view returns (Campaign memory){
        return campaigns[campaignId];
    }
    /*END: Campaign Detail */

    /*START: MyTRC21Mintable */

    /**
	 * @dev Function to change OwnerOfContract
	 * @param newOwner The address that will be new Owner.
	 */
    function changeOwner(address newOwner) public onlyOwner{
        _changeIssuer(newOwner);
        _changeOwnerRole(newOwner);
    }
    /**
	 * @dev Function to mint tokens
	 * @param to The address that will receive the minted tokens.
	 * @param value The amount of tokens to mint.
	 * @return A boolean that indicates if the operation was successful.
	 */
	function mint(
		address to,
		uint256 value
	)
	public
	onlyMinter
	returns (bool)
	{
		_mint(to, value);
		return true;
	}
    /*END: MyTRC21Mintable */
}