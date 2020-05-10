#lang racket

(provide uncover-locals)

(define (uncover-locals p)
  (match p
    [`(program ,info ((,labels . ,blocks) ..1))
     `(program ,info ,(map cons
                           labels
                           (map uncover-block blocks)))]))

(define (uncover-block b)
  (match b
    [`(block ,info ,insts)
     `(block ,(cons (locals insts) info) ,insts)]))

(define (locals insts)
  `(locals . ,(collect-locals insts)))

(define (collect-locals insts)
  (remove-duplicates
    (append-map inst-locals insts)))

(define (inst-locals inst)
  (match inst
    [`(,_ ,a1 ,a2) (append (arg-locals a1) (arg-locals a2))]
    [`(,_ ,a1) (arg-locals a1)]))

(define (arg-locals a)
  (match a
    [`(var ,n) (list n)]
    [else '()]))
