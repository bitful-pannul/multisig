::  multisig gall app [UQ | DAO]
:: 
::  deploy a multisig contract & data item
::
::  off-chain and on-chain data live separately,
::  but are connected by proposal hashes. This prevents conflicts. 
::  note, all multisig contracts (currently) have the same address.
/+  *zig-sys-smart
/=  con  /con/lib/multisig  :: on-chain types in con
/*  multisig-jam  %jam  /con/compiled/multisig/jam
|%
::  off-chain [ALL]
+$  multisig  
  $:  name=@t
      ships=(set ship)
      pending=proposals
  ==
+$  proposals  (map =hash =proposal)
::
+$  proposal
  $:  name=@t
      desc=@t
      calls=(list call)
      =sigs
      deadline=@ud
  ==
+$  sigs  (map address =sig)
+$  action
  ::  need a load function, on- and off-chain versions of propose&vote, currently in the same method, mayb separate
  ::  now separate testing
  $%  [%create =address threshold=@ud ships=(set ship) members=(set address) name=@t]
      [%find-addys ships=(set ship)]
      :: 
      [%propose =address multisig=id calls=@ on-chain=? hash=(unit hash) deadline=@ud name=@t desc=@t]
      [%vote =address multisig=id =hash aye=? on-chain=? sig=(unit sig)]
      [%execute =address multisig=id =hash]
      ::  [%invite @p multisig=id]  poke entire thing to them..?
      [%load multisig=id name=@t]  :: src=@p?
  ==
+$  update
  $%  [%denied from=@p]
      [%shared from=@p address=@ux]
  ==
+$  sig  [v=@ r=@ s=@]
::
++  multisig-code  [- +]:(cue multisig-jam)
++  publish-contract  0x1111.1111
++  execute-jold-hash  0x1bdb.45ec.612a.7371.4ce8.f462.0108.5ab7
++  execute-json
  %-  need
  %-  de-json:^html
  ^-  cord
  '''
  [
    {"multisig": "ux"},
    {"calls": [
      "list",
      [
        {"contract": "ux"},
        {"town": "ux"},
        {"calldata": [{"p": "tas"}, {"q": "*"}]}
      ]
    ]},
    {"nonce": "ud"},
    {"deadline": "ud"}
  ]
  '''
--