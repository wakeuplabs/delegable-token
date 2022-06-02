//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC4907Extension.sol";

contract LendableToken is ERC4907Extension {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public _price = 0;
    uint256 public _maxSupply = 0;
    string public _baseUri;

    constructor(string memory baseUri, uint256 price, uint256 maxSupply) ERC4907Extension("LendableToken", "LT721", true, true) {
        _price = price;
        _maxSupply = maxSupply;
        _baseUri = baseUri;
    }

    // @notice Mints new NFT to msg.sender
    function mint() external payable returns (uint256) {
        require(_tokenIds.current() < _maxSupply, "reached max supply");
        require(msg.value == _price, "incorrect price");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        return newItemId;
    }

    function changeMaxSupply(uint256 maxSupply) external onlyOwner {
        _maxSupply = maxSupply;
    }

    function changePrice(uint256 price) external onlyOwner {
        _price = price;
    }
    
    function withdraw(address payable recipient) external onlyOwner {
        uint256 balance = address(this).balance;
        recipient.transfer(balance);
    }

    function _currentSupply() external view returns (uint256) {
        return _tokenIds.current();
    }

    function changeBaseUri(string memory newBaseUri) external onlyOwner {
        _baseUri = newBaseUri;
    }

    function _baseURI() override internal view virtual returns (string memory) {
        return _baseUri;
    }
}