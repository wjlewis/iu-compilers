#lang racket

(require rackunit
         "explicate-control.rkt")

(check-equal?
 (explicate-control
  '(program info x))
 '(program info ((start . (return x)))))

(check-equal?
 (explicate-control
  '(program info (let ([x (+ 1 2)])
                   (let ([y (- x)])
                     (+ y y)))))
 '(program info ((start . (seq (assign x (+ 1 2))
                          (seq (assign y (- x))
                          (return (+ y y))))))))

(check-equal?
 (explicate-control
  '(program info (let ([x (read)])
                   (+ x t))))
 '(program info ((start . (seq (assign x (read))
                          (return (+ x t)))))))
