#lang racket

(provide prep-blocks)

(define (prep-blocks p)
  (match p
    [`(program ,info ((,labels . ,blocks) ..1))
      (let ([labels1 (cons 'conclusion labels)]
            [blocks1 (cons conclusion-block (map prep-block blocks))])
        `(program ,info ,(map cons labels1 blocks1)))]))

(define (prep-block b)
  (match b
    [`(block ,info ,insts)
      #:when (assv 'frame-size info)
      (let ([frame-size (cdr (assv 'frame-size info))])
        `(block ,info ,(append (create-prelude frame-size)
                               insts
                               (create-postlude 'conclusion))))]))

(define (create-prelude frame-size)
  `((pushq (reg rbp))
    (movq (reg rsp) (reg rbp))
    (subq (int ,frame-size) (reg rsp))))

(define (create-postlude continuation)
  `((popq (reg rbp))
    (jmp ,continuation)))

(define conclusion-block
  '(block () ((movq (reg rax) (reg rbx))
              (movq (int 1) (reg rax))
              (int (int #x80)))))
