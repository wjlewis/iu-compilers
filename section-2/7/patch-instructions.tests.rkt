#lang racket

(require rackunit
         "patch-instructions.rkt")

(check-equal?
 (patch-instructions
  '(program ((var-count . 3))
    ((start . (block () ((movq (int 42) (deref rbp -8))
                         (addq (deref rbp -8) (deref rbp -16))
                         (negq (deref rbp -24))
                         (addq (deref rbp -16) (deref rbp -24))
                         (movq (deref rbp -24) (reg rax))
                         (jmp conclusion)))))))
 '(program ((var-count . 3))
   ((start . (block () ((pushq (reg rbp))
                        (movq (reg rsp) (reg rbp))
                        (subq (int 24) (reg rsp))
                        (movq (int 42) (deref rbp -8))
                        (movq (deref rbp -8) (reg rax))
                        (addq (reg rax) (deref rbp -16))
                        (negq (deref rbp -24))
                        (movq (deref rbp -16) (reg rax))
                        (addq (reg rax) (deref rbp -24))
                        (movq (deref rbp -24) (reg rax))
                        (jmp conclusion)))))))
