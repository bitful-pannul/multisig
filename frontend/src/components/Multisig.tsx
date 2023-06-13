import React from 'react';
import useMultisigStore from '../store/multisigStore';
import { Link, useParams, useNavigate } from 'react-router-dom';
import './styles/Multisig.scss';

const Multisig = () => {
  const { address } = useParams<{ address: string }>();
  const multisigs = useMultisigStore(state => state.multisigs);
  const multisig = multisigs[address ? address : ''];
  
  const navigate = useNavigate();

  return (
    <div className="multisig-container">
      <h1 className="header">{multisig.name} - {address}</h1>
      <p className="threshold">Threshold: {multisig.threshold}/{multisig.members.length}</p>
      <div className="ship-container">
        <h2 className="ships-header">Ships</h2>
        <ul className="ships-list">
          {multisig.ships.map((ship, index) => (
            <li key={index}>{ship}</li>
          ))}
        </ul>
        <button className="add-ship-button" onClick={() => console.log("Add ship")}>Add Ship</button>
      </div>
      <h2 className="members-header">Members</h2>
      <ul className="members-list">
        {multisig.members.map((member, index) => (
          <li key={index}>{member}</li>
        ))}
      </ul>
      <button className="add-member-button" onClick={() => console.log("Add member")}>Add Member</button>
      <button className="create-proposal-button" onClick={() => console.log("Create proposal")}>Create Proposal</button>
      <h2 className="proposals-header">Pending Proposals</h2>
      <div className="proposals-list">
        {Object.entries(multisig.pending).map(([proposalHash, proposal]) => (
          <div className="proposal" key={proposalHash} onClick={() => navigate(`/${address}/proposal/${proposalHash}`)}>
            <h3>{proposal.name}</h3>
            <p>{proposal.desc}</p>
            <progress max={parseInt(multisig.threshold)} value={proposal.sigs.length}></progress>
            <p>Votes: {proposal.sigs.length}</p>
          </div>
        ))}
      </div>
      <h2 className="proposals-header">Executed Proposals</h2>
      <div className="proposals-list">
        {Object.entries(multisig.executed).map(([proposalHash, proposal]) => (
          <div className="proposal" key={proposalHash} onClick={() => navigate(`/${address}/proposal/${proposalHash}`)}>
            <h3>{proposal.name}</h3>
            <p>{proposal.desc}</p>
            <progress max={parseInt(multisig.threshold)} value={proposal.sigs.length}></progress>
            <p>Votes: {proposal.sigs.length}</p>
          </div>
        ))}
      </div>
    </div>
  );
};



  
  export default Multisig;
  