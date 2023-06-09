/-  *multisig, indexer=zig-indexer, wallet=zig-wallet, uqbar=zig-uqbar
/+  sig=zig-sig, merk, eng=zig-sys-engine, m=multisig, default-agent, dbug, verb
|%
+$  state-0
  $:  %0
      msigs=(map @ux multisig)
      invites=(map [@ux @p] multisig)
      :: pending tx:s 
      pending-m=(unit [name=@t ships=(set ship)])
      pending-i=(map [@ux @p] multisig)
      :: trackers w/ orgs integration? 
  ==
+$  card  card:agent:gall
--
=|  state-0
=*  state  -
=<
%-  agent:dbug
^-  agent:gall
%+  verb  &
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
    hc    ~(. +> [bowl ~])
::
++  on-init
  :_  this(state *_state)
  :_  ~
  watch-indexer:hc
++  on-save  !>(state)
++  on-load
  |=  =vase
  ^-  (quip card _this)
  :_  this(state !<(state-0 vase))
  :_  ~
  watch-indexer:hc
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
    ?+    mark  !!
        %multisig-action
      (handle-poke:hc !<(action vase))
        %wallet-update
      (handle-wallet-update:hc !<(wallet-update:wallet vase))
        %uqbar-share-address
      (handle-address-share:hc !<(share-address:uqbar vase))
      ::
    ==
  [cards this]
  --
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  =(src our):bowl
  ?+    path  ~|("watch to erroneous path" !!)
      [%updates ~]
    :_  this
    :~
      [%give %fact ~ %multisig-update !>(`update`[%multisigs msigs])]
      [%give %fact ~ %multisig-update !>(`update`[%invites invites])]
    ==
  ==
++  on-agent  
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%watch-batch ~]
    ?.  ?=(%fact -.sign)
      ?:  ?=(%kick -.sign)
        ::  attempt to re-sub
        [[watch-indexer:hc ~] this]
      (on-agent:def wire sign)
    =/  upd  !<(update:indexer q.cage.sign)
    ?.  ?=(%batch-order -.upd)  `this
    :-  ~
    =-  this(msigs.state -, pending-i ~)
    ::  update all msigs, then verify invites
    =/  up=(map @ux multisig)
      %-  ~(urn by msigs)
      |=  [=id =multisig]
      ?~  m=(get-multisig:hc id)
        multisig
      u.m
    =-  (~(gas by up) -)
    %+  murn  ~(tap by pending-i)
      |=  [[=id =ship] =multisig]
      ?~  msig=(get-multisig:hc id)
        ~
      :-  ~
      :-  id
      %=  u.msig
        name     name.multisig
        ships    ships.multisig
        pending  pending.multisig
      ==
  ==
++  on-leave  on-leave:def
++  on-peek   handle-scry:hc
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|_  [=bowl:gall cards=(list card)]
::
++  handle-poke
  |=  act=action
  ^-  (quip card _state)
  ?-    -.act
      %create
    ?>  =(src our):bowl
    ::  get id of multisig before creating it.
    =+  con=(hash-pact:eng 0x0 address.act 0x0 multisig-code)
    =+  id=(hash-data:eng con con 0x0 0)
    =+  [name.act (~(put in ships.act) our.bowl)]
    :_  state(pending-m `-)  :_  ~
    %-  generate-tx
    :*  `[%multisig /create/(scot %ux id)]  
        address.act  publish-contract  0x0
        :*  %deploy-and-init  
            mutable=%.n
            multisig-code
            interface=~
            :+  %create
              threshold.act
            (make-pset ~(tap in members.act))
    ==  ==
  ::
      %propose
    =+  calls=;;((list call) (cue calls.act))
    =+  m=(~(got by msigs) multisig.act)
    ?:  =(our src):bowl
      ::  off-chain proposal, poke ships 
      =/  =typed-message  
        :+  (need (multisig-source multisig.act))
          execute-jold-hash
        [calls (add 1 (need (nonce multisig.act))) deadline.act]
      ::
      =/  =hash  (shag:merk typed-message)
      :-  %+  murn  ~(tap in ships.m)
        |=  =ship
        ?:  =(ship our.bowl)  ~
        :-  ~
        :*  %pass   /poke-proposal
            %agent  [ship %multisig]
            %poke   %multisig-action
            !>  ^-  action
            :*  %propose  
                address.act
                multisig.act
                calls.act
                `hash
                deadline.act
                name.act
                desc.act
        ==  ==
      =-  state(msigs (~(put by msigs) multisig.act -))
      =-  m(pending (~(put by pending.m) hash -))
      ^-  proposal
      [name.act desc.act calls ~ deadline.act]
    ::  someone is poking us with off-chain proposal,  
    ::  what if my off-chain ships are outdated? 
    ::  ?>  (~(has in ships.m) src.bowl)  
    ::  solution: always sign first proposal, verify
    =+  (~(get by pending.m) (need hash.act))
    ?^  -  `state
    :-  :_  ~
    %-  give-update
      :^    %proposal
          multisig.act  
        (need hash.act)
      [name.act desc.act calls ~ deadline.act] 
    =-  state(msigs (~(put by msigs) multisig.act -))
    =-  m(pending (~(put by pending.m) (need hash.act) -))
    [name.act desc.act calls ~ deadline.act]
  :: 
      %execute
    =+  m=(~(got by msigs) multisig.act)
    =+  con=(need (multisig-source multisig.act))
    =/  prop=proposal  (~(got by pending.m) hash.act)
    ?:  =(our src):bowl
      ::  optional, veriff sigs off-chain?
      :_  state
      :_  ~
      :*  %pass   /execute
          %agent  [our.bowl %uqbar]
          %poke   %wallet-poke
          !>  ^-  wallet-poke:wallet
          :*  %unsigned-transaction
              `[%multisig /execute/(scot %ux multisig.act)/(scot %ux hash.act)]
              con
              0x0
              :-  %noun
              :*  %validate
                  multisig.act
                  sigs.prop
                  deadline.prop
                  (format-calldata multisig.act con calls.prop)
      ==  ==  ==
    ::  someone executed a proposal, verify receipt & ingest.
    ?~  receipt.act  !!
    =+  [ship-sig uqbar-sig position transaction output]:u.receipt.act
    ?>  (verify-seq-receipt -) 
    =/  =action:^con
      ;;(action:^con calldata.transaction.u.receipt.act)
    ::  sneaky seq-receipt attack possible with malformed nonce?
    =/  msig=state:^con
      =+  (got:big:eng modified.output.u.receipt.act multisig.act)
      ;;(state:^con ?>(?=(%& -.-) noun.p.-))
    ::  
    ?>  ?&  ?=(%validate -.action)
            =([%execute multisig.act calls.prop] calldata.call.action)
        ==
    =+  %=  m
          members    members.msig
          threshold  threshold.msig
          nonce      nonce.msig
          pending    (~(del by pending.m) hash.act)
          executed   (~(put by executed.m) hash.act prop)
        ==
    :_  state(msigs (~(put by msigs) multisig.act -))
    :-  (give-update [%execute multisig.act hash.act])
    :-  (give-update [%multisig multisig.act -])
    ~
  ::
      %vote
    =+  m=(~(got by msigs) multisig.act)
    =+  con=(need (multisig-source multisig.act))
    =/  prop=proposal  (~(got by pending.m) hash.act)
    ?:  =(our src):bowl
      ::  vote on off-chain proposal. 
      ::  sign-message, then poke to ships.
      :_  state  :_  ~
      :*  %pass   /sign
          %agent  [our.bowl %uqbar]
          %poke   %wallet-poke
          !>  ^-  wallet-poke:wallet
          :*  %sign-typed-message
            :-  ~  :-  %multisig
            %+  weld  /sign-vote
            /(scot %ux multisig.act)/(scot %ux hash.act)/(scot %ux address.act)
            from=address.act
            domain=(need (multisig-source multisig.act))
            type=execute-json
            :+  calls.prop
              (add 1 (need (nonce multisig.act)))
            deadline.prop
      ==  ==
    ::  someone voted
    ?~  sig.act  !!
    ?>  (uqbar-validate:sig address.act hash.act u.sig.act)
    :-  :_  ~
    (give-update [%vote multisig.act hash.act address.act])
    =-  state(msigs (~(put by msigs) multisig.act -))
    =-  m(pending (~(put by pending.m) hash.act -))
    %=  prop
      sigs  (~(put by sigs.prop) address.act u.sig.act)
    ==
  :: 
      %load
    ?>  =(our src):bowl
    ::  scry out multisig and add to our state/tracked
    =+  msig=(get-multisig multisig.act)
    ?~  msig  !!
    =:  name.u.msig   ?~(off.act name.u.msig name.u.off.act)
        ships.u.msig  ?~(off.act ships.u.msig ships.u.off.act)
        ships.u.msig  (~(put in ships.u.msig) our.bowl) 
    ==
    :-  ~
    state(msigs (~(put by msigs) multisig.act u.msig))
  ::
      %share
    ::  is a %request poke necessary?
    ?:  =(our src):bowl
      ::  us inviting someone
      =+  m=(~(got by msigs) multisig.act)
      :_  =-  state(msigs (~(put by msigs) multisig.act -))
          m(ships (~(put in ships.m) (need ship.act)))
      :_  ~
      :*  %pass   /share
          %agent  [(need ship.act) %multisig]
          %poke   %multisig-action
          !>(`action`[%share multisig.act ~ `m])
      ==
    ::  someone inviting us 
    ?~  state.act  `state 
    :_  state(invites (~(put by invites) [multisig.act src.bowl] u.state.act))
    :_  ~
    %-  give-update
    :^    %invite
        multisig.act
      src.bowl
    u.state.act
  ::
      %accept
    ?>  =(our src):bowl
    =+  m=(~(got by invites) [multisig.act ship.act])  
    ::  =.  might be unnecessary, but helps propagation
    =.  ships.m  (~(put in ships.m) ship.act)
    =.  ships.m  (~(put in ships.m) our.bowl)
    ?~  msig=(get-multisig multisig.act)
      :-  :_  ~
      %-  give-update  
      [%notif 'did not find on-chain multisig, waiting for next batch.']
      %=  state
        pending-i  (~(put by pending-i) [multisig.act ship.act] m)
        invites    (~(del by invites) [multisig.act ship.act])
      ==
    :-  :_  ~
    (give-update [%multisig multisig.act m])
    %=  state
      msigs       (~(put by msigs) multisig.act m)
      invites   (~(del by invites) [multisig.act ship.act])
    ==
  :: 
      %clear-pending
    =+  m=(~(got by msigs) multisig.act)
    ?~  hash.act
      :-  ~
      state(msigs (~(put by msigs) multisig.act m(pending ~)))
    :-  ~
    =-  state(msigs (~(put by msigs) multisig.act -))
        m(pending (~(del by pending.m) u.hash.act))
  ::
      %find-addys
    ::  perhaps vice versa could scry out address=>ship from social graph
    :_  state
    %+  murn  ~(tap in ships.act)
      |=  =ship
      ?:  =(ship our.bowl)  ~
      :-  ~
      :*  %pass   /uqbar-address-from-ship
          %agent  [ship %wallet]
          %poke   uqbar-share-address+!>([%request %multisig])
      == 
  ==
::
++  handle-wallet-update
  |=  update=wallet-update:wallet
  ^-  (quip card _state)
  ?+    -.update  `state
      %sequencer-receipt
    ?>  ?=(^ origin.update)
    ?+    q.u.origin.update  !!
        [%create @ ~]
      ?.  =(%0 errorcode.output.update)
        `state(pending-m ~)
      ?~  pending-m  `state
      =*  path  q.u.origin.update
      =+  id=(slav %ux i.t.path)
      ::  =/  =action:con
      ::    ;;(action:con calldata.transaction.update)
      =/  m=state:con
        =+  (got:big:eng modified.output.update id)
        ;;(state:con ?>(?=(%& -.-) noun.p.-))
      ::
      =/  msig
        :*  name.u.pending-m
            ships.u.pending-m
            ~
            ~
            members.m
            threshold.m
            nonce.m
        ==
      :-  :_  
      %+  murn  ~(tap in ships.u.pending-m)
      |=  =ship
      ?:  =(ship our.bowl)  ~
      :-  ~
      :*  %pass   /share
          %agent  [ship %multisig]
          %poke   %multisig-action
          !>(`action`[%share id ~ `msig])
      == 
      (give-update [%multisig id msig])
      %=  state
        msigs       (~(put by msigs) id msig)
        pending-m  ~
      ==
    ::
        [%execute @ @ ~]
      ?.  =(%0 errorcode.output.update)
        `state
      =*  path  q.u.origin.update
      =+  id=(slav %ux i.t.path)
      =+  hash=(slav %ux i.t.t.path)
      =/  m=state:con
        =+  (got:big:eng modified.output.update id)
        ;;(state:con ?>(?=(%& -.-) noun.p.-))
      =/  msig       (~(got by msigs) id)
      =/  =proposal  (~(got by pending.msig) hash)
      ::
      =:  members.msig    members.m
          threshold.msig  threshold.m
          nonce.msig      nonce.m
          executed.msig   (~(put by executed.msig) hash proposal)
          pending.msig    (~(del by pending.msig) hash)
      ==
      :_  state(msigs (~(put by msigs) id msig))
      :-  (give-update [%execute id hash])
      :-  (give-update [%multisig id msig])
      %+  murn  ~(tap in ships.msig)
          |=  =ship
          ?:  =(our.bowl ship)  ~
          :-  ~
          :*  %pass   /share-executed
              %agent  [ship %multisig]
              %poke   %multisig-action
              !>  ^-  action
              :^    %execute
                  id
                hash
              =+  [ship-sig uqbar-sig position transaction output]:update
              `[hash.update -]
          ==
    ==
  ::
      %signed-message
    ?>  ?=(^ origin.update)
    ::  remove ?+
    ?+    q.u.origin.update  !!
        [%sign-vote @ @ @ ~]   :: typed paths how
      =*  path  q.u.origin.update
      =+  id=(slav %ux i.t.path)
      =+  hash=(slav %ux i.t.t.path)
      =+  address=(slav %ux i.t.t.t.path)
      =/  =multisig  (~(got by msigs) id)
      =/  =proposal  (~(got by pending.multisig) hash)
      ::
      :_  =-  state(msigs (~(put by msigs) id -))
          =-  multisig(pending (~(put by pending.multisig) hash -))
              proposal(sigs (~(put by sigs.proposal) address sig.update))
      :-  (give-update [%vote id hash address])
      %+  murn  ~(tap in ships.multisig)
        |=  =ship
        ?:  =(our.bowl ship)  ~
        :-  ~
        :*  %pass   /vote
            %agent  [ship %multisig]
            %poke   %multisig-action
            !>  ^-  action
            :*  %vote
                address
                id
                hash
                `sig.update
        ==  ==
    ==
  ==
::
++  handle-scry
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  !!
      [%x %multisigs ~]
    ``multisig-update+!>(`update`[%multisigs msigs])
  ::
      [%x %multisig @ ~]
    =+  id=(slav %ux i.t.t.path)
    =+  (~(got by msigs) id)
    ``multisig-update+!>(`update`[%multisig id -])
  ::
      [%x %proposal @ @ ~]
    =+  id=(slav %ux i.t.t.path)
    =+  hash=(slav %ux i.t.t.t.path)
    =/  =multisig  (~(got by msigs) id)
    =+  (~(got by pending.multisig) hash)
    ``multisig-update+!>(`update`[%proposal id hash -])
  ::
      [%x %invites ~]
    ``multisig-update+!>(`update`[%invites invites])
  ::
      [%x %existing @ ~]
    ::  check for existing multisig deployed by address
    =+  address=(slav %ux i.t.t.path)
    =+  con=(hash-pact:eng 0x0 address 0x0 multisig-code)
    =+  id=(hash-data:eng con con 0x0 0)
    =+  (need (get-multisig id))
    ``multisig-update+!>(`update`[%multisig id -])
  ==
::
++  nonce
  |=  =id
  ?~  noun=(multisig-noun id)
    ~
  `nonce:(need noun)
::
++  multisig-item
  |=  =id
  ^-  (unit data)
  =/  up
    .^  update:indexer  %gx
      (scot %p our.bowl)  %uqbar  (scot %da now.bowl)
      /indexer/newest/item/(scot %ux 0x0)/(scot %ux id)/noun
    ==
  ?~  up  ~
  ?>  ?=(%newest-item -.up)
  =+  item=item.up
  ?>  ?=(%.y -.item)
  ?>  =(%multisig label.p.item)
  `+.item
::
++  multisig-source
  |=  =id
  ?~  item=(multisig-item id)
    ~
  `source:(need item)
::
++  multisig-noun
  |=  =id
  ^-  (unit state:con)
  ?~  item=(multisig-item id)
    ~
  `;;(state:con noun:u.item)
::
++  get-multisig
  |=  =id
  ^-  (unit multisig)
  ?~  noun=(multisig-noun id)
    ~  :: no multisig found on-chain
  ?~  off=(~(get by msigs) id)
    :-  ~
    ::  revise where this is used.
    ['no name' ~ ~ ~ [members threshold nonce]:u.noun]
  :-  ~
  :*  name.u.off
      ships.u.off
      pending.u.off
      executed.u.off
      members.u.noun
      threshold.u.noun
      nonce.u.noun
  == 
::
++  format-calldata
  |=  [=id con=id calls=(list call)]
  :+  con
    0x0
  :+  %execute
    id
  calls
::
++  verify-seq-receipt
  |=  =sequencer-receipt:uqbar
  =/  known-sequencer
    .^  (unit (pair address ship))  %gx
        (scot %p our.bowl)  %uqbar  (scot %da now.bowl)
        /sequencer-on-town/(scot %ux town.transaction.sequencer-receipt)/noun
      ==
    ?~  known-sequencer
      ~&  >>>  "multisig: failed to get sequencer info from %uqbar"
    %.n
    ?.  =(q.u.known-sequencer q.ship-sig.sequencer-receipt)
      ~&  >>>  "multisig: received receipt from unknown sequencer"
      %.n
    ~|  "multisig: received invalid signature on sequencer receipt!"
    =+  (sham |3:sequencer-receipt)
    ?>  (validate:sig our.bowl ship-sig.sequencer-receipt - now.bowl)
    ?>  (uqbar-validate:sig p.u.known-sequencer - uqbar-sig.sequencer-receipt)
    %.y
::
++  generate-tx
  |=  [=origin:wallet from=@ux con=@ux town=@ux noun=*] 
  :*  %pass   /execute
      %agent  [our.bowl %uqbar]
      %poke   %wallet-poke
      !>  ^-  wallet-poke:wallet
      :*  %transaction
          origin
          from
          con
          town
          [%noun noun]
  ==  ==
::
++  give-update
  |=  =update
  ^-  card
  :*  %give  %fact
      ~[/updates]
      %multisig-update
      !>  ^-  ^update
      update
  ==
++  watch-indexer
  ^-  card
  =-  [%pass /watch-batch %agent [our.bowl %uqbar] %watch -]
      /indexer/multisig/batch-order/(scot %ux 0x0)
::
++  handle-address-share
  |=  share=share-address:uqbar
  ^-  (quip card _state)
  :_  state  :_  ~
  ?-    -.share
      %request  !!
      %deny
    ::  surface this
    :^    %give
        %fact
      ~[/updates]
    multisig-update+!>(`update`[%denied src.bowl])
  ::
      %share
    :^    %give  
        %fact
      ~[/updates]
    multisig-update+!>(`update`[%shared src.bowl address.share])
  ==
--
