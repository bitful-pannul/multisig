import React from 'react';
import useMultisigStore from '../store/multisigStore';
import { Link } from 'react-router-dom';
import './styles/Home.scss';

const Home = () => {
  const multisigs = useMultisigStore(state => state.multisigs);

  return (
    <div className="home-container">
      <h1 className="header">Your Multisigs</h1>
      <div className="multisigs-list">
        {Object.entries(multisigs).map(([address, multisig]) => (
          <Link key={address} to={`/multisig/${address}`} className="multisig-link">
            <div className="multisig">
              <h2 className="multisig-name">{multisig.name}</h2>
              <p className="multisig-address">{address}</p>
              <p className="multisig-members">Members: {multisig.members.length}</p>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
};

export default Home;