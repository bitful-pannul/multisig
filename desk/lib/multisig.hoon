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
      [`@tas`(scot %ux id.up) (enjs-multisig multisig.up)]
    ::
        %multisigs
      %-  pairs
      %+  turn  ~(tap by msigs.up)
      |=  [=id =multisig]
      [`@tas`(scot %ux id) (enjs-multisig multisig)]
    ::
        %proposal
      %-  pairs
      :_   ~
      :-  `@tas`(rap 3 (scot %ux id.up) '/' (scot %ux hash.up) ~)
      (enjs-proposal proposal.up)
    ::
        %vote 
      %-  pairs
      :~  [%id %s (scot %ux id.up)]
          [%hash %s (scot %ux hash.up)]
          [%address %s (scot %ux address.up)]
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
      |=  [i=[@ux @p] =multisig]
      :-  `@tas`(rap 3 (scot %ux -.i) '/' (scot %p +.i) ~)
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
  ++  enjs-multisig
    |=  =multisig
    ^-  json
    %-  pairs
    :~  [%name %s name.multisig]
        [%ships a+(turn ~(tap in ships.multisig) ship)]
        [%pending (enjs-proposals pending.multisig)]
        [%executed (enjs-proposals executed.multisig)]
        [%members a+(turn ~(tap in members.multisig) |=(a=@ux s+(scot %ux a)))]
        [%threshold s+(scot %ud threshold.multisig)]
        [%nonce s+(scot %ud nonce.multisig)]
    ==
  ::
   ++  enjs-proposals
    |=  m=(map @ux proposal)
    ^-  json
    %-  pairs
    %+  turn  ~(tap by m)
    |=  [hash=@ux =proposal]
    [`@tas`(scot %ux hash) (enjs-proposal proposal)]
  ++  enjs-proposal
    |=  =proposal
    ^-  json
    %-  pairs
    :~  [%name %s name.proposal]
        [%desc %s desc.proposal]
        [%calls %s (scot %ud (jam calls.proposal))]
        [%deadline %s (scot %ud deadline.proposal)]
        [%sigs a+(turn ~(tap in ~(key by sigs.proposal)) |=(a=@ux s+(scot %ux a)))]
    ==
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
        [%load (ot ~[[%multisig (se %ux)] [%off (mu dejs-load)]])]
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
    ++  dejs-propose
      %-  ot
      :~  [%address (se %ux)]
          [%multisig (se %ux)]
          [%calls (se %ud)]   :: jam/cue
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
          [%sig ul]          :: signed in-app
      ==
    ++  dejs-execute
      %-  ot
      :~  [%multisig (se %ux)]
          [%hash (se %ux)]
          [%receipt ul]      :: not from fe
      ==
    ++  dejs-share
      %-  ot
      :~  [%multisig (se %ux)]
          [%ship (mu (se %p))]
          [%state ul]        :: not from fe 
      ==
    ++  dejs-load
      %-  ot
      :~  [%name so]
          [%ships (as (se %p))]
      ==
    --
  --
--