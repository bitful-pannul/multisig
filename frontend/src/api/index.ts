import Urbit from "@urbit/http-api"
const api = new Urbit("", "", "indexer")

// @ts-ignore TODO window typings
api.ship = window.ship
// api.verbose = true;
// @ts-ignore TODO window typings
window.api = api

export function scryNoShip<T>(app: string, path: string): Promise<T | void> {
  return fetch(`/~/scry/${app}${path}.json`)
    .then((r) => {
      if (r.status === 404) {
        throw new Error("Not found")
      } else if (r.status > 399) {
        throw new Error("Scry failed")
      }
      return r.json() as Promise<T>
    })
    .catch()
}

export const getCurrentBlockHeight = async (retryCount: number = 5): Promise<number> => {
  try {
    const response = await fetch('https://api.etherscan.io/api?module=proxy&action=eth_blockNumber');
    const { result } = await response.json();
    
    // convert result from hex to decimal
    return parseInt(result, 16);
  } catch (error) {
    if (retryCount === 0) throw error;

    // wait for a progressively longer period before retrying
    await new Promise(resolve => setTimeout(resolve, 1000 * (6 - retryCount)));
    return getCurrentBlockHeight(retryCount - 1);
  }
};

export default api
