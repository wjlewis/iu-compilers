#lang racket

(require rackunit
         rackunit/text-ui
         "./uniquify.rkt")

(define test-uniquify
  (test-suite
    "uniquify"
    (test-case
      "It doesn't transform expressions that don't include a `let`."
      (let ([p '(program () (+ (- 3) (+ (read) (+ 2 3))))])
        (check-equal? (uniquify p) p)))

    (test-case
      "It doesn't transform expressions in which no shadowing occurs."
      (let ([p '(program () (let ([x 10])
                              (let ([y (let ([z 24]) (- z))])
                                (+ x (+ y (read))))))])
        (check-equal? (uniquify p) p)))

    (test-case
      "It replaces shadowed names with fresh names."
      (check-equal?
        (uniquify '(program () (let ([x 3])
                                 (let ([x 42])
                                   (+ x x)))))
        '(program () (let ([x 3])
                       (let ([x.1 42])
                         (+ x.1 x.1))))))

    (test-case
      "It correctly handles complicated shadowing scenarios."
      (check-equal?
        (uniquify '(program () (let ([x 1])
                                 (let ([x x])
                                   (let ([x x])
                                     (let ([x x])
                                       x))))))
        '(program () (let ([x 1])
                       (let ([x.1 x])
                         (let ([x.2 x.1])
                           (let ([x.3 x.2])
                             x.3)))))))

    (test-case
      "It allows multiple uses of the same name, as long as no shadowing occurs."
      (let ([p '(program () (+ (let ([x (let ([x 3]) x)])
                                 x)
                               (let ([x 42])
                                 (+ x (read)))))])
        (check-equal? (uniquify p) p)))))

(run-tests test-uniquify)
