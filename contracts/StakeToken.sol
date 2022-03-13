// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

 contract StakeToken is ERC20Snapshot, Ownable {

    constructor() ERC20("Stake", "STAKE") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function snapshot() external returns (uint256) {
        return _snapshot();
    }
}
