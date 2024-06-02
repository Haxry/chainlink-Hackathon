// Purpose: To update the price on Avalanche Fuji C-Chain and send it to Ethereum Mainnet


const contractAddress = "0x5683d5F8A28c86dBfa48464AC51a5C5026bcC8b3"
const contractAddressFuji = "0x9Ed9f443BD1F4d4116579388B46B4e049104efdd"
const contractABI = [
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_ccipSender",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_verifier",
                "type": "address"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "approvedAddress",
                "type": "address"
            }
        ],
        "name": "AddressApproved",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "sender",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "Deposit",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "string",
                "name": "req",
                "type": "string"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "user",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "chainid",
                "type": "uint256"
            }
        ],
        "name": "PriceRequested",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "newPrice",
                "type": "uint256"
            }
        ],
        "name": "PriceUpdated",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "name": "addToLatestPrice",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "name": "addToLatestVerification",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_address",
                "type": "address"
            }
        ],
        "name": "allowUpdation",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "name": "approvedAddresses",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "getLatestPrice",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "getLatestVerificationValue",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "owner",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "reqtLatestPrice",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint64",
                "name": "destinationChainSelector",
                "type": "uint64"
            },
            {
                "internalType": "address",
                "name": "receiver",
                "type": "address"
            }
        ],
        "name": "sendCrossChain",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_price",
                "type": "uint256"
            },
            {
                "internalType": "uint256[2]",
                "name": "_pA",
                "type": "uint256[2]"
            },
            {
                "internalType": "uint256[2][2]",
                "name": "_pB",
                "type": "uint256[2][2]"
            },
            {
                "internalType": "uint256[2]",
                "name": "_pC",
                "type": "uint256[2]"
            },
            {
                "internalType": "uint256[6]",
                "name": "_pubSignals",
                "type": "uint256[6]"
            },
            {
                "internalType": "address",
                "name": "calledBy",
                "type": "address"
            }
        ],
        "name": "updatePriceandZkProof",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

const receiverABI = [
    {
        "inputs": [
            {
                "components": [
                    {
                        "internalType": "bytes32",
                        "name": "messageId",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "uint64",
                        "name": "sourceChainSelector",
                        "type": "uint64"
                    },
                    {
                        "internalType": "bytes",
                        "name": "sender",
                        "type": "bytes"
                    },
                    {
                        "internalType": "bytes",
                        "name": "data",
                        "type": "bytes"
                    },
                    {
                        "components": [
                            {
                                "internalType": "address",
                                "name": "token",
                                "type": "address"
                            },
                            {
                                "internalType": "uint256",
                                "name": "amount",
                                "type": "uint256"
                            }
                        ],
                        "internalType": "struct Client.EVMTokenAmount[]",
                        "name": "destTokenAmounts",
                        "type": "tuple[]"
                    }
                ],
                "internalType": "struct Client.Any2EVMMessage",
                "name": "message",
                "type": "tuple"
            }
        ],
        "name": "ccipReceive",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "router",
                "type": "address"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "router",
                "type": "address"
            }
        ],
        "name": "InvalidRouter",
        "type": "error"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "messageId",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "internalType": "uint64",
                "name": "sourceChainSelector",
                "type": "uint64"
            },
            {
                "indexed": false,
                "internalType": "address",
                "name": "sender",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "string",
                "name": "text",
                "type": "string"
            }
        ],
        "name": "MessageReceived",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "string",
                "name": "req",
                "type": "string"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "user",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "chainid",
                "type": "uint256"
            }
        ],
        "name": "priceRequested",
        "type": "event"
    },
    {
        "inputs": [],
        "name": "requestLatestPrice",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getLastPriceAndZkVerification",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "messageId",
                "type": "bytes32"
            },
            {
                "internalType": "string",
                "name": "text",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "user",
                "type": "address"
            }
        ],
        "name": "getRecentPriceAndVerification",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getRouter",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "name": "hasPendingRequest",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes4",
                "name": "interfaceId",
                "type": "bytes4"
            }
        ],
        "name": "supportsInterface",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "name": "userToData",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];

const privateKey = '2cb2f84172cd4b08f72db79626ffb0ee1672b8b4804569fbd5b7909262741c2f'
let price = 100 * 1e8;


let userAddress = "0x0355B7DCC1Dfab89904bAFA9b39113234DA3f691";
let chainId;
const provider = new ethers.providers.JsonRpcProvider('https://sepolia.infura.io/v3/dd6bf29b25064af9be1bb6a29a1955de');

try {

    async function ShowData() {
        try {

            const wallet = new ethers.Wallet(privateKey, provider);
            const contract = new ethers.Contract(contractAddress, contractABI, wallet)
            try {
                const tx = await contract.updatePriceandZkProof(price, ["0x2ead686faca7ebbab74a2bdbb812c606faa099f2e004ff01b3d2f90d526d958a", "0x2fdd3849f1897514909c566ca64d9eb956f584f4177c7e36d3f818cb3ccd6b50"], [["0x11e09899259a4845d5c025c7f19b2635410c0337288f79d1dd730474dd38cd20", "0x0d116dd0199fe9d750438d64e70d5ecbb2c91a3d9103aae73151f6f29cb9f624"], ["0x05ce4ebd911de5bdee9f7f590f1403a2b1ab13ab95644daa5c223e2b2a2c63e7", "0x1eb58ed60b674ce0c84286d14910b84dd9a60665b78cb824f10e37b14dd9c40a"]], ["0x10328f0478d7e74d2ceb18d14670bc39ba2807d02ddacacc0a1c0ec478aadc70", "0x166a0cbc61ceef4b228b4a7e18c504958a07241cd6e2eb878ea551214ffcf315"], ["0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000"], userAddress);
                console.log("userAddress", userAddress)
                await tx.wait();
                console.log("Price updated")
            } catch (error) {
                console.error("Error:", error);
            }
            try {
                const chainIdFuji = "14767482510784806043";
                const tx2 = await contract.sendCrossChain(chainIdFuji, userAddress);
                await tx2.wait();
                console.log("Price sent to Fuji")
            } catch (error) {
                console.error("Error:", error);
            }
        } catch (error) {
            console.error("Error:", error);
        }

    }

    async function DataProceed() {
        try {
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            const FujiProvider = new ethers.providers.Web3Provider(window.ethereum);


            chainId = await FujiProvider.getNetwork().chainId;


            const signer = FujiProvider.getSigner();
            userAddress = signer.getAddress();
            const contract = new ethers.Contract(contractAddressFuji, receiverABI, signer);
            try {
                const tx = await contract.requestLatestPrice();
                await tx.wait();
                ShowData();
            } catch (error) {
                console.error("Error:", error);
            }
        } catch (error) {
            console.error("Error:", error);
        }

    }

    DataProceed();
    document.getElementById("myButton").addEventListener("click", DataProceed);

} catch (error) {
    console.error("Error:", error);

}



/*async function ShowPrice() {
    const FujiProvider = new ethers.providers.WebSocketProvider(`wss://avalanche-fuji-c-chain-rpc.publicnode.com`);
    const wallet = new ethers.Wallet(privateKey, FujiProvider);
    const contract = new ethers.Contract(contractAddressFuji, receiverABI, wallet);
    const chainId = await FujiProvider.getNetwork().chainId;

    if (chainId == 43113) {
        const tx = await contract.getLastPriceAndZkProof();
        await tx.wait();
        console.log("Price:", tx)
        /*const event = receipt.events.find(event => event.event === 'PriceUpdated');
         if (event) {
             RequestId = event.args.id;
             console.log("Request ID:", RequestId);
 
         } else {
             console.error("Event not found in receipt");
         } */
/*}
}

DataProceed(); */

/* contract.on('RequestVolume', (requestId, volume, event) => {
//     if (requestId == RequestId) {
        const string2 = volume.toString();
        console.log("Volume:", string2);
        provider.removeAllListeners();
    }
})

addEvent(userAddress, RequestId);


}

async function recents() {
    addEvent("0x47D7aaB25647dfd2C8c7ADe6A74162f07c516182", "0xf7226a12427ed3371e86e00b66c380253c8b5d058aa4afd0e4f98019502a21c2")
    addEvent("0x47D7aaB25647dfd2C8c7ADe6A74162f07c516182", "0x5308d0f30024d7d380f528db509c3d69f86e56fbedcd820acc41c68da37f4a2c")
    console.log("sex")

    const userAddress = await wallet.getAddress();
    const events = getEvents(userAddress);
    for (const event of events) {
        const trans = contract.filters.RequestVolume(event);
        const transactions = await contract.queryFilter(trans);
        transactions.forEach((transaction) => {
            const volumereq = transaction.args.volume.toString();
            console.log(event + ":" + volumereq);
        });
    }






    // console.log("tx", tx)

    // contract.on("ChainlinkRequested", (requestId, event) => {
    //   if (requestId == tx) {
    //   console.log("Event detected for specific request ID:", id);
    // console.log(event);
    //  }
    // });

    // contract.on("RequestVolume", (requestId, volume, event) => {
    //     if (requestId == tx) {
    //         console.log(volume);
    //         console.log(event);
    //     }
    // });}

    // async function recents() {
    //     const userAddress = await signer.getAddress();
    //     const events = getEvents(userAddress);
    //     for(const event of events) {
    //        var filter = {
    //             address: contractAddress,
    //             topics: [ethers.utils.id("ChainlinkRequested(bytes32)"), event]
    //         }
    //         const logs = await provider.getLogs(filter);
    //         for(const log of logs) {
    //             console.log("Log:", log);
    //        }
    //     }
    // }


    // async function favorites() {

    // }



    // ShowData();
    recents();
    console.log("ended") */
