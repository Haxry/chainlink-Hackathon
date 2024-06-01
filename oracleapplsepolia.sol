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

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 8658581402644557568375439592645246291401095424445978188195432525470964737925;
    uint256 constant alphay  = 15750768004560173985384047871950034065944919011852736318317363378500003499617;
    uint256 constant betax1  = 13247477584010130284336036832064112214868752655746930974517526337390432918738;
    uint256 constant betax2  = 11356473590216902612081547759089976396731989850321125151945768582686127531767;
    uint256 constant betay1  = 1606200770187687201555575647419487318534159247126822117164670375630830021613;
    uint256 constant betay2  = 13716399765602628374401939207764281736902009900260068546454790031958590352668;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 13242503392945497908935958039737746553745130102691824173243218450311881698160;
    uint256 constant deltax2 = 51971941962907804683760861270690136275948094971574997625491088323770881680;
    uint256 constant deltay1 = 15882055992911938347916482512210819586682334096547210920047716086328013736037;
    uint256 constant deltay2 = 14549022159907791841853117315460252912128241258198925097086190804527157115122;

    
    uint256 constant IC0x = 18464938452989286535709726483950160470798392266365292091338958274287126184792;
    uint256 constant IC0y = 14693514241209505931776297858389515347755397328270030027136541994524508564714;
    
    uint256 constant IC1x = 678390225082077692910717339632023925867188687449827574282687642362555871601;
    uint256 constant IC1y = 17114215100991687246902376772630651981853318265160480170727695431768412830510;
    
    uint256 constant IC2x = 16525916638281527021260756819208884039257282212914579404327182030376378195091;
    uint256 constant IC2y = 16025318367972114230280640284266398717811912847119310629309796492686663982818;
    
    uint256 constant IC3x = 7520172702347342694710255936614641927296709186571617147582195518676751970351;
    uint256 constant IC3y = 14931149556323046165628913486161329543747128890657165543843588658475027853499;
    
    uint256 constant IC4x = 17868407351830064926333670632831571265609146768070836654574219222258457902233;
    uint256 constant IC4y = 18036682294689573229021118667134752593059864055645041752735869291814362642712;
    
    uint256 constant IC5x = 974232705409844645877386074230615369206108216894241127758746376081871121654;
    uint256 constant IC5y = 3695104621698605381229392824689244578520511682175592879653193457260331363140;
    
    uint256 constant IC6x = 100620135086017915450717815076271621791211235334195785645333553018057008397;
    uint256 constant IC6y = 8344504826156103888722601554605496057345349155123383479627767679866219626149;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[6] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }



contract oracleapplesepolia {
   
    
    
    
   
    
    //uint256 public totalDeposits;
    //mapping(address => uint256) public balances;
    uint256 private updationPrice;
    uint256 private CCIPPrice;
    uint256 private price;
    address public owner;
    address private user;
    address private ccipSpenderAddress;
    //mapping(address=> bytes32[] ) public addressToProof;
    bytes32 proof;
    Groth16Verifier private verifier;
     Sender private ccipSender;
    mapping(address => uint[2]) addTo_pA;
    mapping(address=> uint[2][2]) addTo_pB;
    mapping(address=> uint[2]) addTo_pC;
    mapping(address=> uint[6]) addToPublicSig;
    mapping(address => bool) public approvedAddresses;
    mapping(address=> uint256) public addToLatestPrice;
    mapping(address=> bool) public addToLatestVerification;
     

    

    
    event PriceUpdated(uint256 newPrice);
    event AddressApproved(address indexed approvedAddress);
    event Deposit(address indexed sender, uint256 amount);
     event PriceRequested(string indexed req,address indexed user,uint256 indexed chainid);

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyOwnerOrApproved() {
        require(msg.sender == owner || approvedAddresses[msg.sender], "Not authorized");
        _;
    }

    
    constructor(address _ccipSender, address _verifier) {
        owner = msg.sender;
        ccipSender=Sender(_ccipSender);
        verifier= Groth16Verifier(_verifier);
    }

    
    function updatePriceandZkProof(uint256 _price,uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[6] calldata _pubSignals,address calledBy) external onlyOwnerOrApproved {
       
         user=calledBy;
        
        
        price = _price;

        addToLatestPrice[user]= _price;
        
      
        emit PriceUpdated(_price);
           
        addTo_pA[user]= _pA;
        addTo_pB[user]=_pB;
        addTo_pC[user]= _pC;
        addToPublicSig[user]= _pubSignals;

        addToLatestVerification[user]=getDataVerified(_pA, _pB, _pC, _pubSignals);
   
     
    }

    function getDataVerified(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[6] calldata _pubSignals)  internal view returns(bool){
       return verifier.verifyProof(_pA, _pB, _pC, _pubSignals);

    }

   

    
    function allowUpdation(address _address) external onlyOwner {
        approvedAddresses[_address] = true;
        emit AddressApproved(_address);
    }

    

    
    function reqtLatestPrice() external   {
       address _user= msg.sender;   
        string memory _req= "get Price";
        uint256 chainid= block.chainid;
        emit PriceRequested(_req,_user,chainid);  
    }

    function getLatestPrice(address account) external view returns(uint256){
        
        return addToLatestPrice[account];
    }

    function getLatestVerificationValue(address account) external view returns(bool){
        return addToLatestVerification[account];
    }

    function convertBoolToString(bool input) internal pure returns (string memory) {
    if (input) {
        return "true";
    } else {
        return "false";
    }
    }

    
     
     

    function sendCrossChain(uint64 destinationChainSelector,
        address receiver
        ) external onlyOwnerOrApproved{
                   //uint256 initialGas = gasleft();
        //uint256 gasPrice = tx.gasprice;
        
                 string memory _price= Strings.toString(addToLatestPrice[user]);
                 string memory verification= convertBoolToString(addToLatestVerification[user]);
                 string memory data= string(abi.encodePacked(_price," ",verification));   
    
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

