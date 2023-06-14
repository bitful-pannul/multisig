import create from "zustand"
import api, { getCurrentBlockHeight} from '../api'
import { handleUpdate, createSubscription } from "./subscriptions"
import { addDecimalDots } from "../constants"

export interface Multisigs {
  [key: string]: Multisig
}

export interface Multisig {
  name: string
  members: string[]
  ships: string[]
  threshold: string  
  nonce: string
  pending: Proposals
  executed: Proposals
}

export interface Proposals {
  [key: string]: Proposal
}

export interface Proposal {
  name: string
  desc: string
  deadline: string        // 
  sigs: string[]          // 
  calls: string           // 
}

export interface Store {
  multisigs: Multisigs
  invites: {}
  init: () => Promise<void>
  create: ( address: string, name: string,  ships: string[], members: string[], threshold: string,) => Promise<void>
}

const useMultisigStore = create<Store>((set, get) => ({
  multisigs: {},
  invites: {},
  init: async () => {
    await api.subscribe(createSubscription('multisig', '/updates', handleUpdate(get, set)));
  },
  create: async ( address: string, name: string, ships: string[], members: string[], threshold: string,) => {
    // or just pass in json from the component itself?
    const jon = {
      create: {
        address,
        threshold,
        ships,
        members,
        name
      }
    }
    console.log('poke json', jon)
    const res = await api.poke({ app: 'multisig', mark: 'multisig-action', json: jon })
    console.log('CREATE res: ', res)
  },
  }))

export default useMultisigStore
