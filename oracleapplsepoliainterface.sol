// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
