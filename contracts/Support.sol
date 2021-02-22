// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
import "./TRC21.sol";
import "./SignDocument.sol";
import "./CampaignMoney.sol";
import './SafeMath.sol';
import './Ownable.sol';


contract Support is Ownable, MyTRC21Mintable("Adverising2","LBA2", 0, uint256(0) * uint256(10)**18, 1 * uint256(10)**18), SignDocument, CampaignMoney{
    using SafeMath for uint256;

    function authorityCampaign (string memory campaingId, uint value) public onlyUser{
        if(!_allowedCampaign[msg.sender][campaingId].isExist){
            uint256 allowed = allowance(msg.sender, address(this));
            require(value <= allowed,"Not Enough Money");
            _transfer(msg.sender, address(this), value);
            _allowedCampaign[msg.sender][campaingId] = Campaign(campaingId, value, block.timestamp, true, true);
            emit AuthorityCampaign(msg.sender, campaingId, value);
        }
    }

    function payForAdvertising(address from, address to, string memory campaignId, uint256 total, uint timesFee) public onlyOwner returns (bool) {
        uint256 payToSuplier = total.sub(getFeePublisherCampaign() * timesFee);
        require(to != address(0));
        require(total <= _allowedCampaign[from][campaignId].money);

        _allowedCampaign[from][campaignId].money = _allowedCampaign[from][campaignId].money.sub(total);
        _transfer(address(this), to, payToSuplier);
        return true;
    }

    function checkOutCampaign(string memory campaignId, address ownerOfCampaign, uint timesFee) public onlyOwner{
        require(_allowedCampaign[ownerOfCampaign][campaignId].isExist,"Campaign is not Exist");
        require(_allowedCampaign[ownerOfCampaign][campaignId].isActive,"Campaign is not Active");
        if(_allowedCampaign[ownerOfCampaign][campaignId].money > getFeeAdvertiserCampaign() * timesFee){
            transfer(ownerOfCampaign, _allowedCampaign[ownerOfCampaign][campaignId].money.sub(getFeeAdvertiserCampaign()*timesFee));
        }
        _allowedCampaign[ownerOfCampaign][campaignId].isActive = false;
        _allowedCampaign[ownerOfCampaign][campaignId].money = 0;
    }

    function cancelCampaign(string memory campaignId, address ownerOfCampaign, uint redundant, uint timesCancelFee) public onlyOwner{
        require(_allowedCampaign[ownerOfCampaign][campaignId].isExist,"Campaign is not Exist");
        require(_allowedCampaign[ownerOfCampaign][campaignId].isActive,"Campaign is not Active");

        if(redundant <= _allowedCampaign[ownerOfCampaign][campaignId].money){
            _allowedCampaign[ownerOfCampaign][campaignId].money.sub(redundant);
        }else{
            _allowedCampaign[ownerOfCampaign][campaignId].money = 0;
        }
        if(redundant > getFeeCampaignCancel()*timesCancelFee){
            transfer(ownerOfCampaign, redundant.sub(getFeeCampaignCancel()*timesCancelFee));
        }
        _allowedCampaign[ownerOfCampaign][campaignId].isActive = false;
    }
}