#lang racket

(provide w/env
         ->env
         get-env
         put-env
         run-w/env)

;; Mimic the do-syntax for the State Monad.
;; For example:
;;
;; (w/env ([res1 (app arg1 arg2)]
;;         [res2 (w/result res1)])
;;   (->env (+ res1 res2)))
;;
;; is transformed into:
;;
;; (>>=env (app arg1 arg2)
;;  (lambda (res1)
;;    (>>=env (w/result res1)
;;     (lambda (res2)
;;       (->env (+ res1 res2))))))
(define-syntax w/env
  (syntax-rules (let)
    [(w/env () result) result]
    [(w/env ((let [n e]) [ns es] ...) result)
     (let ([n e])
       (w/env ([ns es] ...)
         result))]
    [(w/env ([n e] [ns es] ...) result)
     (>>=env e
      (lambda (n)
        (w/env ([ns es] ...) result)))]))

;; Bring a value X into the State Monad.
(define (->env x)
  (lambda (env)
    (cons x env)))

;; Chain a computation in the State Monad.
(define (>>=env sr f)
  (lambda (env)
    (match (sr env)
      [`(,x . ,env1) ((f x) env1)]
      [else (error '>>= "Invalid state runner")])))

;; Bring the current environment into the value.
(define get-env
  (lambda (env)
    (cons env env)))

;; Replace the current environment with ENV.
(define (put-env env)
  (lambda (_)
    (cons empty env)))

;; Run a computation X with environment ENV.
(define (run-w/env x [env empty])
  (car (x env)))
