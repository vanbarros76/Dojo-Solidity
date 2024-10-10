import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { useWeb3React } from '@web3-react/core';
import { InjectedConnector } from '@web3-react/injected-connector';

const injected = new InjectedConnector({
  supportedChainIds: [1, 3, 4, 5, 42],
});

const contractAddress = "YOUR_CONTRACT_ADDRESS_HERE";
const contractABI = [
  "function claimTokens() public",
  "function balanceOf(address) public view returns (uint256)",
  "function TOTAL_SUPPLY() public view returns (uint256)",
  "function REWARD_AMOUNT() public view returns (uint256)",
  "function REWARD_INTERVAL() public view returns (uint256)",
  "function nextClaimTime(address) public view returns (uint256)"
];

function App() {
  const { active, account, library, activate, deactivate } = useWeb3React();

  const [contract, setContract] = useState(null);
  const [totalSupply, setTotalSupply] = useState('');
  const [rewardAmount, setRewardAmount] = useState('');
  const [rewardInterval, setRewardInterval] = useState('');
  const [nextClaimTime, setNextClaimTime] = useState('');

  useEffect(() => {
    if (active && library) {
      const signer = library.getSigner();
      const contract = new ethers.Contract(contractAddress, contractABI, signer);
      setContract(contract);
      updateContractInfo(contract);
    }
  }, [active, library]);

  async function connect() {
    try {
      await activate(injected);
    } catch (ex) {
      console.log(ex);
    }
  }

  async function disconnect() {
    try {
      deactivate();
    } catch (ex) {
      console.log(ex);
    }
  }

  async function claimTokens() {
    if (contract) {
      try {
        const tx = await contract.claimTokens();
        await tx.wait();
        alert("Tokens claimed successfully!");
        updateContractInfo(contract);
      } catch (error) {
        alert(`Failed to claim: ${error.message}`);
      }
    }
  }

  async function updateContractInfo(contract) {
    const totalSupply = await contract.TOTAL_SUPPLY();
    const rewardAmount = await contract.REWARD_AMOUNT();
    const rewardInterval = await contract.REWARD_INTERVAL();
    const nextClaim = await contract.nextClaimTime(account);

    setTotalSupply(ethers.utils.formatEther(totalSupply));
    setRewardAmount(ethers.utils.formatEther(rewardAmount));
    setRewardInterval(`${rewardInterval / 3600} hours`);
    setNextClaimTime(new Date(nextClaim.toNumber() * 1000).toLocaleString());
  }

  return (
    <div className="App">
      <h1>TimedToken Interface</h1>
      {active ? (
        <>
          <p>Connected Account: {account}</p>
          <button onClick={disconnect}>Disconnect</button>
          <button onClick={claimTokens}>Claim Tokens</button>
        </>
      ) : (
        <button onClick={connect}>Connect to MetaMask</button>
      )}
      <div>
        <h3>Contract Info:</h3>
        <p>Total Supply: {totalSupply}</p>
        <p>Reward Amount: {rewardAmount}</p>
        <p>Reward Interval: {rewardInterval}</p>
        <p>Next Claim Time: {nextClaimTime}</p>
      </div>
    </div>
  );
}

export default App;
