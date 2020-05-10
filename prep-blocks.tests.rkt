#lang racket

(require rackunit
         rackunit/text-ui
         "./prep-blocks.rkt")

(define test-prep-blocks
  (test-suite
    "prep-blocks"
    (test-case
      "It passes smoke test (1)."
      (check-equal?
        (prep-blocks '(program () ((main . (block ((frame-size . 32) (locals . (a b c)))
                                                  ((movq (int 12) (deref rbp -8))
                                                   (callq read_int)
                                                   (movq (reg rax) (deref rbp -16))
                                                   (negq (deref rbp -16))
                                                   (movq (deref rbp -16) (reg rax))
                                                   (movq (reg rax) (deref rbp -24))
                                                   (movq (deref rbp -8) (reg rax))
                                                   (addq (deref rbp -24) (reg rax))))))))
        '(program () ((conclusion . (block () ((movq (reg rax) (reg rbx))
                                               (movq (int 1) (reg rax))
                                               (int (int #x80)))))
                      (main . (block ((frame-size . 32) (locals . (a b c)))
                                     ((pushq (reg rbp))
                                      (movq (reg rsp) (reg rbp))
                                      (subq (int 32) (reg rsp))
                                      (movq (int 12) (deref rbp -8))
                                      (callq read_int)
                                      (movq (reg rax) (deref rbp -16))
                                      (negq (deref rbp -16))
                                      (movq (deref rbp -16) (reg rax))
                                      (movq (reg rax) (deref rbp -24))
                                      (movq (deref rbp -8) (reg rax))
                                      (addq (deref rbp -24) (reg rax))
                                      (popq (reg rbp))
                                      (jmp conclusion))))))))))

(run-tests test-prep-blocks)
