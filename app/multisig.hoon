/-  *multisig, indexer=zig-indexer, wallet=zig-wallet
/+  smart=zig-sys-smart, sig=zig-sig, default-agent, dbug
|%
+$  state-0
  $:  %0
      multis=(map @ux multisig)
      :: pending tx:s 
      pending-m=(unit multisig)
      pending-p=(unit proposal)
  ==
+$  card  card:agent:gall
--
=|  state-0
=*  state  -
=<
%-  agent:dbug
^-  agent:gall
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
      ::
      ::  share-address-poke, through khan thread?
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
    :: if one of the addresses is ~, poke ship to get theirs before creation
    ?>  =(src.bowl our.bowl)
    =/  members  
      %+  murn  ~(tap by members.act)
      |=  [addy=(unit address:smart) ship=(unit ship:smart)]
      ?~  addy  ~  :: add a poke if ship exists
      `addy
    ::
    =+  [name.act members.act ~ ~ 0x0]
    :_  state(pending-m `-)  :_  ~
    :*  %pass   /create-multisig
        %agent  [our.bowl %uqbar]
        %poke   %wallet-poke
        !>  ^-  wallet-poke:wallet
        :*  %transaction
            origin=`[%multisig /create]
            from=address.act
            contract=publish-contract
            town=0x0
            :-  %noun
            :*  %deploy-and-init
                ::  hmm mutable, choose and inform users
                mutable=%.n
                multisig-code
                interface=~
                :+  %create
                  threshold.act
                (make-pset:smart members)
    ==  ==  ==
  ::
      %vote
    ?:  =(our.bowl src.bowl)
      ?:  =(on-chain.act %.n)
        ::  vote on off-chain proposal. 
        ::  note: need a divide between off and on-chain data.
        ::  especially for molding. should be doable, but a flag somewhere.
        `state
      ::  post vote on-chain, pending-v too much?
      `state
    `state
  :: 
      %propose
    =+  m=(~(got by multis) multisig.act)  :: revise got by
    ?:  =(our.bowl src.bowl)
      ?:  =(on-chain.act %.n)
        :: we are posting an on-chain proposal
        :: concanate
        =+  calls=;;((list call:smart) (cue calls.act))
        :_  state(pending-p `[name.act calls ~ ~ deadline.act 0 0])  
        :_  ~
        :*  %pass   /create-proposal
            %agent  [our.bowl %uqbar]
            %poke   %wallet-poke
            !>  ^-  wallet-poke:wallet
            :*  %transaction
                origin=`[%multisig /create-proposal]
                from=address.act
                contract=con.m
                town=0x0
                :-  %noun
                :+  %propose
                  multisig.act
                calls
        ==  ==
      ::  off-chain proposal
      `state
    ::  someone is poking us with off-chain proposal, 
    ::  could be on-chain but we should hear that from chain in that case
    ?>  =(on-chain.act %.n)  
    `state
  :: 
      %execute
    ?>  =(our.bowl src.bowl)
    =+  m=(~(got by multis) multisig.act)
    =/  prop=proposal  (~(got by proposals.m) hash.act)
    ::  optional, veriff sigs off-chain...?
    :_  state ::  add pending
    :_  ~
    :*  %pass   /execute
        %agent  [our.bowl %uqbar]
        %poke   %wallet-poke
        !>  ^-  wallet-poke:wallet
        :*  %transaction
            origin=`[%multisig /execute]
            from=address.act
            contract=con.m
            town=0x0
            :-  %noun
            :^    %execute
                multisig.act
              calls.prop
            deadline.prop
    ==  ==
  ::
      %load
    ?>  =(our.bowl src.bowl)
    ::  scry out multisig and add to our state/tracked
    =/  up
      .^  update:indexer  %gx
        (scot %p our.bowl)  %uqbar  (scot %da now.bowl)
        /indexer/newest/item/(scot %ux 0x0)/(scot %ux multisig.act)/noun
      ==
    ?>  ?=(%newest-item -.up)
    =+  item=item.up
    ?>  ?=(%.y -.item)
    ::  fix
    =/  m  ;;(multisig-state noun.p.item)
    =/  members  %+  turn  ~(tap in members.m)
        |=  =address
        [`address ~]
    ::  format proposals, members, to be like off-chain state...
    ::  empty names and deadlines?
    `state
  ::
      %find-addy
    :: route to khan. answer in on-arvo.
    `state
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
    ?>  =([%multisig /sign-calls] u.origin.update)
    ::
    `state
  ==
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
--
