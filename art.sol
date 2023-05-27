// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtToken is ERC721, Ownable {

    // ======================================
    // Initial Statements
    // ======================================

    // Smart Contract Constructor
    constructor (string memory _name, string memory _symbol)
    ERC721(_name, _symbol){}

    // NFT token counter
    uint256 COUNTER;

    // Princing of NFT Tokens
    uint256 public fee = 5 ether / 10**18;

    // Data structure with the properties of the artwork
    struct Art {
        string name;
        uint256 id;
        uint256 dna;
        uint8 level;
        uint8 rarity;
    }

    // Storage structure for keeping artworks array of Art
    Art [] public art_works;

    // Declaration of an event
    event newArtWork (address indexed owner, uint256 id, uint256 dna);


    // ======================================
    // Help functions
    // ======================================

    // Creation of a random number (require for NFT token properties)
    function _createRandomNum(uint256 _mod) internal view returns (uint256){
        bytes32 hash_randomNum = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        uint256 randomNum = uint256(hash_randomNum);
        return randomNum % _mod;
    }

    // NFT Token Creation (ArtWork)
    function _createArtWork(string memory _name) internal {
        uint8 ranndomRarity = uint8(_createRandomNum(10));
        uint256 randomDna = _createRandomNum(10**16);
        Art memory newArt = Art(_name, COUNTER, randomDna, 1, ranndomRarity);
        art_works.push(newArt);
        _safeMint(msg.sender, COUNTER);
        emit newArtWork(msg.sender, COUNTER, randomDna);
        COUNTER++;
    }

    // NFT Token Price Update using onlyOwner Ownable.sol function
    function updateFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    // Visualize the balance of the Smart Contract (ethers)
    function infoSmartContract() public view returns (address, uint256){
        address SC_address = address(this);
        uint256 SC_money = address(this).balance / 10**18;
        return (SC_address, SC_money);
    }

    // Obtaining all created NFT tokens (artwork)
    function getArtWorks() public view returns (Art [] memory){
        return art_works;
    }

    // Obtaining a user's NFT token
    function getOwnerArtWork(address _owner) public view returns (Art [] memory){
        Art [] memory result = new Art[](balanceOf(_owner));
        uint256 counter_owner = 0;
        for (uint256 i = 0; i < art_works.length; i++){
            if (ownerOf(i) == _owner){
                result[counter_owner] = art_works[i];
                counter_owner++;
            }
        }
        return result;
    }


    // ======================================
    // NFT token development
    // ======================================

    // NFT Token Payment
    function _createRandomArtWork(string memory _name) public payable {
        require(msg.value >= fee);
        _createArtWork(_name);

    }

    // Extraction of ethers from the Smart Contract to the Owner
    function withdraw() external payable onlyOwner{
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    // Level UP nft Tokens
    function levelUp(uint256 _artId) public payable {
        require(ownerOf(_artId) == msg.sender, "ERROR: you dont have the ownership of the NFT");
        Art storage art = art_works[_artId];
         require(msg.value >= 1 ether);
        art.level++;
    }
}