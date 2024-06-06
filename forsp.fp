(
  (tag 0 eq) $is-nil  (tag 1 eq) $is-atom (tag 3 eq) $is-pair (tag 4 eq) $is-clos

  ($n ^n ^n)                     $dup
  ('t cswap)                     $swap
  ($x x)                         $force
  (force cswap $_ force)         $if
  ($f $t $c $fn ^f ^t ^c fn)     $endif
  ($a $b '() ('() 't b if) a if) $and
  ($a $b ('() 't b if) 't a if)  $or

  ; rec: Recursion via Y-Combinator
  ($f ($x (^x x) f) dup force) $Y ($g (^g Y)) $rec

  ; env-find
  ($self $key $env
    ^if (^env is-nil) ('NOT_FOUND_IN_ENV ^key cons print FAIL) (
      ^env car $kv
      ^if (^kv car ^key eq) (^kv cdr)
        (^env cdr ^key self) endif
    ) endif
  ) rec $env-find

  ; stack operations
  (cons)                    $push
  ($b push ^b push)         $push2
  (dup cdr swap car)        $pop
  (pop $b pop ^b)           $pop2
  (pop $c pop $b pop ^b ^c) $pop3

  ($expr $env '() ^env cons ^expr cons '#closure cons)  $make-closure
  ($expr (^expr car '#closure eq) (^expr is-pair) and)  $is-closure

  ; compute
  ($self $eval $stack $comp $env (^eval self) $self ; curry eval into self
    ^if (^comp is-nil) ^stack (
      ^comp pop $cmd $comp
      ^if (^cmd '' eq) (
        ^comp pop $literal $comp
        ^stack ^literal push $stack
        ^env ^comp ^stack self
      ) (^if  (^cmd '^ eq) (
        ^comp pop $name $comp
        ^env ^name env-find $value
        ^stack ^value push $stack
        ^env ^comp ^stack self
      ) (^if  (^cmd '$ eq) (
        ^comp pop $name $comp
        ^stack pop $val $stack
        ^env ^val ^name cons cons $env
        ^env ^comp ^stack self
      ) (
        ^env ^cmd ^stack eval $stack
        ^env ^comp ^stack self
      ) endif) endif) endif) endif
  ) rec $compute

  ; eval: $eval $stack $expr $env
  ($eval $stack $expr $env (^eval compute) $compute ; curry eval into compute
    ^if (^expr is-atom) (
      ^env ^expr env-find $callable
      ^if (^callable is-closure) (^callable cdr dup cdr car swap car ^stack compute)
      (^if (^callable is-clos)   (^stack callable)
                                 (^stack ^callable push) endif) endif)
    (^if ((^expr is-nil) (^expr is-pair) or)
      (^stack ^env ^expr make-closure push)
      (^stack ^expr push) endif) endif
  ) rec $eval

 ; init-env
 '()
 (pop print)        'print  cons cons
 (pop2 eq push)     'eq     cons cons
 (pop3 cswap push2) 'cswap  cons cons
 (pop2 - push)      '-      cons cons
 (pop2 * push)      '*      cons cons

 read '() ^eval compute
)

(
  ($x x)                       $force
  (force cswap $_ force)       $if
  ($f $t $c $fn ^f ^t ^c fn)   $endif
  ()                           $[
  ()                           $]

  ; Y-Combinator
  ($f
    ($x (^x x) f)
    ($x (^x x) f)
    force
  ) $Y

  ; rec: syntax sugar for applying the Y-Combinator
  ($g (^g Y)) $rec

  ; factorial
  ($self $n
    ^if [ ^n 0 eq ] 1
      ([ ^n 1 - ] self ^n *)
    endif
  ) rec $factorial

  5 factorial print
)
