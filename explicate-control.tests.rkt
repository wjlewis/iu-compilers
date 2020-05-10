#lang racket

(require rackunit
         rackunit/text-ui
         "./explicate-control.rkt")

(define test-explicate-control
  (test-suite
    "explicate-control"
    (test-case
      "It simply returns simple expressions (1)."
      (check-equal?
        (explicate-control '(program () (+ 1 2)))
        '(program () ((main . (return (+ 1 2)))))))

    (test-case
      "It simply returns simple expressions (2)."
      (check-equal?
        (explicate-control '(program () (read)))
        '(program () ((main . (return (read)))))))

    (test-case
      "It transforms `let`s into sequences."
      (check-equal?
        (explicate-control '(program () (let ([x 3])
                                          (let ([y (- x)])
                                            (let ([z (read)])
                                              (let ([w (+ z 3)])
                                                (+ y w)))))))
        '(program () ((main . (seq (assign x 3)
                              (seq (assign y (- x))
                              (seq (assign z (read))
                              (seq (assign w (+ z 3))
                              (return (+ y w)))))))))))))

(run-tests test-explicate-control)
