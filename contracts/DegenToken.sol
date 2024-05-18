// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DegenToken is ERC20 {

    address public owner;

    mapping(address => bool) private redeemFood;
    mapping(address => bool) private redeemWater;
    mapping(address => bool) private redeemFire;
    mapping(address => bool) private canPlayGame;

    // custom errors
    error NotOwner();
    error InsufficientBalance();
    error InvalidItem();
    error RedeemWaterToProceed();
    error RedeemFoodToProceed();

    constructor() ERC20("Degen", "DGN") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier hasEnoughTokens(uint256 _amount) {
        if (balanceOf(msg.sender) < _amount) revert InsufficientBalance();
        _;
    }

    function mintDegenTokens(address _player, uint256 _amount) external onlyOwner {
        _mint(_player, _amount);
    }

    function burnDegenTokens(uint256 amount) external hasEnoughTokens(amount) {
        _burn(msg.sender, amount);
    }

    function transferDegenToken(address to, uint256 amount) external hasEnoughTokens(amount) returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function getDegenBalance(address _playerAddress) external view returns (uint256) {
        return balanceOf(_playerAddress);
    }

    function viewMarketplace() external pure returns (string memory) {
        return "Marketplace: 1. Food - 50DGN, 2. Water - 100DGN, 3. Fire - 150DGN";
    }

    function redeemMarketPlaceItem(uint8 _itemToRedeem) external returns (bool) {
        if (_itemToRedeem == 1) {
            redeemItem(50, redeemFood);
        } else if (_itemToRedeem == 2) {
            if (!redeemFood[msg.sender]) revert RedeemFoodToProceed();
            redeemItem(100, redeemWater);
        } else if (_itemToRedeem == 3) {
            if (!redeemWater[msg.sender]) revert RedeemWaterToProceed();
            redeemItem(150, redeemFire);
            canPlayGame[msg.sender] = true;
        } else {
            revert InvalidItem();
        }
        return true;
    }

    function canUserPlay() external view returns (bool) {
        return canPlayGame[msg.sender];
    }

    function redeemItem(uint256 _amount, mapping(address => bool) storage _itemRedeemed) private hasEnoughTokens(_amount) {
        _approve(msg.sender, owner, _amount);
        transferFrom(msg.sender, owner, _amount);
        _itemRedeemed[msg.sender] = true;
    }
}
