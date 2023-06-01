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
++  execute-jold-hash  0x74cb.8490.d479.82bb.e371.8ead.78f0.c68f
::
::  ^-  @ux
::  %-  sham
::  %-  need
::  %-  de-json:html
::  ^-  cord
::  '''
::  [
::    {"calls": [
::      "list",
::      [
::        {"contract": "ux"},
::        {"town": "ux"},
::        {"calldata": [{"p": "tas"}, {"q": "*"}]}
::      ]
::    ]},
::    {"nonce": "ud"},
::    {"deadline": "ud"}
::  ]
::  '''
--