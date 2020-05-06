#lang racket

(require rackunit
         "assign-homes.rkt")

(check-equal?
 (assign-homes
  '(program ((locals . (a b c)))
    ((start . (block () ((movq (int 42) (var b))
                         (movq (var b) (var a))
                         (negq (var a))
                         (movq (int 3) (var c))
                         (addq (var a) (var c))
                         (movq (var c) (reg rax))
                         (jmp conclusion)))))))
 '(program ((var-count . 3) (locals . (a b c)))
   ((start . (block () ((movq (int 42) (deref rbp -16))
                        (movq (deref rbp -16) (deref rbp -8))
                        (negq (deref rbp -8))
                        (movq (int 3) (deref rbp -24))
                        (addq (deref rbp -8) (deref rbp -24))
                        (movq (deref rbp -24) (reg rax))
                        (jmp conclusion)))))))
