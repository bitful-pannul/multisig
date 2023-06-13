import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import useMultisigStore from '../store/multisigStore';
import './styles/Proposal.scss';
import { getCurrentBlockHeight } from '../api';
import { removeDots } from '../constants';

const Proposal = () => {
  const { address, hash } = useParams<{ address: string, hash: string }>();
  const multisigs = useMultisigStore(state => state.multisigs);
  const multisig = multisigs[address ? address : ''];
  const proposal = {...multisig.pending[hash ? hash : ''], ...multisig.executed[hash ? hash : '']};
  
  // State to hold the estimated deadline
  const [deadline, setDeadline] = useState<Date | null>(null);

  useEffect(() => {
    const estimateDeadline = async () => {
      const currentBlockNumber = await getCurrentBlockHeight();
      const futureBlockNumber = parseInt(removeDots(proposal.deadline));
      const averageBlockTime = 15; // 15 seconds

      const blocksToGo = futureBlockNumber - currentBlockNumber;
      const estimatedSecondsToGo = blocksToGo * averageBlockTime;

      // Create a Date object representing the estimated deadline time
      const estimatedDeadline = new Date(Date.now() + estimatedSecondsToGo * 1000);
      setDeadline(estimatedDeadline);
    };

    estimateDeadline();
  }, []);

  return (
    <div className="proposal-container">
      <h1>{proposal.name} - {hash}</h1>
      <p>Description: {proposal.desc}</p>
      <p>Votes: {proposal.sigs.length}</p>
      {deadline && <h2>Deadline: Block {proposal.deadline} (~ {deadline.toString()})</h2>} {/* Display the estimated deadline */}
      <h2>Calls</h2>
      {/* Render your calls here */}
    </div>
  );
};

export default Proposal;
