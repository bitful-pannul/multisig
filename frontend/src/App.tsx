import React, { useEffect } from 'react';
import { BrowserRouter, Routes, Route, Link } from "react-router-dom";
import { AccountSelector, useWalletStore } from '@uqbar/wallet-ui';
import { Navbar } from './components'
import './App.scss'
import useMultisigstore from './store/multisigStore';

function App() {
  const initWallet = useWalletStore(state => state.initWallet)
  const init  = useMultisigstore(state => state.init)
  

  useEffect(() => {
    (async () => {
      init()
      initWallet({ prompt: true })
    })()
  }, [])
  
  return (
    <BrowserRouter basename={'/apps/multisig'}>
      <Navbar />
      <Routes>
        <Route path="/" element={<div>yes henlo</div>} />
        <Route
          path="*"
          element={
            <main style={{ padding: "1rem" }}>
              <p>There's nothing here!</p>
            </main>
          }
        />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
