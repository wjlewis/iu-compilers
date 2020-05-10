#lang racket

(require rackunit
         rackunit/text-ui
         "./tools.rkt")

(define test-lookup
  (test-suite
    "lookup"
    (test-case
      "It finds the value associated with a name."
      (check-eq?
        (lookup 'a '((a . 3)))
        3))

    (test-case
      "It finds the value associated with a name."
      (check-eq?
        (lookup 'a '((b . 1) (a . 42) (c .10)))
        42))

    (test-case
      "It finds the first value associated with a name."
      (check-eq?
        (lookup 'a '((a . 13) (a . 56)))
        13))

    (test-case
      "It reports an error if the name is not bound."
      (check-exn
        exn:fail?
        (lambda ()
          (lookup 'a '((b . 10) (c . 23))))))))

(define test-extend
  (test-suite
    "extend"
    (test-case
      "It adds a new pair to the front of the env."
      (check-equal?
        (extend '((a . 1)) 'b #t)
        '((b . #t) (a . 1))))))

(define test-fresh-name
  (test-suite
    "fresh-name"
    (test-case
      "It returns the provided name if it hasn't been used."
      (check-equal?
        (fresh-name 'a '(b c))
        'a))

    (test-case
      "It adds the smallest index to a name in order to make it unique."
      (check-equal?
        (fresh-name 'a '(a a.1 a.2 a.4))
        'a.3))))

(run-tests test-lookup)
(run-tests test-extend)
(run-tests test-fresh-name)
