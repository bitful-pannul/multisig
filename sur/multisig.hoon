::  multisig gall app [UQ | DAO]
:: 
::  deploy a multisig contract & data item
::
::  account abstraction enabled multisig,
::  exclusively uses off-chain signatures.
::
/-  uqbar=zig-uqbar
/+  *zig-sys-smart
/=  con  /con/lib/multisig  :: on-chain noun type in con
/*  multisig-jam  %jam  /con/compiled/multisig/jam
|%
+$  multisig  
  $:  name=@t
      ships=(set ship)
      pending=proposals
      executed=proposals
      ::  on
      members=(pset address)
      threshold=@ud
      nonce=@ud
  ==
+$  proposals  (map =hash =proposal)
+$  proposal
  $:  name=@t
      desc=@t
      calls=(list call)
      =sigs
      deadline=@ud
  ==
+$  sigs  (map address =sig)
+$  action
  $%  [%create =address threshold=@ud ships=(set ship) members=(set address) name=@t]
      [%propose =address multisig=id calls=@ hash=(unit hash) deadline=@ud name=@t desc=@t]
      [%vote =address multisig=id =hash sig=(unit sig)]
      [%execute multisig=id =hash receipt=(unit [tx=hash sequencer-receipt:uqbar])]
      ::
      :: [%edit multisig=id name=(unit @t) remove/add ships]
      [%find-addys ships=(set ship)]
      [%share multisig=id ship=(unit ship) state=(unit multisig)]
      [%load multisig=id off=(unit [name=@t ships=(set ship)])]
      [%accept multisig=id =ship]
      [%clear-pending multisig=id hash=(unit hash)]
  ==
::
+$  update
  $%  
      [%multisigs msigs=(map id multisig)]
      [%multisig =id =multisig]
      ::
      [%proposal =id =hash =proposal]
      [%vote =id =hash =address] 
      [%execute =id =hash]
      ::
      [%invite =id =ship =multisig]
      [%invites invites=(map [id ship] multisig)]
      [%denied from=@p]
      [%shared from=@p address=@ux]
      [%notif message=@t]
  ==
+$  sig  [v=@ r=@ s=@]
::
++  multisig-code  [- +]:(cue multisig-jam)
++  publish-contract  0x1111.1111
++  execute-jold-hash  0x74cb.8490.d479.82bb.e371.8ead.78f0.c68f
++  execute-json
  %-  need
  %-  de-json:^html
  ^-  cord
   '''
   [
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