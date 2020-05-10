#lang racket

(require rackunit
         rackunit/text-ui
         "./assign-homes.rkt")

(define test-assign-homes
  (test-suite
    "assign-homes"
    (test-case
      "It passes smoke test (1)."
      (check-equal?
        (assign-homes '(program () ((main . (block ((locals . (x y z)))
                                                   ((movq (int 42) (var x))
                                                    (movq (var x) (var y))
                                                    (negq (var y))
                                                    (addq (var y) (var z))
                                                    (movq (var z) (reg rax))))))))
        '(program () ((main . (block ((frame-size . 32) (locals . (x y z)))
                                     ((movq (int 42) (deref rbp -8))
                                      (movq (deref rbp -8) (deref rbp -16))
                                      (negq (deref rbp -16))
                                      (addq (deref rbp -16) (deref rbp -24))
                                      (movq (deref rbp -24) (reg rax)))))))))))

(run-tests test-assign-homes)
