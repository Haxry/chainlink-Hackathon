

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
interface IOracleAppleSepolia {
    event PriceUpdated(uint256 newPrice);
    event AddressApproved(address indexed approvedAddress);
    event Deposit(address indexed sender, uint256 amount);
    event PriceRequested(string indexed req, address indexed user, uint256 indexed chainid);

    function updatePriceandZkProof(
        uint256 _price,
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[6] calldata _pubSignals,
        address calledBy
    ) external;

    function getLatestPrice(address account) external view returns (uint256);

    function getLatestVerificationValue(address account) external view returns (bool);

    function allowUpdation(address _address) external;

    function reqtLatestPrice() external;

    function sendCrossChain(
        uint64 destinationChainSelector,
        address receiver
    ) external;
}

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import {OracleLib, AggregatorV3Interface} from "./libraries/OracleLib.sol";

/*
 * @dev the codebase will mint sAPPL based on the collateral 
 * deposited into this contract. In our example, ETH is the
 * collateral that we will use to mint sAPPL.
 * 
 * This codebase is NOT COMPLETE
 * 
 * As far as the incentives to do this, people who want to 
 * short APPL and long eth would have the incentive to do this. 
 */
contract sAPPL is ERC20 {
    //using OracleLib for AggregatorV3Interface;

    error sAPPL_feeds__InsufficientCollateral();

    // These both have 8 decimal places for Polygon
    // https://docs.chain.link/data-feeds/price-feeds/addresses?network=polygon
    address private i_applFeed;
    address private i_ethUsdFeed;
    uint256 public constant DECIMALS = 8;
    uint256 public constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 public constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // This means you need to be 200% over-collateralized
    uint256 private constant LIQUIDATION_BONUS = 10; // This means you get assets at a 10% discount when liquidating
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;



    mapping(address user => uint256 applMinted) public s_applMintedPerUser;
    mapping(address user => uint256 ethCollateral) public s_ethCollateralPerUser;

    constructor(address applFeed, address ethUsdFeed) ERC20("Synthetic APPL (Feeds)", "sAPPL") {
        i_applFeed = applFeed;
        i_ethUsdFeed = ethUsdFeed;
    }

    /* 
     * @dev User must deposit at least 200% of the value of the sAPPL they want to mint
     */
    function depositAndmint(uint256 amountToMint) external payable {
        // Checks / Effects
        s_ethCollateralPerUser[msg.sender] += msg.value;
        s_applMintedPerUser[msg.sender] += amountToMint;
        uint256 healthFactor = getHealthFactor(msg.sender);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert sAPPL_feeds__InsufficientCollateral();
        }
        _mint(msg.sender, amountToMint);
        // No external interactions
    }

    function redeemAndBurn(uint256 amountToRedeem) external {
        // Checks / Effects
        uint256 valueRedeemed = getUsdAmountFromappl(amountToRedeem);
        uint256 ethToReturn = getEthAmountFromUsd(valueRedeemed);
        s_applMintedPerUser[msg.sender] -= amountToRedeem;
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
    function getHealthFactor(address user) public  returns (uint256) {
        (uint256 totalapplMintedValueInUsd, uint256 totalCollateralEthValueInUsd) = getAccountInformationValue(user);
        return _calculateHealthFactor(totalapplMintedValueInUsd, totalCollateralEthValueInUsd);
    }

    

    function getUsdAmountFromappl(uint256 amountapplInWei) public  returns (uint256) {
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(i_applFeed);
          IOracleAppleSepolia priceFeed= IOracleAppleSepolia(i_applFeed);
                              priceFeed.reqtLatestPrice();
                              uint256 price=priceFeed.getLatestPrice(address(this));
        //(, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
        return (amountapplInWei * (uint256(price) * ADDITIONAL_FEED_PRECISION)) / PRECISION;
    }

    function getUsdAmountFromEth(uint256 ethAmountInWei) public  returns (uint256) {
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(i_ethUsdFeed);
            IOracleAppleSepolia priceFeed= IOracleAppleSepolia(i_applFeed);
                              priceFeed.reqtLatestPrice();
                              uint256 price=priceFeed.getLatestPrice(address(this));
        //(, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
        return (ethAmountInWei * (uint256(price) * ADDITIONAL_FEED_PRECISION)) / PRECISION;
    }

    function getEthAmountFromUsd(uint256 usdAmountInWei) public  returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(i_ethUsdFeed);
        // (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
            IOracleAppleSepolia priceFeed= IOracleAppleSepolia(i_applFeed);
                              priceFeed.reqtLatestPrice();
                              uint256 price=priceFeed.getLatestPrice(address(this));
        return (usdAmountInWei * PRECISION) / ((uint256(price) * ADDITIONAL_FEED_PRECISION) * PRECISION);
    }

    function getAccountInformationValue(address user)
        public
        
        returns (uint256 totalapplMintedValueUsd, uint256 totalCollateralValueUsd)
    {
        (uint256 totalapplMinted, uint256 totalCollateralEth) = _getAccountInformation(user);
        totalapplMintedValueUsd = getUsdAmountFromappl(totalapplMinted);
        totalCollateralValueUsd = getUsdAmountFromEth(totalCollateralEth);
    }

    function _calculateHealthFactor(uint256 applMintedValueUsd, uint256 collateralValueUsd)
        internal
        pure
        returns (uint256)
    {
        if (applMintedValueUsd == 0) return type(uint256).max;
        uint256 collateralAdjustedForThreshold = (collateralValueUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / applMintedValueUsd;
    }

    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalapplMinted, uint256 totalCollateralEth)
    {
        totalapplMinted = s_applMintedPerUser[user];
        totalCollateralEth = s_ethCollateralPerUser[user];
    }
}
