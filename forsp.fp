(
  (tag 0 eq) $is-nil  (tag 1 eq) $is-atom (tag 3 eq) $is-pair (tag 4 eq) $is-clos

  ($n ^n ^n)                     $dup
  ($_)                           $drop
  ('t cswap)                     $swap
  ($a $b ^b ^a ^b)               $over
  ($a $b $c ^c ^b ^a ^c)         $over2
  ($a $b $c ^b ^a ^c)            $rot
  ($x x)                         $force
  ($c $t $f c ^f ^t rot cswap $_ force) $if
  ($f $t $c $fn ^f ^t ^c fn)     $endif
  ($a $b '() ('() 't b if) a if) $and
  ($a $b ('() 't b if) 't a if)  $or


  ; rec: Recursion via Y-Combinator
  ($f ($x (^x x) f) dup force) $Y ($g (^g Y)) $rec

  ; env-find
  ($self $key $env
    ^if (^env is-nil) ('NOT_FOUND_IN_ENV ^key cons print FAIL) (
      ^if (^env car car ^key eq) (^env car cdr) (^env cdr ^key self) endif
    ) endif
  ) rec $env-find


  ; stack operations
  (cons)                                      $stack-push
  ($b stack-push ^b stack-push)               $stack-push2
  (dup cdr swap car)                          $stack-pop
  (stack-pop $b stack-pop ^b)                 $stack-pop2
  (stack-pop $c stack-pop $b stack-pop ^b ^c) $stack-pop3

  ($expr $env '() ^env cons ^expr cons '#closure cons)  $make-closure
  ($expr (^expr car '#closure eq) (^expr is-pair) and)  $is-closure

  ; compute: $comp $stack $env -> $stack
  ($self $eval (^eval self) $self ; curry eval into self
    ^if (dup is-nil) (rot drop drop) ( ; false: result ^stack
      stack-pop
      ^if (dup 'quote eq)
        (drop stack-pop rot swap stack-push swap self)
        (swap $comp eval ^comp self) endif
    ) endif
  ) rec $compute

  ; eval: $expr $stack $env -> $stack $env
  ($eval $expr $stack $env (^eval compute) $compute ; curry eval into compute
    ^if (^expr is-atom) (
      ^env ^stack ^expr
      over2 swap env-find dup $callable
      ^if (dup is-closure) (swap $stack cdr dup cdr car swap car ^stack swap compute)
      (^if (dup is-clos)   (force)
                           (stack-push) endif) endif)
    (^if ((^expr is-nil) (^expr is-pair) or)
      (^env ^stack ^env ^expr make-closure stack-push)
      (^env ^stack ^expr stack-push) endif) endif
  ) rec $eval

 ; init-env
 '()

 (stack-pop over2 swap env-find stack-push)  'push   cons cons
 (stack-pop2 cons rot swap cons swap)        'pop    cons cons
 (stack-pop2 cons stack-push)                'cons   cons cons
 (stack-pop car stack-push)                  'car    cons cons
 (stack-pop cdr stack-push)                  'cdr    cons cons
 (dup cons)                                  'stack  cons cons
 (stack-pop print)                           'print  cons cons
 (stack-pop2 eq stack-push)                  'eq     cons cons
 (stack-pop3 cswap stack-push2)              'cswap  cons cons
 (stack-pop2 - stack-push)                   '-      cons cons
 (stack-pop2 * stack-push)                   '*      cons cons

 '() read ^eval compute
)

;('a 'b cons 'c cons print )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input: factorial
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
