::  multisig gall app
:: 
::  deploy a multisig contract & data item
/+  *zig-sys-smart
/=  multisig-con  /con/lib/multisig
/*  multisig-jam  %jam  /con/compiled/multisig/jam
|%
::
+$  multisig  
  $:  name=@t
      members=(set member)  
      pending=proposals
      executed=(list hash)    :: storing specific on-chain tx data might lead to mismatches           
      con=id
  ==
++  multisig-state  multisig-state:multisig-con ::  on-chain noun
+$  member  (pair (unit address) (unit ship))
::
+$  proposals  (map =hash =proposal)
+$  sigs  (map address =sig)
::
+$  proposal
  $:  name=@t
      calls=(list call)
      votes=(map address ?)
      =sigs
      deadline=@ud
      ayes=@ud
      nays=@ud
  ==
+$  action
  ::  need a load function, on- and off-chain versions of propose&vote, currently in the same method, mayb separate
  $%  [%create =address threshold=@ud members=(set member) name=@t]
      [%propose =address multisig=id calls=@ on-chain=? hash=(unit hash) deadline=@ud name=@t]
      [%vote =address multisig=id =hash aye=? on-chain=? sig=(unit sig)]
      [%execute =address multisig=id =hash]
      :: 
      [%find-addy to=@p]
      ::  [%invite @p multisig=id]  poke entire thing to them..?
      [%load multisig=id name=@t]
  ==
+$  thread-update
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