// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.7.0 <0.8.0;
import "./TRC21.sol";
import "./SignDocument.sol";
import "./CampaignDetail.sol";
import './SafeMath.sol';
import './Ownable.sol';

contract Support is Ownable, MyTRC21Mintable("Adverising2","LBA2", 0, uint256(0) * uint256(10)**18, 1 * uint256(10)**18), SignDocument, CampaignDetail{
    using SafeMath for uint;

    function createCampaign (string memory campaignId, uint totalWithFee, uint totalBudget, uint remainBudget, uint feeCancel) public onlyUser{
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

    function checkOutCampaign(string memory campaignId, uint redudant) public onlyOwner{
        require(campaigns[campaignId].isExist,"Campaign is not Exist");
        require(campaigns[campaignId].isActive,"Campaign is not Active");
        require(campaigns[campaignId].remainBudget > redudant, "Redudant is wrong");

        transfer(campaigns[campaignId].advertiser, redudant);
        campaigns[campaignId].isActive = false;
        campaigns[campaignId].remainBudget = campaigns[campaignId].remainBudget.sub(redudant);
    }

    function payToSupplier(string memory campaignId, address supplier, uint256 value) public onlyOwner returns (bool) {
        require(supplier != address(0));
        require(value <= campaigns[campaignId].remainBudget);

        campaigns[campaignId].remainBudget = campaigns[campaignId].remainBudget.sub(value);
        _transfer(address(this), campaigns[campaignId].advertiser, value);
        return true;
    }

    function cancelCampaign(string memory campaignId) public onlyUser{
        require(campaigns[campaignId].isExist,"Campaign is not Exist");
        require(campaigns[campaignId].isActive,"Campaign is not Active");
        require(campaigns[campaignId].advertiser == msg.sender);

        transfer(campaigns[campaignId].advertiser, 
                            campaigns[campaignId].totalBudget.sub(campaigns[campaignId].feeCancel));

        
        campaigns[campaignId].isActive = false;
        campaigns[campaignId].remainBudget = 0;
    }

    function getCampaignById(string memory campaignId) public view returns (Campaign memory){
        return campaigns[campaignId];
    }
}