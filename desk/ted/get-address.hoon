/-  spider, multisig, uqbar=zig-uqbar, wallet=zig-wallet
/+  *strandio
=,  strand=strand:spider
=>
|%
++  take-update
  |=  to=@p
  =/  m  (strand ,(unit @ux))
  ^-  form:m
  ;<  =cage  bind:m  (take-fact /thread-watch)
  =/  upd=thread-update:multisig  !<(thread-update:multisig q.cage)
  ?.  ?&  ?=(%shared -.upd)
          =(to from.upd)
      ==
    (pure:m ~)
  (pure:m `address.upd)
--
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
=/  act  !<(action:multisig arg)
?.  ?=(%find-addy -.act)  (pure:m !>(~))
^-  form:m
::  first, watch updates from multisig
::
;<  ~  bind:m  (watch-our /thread-watch %multisig /find-updates)
::  next, poke wallet of ship we want address for
::
;<  ~  bind:m
  %-  send-raw-card
  :*  %pass   /uqbar-address-from-ship
      %agent  [to.act %wallet]
      %poke   uqbar-share-address+!>([%request %multisig])
  ==
::  set timer so that if we don't hear back from ship in 2 minutes,
::  we cancel the token send
;<  now=@da  bind:m  get-time
::  take fact from pongo with result of poke
::
;<  address=(unit @ux)  bind:m  (take-update to.act)
;<  our=@p  bind:m  get-our
::  if address is ~, surface error (user didn't share wallet addr)
?~  address  !!
::  if it's too late, don't send anymore
;<  later=@da  bind:m  get-time
?:  (gth (sub later now) ~m1)  !!
::  now give fact/facts to %multisig that we've found a corresponding address.
(pure:m !>(~))