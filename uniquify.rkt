#lang racket

(require "./tools.rkt")
(provide uniquify)

(define (uniquify p)
  (match p
    [`(program ,info ,e)
     `(program ,info ,(uniquify-e e))]))

(define (uniquify-e e [env empty])
  (match e
    [(? number?) e]
    [(? symbol?) (lookup e env)]
    ['(read) e]
    [`(- ,e1) `(- ,(uniquify-e e1 env))]
    [`(+ ,e1 ,e2) `(+ ,(uniquify-e e1 env)
                      ,(uniquify-e e2 env))]
    [`(let ([,n ,e1]) ,b)
      (let* ([n1 (fresh-name n (map cdr env))]
             [env1 (extend env n n1)])
        `(let ([,n1 ,(uniquify-e e1 env)])
           ,(uniquify-e b env1)))]))
