#lang racket

(require rackunit
         rackunit/text-ui
         "./select-insts.rkt")

(define test-select-insts
  (test-suite
    "select-insts"
    (test-case
      "It passes smoke test (1)."
      (check-equal?
        (select-insts '(program () ((main . (return 1)))))
        '(program () ((main . (block () ((movq (int 1) (reg rax)))))))))

    (test-case
      "It passes smoke test (2)."
      (check-equal?
        (select-insts '(program () ((main . (seq (assign x (read))
                                            (seq (assign y (- x))
                                            (seq (assign z 42)
                                            (seq (assign w (+ y z))
                                            (return (- w))))))))))
        '(program () ((main . (block () ((callq read_int)
                                         (movq (reg rax) (var x))
                                         (movq (var x) (var y))
                                         (negq (var y))
                                         (movq (int 42) (var z))
                                         (movq (var y) (var w))
                                         (addq (var z) (var w))
                                         (movq (var w) (reg rax))
                                         (negq (reg rax)))))))))

    (test-case
      "It passes smoke test (3)."
      (check-equal?
        (select-insts '(program () ((main . (seq (assign x (+ 1 2))
                                            (seq (assign y 36)
                                            (seq (assign z (- y))
                                            (seq (assign w (read))
                                            (seq (assign q (- w))
                                            (return x))))))))))
        '(program () ((main . (block () ((movq (int 1) (var x))
                                         (addq (int 2) (var x))
                                         (movq (int 36) (var y))
                                         (movq (var y) (var z))
                                         (negq (var z))
                                         (callq read_int)
                                         (movq (reg rax) (var w))
                                         (movq (var w) (var q))
                                         (negq (var q))
                                         (movq (var x) (reg rax)))))))))))

(run-tests test-select-insts)
