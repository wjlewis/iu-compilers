#lang racket

(require rackunit
         "uniquify.rkt")

(check-equal?
 (uniquify
  '(program info (let ([x 3])
                   (let ([x 10])
                     (+ x x)))))
 '(program info (let ([x 3])
                  (let ([x.1 10])
                    (+ x.1 x.1)))))

(check-equal?
 (uniquify
  '(program info (let ([x (let ([x 42]) x)])
                   (- (- x)))))
 '(program info (let ([x (let ([x.1 42]) x.1)])
                  (- (- x)))))

(check-equal?
 (uniquify
  '(program info (+ (let ([x 42]) x)
                    (let ([x 1]) x))))
 '(program info (+ (let ([x 42]) x)
                   (let ([x.1 1]) x.1))))

(check-equal?
 (uniquify
  '(program info (let ([x 4])
                   (let ([y 2])
                     (+ y (- x))))))
 '(program info (let ([x 4])
                  (let ([y 2])
                    (+ y (- x))))))
