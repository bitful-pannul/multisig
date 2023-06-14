import React, { useState, ChangeEvent, FormEvent } from 'react';
import { useWalletStore, AccountSelector } from '@uqbar/wallet-ui';
import { formataddy } from '../constants';
import './styles/Create.scss';
import useMultisigStore from '../store/multisigStore';

interface FormState {
  address: string;
  name: string;
  members: string[];
  ships: string[];
  threshold: string;
}

const Create = () => {
  const addresses = useWalletStore(state => state.accounts.map(account => account.address));
  const setInsetView = useWalletStore(state => state.setInsetView)
  const create = useMultisigStore(state => state.create)
  const [form, setForm] = useState<FormState>({
    address: addresses[0], // default to first address in list
    name: '',
    members: [],
    // @ts-ignore window typings..
    ships: [`~${window.ship}`],
    threshold: '1',
  });

  const [memberInput, setMemberInput] = useState('');
  const [shipInput, setShipInput] = useState('');

  const handleChange = (event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = event.target;
    setForm(prevState => ({
      ...prevState,
      [name]: value
    }));
  };

  const handleMemberAdd = () => {
    setForm(prevState => ({
      ...prevState,
      members: [...prevState.members, memberInput]
    }));
    setMemberInput('');
  };

  const handleShipAdd = () => {
    setForm(prevState => ({
      ...prevState,
      ships: [...prevState.ships, shipInput]
    }));
    setShipInput('');
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    console.log(form);
    await create(formataddy(form.address), form.name, form.ships, form.members, form.threshold);
    await setInsetView('confirm-most-recent')

    // wait for confirm, redirect to home / new multisig.
  };

  return (
    <>
    <div className="create-container">
      <form onSubmit={handleSubmit}>
        <label>
          Use address:
          <select name="address" value={form.address} onChange={handleChange}>
            {addresses.map(address => <option key={address} value={address}>{address}</option>)}
          </select>
        </label>
        <label>
          Name:
          <input type="text" name="name" value={form.name} onChange={handleChange} />
        </label>
        <label>
          Members:
          <div>
            <input type="text" value={memberInput} onChange={event => setMemberInput(event.target.value)} />
            <button type="button" onClick={handleMemberAdd}>Add Member</button>
          </div>
          <ul>
            {form.members.map((member, index) => <li key={index}>{member}</li>)}
          </ul>
        </label>
        <label>
          Ships:
          <div>
            <input type="text" value={shipInput} onChange={event => setShipInput(event.target.value)} />
            <button type="button" onClick={handleShipAdd}>Add Ship</button>
          </div>
          <ul>
            {form.ships.map((ship, index) => <li key={index}>{ship}</li>)}
          </ul>
        </label>
        <label>
          Threshold:
          <input type="text" name="threshold" value={form.threshold} min="1" onChange={handleChange} />
        </label>
        <button type="submit">Create Multisig</button>
      </form>
    </div>
    </>
  );
};

export default Create;
