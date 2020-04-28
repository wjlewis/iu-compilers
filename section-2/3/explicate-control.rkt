#lang racket

(provide explicate-control)

;; Make the order of execution explicit in the syntax of the program.

;; The C0 intermediate language:
;; Arg  => Int | Var
;; Exp  => Arg | (read) | (- Arg) | (+ Arg Arg)
;; Stmt => (assign Var Exp)
;; Tail => (return Exp) | (seq Stmt Tail)
;; C0   => (program Info ((Label . Tail) ..1))

(define (explicate-control p)
  (match p
    [`(program ,info ,e)
     `(program ,info ((start . ,(ec e))))]
    [else (error 'explicate-control "Invalid program: ~a" p)]))

(define (ec e)
  (match e
    [(? exp?) (ec-tail e)]
    [`(let ([,n1 ,e1]) ,b)
     `(seq (assign ,n1 ,e1)
        ,(ec-tail b))]
    [else (error 'ec "Invalid expression: ~a" e)]))

(define (ec-tail e)
  (match e
    [(? exp?) `(return ,e)]
    [`(let ([,n1 ,e1]) ,b) (ec e)]
    [else (error 'ec-tail "Invalid expression: ~a" e)]))

;; Return true if E is a valid C0 Exp.
(define (exp? e)
  (match e
    [(? fixnum?) #t]
    [(? symbol?) #t]
    ['(read) #t]
    [`(- ,_) #t]
    [`(+ ,_ ,_) #t]
    [else #f]))
