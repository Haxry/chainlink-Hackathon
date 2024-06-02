// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

 import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {OracleLib, AggregatorV3Interface} from "contracts/oraclelib.sol";

/*
 * @dev the codebase will mint sAPPL based on the collateral 
 * deposited into this contract. In our example, ETH is the
 * collateral that we will use to mint sAPPL.
 * 
 * This codebase is NOT COMPLETE
 * 
 * As far as the incentives to do this, people who want to 
 * short tesla and long eth would have the incentive to do this. 
 */
contract sAPPL is ERC20 {
    //using OracleLib for AggregatorV3Interface;

    error sAPPL_feeds__InsufficientCollateral();

    // These both have 8 decimal places for Polygon
    // https://docs.chain.link/data-feeds/price-feeds/addresses?network=polygon
    address private i_APPLFeed;
    address private i_ethUsdFeed;
    uint256 public constant DECIMALS = 8;
    uint256 public constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 public constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // This means you need to be 200% over-collateralized
    uint256 private constant LIQUIDATION_BONUS = 10; // This means you get assets at a 10% discount when liquidating
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;

    mapping(address user => uint256 APPLMinted) public s_APPLMintedPerUser;
    mapping(address user => uint256 ethCollateral) public s_ethCollateralPerUser;

    constructor() ERC20("Synthetic Apple (Feeds)", "sAPPL") {
        // i_APPLFeed = APPLFeed;
        // i_ethUsdFeed = ethUsdFeed;
    }

    /* 
     * @dev User must deposit at least 200% of the value of the sAPPL they want to mint
     */
    function depositAndmint(uint256 amountToMint) external payable {
        // Checks / Effects
        s_ethCollateralPerUser[msg.sender] += msg.value;
        s_APPLMintedPerUser[msg.sender] += amountToMint;
        uint256 healthFactor = getHealthFactor(msg.sender);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert sAPPL_feeds__InsufficientCollateral();
        }
        _mint(msg.sender, amountToMint);
        // No external interactions
    }

    function redeemAndBurn(uint256 amountToRedeem) external {
        // Checks / Effects
        uint256 valueRedeemed = getUsdAmountFromAPPL(amountToRedeem);
        uint256 ethToReturn = getEthAmountFromUsd(valueRedeemed);
        s_APPLMintedPerUser[msg.sender] -= amountToRedeem;
        uint256 healthFactor = getHealthFactor(msg.sender);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert sAPPL_feeds__InsufficientCollateral();
        }
        _burn(msg.sender, amountToRedeem);
        // External
        (bool success,) = msg.sender.call{value: ethToReturn}("");
        if (!success) {
            revert("sAPPL_feeds: transfer failed");
        }
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW AND PURE
    //////////////////////////////////////////////////////////////*/
    function getHealthFactor(address user) public view returns (uint256) {
        (uint256 totalAPPLMintedValueInUsd, uint256 totalCollateralEthValueInUsd) = getAccountInformationValue(user);
        return _calculateHealthFactor(totalAPPLMintedValueInUsd, totalCollateralEthValueInUsd);
    }

    function getUsdAmountFromAPPL(uint256 amountAPPLInWei) public view returns (uint256) {
        price= //hardcode tesla/usd
        return (amountAPPLInWei * (uint256(price) * ADDITIONAL_FEED_PRECISION)) / PRECISION;
    }

    function getUsdAmountFromEth(uint256 ethAmountInWei) public view returns (uint256) {
        price= //hardcode eth/usd
        return (ethAmountInWei * (uint256(price) * ADDITIONAL_FEED_PRECISION)) / PRECISION;
    }

    function getEthAmountFromUsd(uint256 usdAmountInWei) public view returns (uint256) {
       price= //hardcode eth/usd
        return (usdAmountInWei * PRECISION) / ((uint256(price) * ADDITIONAL_FEED_PRECISION) * PRECISION);
    }

    function getAccountInformationValue(address user)
        public
        view
        returns (uint256 totalAPPLMintedValueUsd, uint256 totalCollateralValueUsd)
    {
        (uint256 totalAPPLMinted, uint256 totalCollateralEth) = _getAccountInformation(user);
        totalAPPLMintedValueUsd = getUsdAmountFromAPPL(totalAPPLMinted);
        totalCollateralValueUsd = getUsdAmountFromEth(totalCollateralEth);
    }

    function _calculateHealthFactor(uint256 APPLMintedValueUsd, uint256 collateralValueUsd)
        internal
        pure
        returns (uint256)
    {
        if (APPLMintedValueUsd == 0) return type(uint256).max;
        uint256 collateralAdjustedForThreshold = (collateralValueUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / APPLMintedValueUsd;
    }

    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalAPPLMinted, uint256 totalCollateralEth)
    {
        totalAPPLMinted = s_APPLMintedPerUser[user];
        totalCollateralEth = s_ethCollateralPerUser[user];
    }
}
