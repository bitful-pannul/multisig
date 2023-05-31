::  account-abstracted multisig [UQ| DAO]
/+  *zig-sys-smart
/=  lib  /con/lib/multisig
=,  lib
|_  =context
++  write
  |=  =action
  ^-  (quip call diff)
  ?:  ?=(%create -.action)
    ::  issue a new item for a new multisig wallet
    ::  threshold must be <= member count, > 0
    ?>  ?&  (gth threshold.action 0)
            (lte threshold.action ~(wyt pn members.action))
        ==
    ::  must have at least one member
    ?>  ?=(^ members.action)
    ::  no salt -- this contract creates a single grain.
    =/  =item
      :*  %&  (hash-data [this this town 0]:context)
          this.context
          this.context
          town.context
          0  %multisig
          [members.action threshold.action 0]
      ==
    `(result ~ item^~ ~ ~)
  =+  (need (scry-state our.action))
  =/  multisig  (husk state - `this.context ~)
  ?-    -.action
      %validate
    ?>  ?&  ~(apt py sigs.action)
            (gte ~(wyt py sigs.action) threshold.noun.multisig)
            (lte eth-block.context deadline.action)
        ::  enforce that call is %execute to ourself
            =(contract.call.action this.context)
            =(p.calldata.call.action %execute)
        ==
    ::  assert signatures are correct
    =/  =typed-message
      :+  this.context  execute-jold-hash
      [call.action +(nonce.noun.multisig) deadline.action]
    ?>  %+  levy  ~(tap py sigs.action)
        |=  [=address =sig]
        =((recover typed-message sig) address)
    [call.action^~ [~ ~ ~ ~]]
  ::
      %execute
    :-  calls.action
    (result [%& multisig(nonce.noun +(nonce.noun.multisig))]^~ ~ ~ ~)
  ::
      %add-member
    ?>  =(id.caller.context this.context)
    =.  members.noun.multisig
      (~(put pn members.noun.multisig) address.action)
    `(result [%&^multisig]^~ ~ ~ ~)
  ::
      %remove-member
    ?>  =(id.caller.context this.context)
    =.  members.noun.multisig
      (~(del pn members.noun.multisig) address.action)
    ::  if member count has been reduced below threshold, decrement it.
    ::  will also force a crash if we are removing the only member of
    ::  a 1-address multisig.
    =?    threshold.noun.multisig
        (gth threshold.noun.multisig ~(wyt pn members.noun.multisig))
      (dec threshold.noun.multisig)
    `(result [%&^multisig]^~ ~ ~ ~)
  ::
      %set-threshold
    ?>  =(id.caller.context this.context)
    ::  threshold must be <= member count, > 0
    ?>  ?&  (gth new.action 0)
            (lte new.action ~(wyt pn members.noun.multisig))
        ==
    =.  threshold.noun.multisig  new.action
    `(result [%&^multisig]^~ ~ ~ ~)
  ==
::
++  read
  |=  =pith
  ~
--