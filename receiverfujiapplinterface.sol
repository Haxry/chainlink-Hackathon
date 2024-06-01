// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IReceiverFujiappl {
    event MessageReceived(
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address sender,
        string text
    );

    event priceRequested(
        string indexed req,
        address indexed user,
        uint256 indexed chainid
    );

    function getLastPriceAndZkVerification()
        external
        view
        returns (bytes32 messageId, string memory text);

    function requestLatestPrice() external;

    function getRecentPriceAndVerification(address user)
        external
        view
        returns (string memory);
}
