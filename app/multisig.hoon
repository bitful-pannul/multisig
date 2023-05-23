/-  *multisig, indexer=zig-indexer, wallet=zig-wallet, uqbar=zig-uqbar
/+  smart=zig-sys-smart, sig=zig-sig, merk, default-agent, dbug, verb
|%
+$  state-0
  $:  %0
      multis=(map @ux multisig)
      :: pending tx:s 
      pending-m=(unit multisig)
      pending-p=(unit proposal)
      :: optional pending ships 
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
++  on-agent  on-agent:def
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
    ?>  =(src our):bowl
    =/  addys
      %+  turn  ~(tap by members.act)
      |=  [=address:smart ship=(unit ship:smart)]
      address
    ::
    =+  [name.act members.act threshold.act ~ ~ 0x0]
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
            (make-pset:smart addys)
    ==  ==
  ::
      %propose
    =+  calls=;;((list call:smart) (cue calls.act))
    ?:  =(our src):bowl
      =+  m=(~(got by multis) multisig.act)
      ?:  =(on-chain.act %.y)
        :: we are posting an on-chain proposal
        :_  state(pending-p `[name.act calls ~ ~ 0 0 0])  
        :_  ~
        %-  generate-tx 
        :*  `[%multisig /create-proposal]  
             address.act  con.m  0x0
             [%propose multisig.act calls]
        ==
      ::  off-chain proposal, poke ships 
      =+  (need (len-executed multisig.act))
      =/  typed-message  
        :+  multisig.act
          execute-jold-hash
        [multisig.act calls - deadline.act]
      ::
      :-  %+  murn  ~(tap in members.m)
        |=  [=address:smart ship=(unit ship)]
        ?~  ship  ~
        ?:  =(u.ship our.bowl)  ~
        :-  ~
        :*  %pass   /poke-proposal
            %agent  [u.ship %multisig]
            %poke   %multisig-action
            !>  ^-  action
            :*  %propose     :: define forwarding abstract logic 
                address.act
                multisig.act
                calls.act
                %.n
                `(shag:merk typed-message)
                deadline.act
                name.act
        ==  ==
      =-  state(multis (~(put by multis) multisig.act -))
      =-  m(pending (~(put by pending.m) (shag:merk typed-message) -))
      ^-  proposal
      [name.act calls ~ ~ deadline.act 0 0]
    ::  someone is poking us with off-chain proposal,  
    ::  could be on-chain but we should hear that from chain in that case
    ::  or use sequencer receipts.
    ?>  =(on-chain.act %.n)
    ::  refactor, contemplate whether this edge case needs to be handled at all.
    =/  m=multisig
      ?~  mm=(~(get by multis) multisig.act)
        (need (multisig-noun multisig.act))
      (need mm)
    =+  %+  murn  ~(tap in members.m)
      |=  [=address:smart ship=(unit ship)]
      ship
    ?~  (find ~[src.bowl] -)  !!  
    =+  (~(get by pending.m) (need hash.act))
    ?^  -  `state  :: already have a pending proposal with that hash..   
    ::  verify sigs timepoint wen
    =-  `state(multis (~(put by multis) multisig.act -))
    =-  m(pending (~(put by pending.m) (need hash.act) -))
    [name.act calls ~ ~ deadline.act 0 0]
  :: 
      %execute
    ?>  =(our src):bowl
    =+  m=(~(got by multis) multisig.act)
    =/  prop=proposal  (~(got by pending.m) hash.act)
    ::  optional, veriff sigs off-chain...?
    :_  state ::  add pending
    :_  ~
    %-  generate-tx
    :*  `[%multisig /execute]
        from=address.act
        contract=con.m
        town=0x0
        :*  %execute
            multisig.act
            sigs.prop
            calls.prop
            deadline.prop
    ==  ==  
  ::
      %vote
    =+  m=(~(got by multis) multisig.act)
    ?:  =(our src):bowl
      ?:  =(on-chain.act %.y)
        ::  pending or just wait for batch
        :_  state
        :_  ~
        %-  generate-tx
        :*  `[%multisig /create-vote]
            from=address.act
            contract=con.m
            town=0x0
            :+  %vote
              multisig.act
            hash.act
        ==
      ::  vote on off-chain proposal. 
      ::  note: need a divide between off and on-chain data.
      ::  especially for molding. should be doable, but a flag somewhere.
      ::  sign-message, then poke to ships.
      =/  prop=proposal  (~(got by pending.m) hash.act)
      :_  state  :_  ~
      :*  %pass   /sign
          %agent  [our.bowl %uqbar]
          %poke   %wallet-poke
          !>  ^-  wallet-poke:wallet
          :*  %sign-typed-message
            origin=`[%multisig /sign-vote/(scot %ux hash.act)]
            from=address.act
            domain=multisig.act
            type=execute-json
            :^    multisig.act 
                calls.prop
              (len-executed multisig.act) 
            deadline.prop
      ==  ==
    ::  someone voted on an off-chain proposal and poked us 
    ?>  =(on-chain.act %.n)
    ?~  sig.act  !!
    =/  prop=proposal  (~(got by pending.m) hash.act)
    =+  %-  shag:merk 
        :*  multisig.act 
            calls.prop 
            (need (len-executed multisig.act)) 
            deadline.prop
        ==
    ?>  (uqbar-validate:sig address.act - u.sig.act)
    :-  ~
    =-  state(multis (~(put by multis) multisig.act -))
    =-  m(pending (~(put by pending.m) hash.act -))
    %=  prop
      ayes  +(ayes.prop)  :: off-chain, check
      sigs  (~(put by sigs.prop) address.act u.sig.act)
    ==
  :: 
      %load
    ?>  =(our src):bowl
    ::  scry out multisig and add to our state/tracked
    `state
  ::
      %find-addys
    ::  thread seems a bit unnecessary. 
    ::  could also do no pending state, just updates to fe
    ::  perhaps scry out address=>ship from social graph
    :_  state
    %+  murn  ~(tap in who.act)
      |=  [addy=(unit address:smart) ship=(unit ship)]
      ?:  ?&  =(~ addy)
              ?!  =(~ ship)
          ==
        :: fix type propagation
        :-  ~
        :*  %pass   /uqbar-address-from-ship
            %agent  [(need ship) %wallet]
            %poke   uqbar-share-address+!>([%request %multisig])
        ==
      :: scry social graph
      ~  
  ==
::
++  handle-wallet-update
  |=  update=wallet-update:wallet
  ^-  (quip card _state)
  ?+    -.update  `state
      %sequencer-receipt
    ?>  ?=(^ origin.update)
    ?+    q.u.origin.update  ~|("got receipt from weird origin" !!)
        [%create ~]      
      ?.  =(%0 errorcode.output.update)
        `state(pending-m ~)
      ::  look for %multisig label, fetch contract from it.
      ::  or other way around, one contract changed, with us as holder due to deploy?
      ?~  pending-m  `state
      =/  modified=(list item:smart)  
        (turn ~(val by modified.output.update) tail)
      ::  
      =|  ids=(unit [data=id:smart con=id:smart]) 
      =.  ids
        |-  ^+  ids
        ?~  modified  ~
        =/  =item:smart  i.modified
        ?.  ?&  ?=(%& -.item)
                =(label.p.item %multisig)
                ::  additional possible checks? accidental other multisig here in batch?
            ==
            $(modified t.modified)
        `[id.p.item source.p.item]
      ?~  ids  `state
      ::
      =/  new  u.pending-m(con con.u.ids)
      :_  state(multis (~(put by multis) data.u.ids new), pending-m ~)
      ~
    ::
        [%create-proposal ~]
      `state
    ::  
        [%create-vote ~]
      `state
    ::  
        [%execute ~]
      :: only one that's exclusively off-chain
      `state
    ==
  ::
      %signed-message
    ?>  ?=(^ origin.update)
    ?+    q.u.origin.update  ~|("got receipt from weird origin" !!)
        [%sign-vote @ ~]
      ~&  "{<q.u.origin.update>}"
      `state
    ==
  ==
::
++  handle-scry
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  ~|("unexpected scry into {<dap.bowl>} on path {<path>}" !!)
      [%x %multisigs ~]
    ``noun+!>(~)
  :: 
      [%x %multisig @ ~]
    =/  id  (slav %ux i.t.t.path)
    =/  multi  (~(get by multis) id)
    ``noun+!>(~)
  ==
::
++  len-executed
  |=  =id:smart
  ?~  noun=(multisig-noun id)
    ~
  `(lent executed:(need noun))
::
++  multisig-noun
  ::  scry the on-chain noun, and merge/mold to off-chain one.
  |=  =id:smart
  ^-  (unit multisig)
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
  =+  on=;;(multisig-state:con noun.p.item)
  ?~  off=(~(get by multis) id)
    :-  ~
    :*  'default multisig name'             :: fix
        (members-to-off members.on)
        threshold.on
        pending=(props-to-off pending.on)
        executed=executed.on
        source.p.item
    ==
  off  :: update merge from on-chain values?
::
++  members-to-off
  |=  m=(pset address:smart)
  ^-  (set member)
  %-  silt
  %+  turn  ~(tap pn m)
    |=  =address:smart
    [address ~]
::
++  props-to-off
  |=  on=(pmap:smart @ux proposal:multisig-state:con)
  ^-  (map hash:smart proposal)
  %-  malt
  %+  turn  ~(tap pn on)
    |=  [hash=@ux p=proposal:multisig-state:con]
    :-  hash
    :*  'default proposal name'             :: fix
        calls.p
        votes.p
        sigs=~
        0
        ayes.p
        nays.p
    ==   
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
++  handle-address-share
  |=  share=share-address:uqbar
  ^-  (quip card _state)
  :_  state  :_  ~
  ?-    -.share
      %request  !!
      %deny
    ::  surface this
    :*  %give  %fact
        ~[/updates]
        %noun              :: multisig update
        !>
        [%denied src.bowl]
    ==
  ::
      %share
    :*  %give  %fact
        ~[/updates]
        %noun              :: multisig update
        !>  
        [%share src.bowl address.share]
    ==
  ==
--
