#lang racket

(require rackunit
         rackunit/text-ui
         "./remove-complex.rkt")

(define test-remove-complex
  (test-suite
    "remove-complex"
    (test-case
      "It unwraps compound arithmetic expressions (1)."
      (check-match
        (remove-complex '(program () (+ 1 (+ 2 3))))
        `(program () (let ([,tmp.1 (+ 2 3)])
                       (+ 1 ,tmp.1)))))

    (test-case
      "It unwraps compound arithmetic expressions (2)."
      (check-match
        (remove-complex '(program () (+ a (+ (- b) (+ a d)))))
        `(program () (let ([,tmp.1 (- b)])
                       (let ([,tmp.2 (+ a d)])
                         (let ([,tmp.3 (+ ,tmp.1 ,tmp.2)])
                           (+ a ,tmp.3)))))))

    (test-case
      "It creates a temporary name for (read) expressions (1)."
      (check-match
        (remove-complex '(program () (+ (read) (- a))))
        `(program () (let ([,tmp.1 (read)])
                       (let ([,tmp.2 (- a)])
                         (+ ,tmp.1 ,tmp.2))))))

    (test-case
      "It unwraps nested `let`s."
      (check-equal?
        (remove-complex '(program () (let ([x (let ([y 42]) (- y))])
                                       (+ x x))))
        '(program () (let ([y 42])
                       (let ([x (- y)])
                         (+ x x))))))))

(run-tests test-remove-complex)
