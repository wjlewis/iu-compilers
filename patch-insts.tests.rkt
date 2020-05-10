#lang racket

(require rackunit
         rackunit/text-ui
         "./patch-insts.rkt")

(define test-patch-insts
  (test-suite
    "patch-insts"
    (test-case
      "It passes smoke test (1)."
      (check-equal?
        (patch-insts '(program () ((main . (block ((frame-size . 16) (locals . (a b)))
                                                  ((movq (int 42) (deref rbp -8))
                                                   (movq (int 2) (deref rbp -16))
                                                   (addq (deref rbp -8) (deref rbp -16))
                                                   (movq (deref rbp -16) (reg rax))))))))
        '(program () ((main . (block ((frame-size . 16) (locals . (a b)))
                                     ((movq (int 42) (deref rbp -8))
                                      (movq (int 2) (deref rbp -16))
                                      (movq (deref rbp -8) (reg rax))
                                      (addq (reg rax) (deref rbp -16))
                                      (movq (deref rbp -16) (reg rax)))))))))))

(run-tests test-patch-insts)
