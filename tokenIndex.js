document.getElementById('submitButton').addEventListener('click', async function () {
    const mintAmount = document.getElementById('mintAmount').value; // Get the mint amount
    const etherAmount = document.getElementById('etherAmount').value; // Get the Ether amount

    // Call the function to interact with the smart contract
    await depositAndMint(mintAmount, etherAmount);
});

document.getElementById('burnButton').addEventListener('click', async function () {
    const redeemAmount = document.getElementById('redeemAmount').value; // Get the redeem amount

    // Call the function to interact with the smart contract
    await redeemAndBurn(redeemAmount);
});

async function depositAndMint(mintAmount, etherAmount) {
    if (typeof window.ethereum !== 'undefined') {
        try {
            // Request account access
            await window.ethereum.request({ method: 'eth_requestAccounts' });

            // Initialize ethers.js
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();

            // The address of the smart contract
            const contractAddress = '0xe748705d2d97Ee760Bb3b0F66ecbC9D781D041c6';
            const abi = [
                "function depositAndmint(uint256 amountToMint) external payable"
            ];

            // Create a contract instance
            const contract = new ethers.Contract(contractAddress, abi, signer);

            // Convert the Ether amount to Wei
            let etherAmountInWei;
            try {
                let mintAmountInWei = ethers.utils.parseEther(etherAmount.toString());
                etherAmountInWei = ethers.BigNumber.from(mintAmountInWei);
            } catch (error) {
                console.error('Invalid Ether amount:', error);
                return;
            }

            // Validate and convert the mint amount to a BigNumber
            let mintAmountBN;
            try {
                mintAmountBN = ethers.BigNumber.from(mintAmount);
            } catch (error) {
                console.error('Invalid mint amount:', error);
                return;
            }

            // Send the transaction
            const transaction = await contract.depositAndmint(mintAmountBN, { value: etherAmountInWei });
            console.log('Transaction sent:', transaction);
        } catch (error) {
            console.error('Error sending transaction:', error);
        }
    } else {
        console.error('No Ethereum provider detected. Install MetaMask or another wallet extension.');
    }
}

async function redeemAndBurn(redeemAmount) {
    if (typeof window.ethereum !== 'undefined') {
        try {
            // Request account access
            await window.ethereum.request({ method: 'eth_requestAccounts' });

            // Initialize ethers.js
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();

            // The address of the smart contract
            const contractAddress = '0xe748705d2d97Ee760Bb3b0F66ecbC9D781D041c6';
            const abi = [
                "function redeemAndBurn(uint256 amountToRedeem) external"
            ];

            // Create a contract instance
            const contract = new ethers.Contract(contractAddress, abi, signer);

            // Validate and convert the redeem amount to a BigNumber
            let redeemAmountBN;
            try {
                redeemAmountBN = ethers.BigNumber.from(redeemAmount);
            } catch (error) {
                console.error('Invalid redeem amount:', error);
                return;
            }

            // Send the transaction
            const transaction = await contract.redeemAndBurn(redeemAmountBN);
            console.log('Transaction sent:', transaction);
        } catch (error) {
            console.error('Error sending transaction:', error);
        }
    } else {
        console.error('No Ethereum provider detected. Install MetaMask or another wallet extension.');
    }
}
