import { useEffect } from 'react';
import { Link } from 'react-router-dom'
import { AccountSelector, useWalletStore } from '@uqbar/wallet-ui';
import './styles/Navbar.scss'


const Navbar = () => {
  const { selectedAccount, setSelectedAccount, loadingText } = useWalletStore()
  

  return (
    <div className="navbar">
      <div className="navbar-links">
        <Link className="nav-link" to="/">
          /swap
        </Link>
        <Link className="nav-link" to="/pools">
          /pools
        </Link>
        <Link className="nav-link" to="/tokens">
          /tokens
        </Link>
      </div>
      <div className="account-selector-container">
        <AccountSelector
          onSelectAccount={(account) => setSelectedAccount(account)}
        />
      </div>
    </div>

  )
}

export default Navbar