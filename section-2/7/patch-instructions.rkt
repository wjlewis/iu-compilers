#lang racket

(provide patch-instructions)

;; Ensure that at most one operand is a memory location by temporarily
;; moving values into %rax if necessary

(define (patch-instructions p)
  (match p
    [`(program ,info ((,labels . ,blocks) ...))
     `(program ,info
       ,(map (lambda (l b)
               `(,l . ,(patch-block b (cdr (assv 'var-count info)))))
             labels blocks))]
    [else (error 'patch-instructions "Invalid program: ~a" p)]))

(define (patch-block b var-count)
  (match b
    [`(block ,info ,insts)
     `(block ,info ,(append (setup-stack var-count)
                            (apply append (map patch-inst insts))))]
    [else (error 'patch-block "Invalid block: ~a" b)]))

(define (setup-stack var-count)
  `((pushq (reg rbp))
    (movq (reg rsp) (reg rbp))
    (subq (int ,(* var-count 8)) (reg rsp))))

(define (patch-inst inst)
  (match inst
    [`(,binop (deref rbp ,i1) (deref rbp ,i2))
     `((movq (deref rbp ,i1) (reg rax))
       (,binop (reg rax) (deref rbp ,i2)))]
    [else (list inst)]))
