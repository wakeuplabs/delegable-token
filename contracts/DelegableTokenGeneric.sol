//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//   __        __    _        _   _
//   \ \      / /_ _| | _____| | | |_ __
//    \ \ /\ / / _` | |/ / _ \ | | | '_ \
//     \ V  V / (_| |   <  __/ |_| | |_) |
//      \_/\_/ \__,_|_|\_\___|\___/| .__/
//                                 |_|
//       WakeUp Labs 2022

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./extensions/DelegableTokenExtension.sol";

contract DelegableTokenGeneric is DelegableTokenExtension {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 private _price = 0;
    uint256 private _maxSupply = 0;
    string private _baseUri;
    bool public paused = false;
    
    constructor(
        string memory name,
        string memory symbol,
        string memory baseUri,
        uint256 price,
        uint256 maxSupply,
        bool allowTransferBeforeUserExpired,
        bool allowChangeUserBeforeUserExpired
    )
        DelegableTokenExtension(name, symbol)
        DelegableTokenConfiguration(
            allowTransferBeforeUserExpired,
            allowChangeUserBeforeUserExpired
        )
    {
        _price = price;
        _maxSupply = maxSupply;
        _baseUri = baseUri;
    }

    // @notice Mints new NFT to msg.sender
    function mint() public payable returns (uint256) {
        require(!paused, "Minting is disabled");
        require(_tokenIds.current() < _maxSupply, "reached max supply");
        require(msg.value == _price, "incorrect price");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        return newItemId;
    }

    function changeMaxSupply(uint256 maxSupply) public onlyOwner {
        _maxSupply = maxSupply;
    }

    function changePrice(uint256 price) public onlyOwner {
        _price = price;
    }

    function withdraw(address payable recipient) public onlyOwner {
        uint256 balance = address(this).balance;
        recipient.transfer(balance);
    }

    function currentSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function changeBaseUri(string memory newBaseUri) public onlyOwner {
        _baseUri = newBaseUri;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseUri;
    }

    function getPrice() public view returns (uint256) {
        return _price;
    }

    function getMaxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev Triggers stopped state.
     */
    function pause() external onlyOwner {
        paused = true;
    }

    /**
     * @dev Returns the tier to normal state.
     */
    function unpause() external onlyOwner {
        paused = false;
    }

}
