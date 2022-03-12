// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

contract StakeToken is ERC20Snapshot {

    constructor() ERC20("Stake", "STAKE") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function snapshot() external returns (uint256) {
        return _snapshot();
    }
}
