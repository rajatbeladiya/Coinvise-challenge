// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./StakeToken.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CollectiveNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 private constant REWARDS_ROUND_MIN_DURATION = 5 days;

    uint256 public lastSnapshotIdForRewards;
    uint256 public lastRecordedSnapshotTimestamp;

    mapping(address => uint256) public lastRewardTimestamps;

    StakeToken public stakeToken;

    uint256 public roundNumber;

    event CollectiveNFTMinted(address owner, uint256 tokenId);

    constructor(address tokenAddress) ERC721("CollectiveNFT", "CNFT") {
        stakeToken = StakeToken(tokenAddress);

        _recordSnapshot();
    }

    function buyNFT() public payable {
        require(msg.value == 1 ether, "amount should be 1 ether");
        _mintNFT(msg.sender);
    }

    function _mintNFT(address _owner) private {
        uint256 newItemId = _tokenIds.current();
        _safeMint(_owner, newItemId);
        _tokenIds.increment();

        emit CollectiveNFTMinted(msg.sender, newItemId);
    }

    function distributeRewards() public returns (uint256) {
        uint256 rewards = 0;

        if (isNewRewardsRound()) {
            _recordSnapshot();
        }

        uint256 totalStakeSupply = stakeToken.totalSupplyAt(lastSnapshotIdForRewards);
        uint256 totalBalanceAtSnapshot = stakeToken.balanceOfAt(msg.sender, lastSnapshotIdForRewards);

        require(totalBalanceAtSnapshot >= 100000 * 10 ** 18, "not eligible for reward");

        if (totalBalanceAtSnapshot > 0 && totalStakeSupply > 0) {
            rewards = totalBalanceAtSnapshot * 10 ** 18 / totalStakeSupply;
            if (rewards > 0 && !_hasRetrivedReward(msg.sender)) {
                payable(msg.sender).transfer(rewards);
                lastRewardTimestamps[msg.sender] = block.timestamp;
            }
        }


        return rewards;
    }

    function _recordSnapshot() private {
        lastSnapshotIdForRewards = stakeToken.snapshot();
        lastRecordedSnapshotTimestamp = block.timestamp;
        roundNumber++;
    }

    function _hasRetrivedReward(address account) private view returns (bool) {
        return (
            lastRewardTimestamps[account] >= lastRecordedSnapshotTimestamp &&
            lastRewardTimestamps[account] <= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION
        );
    }

    function isNewRewardsRound() public view returns (bool) {
        return block.timestamp >= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION;
    }
}
