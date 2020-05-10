#lang racket

(require rackunit
         rackunit/text-ui
         "./uncover-locals.rkt")

(define test-uncover-locals
  (test-suite
    "uncover-locals"
    (test-case
      "It passes smoke test (1)."
      (check-equal?
        (uncover-locals '(program () ((main . (block () ((movq (int 42) (var x))
                                                         (movq (int 2) (var y))
                                                         (addq (var x) (var y))
                                                         (callq read_int)
                                                         (movq (reg rax) (var z))
                                                         (movq (var z) (var w))
                                                         (addq (var y) (var w))
                                                         (movq (var w) (reg rax))))))))
        `(program () ((main . (block ((locals . (x y z w)))
                                     ((movq (int 42) (var x))
                                      (movq (int 2) (var y))
                                      (addq (var x) (var y))
                                      (callq read_int)
                                      (movq (reg rax) (var z))
                                      (movq (var z) (var w))
                                      (addq (var y) (var w))
                                      (movq (var w) (reg rax)))))))))))


(run-tests test-uncover-locals)
