// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IERC4907.sol";

abstract contract ERC4907Extension is Ownable, ERC721, IERC4907 {
    struct UserInfo 
    {
        address user;   // address of user role
        uint256 expires; // unix timestamp, user expires
    }

    mapping (uint256  => UserInfo) internal _users;
    bool private allowTransferBeforeUserExpired;
    bool private allowChangeUserBeforeUserExpired;

    constructor(
        string memory name_, 
        string memory symbol_, 
        bool allowTransferBeforeUserExpired_, 
        bool allowChangeUserBeforeUserExpired_
    ) ERC721(name_, symbol_)
    {
        allowTransferBeforeUserExpired = allowTransferBeforeUserExpired_;
        allowChangeUserBeforeUserExpired = allowChangeUserBeforeUserExpired_;
    }

    function changeConfiguration(
        bool allowTransferBeforeUserExpired_, 
        bool allowChangeUserBeforeUserExpired_
    ) external onlyOwner {
        allowTransferBeforeUserExpired = allowTransferBeforeUserExpired_;
        allowChangeUserBeforeUserExpired = allowChangeUserBeforeUserExpired_;
    }
    
    /// @notice set the user and expires of a NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint256 expires) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "not owner nor approved");
        require(allowChangeUserBeforeUserExpired || this.userOf(tokenId) == address(0), "token not available");

        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) public view virtual override returns(address){
        if(uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user;
        }
        else{
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) public view virtual override returns(uint256){
        return _users[tokenId].expires;
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(allowTransferBeforeUserExpired || this.userOf(tokenId) == address(0), "token not available");

        super._beforeTokenTransfer(from, to, tokenId);

        if (from != to) {
            _users[tokenId].user = address(0);
            _users[tokenId].expires = 0;
            emit UpdateUser(tokenId, address(0), 0);
        }
    }
} 