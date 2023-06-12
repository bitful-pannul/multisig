import create from "zustand"
import api, { getCurrentBlockHeight} from '../api'
import { handleUpdate, createSubscription } from "./subscriptions"
import { addDecimalDots } from "../constants"

export interface Store {
  test: {}
  init: () => Promise<void>
}

const useMultisigStore = create<Store>((set, get) => ({
  test: {},
  init: async () => {
    await api.subscribe(createSubscription('multisig', '/updates', handleUpdate(get, set)));
  },
  }))

export default useMultisigStore
