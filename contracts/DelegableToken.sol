//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC4907Extension.sol";

contract DelegableToken is ERC4907Extension {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public _price = 0;
    uint256 public _maxSupply = 0;
    string public _baseUri;

    bool public _allowTransferBeforeUserExpired;
    bool public _allowChangeUserBeforeUserExpired;

    constructor(
        string memory baseUri,
        uint256 price,
        uint256 maxSupply,
        bool allowTransferBeforeUserExpired,
        bool allowChangeUserBeforeUserExpired
    ) ERC4907Extension("DelegableToken", "DT721") {
        _price = price;
        _maxSupply = maxSupply;
        _baseUri = baseUri;

        _allowTransferBeforeUserExpired = allowTransferBeforeUserExpired;
        _allowChangeUserBeforeUserExpired = allowChangeUserBeforeUserExpired;
    }

    function changeConfiguration(
        bool allowTransferBeforeUserExpired,
        bool allowChangeUserBeforeUserExpired
    ) external onlyOwner {
        _allowTransferBeforeUserExpired = allowTransferBeforeUserExpired;
        _allowChangeUserBeforeUserExpired = allowChangeUserBeforeUserExpired;
    }

    function setUser(
        uint256 tokenId,
        address user,
        uint256 expires
    ) public virtual override {
        require(
            _allowChangeUserBeforeUserExpired ||
                this.userOf(tokenId) == address(0),
            "token not available"
        );

        super.setUser(tokenId, user, expires);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(
            _allowTransferBeforeUserExpired ||
                this.userOf(tokenId) == address(0),
            "token not available"
        );

        super._beforeTokenTransfer(from, to, tokenId);
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

    function currentSupply() external view returns (uint256) {
        return _tokenIds.current();
    }

    function changeBaseUri(string memory newBaseUri) external onlyOwner {
        _baseUri = newBaseUri;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseUri;
    }
}
