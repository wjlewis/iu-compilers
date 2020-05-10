#lang racket

(require rackunit
         rackunit/text-ui
         "./show-x86.rkt")

(define test-show-x86
  (test-suite
    "show-x86"
    (test-case
      "It passes smoke test (1)."
      (check-equal?
        (show-x86 '(program () ((conclusion . (block () ((movq (int 1) (reg rbx))
                                                         (movq (int 0) (reg rax))
                                                         (int (int 128)))))
                                (main . (block () ((movq (int 42) (deref rbp -8))
                                                   (negq (deref rbp -8))
                                                   (callq read_int)
                                                   (movq (reg rax) (deref rbp -16))
                                                   (movq (deref rbp -16) (reg rax))
                                                   (addq (deref rbp -8) (reg rax))
                                                   (negq (reg rax))
                                                   (jmp conclusion)))))))
        (string-join '("\t.section .text"
                       "\t.globl main"
                       "conclusion:"
                       "\tmovq\t$1, %rbx"
                       "\tmovq\t$0, %rax"
                       "\tint\t$128"
                       "main:"
                       "\tmovq\t$42, -8(%rbp)"
                       "\tnegq\t-8(%rbp)"
                       "\tcallq\tread_int"
                       "\tmovq\t%rax, -16(%rbp)"
                       "\tmovq\t-16(%rbp), %rax"
                       "\taddq\t-8(%rbp), %rax"
                       "\tnegq\t%rax"
                       "\tjmp\tconclusion\n")
                     "\n")))))

(run-tests test-show-x86)
