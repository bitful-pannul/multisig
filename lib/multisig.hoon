/-  *multisig, wallet=zig-wallet
:: 
|%
++  enjs
  =,  enjs:format
  |%
  ++  update
    |=  up=^update
    ^-  json
    %+  frond  -.up
    ?-    -.up
        %multisig
      %-  pairs
      :_  ~
      [`@tas`(scot %ux id.up) (enjs-msig msig.up)]
    ::
        %multisig-on
      %-  pairs
      :_  ~
      [`@tas`(scot %ux id.up) (enjs-on-multisig multisig.up)]
    ::
        %multisigs
      %-  pairs
      %+  turn  ~(tap by msigs.up)
      |=  [=id =msig]
      [`@tas`(scot %ux id) (enjs-msig msig)]
    ::
        %proposal
      %-  pairs
      :_   ~
      :-  `@tas`(scot %ux hash.up)
      ::  revise if this is good for frontend 
      ?:  ?=(%.y -.proposal.up)
        (enjs-on-proposal +.proposal.up)
      (enjs-off-proposal +.proposal.up)
    ::
        %vote 
      %-  pairs
      :~  [%id %s (scot %ux id.up)]
          [%hash %s (scot %ux hash.up)]
          [%address %s (scot %ux address.up)]
          [%aye %s (scot %ud aye.up)]           :: fix
      ==
    :: 
        %execute
      %-  pairs
      :~  [%id %s (scot %ux id.up)]
          [%hash %s (scot %ux hash.up)]
      ==
    ::
        %invite
      %-  pairs
      :~  [%id %s (scot %ux id.up)]
          [%ship %s (scot %p ship.up)]
          [%multisig (enjs-multisig multisig.up)]
      ==
    ::
        %invites
      %-  pairs
      %+  turn  ~(tap by invites.up)
      |=  [* =multisig]
      :-  `@tas`(rap 3 (scot %ux 0x0) '/' (scot %p ~zod) ~)
      (enjs-multisig multisig)
    ::
        %denied
      %-  pairs
      :~  [%from %s (scot %p from.up)]
      ==
    ::
        %shared
      %-  pairs
      :~  [%from %s (scot %p from.up)]
          [%address %s (scot %ux address.up)]
      ==
    ::
        %notif
      [%s message.up]
    ==
  ++  enjs-msig
    |=  =msig
    ^-  json
    %-  pairs
    :~  [%name %s name.msig]
        [%members a+(turn ~(tap in members.msig) |=(a=@ux s+(scot %ux a)))]
        [%ships a+(turn ~(tap in ships.msig) ship)]
        [%threshold %s (scot %ud threshold.msig)]
        [%on-pending (enjs-on-pending on-pending.msig)]
        [%off-pending (enjs-off-pending off-pending.msig)]
    ==
  ++  enjs-multisig
    |=  =multisig
    ^-  json
    %-  pairs
    :~  [%name %s name.multisig]
        [%ships a+(turn ~(tap in ships.multisig) ship)]
        [%pending (enjs-off-pending pending.multisig)]
    ==
  ++  enjs-on-multisig
    |=  m=multisig-state:con
    ^-  json
    %-  pairs
    :~  [%members a+(turn ~(tap pn members.m) |=(a=@ux s+(scot %ux a)))]
        [%threshold %s (scot %ud threshold.m)]
        [%executed a+(turn executed.m |=(a=@ux s+(scot %ux a)))]
        [%pending (enjs-on-pending pending.m)]
    ==
  ++  enjs-on-pending
    |=  m=(pmap @ux proposal:con)
    ^-  json
    %-  pairs
    %+  turn  ~(tap py m)
    |=  [hash=@ux =proposal:con]
    [`@tas`(scot %ux hash) (enjs-on-proposal proposal)]
  ++  enjs-on-proposal
    |=  =proposal:con
    ^-  json
    %-  pairs
    :~  [%calls %s (scot %ud (jam calls.proposal))]
        [%votes (enjs-votes votes.proposal)]
        [%ayes %s (scot %ud ayes.proposal)]
        [%nays %s (scot %ud nays.proposal)]
    ==
  ::
  ++  enjs-votes
    |=  v=(pmap @ux ?)
    ^-  json
    %-  pairs
    %+  turn  ~(tap py v)
    |=  [a=@ux aye=?]
    [`@tas`(scot %ux a) %s ?:(aye 'true' 'false')]
  ::
   ++  enjs-off-pending
    |=  m=(map @ux proposal)
    ^-  json
    %-  pairs
    %+  turn  ~(tap by m)
    |=  [hash=@ux =proposal]
    [`@tas`(scot %ux hash) (enjs-off-proposal proposal)]
  ++  enjs-off-proposal
    |=  =proposal
    ^-  json
    %-  pairs
    :~  [%name %s name.proposal]
        [%desc %s desc.proposal]
        [%calls %s (scot %ud (jam calls.proposal))]
        [%deadline %s (scot %ud deadline.proposal)]
        [%sigs (enjs-sigs sigs.proposal)]
    ==
  ++  enjs-sigs
    |=  s=(map @ux *)
    ::  won't pass sigs, if they're here, it's an aye
    ^-  json
    %-  pairs
    %+  turn  ~(tap by s)
    |=  [a=@ux *]
    [`@tas`(scot %ux a) %s 'true']
  --
++  dejs
  =,  dejs:^format
  |%
  ++  action
    |=  jon=json
    ^-  ^action
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~  
        [%create dejs-create]
        [%propose dejs-propose]
        [%vote dejs-vote]
        [%execute dejs-execute]
        ::
        [%find-addys (ot ~[[%ships (as (se %p))]])]
        [%share dejs-share]
        [%load (ot ~[[%multisig (se %ux)]])]
        [%accept (ot ~[[%multisig (se %ux)] [%ship (se %p)]])]
      ==
    ++  dejs-create
      %-  ot
      :~  [%address (se %ux)]
          [%threshold (se %ud)]
          [%ships (as (se %p))]
          [%members (as (se %ux))]
          [%name so]
      ==
    ++  dejs-dist
      ^-  $-(json [to=@ux amount=@ud])
      %-  ot
      :~  [%to (se %ux)]
          [%amount (se %ud)]
      ==
    ++  dejs-propose
      %-  ot
      :~  [%address (se %ux)]
          [%multisig (se %ux)]
          [%calls (se %ud)]   :: jam/cue
          [%on-chain bo]
          [%hash (mu (se %ux))]
          [%deadline (se %ud)]
          [%name so]
          [%desc so]
      ==
    ++  dejs-vote
      %-  ot
      :~  [%address (se %ux)]
          [%multisig (se %ux)]
          [%hash (se %ux)]
          [%aye bo]
          [%on-chain bo]
          [%sig ul]          :: signed in-app
      ==
    ++  dejs-execute
      %-  ot
      :~  [%address (se %ux)]
          [%multisig (se %ux)]
          [%hash (se %ux)]
      ==
    ++  dejs-share
      %-  ot
      :~  [%multisig (se %ux)]
          [%state ul]       :: not from fe 
          [%ship (mu (se %p))]
      ==
    --
  --
--