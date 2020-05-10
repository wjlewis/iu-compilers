#lang racket

(provide explicate-control)

(define (explicate-control p)
  (match p
    [`(program ,info ,e)
     `(program ,info ,(r1->c0 e))]))

(define (r1->c0 e)
  `((main . ,(ec-tail e))))

(define (ec-tail e)
  (match e
    [(? number?) `(return ,e)]
    [(? symbol?) `(return ,e)]
    ['(read) `(return ,e)]
    [`(- ,_) `(return ,e)]
    [`(+ ,_ ,_) `(return ,e)]
    [`(let ([,n1 ,e1]) ,b)
     `(seq ,(ec-assign n1 e1)
           ,(ec-tail b))]))

(define (ec-assign n e)
  `(assign ,n ,e))
