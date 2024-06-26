// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip@1.4.0/src/v0.8/ccip/interfaces/IRouterClient.sol";
//import {OwnerIsCreator} from "@chainlink/contracts-ccip@1.4.0/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip@1.4.0/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts@1.1.1/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

/// @title - A simple contract for sending string data across chains.
contract Sender  {
    // Custom errors to provide more descriptive revert messages.
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        string text, // The text being sent.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the CCIP message.
    );
     
      mapping(address => bool) public approvedAddresses;
      address public owner;

    modifier onlyOwnerOrApproved() {
        require(msg.sender == owner || approvedAddresses[msg.sender], "Not authorized");
        _;
    }
     modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }


    IRouterClient private s_router;

    LinkTokenInterface private s_linkToken;

    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    constructor(address _router, address _link) {
        s_router = IRouterClient(_router);
        s_linkToken = LinkTokenInterface(_link);
        owner=msg.sender;
    }

    /// @notice Sends data to receiver on the destination chain.
    /// @dev Assumes your contract has sufficient LINK.
    /// @param destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param receiver The address of the recipient on the destination blockchain.
    /// @param text The string text to be sent.
    /// @return messageId The ID of the message that was sent.
    function sendMessage(
        uint64 destinationChainSelector,
        address receiver,
        string calldata text
    ) external onlyOwnerOrApproved returns (bytes32 messageId) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver), // ABI-encoded receiver address
            data: abi.encode(text), // ABI-encoded string
            tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array indicating no tokens are being sent
            extraArgs: Client._argsToBytes(
                // Additional arguments, setting gas limit
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            ),
            // Set the feeToken  address, indicating LINK will be used for fees
            feeToken: address(s_linkToken)
        });

        // Get the fee required to send the message
        uint256 fees = s_router.getFee(
            destinationChainSelector,
            evm2AnyMessage
        );

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        s_linkToken.approve(address(s_router), fees);

        // Send the message through the router and store the returned message ID
        messageId = s_router.ccipSend(destinationChainSelector, evm2AnyMessage);

        // Emit an event with message details
        emit MessageSent(
            messageId,
            destinationChainSelector,
            receiver,
            text,
            address(s_linkToken),
            fees
        );

        // Return the message ID
        return messageId;
    }

    function allowUpdation(address _address) external onlyOwner {
        approvedAddresses[_address] = true;
        
    }
}



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/utils/Strings.sol";
import {IRouterClient} from "@chainlink/contracts-ccip@1.4.0/src/v0.8/ccip/interfaces/IRouterClient.sol";
//import {OwnerIsCreator} from "@chainlink/contracts-ccip@1.4.0/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip@1.4.0/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts@1.1.1/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

/// @title - A simple contract for sending string data across chains.
contract Sender  {
    // Custom errors to provide more descriptive revert messages.
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        string text, // The text being sent.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the CCIP message.
    );
     
      mapping(address => bool) public approvedAddresses;
      address public owner;

    modifier onlyOwnerOrApproved() {
        require(msg.sender == owner || approvedAddresses[msg.sender], "Not authorized");
        _;
    }
     modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }


    IRouterClient private s_router;

    LinkTokenInterface private s_linkToken;

    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    constructor(address _router, address _link) {
        s_router = IRouterClient(_router);
        s_linkToken = LinkTokenInterface(_link);
        owner=msg.sender;
    }

    /// @notice Sends data to receiver on the destination chain.
    /// @dev Assumes your contract has sufficient LINK.
    /// @param destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param receiver The address of the recipient on the destination blockchain.
    /// @param text The string text to be sent.
    /// @return messageId The ID of the message that was sent.
    function sendMessage(
        uint64 destinationChainSelector,
        address receiver,
        string calldata text
    ) external onlyOwnerOrApproved returns (bytes32 messageId) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver), // ABI-encoded receiver address
            data: abi.encode(text), // ABI-encoded string
            tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array indicating no tokens are being sent
            extraArgs: Client._argsToBytes(
                // Additional arguments, setting gas limit
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            ),
            // Set the feeToken  address, indicating LINK will be used for fees
            feeToken: address(s_linkToken)
        });

        // Get the fee required to send the message
        uint256 fees = s_router.getFee(
            destinationChainSelector,
            evm2AnyMessage
        );

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        s_linkToken.approve(address(s_router), fees);

        // Send the message through the router and store the returned message ID
        messageId = s_router.ccipSend(destinationChainSelector, evm2AnyMessage);

        
        emit MessageSent(
            messageId,
            destinationChainSelector,
            receiver,
            text,
            address(s_linkToken),
            fees
        );

        
        return messageId;
    }

    function allowUpdation(address _address) external onlyOwner {
        approvedAddresses[_address] = true;
        
    }
}



contract PriceFeed {
   
    address public owner;
    uint256 private price;
    mapping(address => bool) public approvedAddresses;
    Sender private ccipSender;
    address private ccipSpenderAddress;
    uint256 public totalDeposits;
    mapping(address => uint256) public balances;
    uint256 private updationPrice;
    uint256 private CCIPPrice;
    mapping(address=> uint256[]) public addressToPriceArray;
    address private user;
    mapping(address=> bytes32[] ) public addressToProof;
    bytes32 proof;
     

    

    
    event PriceUpdated(uint256 newPrice);
    event AddressApproved(address indexed approvedAddress);
    event Deposit(address indexed sender, uint256 amount);
     event PriceRequested(string indexed req,address indexed user);

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyOwnerOrApproved() {
        require(msg.sender == owner || approvedAddresses[msg.sender], "Not authorized");
        _;
    }

    
    constructor(address _ccipSender) {
        owner = msg.sender;
        ccipSender=Sender(_ccipSender);
    }

    
    function updatePriceandZkProof(uint256 _price, bytes32 _proof,address calledBy) external onlyOwnerOrApproved {
       // uint256 initialGas = gasleft();
        //uint256 gasPrice = tx.gasprice;
         user=calledBy;
         uint256 length= addressToPriceArray[user].length;
         uint256 lengthProof= addressToProof[user].length;
        price = _price;
        proof=_proof;
        emit PriceUpdated(_price);
            addressToPriceArray[user].push(price);
            addressToProof[user].push(_proof);
        if(addressToPriceArray[user].length != length+1 && addressToPriceArray[user].length != addressToProof[user].length)  { 
            revert();
        }
        if(addressToProof[user].length != lengthProof+1 && addressToPriceArray[user].length != addressToProof[user].length){ 
            revert();
        }
        // uint256 finalGas = gasleft();
       // uint256 gasUsed = initialGas - finalGas;
        // updationPrice = gasUsed * gasPrice;
     
    }

   

    
    function allowUpdation(address _address) external onlyOwner {
        approvedAddresses[_address] = true;
        emit AddressApproved(_address);
    }

    

    
    function reqtLatestPrice() external  returns(uint256) {
       address _user= msg.sender;   
        string memory _req= "get Price";
        emit PriceRequested(_req,_user);
       
        return price;
       
    }

    function getLatestPrice() external view returns(uint256){
        uint256 length= addressToPriceArray[msg.sender].length;
        return addressToPriceArray[msg.sender][length-1];
    }
     
     

    function sendCrossChain(uint64 destinationChainSelector,
        address receiver
        ) external {
                   //uint256 initialGas = gasleft();
        //uint256 gasPrice = tx.gasprice;
        uint256 length= addressToPriceArray[user].length;
        uint256 lengthProof= addressToProof[user].length;
                 string memory _price= Strings.toString(addressToPriceArray[user][length-1]);
                 string memory _proof = string(abi.encodePacked(addressToProof[user][lengthProof-1]));
                 string memory data= string(abi.encodePacked(_price,_proof));

                 
                 
            ccipSender.sendMessage(destinationChainSelector, receiver,data);
           // uint256 finalGas = gasleft();
        //uint256 gasUsed = initialGas - finalGas;
       // CCIPPrice = gasUsed * gasPrice;
    }

    //uint256 totalGasPrice= CCIPPrice+updationPrice;

    //  fallback() external payable {
    //     deposit();
    // }

    // receive() external payable {
    //     deposit();
    // }

    // function depositETH() external payable {
    //     deposit();
    // }


    //  function deposit() internal {
    //     require(msg.value > 0, "Must send some ETH");
    //     balances[msg.sender] += msg.value;
    //     totalDeposits += msg.value;
    //     emit Deposit(msg.sender, msg.value);
    // }

    // function withdraw() external {
    //     require(msg.sender == owner, "Only owner can withdraw");
    //     uint256 amount = address(this).balance;
    //     require(amount > 0, "No ETH to withdraw");
    //     payable(owner).transfer(amount);
    // }

    //  function getBalance() external view returns (uint256) {
    //     return address(this).balance;
    // }




}



