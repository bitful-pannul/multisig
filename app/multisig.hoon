/-  *multisig, indexer=zig-indexer, wallet=zig-wallet, uqbar=zig-uqbar
/+  smart=zig-sys-smart, sig=zig-sig, merk, default-agent, dbug, verb
|%
+$  state-0
  $:  %0
      on=(map @ux multisig-state:con)
      off=(map @ux multisig)
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
            (make-pset:smart ~(tap in members.act)) :: check !!!
    ==  ==
  ::
      %propose
    =+  calls=;;((list call:smart) (cue calls.act))
    ?:  =(our src):bowl
      ?:  =(on-chain.act %.y)
        :: we are posting an on-chain proposal
        :_  state  ::  (pending-p `[name.act calls ~ ~ 0 0 0])  
        :_  ~
        %-  generate-tx 
        :*  `[%multisig /create-proposal]  
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
      :-  %+  murn  ~(tap in ships.m)
        |=  =ship
        ?:  =(ship our.bowl)  ~
        :-  ~
        :*  %pass   /poke-proposal
            %agent  [ship %multisig]
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
                desc.act
        ==  ==
      =-  state(off (~(put by off) multisig.act -))
      =-  m(pending (~(put by pending.m) (shag:merk typed-message) -))
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
    ?~  (find ~[src.bowl] -)  !!  
    =+  (~(get by pending.m) (need hash.act))
    ?^  -  `state  :: already have a pending proposal with that hash..   
    =-  `state(off (~(put by off) multisig.act -))
    =-  m(pending (~(put by pending.m) (need hash.act) -))
    [name.act desc.act calls ~ deadline.act]
  :: 
      %execute
    ?>  =(our src):bowl
    =+  m=(~(got by off) multisig.act)
    =/  prop=proposal  (~(got by pending.m) hash.act)
    ::  optional, veriff sigs off-chain...?
    :_  state ::  add pending
    :_  ~
    %-  generate-tx
    :*  `[%multisig /execute]
        from=address.act
        contract=0x0 :: source.p:(need (multisig-item multisig.act))
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
        ::  just wait for batch
        :_  state
        :_  ~
        %-  generate-tx
        :*  `[%multisig /create-vote]
            from=address.act
            contract=0x0  ::  source.p:(need multisig-item multisig.act))
            town=0x0
            :+  %vote
              multisig.act
            hash.act
        ==
      ::  vote on off-chain proposal. 
      ::  note: need a divide between off and on-chain data. !! 
      ::  sign-message, then poke to ships.
      =+  m=(~(got by off) multisig.act)
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
              (need (len-executed multisig.act))
            deadline.prop
      ==  ==
    ::  someone voted on an off-chain proposal and poked us 
    ?>  =(on-chain.act %.n)
    =+  m=(~(got by off) multisig.act)
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
    =-  state(off (~(put by off) multisig.act -))
    =-  m(pending (~(put by pending.m) hash.act -))
    %=  prop
      sigs  (~(put by sigs.prop) address.act u.sig.act)
    ==
  :: 
      %load
    ?>  =(our src):bowl
    ::  scry out multisig and add to our state/tracked
    ::  or poke a ship, request new state
    `state
  ::
      %find-addys
    ::  thread seems a bit unnecessary. 
    ::  could also do no pending state, just updates to fe
    ::  perhaps scry out address=>ship from social graph
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
    ?+    q.u.origin.update  ~|("got receipt from weird origin" !!)
        [%create ~]
      ::  testing, this only populates off-chain data.
      ::  members, threshold are put into on-chain state upon-batch.     
      ?.  =(%0 errorcode.output.update)
        `state(pending-m ~)
      ::  look for %multisig label, fetch contract from it.
      ::  or other way around, one contract changed, with us as holder due to deploy?
      ?~  pending-m  `state
      =/  modified=(list item:smart)  
        (turn ~(val by modified.output.update) tail)
      ::  
      =|  ids=(unit [data=id:smart con=id:smart threshold=@ud members=(pset address:smart)]) 
      =.  ids
        |-  ^+  ids
        ?~  modified  ~
        =/  =item:smart  i.modified
        ?.  ?&  ?=(%& -.item)
                =(label.p.item %multisig)
                ::  additional possible checks? accidental other multisig here in batch?
            ==
            $(modified t.modified)
        =+  ;;(multisig-state:con noun.p.item)
        `[id.p.item source.p.item threshold.- members.-]
      ?~  ids  `state
      :-  ~
      %=  state
        off  (~(put by off) data.u.ids u.pending-m)
        on   (~(put by on) data.u.ids [members.u.ids threshold.u.ids ~ ~])
      ==
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
    =/  multi  (~(get by on) id)
    ``noun+!>(~)
  ==
::
++  len-executed
  |=  =id:smart
  ?~  noun=(multisig-noun id)
    ~
  `(lent executed:(need noun))
::
++  multisig-item
  |=  =id:smart
  ^-  (unit data:smart)
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
  ::  scry the on-chain noun, and merge/mold to off-chain one.
  |=  =id:smart
  ^-  (unit multisig-state:con)
  =+  (need (multisig-item id))
  ?>  ?=(%.y -.item)
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
