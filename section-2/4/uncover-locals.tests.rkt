#lang racket

(require rackunit
         "uncover-locals.rkt")

(check-match
 (uncover-locals
  '(program info ((start . (seq (assign x (+ 1 y))
                           (return (- x)))))))
  `(program ((locals . ,locals)) ,_)
  (set=? (list->set locals)
         (set 'x 'y)))

(check-match
 (uncover-locals
  '(program info ((start . (seq (assign x (- x))
                           (seq (assign y x)
                           (seq (assign z (+ x y))
                           (return (+ z w)))))))))
 `(program ((locals . ,locals)) ,_)
 (set=? (list->set locals)
        (set 'x 'y 'z 'w)))

(check-match
 (uncover-locals
  '(program info ((start . (seq (assign x (+ 3 5))
                           (seq (assign y (- x))
                           (return (+ y 5))))))))
 `(program ,_ ((start . (seq (assign x (+ 3 5))
                        (seq (assign y (- x))
                        (return (+ y 5))))))))
