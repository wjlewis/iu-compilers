#lang racket

(provide patch-insts)

(define (patch-insts p)
  (match p
    [`(program ,info ((,labels . ,blocks) ..1))
     `(program ,info ,(map cons
                           labels
                           (map patch-block blocks)))]))

(define (patch-block b)
  (match b
    [`(block ,info ,insts)
     `(block ,info ,(append-map patch-inst insts))]))

(define (patch-inst inst)
  (match inst
    [`(,op (deref rbp ,o1) (deref rbp ,o2))
     `((movq (deref rbp ,o1) (reg rax))
       (,op (reg rax) (deref rbp ,o2)))]
    [other (list other)]))
