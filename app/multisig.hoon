/-  *multisig, indexer=zig-indexer, wallet=zig-wallet, uqbar=zig-uqbar
/+  sig=zig-sig, merk, eng=zig-sys-engine, m=multisig, default-agent, dbug, verb
|%
+$  state-0
  $:  %0
      on=(map @ux multisig-state:con)
      off=(map @ux multisig)
      invites=(map [@ux @p] multisig)
      :: pending tx:s 
      pending-m=(unit multisig)
      pending-i=(map [@ux @p] multisig)
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
++  on-init  on-init:def
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  `this(state !<(state-0 old-vase))
::
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
  ::  path for frontend to connect to and receive
  ::  all actively-flowing information. does not provide any initial state.
    [%updates ~]  `this
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
    ::  verify accepted invites. 
    ::  current setup with %accept cards returned means 1 extra scry.
    :-  %+  murn  ~(tap by pending-i)
        |=  [[=id =ship] =multisig]
        ?~  noun=(multisig-noun id)
          ~
        :-  ~
        :*  %pass   /accept
            %agent  [our.bowl %multisig]
            %poke   %multisig-action
            !>([%accept id ship])
        ==
    =-  this(on.state -, pending-i ~)
    %-  ~(urn by on)
      |=  [id=@ux m=multisig-state:con]
      ?~  noun=(multisig-noun id)
        m
      u.noun
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
    =+  [name.act ships.act ~]
    :_  state(pending-m `-)  :_  ~
    %-  generate-tx
    :*  `[%multisig /create]  
        address.act  publish-contract  0x0
        :*  %deploy-and-init  
            mutable=%.n     :: check
            multisig-code
            interface=~
            :+  %create
              threshold.act
            ::  b careful with putting psets on chain! noun can be *broken*
            (make-pset ~(tap in members.act))
    ==  ==
  ::
      %propose
    =+  calls=;;((list call) (cue calls.act))
    ?:  =(our src):bowl
      ?:  =(on-chain.act %.y)
        :: we are posting an on-chain proposal
        :_  state
        :_  ~
        %-  generate-tx 
        =+  hash=(shag:merk calls)
        :*  `[%multisig /create-proposal/(scot %ux multisig.act)/(scot %ux hash)]       
             address.act  source:(need (multisig-item multisig.act))  0x0
             [%propose multisig.act calls]
        ==
      ::  off-chain proposal, poke ships 
      =+  m=(~(got by off) multisig.act)
      =/  typed-message  
        :+  multisig.act
          execute-jold-hash
        [multisig.act calls (need (len-executed multisig.act)) deadline.act]
      ::
      =+  hash=(shag:merk typed-message)
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
                %.n
                `hash
                deadline.act
                name.act
                desc.act
        ==  ==
      =-  state(off (~(put by off) multisig.act -))
      =-  m(pending (~(put by pending.m) hash -))
      ^-  proposal
      [name.act desc.act calls ~ deadline.act]
    ::  someone is poking us with off-chain proposal,  
    ::  could be on-chain but we should hear that from chain in that case
    ::  or use sequencer receipts.
    ?>  =(on-chain.act %.n)
    ::  todo: scry unknown multisig from chain, add off chain data later?
    ::  or  poke back, ask for multisig first. receive, then get proposal. 
    =+  m=(~(got by off) multisig.act)
    :: what if my off-chain ships are outdated? 
    ::  ?>  (~(has in ships.m) src.bowl)  
    =+  (~(get by pending.m) (need hash.act))
    ?^  -  `state  :: already have a pending proposal with that hash, crash? 
    :-  :_  ~
    %-  give-update
      :+  %proposal  
        (need hash.act)
      [%.n name.act desc.act calls ~ deadline.act] 
    =-  state(off (~(put by off) multisig.act -))
    =-  m(pending (~(put by pending.m) (need hash.act) -))
    [name.act desc.act calls ~ deadline.act]
  :: 
      %execute
    ?>  =(our src):bowl
    =+  m=(~(got by off) multisig.act)
    =/  prop=proposal  (~(got by pending.m) hash.act)
    ::  optional, veriff sigs off-chain?
    :_  state
    :_  ~
    %-  generate-tx
    :*  `[%multisig /execute/(scot %ux multisig.act)/(scot %ux hash.act)]
        from=address.act
        contract=source:(need (multisig-item multisig.act))
        town=0x0
        :*  %execute
            multisig.act
            sigs.prop
            calls.prop
            deadline.prop
    ==  ==  
  ::
      %vote
    ?:  =(our src):bowl
      ?:  =(on-chain.act %.y)
        ::  vote on-chain proposal
        :_  state
        :_  ~
        %-  generate-tx
        :*  :-  ~  
            :-  %multisig  %+  weld  /create-vote/(scot %ux multisig.act)
            /(scot %ux hash.act)/(scot %ux address.act)/(scot %ud aye.act)
            from=address.act
            contract=source:(need (multisig-item multisig.act))
            town=0x0
            :^    %vote
                multisig.act
              hash.act
            aye.act
        ==
      ::  vote on off-chain proposal. 
      ::  sign-message, then poke to ships.
      =+  m=(~(got by off) multisig.act)
      =/  prop=proposal  (~(got by pending.m) hash.act)
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
            domain=multisig.act
            type=execute-json
            :^    multisig.act 
                calls.prop
              (need (len-executed multisig.act))
            deadline.prop
      ==  ==
    ::  someone voted on an off-chain proposal and poked us 
    ?>  =(on-chain.act %.n)
    =+  m=(~(got by off) multisig.act)
    ?~  sig.act  !!
    =/  prop=proposal  (~(got by pending.m) hash.act)
    ?>  (uqbar-validate:sig address.act hash.act u.sig.act)
    :-  :_  ~
    (give-update [%vote multisig.act hash.act address.act %.y])
    =-  state(off (~(put by off) multisig.act -))
    =-  m(pending (~(put by pending.m) hash.act -))
    %=  prop
      sigs  (~(put by sigs.prop) address.act u.sig.act)
    ==
  :: 
      %load
    ?>  =(our src):bowl
    ::  scry out multisig and add to our state/tracked
    =+  noun=(multisig-noun multisig.act)
    :-  ~
    ?~  noun  state
    state(on (~(put by on) multisig.act u.noun))
  ::
      %share
    ::  is a %request poke necessary?
    ?:  =(our src):bowl
      ::  us inviting someone
      =+  m=(~(got by off) multisig.act)
      :_  =-  state(off (~(put by off) multisig.act -))
          m(ships (~(put in ships.m) (need ship.act)))
      :_  ~
      :*  %pass   /share
          %agent  [(need ship.act) %multisig]
          %poke   %multisig-action
          !>([%add-ship multisig.act `m ~])
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
    ?~  noun=(multisig-noun multisig.act)
      ::  add update effect to fe, "not found yet, waiting for batch."
      :_  =-  state(pending-i -)
          (~(put by pending-i) [multisig.act ship.act] m)
      ~
    :-  :_  ~
    %-  give-update
      :*  %multisig  multisig.act
          name.m   
          members.u.noun
          ships.m
          threshold.u.noun
          pending.u.noun
          pending.m
      ==
    %=  state
      off       (~(put by off) multisig.act m)
      on        (~(put by on) multisig.act u.noun)
      invites   (~(del by invites) [multisig.act ship.act])
    ==
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
        [%create ~]
      ?.  =(%0 errorcode.output.update)
        `state(pending-m ~)
      ?~  pending-m  `state
      =/  modified=(list item)  
        (turn ~(val by modified.output.update) tail)
      ::  
      =|  ids=(unit [data=id con=id threshold=@ud members=(pset address)]) 
      =.  ids
        |-  ^+  ids
        ?~  modified  ~
        =/  =item  i.modified
        ?.  ?&  ?=(%& -.item)
                =(label.p.item %multisig)
            ==
            $(modified t.modified)
        =+  ;;(multisig-state:con noun.p.item)
        `[id.p.item source.p.item threshold.- members.-]
      ?~  ids  `state
      :-  :_  ~
      %-  give-update
        :*  %multisig  data.u.ids
            name.u.pending-m   
            members.u.ids
            ships.u.pending-m
            threshold.u.ids
            ~  ~
        ==
      %=  state
        off       (~(put by off) data.u.ids u.pending-m)
        on        (~(put by on) data.u.ids [members.u.ids threshold.u.ids ~ ~])
        pending-m  ~
      ==
    ::
        ?([%create-proposal @ @ ~] [%create-vote @ @ @ @ ~] [%execute @ @ ~])
      ?.  =(%0 errorcode.output.update)
        `state
      =*  path  q.u.origin.update
      =+  id=(slav %ux i.t.path)
      =+  hash=(slav %ux i.t.t.path)
      =/  m=multisig-state:con
        =+  (got:big:eng modified.output.update id)
        ;;(multisig-state:con ?>(?=(%& -.-) noun.p.-))
      :_  state(on (~(put by on) id m))
      :_  ~
      ?-    i.path 
          %create-proposal
        =+  (~(got by pending.m) hash)
        (give-update [%proposal hash %.y -])
      ::
          %create-vote
        =+  address=(slav %ux i.t.t.t.path)
        ::  aye in i.t.t.t.t.path is %ud scot: FIX
        (give-update [%vote id hash address %.y])
      ::
          %execute
        (give-update [%execute id hash])
      ==
    ==
  ::
      %signed-message
    ?>  ?=(^ origin.update)
    ::  remove ?+
    ?+    q.u.origin.update  !!
        [%sign-vote @ @ @ ~]   :: typed paths how
      =+  id=(slav %ux i.t.q.u.origin.update)
      =+  hash=(slav %ux i.t.t.q.u.origin.update)
      =+  address=(slav %ux i.t.t.t.q.u.origin.update)
      ::  note nesting =+  in =/  doesn't work
      =/  =multisig  (~(got by off) id)
      =/  =proposal  (~(got by pending.multisig) hash)
      ::
      :_  =-  state(off (~(put by off) id -))
          =-  multisig(pending (~(put by pending.multisig) hash -))
              proposal(sigs (~(put by sigs.proposal) address sig.update))
      :-  (give-update [%vote id hash address %.y])
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
                %.y
                %.n
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
    =+  %+  turn  ~(tap by on)
        |=  [=id m=multisig-state:con]
        ?~  multisig=(~(get by off) id)
          :-  id
          ['no name' members.m ~ threshold.m pending.m ~]
        :-  id
        :*  name.u.multisig
            members.m
            ships.u.multisig
            threshold.m
            pending.m
            pending.u.multisig
        ==
    ``multisig-update+!>(`update`[%multisigs (~(gas by *(map id msig)) -)])
    :: 
      [%x %multisig @ ~]
    =/  id  (slav %ux i.t.t.path)
    =/  multi  (~(got by on) id)
    ?~  m=(~(get by off) id)
        =+  :-  id
            ['no name' members.multi ~ threshold.multi pending.multi ~]
        ``multisig-update+!>(`update`[%multisig -])
    =+  :-  id
      :*  name.u.m
          members.multi
          ships.u.m
          threshold.multi
          pending.multi
          pending.u.m
      ==
      ``multisig-update+!>(`update`[%multisig -])
    ::
      [%x %multisig-on @ ~]
    =/  id  (slav %ux i.t.t.path)
    ?~  noun=(multisig-noun id)
      !!
    ``multisig-update+!>(`update`[%multisig-on id u.noun])
    ::
      [%x %proposal @ @ ~]
    ::  revise on/off a bit.
    =/  id  (slav %ux i.t.t.path)
    =/  hash  (slav %ux i.t.t.t.path)
    =/  multi  (~(got by on) id)
    ?~  m=(~(get by off) id)
      ::  if no off-chain multisig
      =+  (~(got by pending.multi) hash)
      ``multisig-update+!>(`update`[%proposal hash [%.y -]])
    ?~  p=(~(get by pending.u.m) hash)
      ::  if no off-chain proposal
      =+  (~(got by pending.multi) hash)
      ``multisig-update+!>(`update`[%proposal hash [%.y -]])
    ::  if off-chain proposal
    ``multisig-update+!>(`update`[%proposal hash [%.n u.p]])
  ==
::
++  len-executed
  |=  =id
  ?~  noun=(multisig-noun id)
    ~
  `(lent executed:(need noun))
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
++  multisig-noun
  |=  =id
  ^-  (unit multisig-state:con)
  =+  (need (multisig-item id))
  `;;(multisig-state:con noun.-)
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
