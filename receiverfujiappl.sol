// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Client} from "@chainlink/contracts-ccip@1.4.0/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip@1.4.0/src/v0.8/ccip/applications/CCIPReceiver.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

/// @title - A simple contract for receiving string data across chains.
contract ReceiverFujiappl is CCIPReceiver {
    // Event emitted when a message is received from another chain.
    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender from the source chain.
        string text // The text that was received.
    );
    event priceRequested(string indexed req,address indexed user, uint256 indexed chainid);

    bytes32 private s_lastReceivedMessageId; // Store the last received messageId.
    string private s_lastReceivedText;
    address private _user;
    uint256 private userid=0;
    //mapping (uint256 => address) idToUser;
    mapping(address => bool) public hasPendingRequest;
     
    //mapping(address=>string[]) public  userToData; // Store the last received text.
    mapping(address=>string) public userToData;

    /// @notice Constructor initializes the contract with the router address.
    /// @param router The address of the router contract.
    constructor(address router) CCIPReceiver(router) {}

    /// handle a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        s_lastReceivedMessageId = any2EvmMessage.messageId; // fetch the messageId
        s_lastReceivedText = abi.decode(any2EvmMessage.data, (string)); // abi-decoding of the sent text
         userToData[_user]=s_lastReceivedText;
          hasPendingRequest[_user] = false;
        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            abi.decode(any2EvmMessage.data, (string))
        );
        //userToData[_user].push(s_lastReceivedText);
        
    }

    /// @notice Fetches the details of the last received message.
    /// @return messageId The ID of the last received message.
    /// @return text The last received text.


    function getLastPriceAndZkVerification()
        external
        view
        returns (bytes32 messageId, string memory text)
    {
        //uint256 length= userToData[msg.sender].length;
        return (s_lastReceivedMessageId, userToData[msg.sender]);
    }

    function requestLatestPrice() external{
        require(!hasPendingRequest[msg.sender], "Pending request already exists");
        string memory _req="price req";

         _user= msg.sender;
         uint256 chainid= block.chainid;
         hasPendingRequest[msg.sender] = true;
        emit priceRequested(_req, _user,chainid);
    }

    function getRecentPriceAndVerification(address user) external view returns(string memory){

        return userToData[user];

    }
}
