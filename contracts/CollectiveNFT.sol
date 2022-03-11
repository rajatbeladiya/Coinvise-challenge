// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CollectiveNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event CollectiveNFTMinted(address owner, uint256 tokenId);

    constructor() ERC721("CollectiveNFT", "CNFT") {}

    function _mintNFT(address _owner) private {
        uint256 newItemId = _tokenIds.current();
        _safeMint(_owner, newItemId);
        _tokenIds.increment();

        emit CollectiveNFTMinted(msg.sender, newItemId);
    }

    function buyNFT() public payable {
        require(msg.value == 1 ether, "amount should be 1 ether");
        _mintNFT(msg.sender);
    }
}
