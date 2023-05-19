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
      =proposals          :: pending
      executed=proposals               
      con=id
  ==
::  this is the on-chain noun
++  multisig-state  multisig-state:multisig-con
+$  member  (pair (unit address) (unit ship))
::
+$  proposals  (map =hash =proposal)
::  or: (map =hash [=proposal =sigs])
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
  ::  need a load function, on- and off-chain versions of propose&vote
  $%  [%create =address threshold=@ud members=(set member) name=@t]
      [%propose =address multisig=id calls=@ on-chain=? deadline=@ud name=@t]
      [%vote multisig=id =hash aye=? on-chain=? sig=(unit sig)]
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
--