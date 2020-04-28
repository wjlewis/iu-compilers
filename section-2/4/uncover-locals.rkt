#lang racket

(provide uncover-locals)

;; List all Vars in the program's info.

(define (uncover-locals p)
  (match p
    [`(program ,info ,e)
     `(program ((locals . ,(collect-locals e))) ,e)]
    [else (error 'uncover-locals "Invalid program: ~a" p)]))

(define (collect-locals e)
  (match e
    [`((,labels . ,tails) ..1)
     (set->list
      (apply set-union (map collect-tail tails)))]
    [else (error 'collect-locals "Invalid segment: ~a" e)]))

(define (collect-tail tail)
  (match tail
    [`(return ,e) (collect-exp e)]
    [`(seq ,stmt ,tail)
     (set-union (collect-stmt stmt)
                (collect-tail tail))]
    [else (error 'collect-tail "Invalid tail: ~a" tail)]))

(define (collect-exp e)
  (match e
    [(? symbol?) (set e)]
    [(? fixnum?) (set)]
    ['(read) (set)]
    [`(- ,a1) (collect-arg a1)]
    [`(+ ,a1 ,a2) (set-union (collect-arg a1) (collect-arg a2))]
    [else (error 'collect-exp "Invalid expression: ~a" e)]))

(define (collect-arg a)
  (match a
    [(? symbol?) (set a)]
    [(? fixnum?) (set)]
    [else (error 'collect-arg "Invalid arg: ~a" a)]))

(define (collect-stmt stmt)
  (match stmt
    [`(assign ,name ,e) (set-add (collect-exp e) name)]
    [else (error 'collect-stmt "Invalid statement: ~a" stmt)]))
