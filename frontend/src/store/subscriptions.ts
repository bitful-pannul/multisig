import { GetState, SetState } from "zustand";
import { SubscriptionRequestInterface } from "@urbit/http-api"
import { Store } from "./multisigStore";


export const handleUpdate = (get: GetState<Store>, set: SetState<Store>) => async (update: any) => {
  console.log('MULTISIG UPDATE: ', update)

  if ('multisigs' in update) {
    const multisigs = update.multisigs
    set({ multisigs })
  }

  if ('invites' in update) {
    const invites = update.invites
    set({ invites })
  }
}

export function createSubscription(app: string, path: string, e: (data: any) => void): SubscriptionRequestInterface {
  const request = {
    app,
    path,
    event: e,
    err: () => console.warn('SUBSCRIPTION ERROR'),
    quit: () => {
      throw new Error('subscription clogged')
    }
  }
  // TODO: err, quit handling (resubscribe?)
  return request
}