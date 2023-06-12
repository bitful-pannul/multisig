::
::  tests for con/multisig.hoon
::  account abstraction!
/+  *test, *transaction-sim, bip32
/=  multisig-lib  /con/lib/multisig
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
++  multi-shell   [caller-1 ~ id.p:pact:multisig [1 1.000.000] 0x0 0]
++  create-shell  [caller-1 ~ id.p:uninitialized-pact:multisig [1 1.000.000] 0x0 0]
::
++  multisig
  |%
  ++  pact
    ^-  item:smart
    =/  code  (cue multisig-contract)
    :*  %|  (hash-pact:smart 0x1234.5678 0x1234.5678 default-town-id code)
        0x1234.5678  ::  source
        0x1234.5678  ::  holder
        default-town-id
        [-.code +.code]
        ~
    ==
  ++  id  (hash-data:smart id.p:pact id.p:pact default-town-id 0)
  ++  our
    |=  =state:multisig-lib
    ^-  item:smart
    :*  %&  id
        id.p:pact
        id.p:pact
        default-town-id
        0  %multisig
        state
    ==
  ++  uninitialized-pact
    ^-  item:smart
    =/  code  (cue multisig-contract)
    :*  %|  (hash-pact:smart 0x9876.5432 0x9876.5432 default-town-id code)
        0x9876.5432  ::  source
        0x9876.5432  ::  holder
        default-town-id
        [-.code +.code]
        ~
    ==
  --
::  private keys for signing proposals
++  m-priv-1  0xaaaa
++  m-priv-2  0xbbbb
++  m-priv-3  0xcccc
++  core-1    (from-seed:bip32 [64 m-priv-1])
++  addr-1    (address-from-prv:key:ethereum private-key:core-1)
++  core-2    (from-seed:bip32 [64 m-priv-2])
++  addr-2    (address-from-prv:key:ethereum private-key:core-2)
++  core-3    (from-seed:bip32 [64 m-priv-3])
++  addr-3    (address-from-prv:key:ethereum private-key:core-3)
::
++  state
  %-  make-chain-state
  :~  pact:multisig
      uninitialized-pact:multisig
      (our:multisig [(make-pset:smart ~[addr-1 addr-2 addr-3]) 2 7])
      (account:zigs id.p:pact:multisig 1.000.000 ~)
      pact:zigs
      (account addr-1 300.000.000 [addr-2 1.000.000]^~):zigs
      (account addr-2 200.000.000 ~):zigs
      (account addr-3 100.000.000 [addr-1 50.000]^~):zigs
      (account addr-4 500.000 ~):zigs
  ==
++  chain
  ^-  chain:engine
  [state ~]
::
++  get-signed-transaction
  |=  calls=(list call:smart)
  ^-  transaction:smart
  =/  my-call=call:smart
    :+  id.p:pact:multisig
      0x0
    :+  %execute
      id:multisig
    calls
  =/  =typed-message:smart
    :+  id.p:pact:multisig                 :: domain
      execute-jold-hash:multisig-lib       :: type-hash
    :+  calls                              :: msg: [(list call) nonce deadline]
      nonce=8
    deadline=1.000
  =/  hash  `@uvI`(shag:smart typed-message)
  :+  fake-sig
    :*  %validate
        id:multisig
        ::  sig map
        %-  make-pmap:smart
        :~  :-  addr-1
            %+  ecdsa-raw-sign:secp256k1:secp:crypto
            hash  private-key:core-1
            :-  addr-2
            %+  ecdsa-raw-sign:secp256k1:secp:crypto
            hash  private-key:core-2
            :-  addr-3
            %+  ecdsa-raw-sign:secp256k1:secp:crypto
            hash  private-key:core-3
        ==
        ::
        deadline=1.000
        my-call
    ==
  [*caller:smart ~ id.p:pact:multisig [1 200.000] default-town-id 0]
::  tests for %give
::
++  test-zz-basic-multisig-give  ^-  test-txn
    =/  tx
      %-  get-signed-transaction
      ^-  (list call:smart)
      :_  ~                              
      :+  id.p:pact:zigs  0x0
      [%give 0xdead.beef 500.000 (id:zigs id.p:pact:multisig)]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=999]
    tx
  :*  gas=~
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  (account:zigs id.p:pact:multisig 500.000 ~)
          (account 0xdead.beef 500.000 ~):zigs
          (our:multisig [(make-pset:smart ~[addr-1 addr-2 addr-3]) 2 8])
      ==
      burned=`~
      events=`~
  ==
++  test-zzz-create-many-members  ^-  test-txn
  =/  member-set  (make-pset:smart ~[0xdead 0xbeef 0xcafe 0xbabe])
  =/  =calldata:smart  [%create 3 member-set]
  =/  tx=transaction:smart  [fake-sig calldata create-shell]
  ::
  =*  con-id  id.p:uninitialized-pact:multisig
  =/  output-item      
    ^-  item:smart
    :*  %&  (hash-data:smart con-id con-id default-town-id 0)
        con-id
        con-id
        default-town-id
        0  %multisig
        [member-set 3 0]
    ==
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~
      errorcode=`%0
      ::  modified
      :-  ~
      %-  make-chain-state
      :~
        output-item
      == 
      burned=`~
      events=`~
  ==
::
++  test-zz-execute-direct  ^-  test-txn
  =/  calldata  
    :+  %execute
      id:multisig
    :_  ~
    :+  id.p:pact:zigs  0x0
    [%give 0xdead.beef 500.000 (id:zigs id.p:pact:multisig)]
  ::
  =/  tx=transaction:smart  [fake-sig calldata multi-shell]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=0]
    tx
  :*  gas=~
      errorcode=`%6
      modified=`~  :: direct call to %execute fails
      burned=`~
      events=`~
  ==
::
++  test-zz-set-threshold
  =/  tx 
    %-  get-signed-transaction
    ^-  (list call:smart)
    :_  ~
    :+  id.p:pact:multisig  0x0
    [%set-threshold id:multisig 3]
 ::
 :^    chain
      [sequencer default-town-id batch=1 eth-block-height=999]
    tx
  :*  gas=~
      errorcode=`%0
      :-  ~
      %-  make-chain-state
      :~  
          (our:multisig [(make-pset:smart ~[addr-1 addr-2 addr-3]) 3 8])
      ==
      burned=`~
      events=`~
  ==
++  test-zz-add-member
  =/  tx 
    %-  get-signed-transaction
    ^-  (list call:smart)
    :_  ~
    :+  id.p:pact:multisig  0x0
    [%add-member id:multisig 0xdead.beef.cafe.babe]
 ::
 :^    chain
      [sequencer default-town-id batch=1 eth-block-height=999]
    tx
  :*  gas=~ 
      errorcode=`%0
      :-  ~
      %-  make-chain-state
      :~  
          (our:multisig [(make-pset:smart ~[addr-1 addr-2 addr-3 0xdead.beef.cafe.babe]) 2 8])
      ==
      burned=`~
      events=`~
  ==
--