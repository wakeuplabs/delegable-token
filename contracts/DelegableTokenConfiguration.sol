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
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract DelegableTokenConfiguration is Ownable {
    bool internal _allowTransferBeforeUserExpired;
    bool internal _allowChangeUserBeforeUserExpired;

    constructor() {
        _allowTransferBeforeUserExpired = true;
        _allowChangeUserBeforeUserExpired = true;
    }

    function setAllowTransferBeforeUserExpired(bool value) external onlyOwner {
        _allowTransferBeforeUserExpired = value;
    }

    function setAllowChangeUserBeforeUserExpired(bool value)
        external
        onlyOwner
    {
        _allowChangeUserBeforeUserExpired = value;
    }

    function getAllowTransferBeforeUserExpired() external view returns (bool) {
        return _allowTransferBeforeUserExpired;
    }

    function getAllowChangeUserBeforeUserExpired()
        external
        view
        returns (bool)
    {
        return _allowChangeUserBeforeUserExpired;
    }
}
