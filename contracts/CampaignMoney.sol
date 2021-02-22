// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
pragma experimental ABIEncoderV2;
import './Ownable.sol';

contract CampaignMoney is Ownable{
    
    struct Campaign {
        string campaignId;
        uint money;
        uint timestamp;
        bool isActive;
        bool isExist;
    }
    event AuthorityCampaign(address indexed owner, string campaignId, uint256 value);
    mapping (address => mapping (string => Campaign)) public _allowedCampaign;
    uint private _feeAdvertiserCampaign;
    uint private _feePublisherCampaign;
    uint private _feeCampaignCancel;

    constructor(){
        _feeAdvertiserCampaign = 1;
        _feePublisherCampaign = 1;
        _feeCampaignCancel = 10;
    }
    

    function getFeeAdvertiserCampaign() public view returns (uint256) {
        return _feeAdvertiserCampaign;
    }

    function setFeeAdvertiserCampaign(uint256 value) public {
        _feeAdvertiserCampaign = value;
    }

    function getFeePublisherCampaign() public view returns (uint256) {
        return _feePublisherCampaign;
    }

    function setFeePublisherCampaign(uint256 value) public {
        _feePublisherCampaign = value;
    }
    
    function getFeeCampaignCancel() public view returns (uint256) {
        return _feeCampaignCancel;
    }

    function changeFeeCampaignCancel(uint256 value) public {
        _feeCampaignCancel = value;
    }
}