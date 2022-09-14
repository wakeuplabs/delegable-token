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
import "../ERC4907/extensions/ERC4907ExtensionURIStorage.sol";
import "./DelegableTokenConfiguration.sol";

abstract contract DelegableTokenExtensionURIStorage is
    ERC4907ExtensionURIStorage,
    DelegableTokenConfiguration
{
    constructor(string memory name, string memory symbol)
        ERC4907ExtensionURIStorage(name, symbol)
    {}

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
}
