/+  *zig-sys-smart
|%
+$  state
  [members=(pset address) threshold=@ud nonce=@ud]
::
+$  action
  $%  
      [%create threshold=@ud members=(pset address)]
      [%validate our=id sigs=(pmap address sig) deadline=@ud =call]
      [%execute our=id calls=(list call)]
      [%add-member our=id =address]
      [%remove-member our=id =address]
      [%set-threshold our=id new=@ud]
  ==
::
++  execute-jold-hash  0xdb2b.6ff8.6b72.36e6.3642.94f3.f9f9.38dc
::  ^-  @ux
::  %-  sham
::  %-  need
::  %-  de-json:html
::  ^-  cord
::  '''
::  [
::    {"multisig": "ux"},
::    {"call": [
::      {"contract": "ux"},
::      {"town": "ux"},
::      {"calldata": [{"p": "tas"}, {"q": "*"}]}
::    ]},
::    {"nonce": "ud"},
::    {"deadline": "ud"}
::  ]
::  '''
--