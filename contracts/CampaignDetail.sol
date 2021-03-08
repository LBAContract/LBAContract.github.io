// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;
import './Ownable.sol';

contract CampaignDetail is Ownable{
    
    struct Campaign {
        string campaignId;
        address advertiser;
        uint totalBudget;
        uint remainBudget;
        uint feeCancel;
        bool isActive;
        bool isExist;
    }

    event AuthorityCampaign(address indexed owner, string campaignId, uint256 value);
    event CreateCampaign(address indexed owner, string campaignId, uint256 value);
    mapping (string => Campaign) public campaigns;
}