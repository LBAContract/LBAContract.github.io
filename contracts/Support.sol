// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.7.0 <0.8.0;
import "./TRC21.sol";
import "./ManageDocument.sol";
import './SafeMath.sol';
import './Ownable.sol';
import './CampaignDetail.sol';

contract Support is MyTRC21Mintable("Adverising","LBAT", 0, uint256(0) * uint256(10)**18, uint256(0) * uint256(10)**18), ManageDocument, CampaignDetail, AccessControl{
    using SafeMath for uint;

    /* BEGIN: Document function*/
    /**
	 * @dev Function to add Document to verify
	 * @param id The security Hash of documents.
	 */
    function addDocument(bytes memory id) public {
        if(documents[keccak256(id)].isExist){
            emit Add(id, msg.sender, "Document is Exist");
            revert("Document is Exist");
        } 
        address[] memory approve = new address[](0);
        address[] memory reject = new address[](0);
        documents[keccak256(id)] = Document(block.timestamp, abi.encodePacked(block.timestamp, id, msg.sender), msg.sender, approve, reject, true);
        emit Add(id, msg.sender, "Document Added");
    }

    /**
	 * @dev Function to delete Document
	 * @param id The security Hash of documents.
	 */
    function deleteDocument(bytes memory id) public {
        if(documents[keccak256(id)].isExist){
            if(keccak256(abi.encodePacked(documents[keccak256(id)].owner)) == keccak256(abi.encodePacked(msg.sender)) || isRole(msg.sender, "Admin")){
                address[] memory approve = new address[](0);
                address[] memory reject = new address[](0);
                documents[keccak256(id)].approve = approve;
                documents[keccak256(id)].reject = reject;
                documents[keccak256(id)].isExist = false;
            }
        } 
    }

    /**
	 * @dev Function to approve to Document to verify.
	 * @param id The security Hash of documents.
	 */
    function approveDocument(bytes memory id) public {
        require(!isRole(msg.sender,"Minter") && !isOwner(msg.sender) && !isRole(msg.sender, "Server"));
        require(isRole(msg.sender,"Admin"));
        if(!documents[keccak256(id)].isExist){
            emit Sign(id, msg.sender, "Document is not Exist"); 
            revert("Document is not Exist");
        }
        removeReject(id, msg.sender);
        documents[keccak256(id)].approve.push(msg.sender);
        emit Sign(id, msg.sender, "Document Approved");
    }

    /**
	 * @dev Function to reject to Document to verify.
	 * @param id The security Hash of documents.
	 */
    function rejectDocument(bytes memory id) public {
        require(!isRole(msg.sender,"Minter") && !isOwner(msg.sender) && !isRole(msg.sender, "Server"));
        require(isRole(msg.sender,"Admin"));
        if(!documents[keccak256(id)].isExist){
            emit Sign(id, msg.sender, "Document is not Exist");
            revert("Document is not Exist");
        }
        removeApprove(id, msg.sender);
        documents[keccak256(id)].reject.push(msg.sender);
        emit Sign(id, msg.sender, "Document Rejected");
    }

    /**
	 * @dev Function to get all signature of document by Security hash of document
	 * @param id The security Hash of documents.
	 * @return Array of address of signed
	 */
    function getOwnerDocument(bytes memory id) public view returns (address) {
        return documents[keccak256(id)].owner;
    }

     /**
	 * @dev Function to get all signature of document by Security hash of document
	 * @param id The security Hash of documents.
	 * @return Array of address of signed
	 */
    function getRejectDocument(bytes memory id) public view returns (address[] memory) {
        return documents[keccak256(id)].approve;
    }

    /**
	 * @dev Function to get all signature of document by Security hash of document
	 * @param id The security Hash of documents.
	 * @return Array of address of signed
	 */
    function getApproveDocument(bytes memory id) public view returns (address[] memory) {
        return documents[keccak256(id)].reject;
    }
    /*END: Document function*/

    /*BEGIN: Campaign Detail */
    
    /**
	 * @dev Function to Create Campaign
	 * @param campaignId The string Identifier of Campaign.
	 * @param totalWithFee This is all money of campaign include all fee.
	 * @param totalBudget This is Budget of campaign.
	 * @param remainBudget This is money after minus fee
	 * @param feeCancel This is fee to cancel campaign.
	 */
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

    /**
	 * @dev Function to CheckOut Campaign
	 * @param campaignId The string Identifier of Campaign.
	 * @param redudant The address of suppiler to transfer money.
	 */
    function checkOutCampaign(string memory campaignId, uint redudant) public onlyServer{
        require(campaigns[campaignId].isExist,"Campaign is not Exist");
        require(campaigns[campaignId].isActive,"Campaign is not Active");
        require(campaigns[campaignId].remainBudget > redudant, "Redudant is wrong");

        transfer(campaigns[campaignId].advertiser, redudant);
        campaigns[campaignId].isActive = false;
        campaigns[campaignId].remainBudget = campaigns[campaignId].remainBudget.sub(redudant);
    }

    /**
	 * @dev Function to Pay To Supplier
	 * @param campaignId The string Identifier of Campaign
	 * @param supplier The address of suppiler to transfer money
	 * @param value The value of money to transfer to supplier
	 * @return A boolean that indicates if the operation was successful.
	 */
    function payToSupplier(string memory campaignId, string memory paymentKey, address supplier, uint256 value) public onlyServer returns (bool) {
        require(supplier != address(0));
        require(value <= campaigns[campaignId].remainBudget);
        require(!checkPayed[campaignId][paymentKey]);
        campaigns[campaignId].remainBudget = campaigns[campaignId].remainBudget.sub(value);
        _transfer(address(this), campaigns[campaignId].advertiser, value);
        checkPayed[campaignId][paymentKey] = true;
        return true;
    }

    /**
	 * @dev Function to Cancel Campaign
	 * @param campaignId The string Identifier of Campaign
	 */
    function cancelCampaign(string memory campaignId) public{
        require(campaigns[campaignId].isExist,"Campaign is not Exist");
        require(campaigns[campaignId].isActive,"Campaign is not Active");
        require(campaigns[campaignId].advertiser == msg.sender || isRole(msg.sender, "Admin"));
        
        if(isRole(msg.sender, "Admin")){
            transfer(campaigns[campaignId].advertiser, campaigns[campaignId].remainBudget);
        }else{
            uint temp = campaigns[campaignId].remainBudget.sub(campaigns[campaignId].feeCancel);
            if(temp > 0){
                transfer(campaigns[campaignId].advertiser,  temp);
            }
        }
        
        campaigns[campaignId].isActive = false;
        campaigns[campaignId].remainBudget = 0;
    }

    /**
	 * @dev Function to Get Campaign By Id
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