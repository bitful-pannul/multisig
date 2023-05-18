::
::  tests for con/multisig.hoon
::
/+  *test, *transaction-sim
/=  lib  /con/lib/multisig
/*  multisig-contract  %jam  /con/compiled/multisig/jam
|%
::
::  test data
::
++  sequencer  caller-1
++  caller-1  ^-  caller:smart  [addr-1 1 (id addr-1)]:zigs
++  caller-2  ^-  caller:smart  [addr-2 1 (id addr-2)]:zigs
++  caller-3  ^-  caller:smart  [addr-3 1 (id addr-3)]:zigs
++  caller-4  ^-  caller:smart  [addr-4 1 (id addr-4)]:zigs
::
++  caller-1-shell
  [caller-1 ~ id.p:pact:zigs [1 1.000.000] default-town-id 0]
::
++  multisig
  |%
  ++  pact
    ^-  item:smart
    =/  code  (cue multisig-contract)
    =/  id  (hash-pact 0x1234.5678 0x1234.5678 default-town-id code)
    :*  %|  id
        0x1234.5678  ::  source
        0x1234.5678  ::  holder
        default-town-id
        [-.code +.code]
        ~
    ==
  ++  add-member-proposal
    ^-  proposal:lib
    =+  [%add-member id.p:pact addr-3:zigs]
    :^  [id.p:pact default-town-id -]^~
    ~  0  0
  ++  remove-member-proposal
    ^-  proposal:lib
    =+  [%remove-member id.p:pact addr-3:zigs]
    :^  [id.p:pact default-town-id -]^~
    ~  0  0
  ++  set-threshold-proposal
    ^-  proposal:lib
    =+  [%set-threshold id.p:pact 2]
    :^  [id.p:pact default-town-id -]^~
    ~  0  0
  ++  send-zigs-proposal
    ^-  proposal:lib
    =+  [%give addr-1:zigs 123.456 (id:zigs id.p:pact) ~]
    :^  [id.p:pact:zigs default-town-id -]^~
    ~  0  0
  ++  multisig
    ^-  item:smart
    =/  members
      %-  ~(gas pn:smart *(pset:smart address:smart))
      ~[addr-1:zigs addr-2:zigs]
    =/  pending
      %-  ~(gas py:smart *(pmap:smart @ux proposal:lib))
      :~  [0x1 add-member-proposal]
          [0x2 remove-member-proposal]
          [0x3 set-threshold-proposal]
          [0x4 send-zigs-proposal]
      ==
    :*  %&  (hash-data id.p:pact id.p:pact default-town-id 0)
        id.p:pact
        id.p:pact
        default-town-id
        0  %multisig
        [members 2 pending]
    ==
  --
::
++  state
  %-  make-chain-state
  :~  pact:zigs
      pact:multisig
      multisig:multisig
      (account addr-1 300.000.000 [addr-2 1.000.000]^~):zigs
      (account addr-2 200.000.000 ~):zigs
      (account addr-3 100.000.000 [addr-1 50.000]^~):zigs
      (account addr-4 500.000 ~):zigs
  ==
++  chain
  ^-  chain:engine
  [state ~]
::
::  begin tests
::
::  tests for %create
::
++  test-zz-create-already-exists
  =/  =calldata:smart
    =-  [%create 1 -]
    (~(gas pn:smart *(pset:smart address:smart)) ~[addr-1:zigs])
  =/  tx=transaction:smart  [fake-sig calldata caller-1-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~
      errorcode=`%6
      modified=`~
      burned=`~
      events=`~
  ==
::
++  test-create-no-members
  =/  =calldata:smart  [%create 0 ~]
  =/  tx=transaction:smart  [fake-sig calldata caller-1-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~
      errorcode=`%6
      modified=`~
      burned=`~
      events=`~
  ==
::
++  test-create-high-threshold
  =/  =calldata:smart
    =-  [%create 2 -]
    (~(gas pn:smart *(pset:smart address:smart)) ~[addr-1:zigs])
  =/  tx=transaction:smart  [fake-sig calldata caller-1-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~
      errorcode=`%6
      modified=`~
      burned=`~
      events=`~
  ==
::
++  test-create-many-members
  =/  member-set
    %-  ~(gas pn:smart *(pset:smart address:smart))
    ~[addr-1:zigs 0xdead 0xbeef 0xcafe 0xbabe]
  =/  =calldata:smart  [%create 3 member-set]
  =/  tx=transaction:smart  [fake-sig calldata caller-1-shell]
  ::
  =/  correct-id
    (hash-data id.p:pact:multisig id.p:pact:multisig default-town-id 0)
  ::
  :^    chain(p (del:big p.chain id.p:multisig:multisig))
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~
      errorcode=`%0
      ::  modified
      :-  ~
      %-  make-chain-state
      :~  :*  %&  correct-id
              id.p:pact:multisig
              id.p:pact:multisig
              default-town-id
              0  %multisig
              [member-set 3 ~]
      ==  ==
      burned=`~
      events=`~
  ==
::
::  tests for %vote
::
:: ++  test-vote-not-member
::   =/  =calldata:smart  [%vote id:multisig 0x1 %.y]
::   =/  shel=shell:smart
::     [caller-3 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  res=single-result
::     %+  ~(mill mil miller town-id batch-num)
::       fake-land
::     `transaction:smart`[fake-sig shel yolk]
::   ::
::   %+  expect-eq
::   !>(%6)  !>(errorcode.res)
:: ::
:: ++  test-vote-no-proposal
::   =/  =calldata:smart  [%vote id:multisig 0x6789 %.y]
::   =/  shel=shell:smart
::     [caller-1 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  res=single-result
::     %+  ~(mill mil miller town-id batch-num)
::       fake-land
::     `transaction:smart`[fake-sig shel yolk]
::   ::
::   %+  expect-eq
::   !>(%6)  !>(errorcode.res)
:: ::
:: ++  test-vote-aye
::   =/  =calldata:smart  [%vote id:multisig 0x1 %.y]
::   =/  shel=shell:smart
::     [caller-1 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  res=single-result
::     %+  ~(mill mil miller town-id batch-num)
::       fake-land
::     `transaction:smart`[fake-sig shel yolk]
::   =/  correct-proposal
::     :^  [id.p:wheat:multisig town-id [%add-member id:multisig holder-3]]^~
::       %-  ~(gas py:smart *(pmap:smart address:smart ?))
::       [holder-1 %.y]^~
::     1  0
::   ::
::   ;:  weld
::     %+  expect-eq
::     !>(%0)  !>(errorcode.res)
::   ::
::     %+  expect-eq
::       !>(correct-proposal)
::     !>  =+  (got:big p.land.res id:multisig)
::         =+  data:(husk:smart multisig-state - ~ ~)
::         (~(got py:smart pending.-) 0x1)
::   ==
:: ::
:: ++  test-vote-nay
::   =/  =calldata:smart  [%vote id:multisig 0x1 %.n]
::   =/  shel=shell:smart
::     [caller-1 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  res=single-result
::     %+  ~(mill mil miller town-id batch-num)
::       fake-land
::     `transaction:smart`[fake-sig shel yolk]
::   ::  proposal will be removed
::   ;:  weld
::     %+  expect-eq
::     !>(%0)  !>(errorcode.res)
::   ::
::     %+  expect-eq
::       !>(%.n)
::     !>  =+  (got:big p.land.res id:multisig)
::         =+  data:(husk:smart multisig-state - ~ ~)
::         (~(has py:smart pending.-) 0x1)
::   ==
:: ::
:: ++  test-vote-run
::   =/  =calldata:smart  [%vote id:multisig 0x1 %.y]
::   =/  shel-1=shell:smart
::     [caller-1 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  shel-2=shell:smart
::     [caller-2 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  =basket:mill
::     %-  silt
::     :~  [(shag:smart [shel-1 yolk]) [fake-sig shel-1 yolk]]
::         [(shag:smart [shel-2 yolk]) [fake-sig shel-2 yolk]]
::     ==
::   =/  res=[state-transition:mill rejected=carton:mill]
::     %-  ~(mill-all mil miller town-id batch-num)
::     [fake-land basket 256]
::   ::
::   =/  correct
::     ^-  item:smart
::     :*  %&  0  %multisig
::         :+  (~(gas pn:smart *(pset:smart address:smart)) ~[holder-1 holder-2 holder-3])
::           2
::         %-  ~(gas py:smart *(pmap:smart @ux proposal))
::         :~  [0x2 proposal-2:multisig]
::             [0x3 proposal-3:multisig]
::             [0x4 proposal-4:multisig]
::         ==
::         id:multisig
::         id.p:wheat:multisig
::         id.p:wheat:multisig
::         town-id
::     ==
::   ::
::   %+  expect-eq
::     !>(correct)
::   !>((got:big p.land.res id:multisig))
:: ::
:: ::  tests for %propose
:: ::
:: ++  test-propose
::   =/  my-proposal
::     [id.p:wheat:multisig town-id [%add-member id:multisig 0xdead.beef]]^~
::   =/  proposal-hash
::     (shag:smart my-proposal)
::   =/  =calldata:smart
::     [%propose id:multisig my-proposal]
::   =/  shel=shell:smart
::     [caller-1 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  res=single-result
::     %+  ~(mill mil miller town-id batch-num)
::       fake-land
::     `transaction:smart`[fake-sig shel yolk]
::   =/  correct-proposal
::     :^  my-proposal
::       %-  ~(gas py:smart *(pmap:smart address:smart ?))
::       [id:caller-1 %.y]^~
::     1  0
::   ::
::   ;:  weld
::     %+  expect-eq
::     !>(%0)  !>(errorcode.res)
::   ::
::     %+  expect-eq
::       !>(correct-proposal)
::     !>  =+  (got:big p.land.res id:multisig)
::         =+  data:(husk:smart multisig-state - ~ ~)
::         (~(got py:smart pending.-) proposal-hash)
::   ==
:: ::
:: ++  test-propose-not-member
::   =/  my-proposal
::     [id.p:wheat:multisig town-id [%add-member id:multisig 0xdead.beef]]^~
::   =/  =calldata:smart  [%propose id:multisig my-proposal]
::   =/  shel=shell:smart
::     [caller-3 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  res=single-result
::     %+  ~(mill mil miller town-id batch-num)
::       fake-land
::     `transaction:smart`[fake-sig shel yolk]
::   ::
::   %+  expect-eq
::   !>(%6)  !>(errorcode.res)
:: ::
:: ++  test-proposal-4
::   =/  =calldata:smart  [%vote id:multisig 0x4 %.y]
::   =/  shel-1=shell:smart
::     [caller-1 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  shel-2=shell:smart
::     [caller-2 ~ id.p:wheat:multisig 1 1.000.000 town-id 0]
::   =/  =basket:mill
::     %-  silt
::     :~  [(shag:smart [shel-1 yolk]) [fake-sig shel-1 yolk]]
::         [(shag:smart [shel-2 yolk]) [fake-sig shel-2 yolk]]
::     ==
::   =/  res=[state-transition:mill rejected=carton:mill]
::     %-  ~(mill-all mil miller town-id batch-num)
::     [fake-land basket 256]
::   ::
::   =/  correct
::     ^-  item:smart
::     :*  %&  0  %multisig
::         :+  (~(gas pn:smart *(pset:smart address:smart)) ~[holder-1 holder-2])
::           2
::         %-  ~(gas py:smart *(pmap:smart @ux proposal))
::         :~  [0x1 proposal-1:multisig]
::             [0x2 proposal-2:multisig]
::             [0x3 proposal-3:multisig]
::         ==
::         id:multisig
::         id.p:wheat:multisig
::         id.p:wheat:multisig
::         town-id
::     ==
::   ::
::   %+  expect-eq
::     !>(correct)
::   !>((got:big p.land.res id:multisig))
--