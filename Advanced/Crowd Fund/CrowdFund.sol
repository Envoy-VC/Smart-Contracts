// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}


    /** 
    * @title CrowdFund Smart Contract
    * @author Vedant Chainani
    */

contract CrowdFund {
    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint startAt;
        uint endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count;
    uint public maxDuration;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

    constructor(address _token, uint _maxDuration) {
        token = IERC20(_token);
        maxDuration = _maxDuration;
    }

    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp,"Start time is less than current Block Timestamp");
        require(_endAt > _startAt,"End time is less than Start time");
        require(_endAt <= block.timestamp + maxDuration, "End time exceeds the maximum Duration");

        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(count,msg.sender,_goal,_startAt,_endAt);
    }

    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "You did not create this Campaign");
        require(block.timestamp < campaign.startAt, "Campaign has already started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign has not Started yet");
        require(block.timestamp <= campaign.endAt, "Campaign has already ended");
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unPledge(uint _id,uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign has not Started yet");
        require(block.timestamp <= campaign.endAt, "Campaign has already ended");
        require(pledgedAmount[_id][msg.sender] >= _amount,"You do not have enough tokens Pledged to withraw");

        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "You did not create this Campaign");
        require(block.timestamp > campaign.endAt, "Campaign has not ended");
        require(campaign.pledged >= campaign.goal, "Campaign did not succed");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);

        emit Claim(_id);
    }

    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "You cannot Withdraw, Campaign has succeeded");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }


}