// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


// Deployed to https://mumbai.polygonscan.com/address/0x8383e479F43395EeeF2b387C1E794Ad9b0d51145

contract Merkeltree is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint public maxSupply = 10000;
    string internal uri;
    bytes32 public root;

    constructor(string memory baseURI, bytes32 _root) ERC721("Merkeltree", "MKT") {
        root = _root;
        _tokenIdCounter.increment();
        uri = baseURI;
    }


    function changeBaseURI(string memory _uri) public onlyOwner {
        uri = _uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return uri;
    }

    function isWhitelisted(bytes32[] memory proof, bytes32 leaf) public view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function mint(bytes32[] memory proof) public {
        require(isWhitelisted(proof, keccak256(abi.encodePacked(msg.sender))), "Not a part of Whitelist");
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId <= maxSupply,"All NFTs have been Minted");
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function withdrawFunds(address payable to) public onlyOwner {
        to.transfer(address(this).balance);
    }

    fallback() external payable {}
    receive() external payable {}
}