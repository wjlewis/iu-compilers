#lang racket

(provide remove-complex)

(define (remove-complex p)
  (match p
    [`(program ,info ,e)
     `(program ,info ,(norm e))]))

;; Atomic => Int | Name
;; Simple => Atomic | (read) | (- Atomic) | (+ Atomic Atomic)
;; Complex => Simple | (let ([Name Simple]) Complex)
;;
;; `norm` always returns a complex expression, and its continuation
;; argument (k) is always applied to a simple expression.
(define (norm e [k identity])
  (match e
    [(? number?) (k e)]
    [(? symbol?) (k e)]
    ['(read) (k e)]
    [`(- ,e1) (atomize e1
               (lambda (a1)
                 (k `(- ,a1))))]
    [`(+ ,e1 ,e2)
      (atomize e1
        (lambda (a1)
          (atomize e2
            (lambda (a2)
              (k `(+ ,a1 ,a2))))))]
    [`(let ([,n1 ,e1]) ,b)
      (norm e1
       (lambda (s1)
         `(let ([,n1 ,s1])
            ,(norm b k))))]))

;; `atomize` always returns a complex expression, and its continuation
;; argument (k) is always applied to a complex expression.
(define (atomize e k)
  (norm e
   (lambda (c)
     (match c
       [(? number?) (k c)]
       [(? symbol?) (k c)]
       [else (let ([tmp (gensym 'tmp.)])
               `(let ([,tmp ,c])
                  ,(k tmp)))]))))
