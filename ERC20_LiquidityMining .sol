// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract LiquidityMining {
    IERC20 public liquidityToken;
    IERC20 public rewardToken;

    uint256 public totalLiquidity;
    uint256 public totalRewards;
    uint256 public rewardRate;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public rewards;

    uint256 public startTime;
    uint256 public endTime;

    constructor(address _liquidityToken, address _rewardToken, uint256 _endTime) {
        liquidityToken = IERC20(_liquidityToken);
        rewardToken = IERC20(_rewardToken);
        endTime = _endTime;
    }

    function deposit(uint256 amount) public {
        require(block.timestamp < endTime, "Mining has ended");
        liquidityToken.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        totalLiquidity += amount;
    }

    function withdraw(uint256 amount) public {
        require(block.timestamp >= endTime, "Mining has not ended");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        liquidityToken.transfer(msg.sender, amount);
        rewardToken.transfer(msg.sender, reward);
        balances[msg.sender] -= amount;
        totalLiquidity -= amount;
        totalRewards -= reward;
    }

    function claimReward() public {
        require(block.timestamp >= startTime, "Mining has not started");
        require(block.timestamp < endTime, "Mining has ended");
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
        totalRewards -= reward;
    }

    function startMining(uint256 _rewardAmount, uint256 _duration) public {
        require(block.timestamp < startTime, "Mining has already started");
        startTime = block.timestamp;
        endTime = startTime + _duration;
        rewardRate = _rewardAmount / _duration;
        totalRewards = _rewardAmount;
        rewardToken.transferFrom(msg.sender, address(this), _rewardAmount);
    }

    function updateMining(uint256 _rewardAmount, uint256 _duration) public {
        require(block.timestamp < startTime, "Mining has already started");
        rewardRate = _rewardAmount / _duration;
        totalRewards = _rewardAmount;
    }

    function getReward() public view returns (uint256) {
        if (block.timestamp < startTime) {
            return 0;
        } else if (block.timestamp >= endTime) {
            return totalRewards;
        } else {
            return (block.timestamp - startTime) * rewardRate;
        }
    }

    function getBalance() public view returns (uint256) {
        return liquidityToken.balanceOf(address(this));
    }
}
