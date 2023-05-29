::  multisig gall app [UQ | DAO]
:: 
::  deploy a multisig contract & data item
::
::  off-chain and on-chain data live separately,
::  but are connected by proposal hashes. 
::
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
  $%  [%create =address threshold=@ud ships=(set ship) members=(set address) name=@t]
      [%propose =address multisig=id calls=@ on-chain=? hash=(unit hash) deadline=@ud name=@t desc=@t]
      [%vote =address multisig=id =hash aye=? on-chain=? sig=(unit sig)]
      [%execute =address multisig=id =hash]
      ::
      [%find-addys ships=(set ship)]
      [%share multisig=id state=(unit multisig) ship=(unit ship)]
      [%load multisig=id ship=(unit ship)]
      [%accept multisig=id =ship]
  ==
::
::  combined on/off type for scry/sub updates
+$  msig  
  $:  name=@t
      members=(set address)
      ships=(set ship)
      threshold=@ud
      on-pending=(map hash proposal:con)
      off-pending=(map hash proposal)
  ==
::
+$  update
  $%  [%multisigs msigs=(map id msig)]
      [%multisig =id =msig]
      [%multisig-on =id multisig=multisig-state:con]
      ::
      [%proposal =hash proposal=(each proposal:con proposal)]
      [%vote =id =hash =address aye=?]
      [%execute =id =hash]
      ::
      [%invite =id =ship =multisig]
      [%inivites invites=(map [id ship] multisig)]
      [%denied from=@p]
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