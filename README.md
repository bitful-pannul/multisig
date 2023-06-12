## multisig

Used to deploy account abstracted multisigs, create proposals and vote on them off-chain! 

Run tests with `-zig!transaction-sim /=multisig=/tests/contracts/multisig/hoon`

Gall app actions like %create, %propose, %vote and %execute can be found in `sur/multisig.hoon`


Frontend and todo:
- update symlinks in /desk []
- check json updates flow to fe [] 
- store set of tracked assets in gall/%wallet app?
- decode/encode proposals, standard actions (%give %swap?) []


Some things to think about: 
	- wallet signing flow (confirm w/ metamask etc)
	- ships in a multisig, stored in social-graph instead? propagation?
	- instead of messing with nockjs, instead just %text + ream the calls...? 


