#lang racket

(provide remove-complex-opera*)

;; Transform the input program into A-Normal Form.

(define (remove-complex-opera* p)
  (match p
    [`(program ,info ,e)
     `(program ,info ,(anf e))]
    [else (error 'remove-complex-opera*
                 "Invalid program: ~a" p)]))

;; AExp => Number | Name
;; CExp => (- AExp)
;;      |  (+ AExp AExp)
;;      |  (read)
;;      |  AExp
;; Exp  => CExp
;;      |  (let ([Name CExp]) Exp)

;; Normalize E and apply K to the resulting term.
;; Note: K is always applied to a CExp, and the result is always an Exp:
;;
;; (: anf (-> (* InExp CCont)
;;          Exp))
;; (define-type CCont (-> CExp Exp))
(define (anf e [k identity])
  (match e
    [(? atomic?) (k e)]
    ['(read) (k e)]
    [`(- ,e1)
     (atomize e1
      (lambda (a1)
        (k `(- ,a1))))]
    [`(+ ,e1 ,e2)
     (atomize e1
      (lambda (a1)
        (atomize e2
         (lambda (a2)
           (k `(+ ,a1 ,a2))))))]
    [`(let ([,n1 ,e1]) ,b)
     (anf e1
      (lambda (c1)
        `(let ([,n1 ,c1])
           ,(anf b k))))]
    [else (error 'anf "Invalid expression: ~a" e)]))

;; Transform e into an AExp. If e is already atomic, apply K to e;
;; otherwise, apply K to the temporary name generated to be bound to
;; the complex expression.
;;
;; (: atomize (-> (* InExp ACont)
;;              Exp))
;; (define-type ACont (-> AExp Exp))
(define (atomize e k)
  (anf e
   (lambda (c)
     (if (atomic? c)
         (k c)
         (let ([n (gensym 'tmp.)])
           `(let ([,n ,c])
              ,(k n)))))))

(define (atomic? e)
  (match e
    [(? fixnum?) #t]
    [(? symbol?) #t]
    [else #f]))
