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
++  my-shell  [caller-1 ~ id.p:pact:zigs [1 1.000.000] default-town-id 0]
::
++  multisig-pact
  ^-  item:smart
  =/  code  (cue multisig-contract)
  :*  %|  (hash-pact:smart 0x1234.5678 0x1234.5678 default-town-id code)
      0x1234.5678  ::  source
      0x1234.5678  ::  holder
      default-town-id
      [-.code +.code]
      ~
  ==
::
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
++  my-multisig-id
  ^-  id:smart
  %:  hash-data:smart
      id.p:multisig-pact
      id.p:multisig-pact
      default-town-id
      0
  ==
++  my-multisig
  |=  =state:multisig-lib
  ^-  item:smart
  :*  %&  my-multisig-id
      id.p:multisig-pact
      id.p:multisig-pact
      default-town-id
      0  %multisig
      state
  ==
::
++  uninitialized-multisig-pact
  ^-  item:smart
  =/  code  (cue multisig-contract)
  =/  id  (hash-pact:smart 0x9876.5432 0x9876.5432 default-town-id code)
  :*  %|  id
      0x9876.5432  ::  source
      0x9876.5432  ::  holder
      default-town-id
      [-.code +.code]
      ~
  ==
::
++  state
  %-  make-chain-state
  :~  multisig-pact
      (my-multisig [(make-pset:smart ~[addr-1 addr-2 addr-3]) 2 7])
      (account:zigs id.p:multisig-pact 1.000.000 ~)
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
::  tests for %give
::
++  test-zz-basic-multisig-give  ^-  test-txn
  =/  my-call=call:smart
    :+  id.p:multisig-pact
      0x0
    :+  %execute
      my-multisig-id
    :_  ~
    :+  id.p:pact:zigs  0x0
    [%give 0xdead.beef 500.000 (id:zigs id.p:multisig-pact)]
  =/  =typed-message:smart
    :+  id.p:multisig-pact
      execute-jold-hash:multisig-lib
    :+  my-call
      nonce=8
    deadline=1.000
  =/  hash  `@uvI`(shag:smart typed-message)
  =/  tx=transaction:smart
    :+  fake-sig
      :*  %validate
          my-multisig-id
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
    [*caller:smart ~ id.p:multisig-pact [1 200.000] default-town-id 0]
  :^    chain
      [sequencer default-town-id batch=1 eth-block-height=999]
    tx
  :*  gas=~  ::  we don't care
      errorcode=`%0
      ::  assert correct modified state
      :-  ~
      %-  make-chain-state
      :~  (account:zigs id.p:multisig-pact 500.000 ~)
          (account 0xdead.beef 500.000 ~):zigs
          (my-multisig [(make-pset:smart ~[addr-1 addr-2 addr-3]) 8 2])
      ==
      burned=`~
      events=`~
  ==
--