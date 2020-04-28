#lang racket

(require rackunit
         "remove-complex.rkt")

(check-match
 (remove-complex-opera*
  '(program info (+ 1 (+ 2 3))))
 `(program info (let ([,aux.1 (+ 2 3)])
                  (+ 1 ,aux.1))))

(check-equal?
 (remove-complex-opera*
  '(program info (let ([x (let ([y 3]) y)])
                   x)))
 '(program info (let ([y 3])
                  (let ([x y])
                    x))))

(check-match
 (remove-complex-opera*
  '(program info (+ (let ([x 3]) (- x))
                    (+ 1 2))))
 `(program info (let ([x 3])
                  (let ([,aux.1 (- x)])
                    (let ([,aux.2 (+ 1 2)])
                      (+ ,aux.1 ,aux.2))))))

(check-equal?
 (remove-complex-opera*
  '(program info (- (let ([x (let ([y (let ([z 1])
                                        z)])
                               y)])
                       x))))
 '(program info (let ([z 1])
                  (let ([y z])
                    (let ([x y])
                      (- x))))))

(check-equal?
 (remove-complex-opera*
  '(program info (+ 1 2)))
 '(program info (+ 1 2)))

(check-match
 (remove-complex-opera*
  '(program info (+ 1 (read))))
 `(program info (let ([,aux.1 (read)])
                  (+ 1 ,aux.1))))
