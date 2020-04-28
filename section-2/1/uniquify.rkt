#lang racket

(require "tools.rkt")
(require "env.rkt")
(provide uniquify)

;; Ensure that each `let` uses a unique name.

(define (uniquify p)
  (match p
    [`(program ,info ,e)
     `(program ,info ,(run-w/env (uniquify-e e)))]
    [else (error 'uniquify "Invalid program: ~a" p)]))

(define (uniquify-e e)
  (match e
    [(? fixnum?) (->env e)]
    ['(read) (->env '(read))]
    [`(- ,e1)
     (w/env ([ue1 (uniquify-e e1)])
       (->env `(- ,ue1)))]
    [`(+ ,e1 ,e2)
     (w/env ([ue1 (uniquify-e e1)]
             [ue2 (uniquify-e e2)])
       (->env `(+ ,ue1 ,ue2)))]
    [(? symbol?)
     (w/env ([env get-env])
       (->env (lookup e env)))]
    [`(let ([,n1 ,e1]) ,b)
     (w/env ([env get-env]
             (let [n1* (fresh-name n1 (map car env))])
             [_ (put-env (extend env n1 n1*))]
             [ub (uniquify-e b)]
             [ue1 (uniquify-e e1)])
       (->env `(let ([,n1* ,ue1])
                 ,ub)))]
    [else (error 'uniquify "Invalid expression: ~a" e)]))

(define (fresh-name hint used)
  (let loop ([try hint] [index 1])
    (if (memv try used)
        (loop (append-index hint index)
              (add1 index))
        try)))

(define (append-index name index)
  (string->symbol
   (string-append (symbol->string name)
                  "."
                  (number->string index))))
