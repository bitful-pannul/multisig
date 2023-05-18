::  multisig gall app
:: 
::  deploy a multisig contract & data item
/+  smart=zig-sys-smart
/*  multisig-jam  %jam  /con/compiled/multisig/jam
|%
++  multisig-code  [- +]:(cue multisig-jam)
++  publish-contract  0x1111.1111
::
+$  multisig  
  $:  =members
      pending=proposals
      =proposals
      name=@t           :: remove?
      con=id:smart
  ==
+$  member  (pair (unit address:smart) (unit ship))
+$  members  (set member)
::
+$  sigs  (map address:smart =sig:smart)
+$  proposals  (map =hash:smart [=proposal =sigs])
::
+$  proposal  :: from con/lib
  $:  calls=(list call:smart)
      votes=(map address:smart ?)
      ayes=@ud
      nays=@ud
  ==
+$  action
  $%  [%create =address:smart threshold=@ud =members name=@t]
      [%vote multisig=id:smart =hash:smart aye=?]
  ==
+$  sig  [v=@ r=@ s=@]
--