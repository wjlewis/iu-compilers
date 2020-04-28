#lang racket

(provide lookup extend)

;; Lookup the value of NAME in ENV.
(define (lookup name env)
  (match (assv name env)
    [`(,_ . ,v) v]
    [else (error 'lookup "Unbound name: \"~a\"" name)]))

;; Extend ENV, binding NAME to VALUE.
(define (extend env name value)
  (cons (cons name value) env))
