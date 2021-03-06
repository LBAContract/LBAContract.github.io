// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

contract CampaignDetail{
    
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
    mapping (string => mapping (string => bool)) public checkPayed;
}