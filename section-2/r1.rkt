#lang racket

(require "../tools/tools.rkt")
(provide meaning)

;; The R1 language
;; along with an interpreter demonstrating its semantics

;; Exp => Int | (read) | (- Exp) | (+ Exp Exp)
;;     |  Name | (let ([Name Exp]) Exp)
;; R1  => (program Info Exp)

(define (meaning p)
  (match p
    [`(program ,_ ,e) (meaning-e e)]
    [else (error 'meaning "Invalid program ~a" p)]))

(define (meaning-e e [env empty])
  (match e
    [(? fixnum?) e]
    ['(read)
     (let ([r (read)])
       (if (fixnum? r)
           r
           (error 'meaning-e "Expected a fixnum, not ~a" r)))]
    [`(- ,e1)
     (let ([v1 (meaning-e e1 env)])
       (- v1))]
    [`(+ ,e1 ,e2)
     (let ([v1 (meaning-e e1 env)]
           [v2 (meaning-e e2 env)])
       (+ v1 v2))]
    [(? symbol?) (lookup e env)]
    [`(let ([,n1 ,e1]) ,b)
     (meaning-e b (extend env n1 (meaning-e e1 env)))]
    [else (error 'meaning-e "Invalid expression ~a" e)]))
