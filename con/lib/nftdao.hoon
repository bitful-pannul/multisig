::  lib/nftdao.hoon  [UQ| DAO]
:: 
::  thoughts: 
::
::
::
::
::
::
/+  *zig-sys-smart
|%
::
+$  state
  $:
    props=(list prop)
    members=(set address)
  ==
::
+$  action
  $%
    [%propose org-id=id calls=(list call)] :: <- specific id?
    [%vote prop-id=id bool=?]
    [%execute prop-id=id sigs=(list [address sig])]
  ==
::
::  matches %social-graph API, but always address->ships
::  nests under contract `event`
::  tags are always absolute, relative to a top-level org
::
+$  nftdao-event
  $%  [%add-tag =tag from=[%address address] to=[%ship @p]]
      [%del-tag =tag from=[%address address] to=[%ship @p]]
      [%nuke-tag =tag]  ::  remove this tag from all edges
      [%nuke-top-level-tag =tag]  :: remove all tags with same first element
  ==
::
::  helpers for producing events
::
++  add-tag
  |=  [=tag =id =ship]
  ^-  (list org-event)
  [%add-tag tag [%address id] [%ship ship]]^~
::
++  del-tag
  |=  [=tag =id =ship]
  ^-  (list org-event)
  [%del-tag tag [%address id] [%ship ship]]^~
::
++  nuke-tag
  |=  =tag
  ^-  (list org-event)
  [%nuke-tag tag]^~
::
++  make-tag
  |=  [=tag =id members=(pset ship)]
  ^-  (list event)
  %+  turn  ~(tap pn members)
  |=  =ship
  [%add-tag tag [%address id] [%ship ship]]
::
::  make all the add-tag events for a new org
::
++  produce-org-events
  |=  [=id =org]
  ^-  (list org-event)
  =/  =tag
    ?~  parent-path.org  /[name.org]
    (snoc parent-path.org name.org)
  ?>  ?=(^ tag)
  %+  weld
    %+  turn  ~(tap pn members.org)
    |=  =ship
    [%add-tag tag [%address id] [%ship ship]]
  ^-  (list org-event)
  %-  zing
  %+  turn  ~(val py sub-orgs.org)
  |=  sub=^org
  (produce-org-events id sub)
::
::  cannot touch name.org
+$  org-mod  $-(org org)
::
::  given an org, modify either that org or sub-org within
::
++  modify-org
  |=  [=org at=tag =org-mod]
  ^+  org
  ?~  at  (org-mod org)
  ?>  =(i.at name.org)
  ?~  t.at  (org-mod org)
  %=    org
      sub-orgs
    %+  ~(put py sub-orgs.org)
      i.t.at
    $(at t.at, org (~(got py sub-orgs.org) i.t.at))
  ==
::
::  given a path, find allowed controllers for sub-org
::
++  valid-controller
  |=  [where=tag =org who=id]
  ^-  ?
  ?:  =(who controller.org)  %.y
  ?~  where  %.n
  ?>  =(i.where name.org)
  ?~  t.where  %.n
  $(where t.where, org (~(got py sub-orgs.org) i.t.where))
--
