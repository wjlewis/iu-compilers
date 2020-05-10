#lang racket

(provide select-insts)

(define (select-insts p)
  (match p
    [`(program ,info ((,labels . ,tails) ..1))
     `(program ,info
               ,(map cons
                     labels
                     (map block->x86 tails)))]))

(define (block->x86 t)
  `(block () ,(tail->x86 t)))

(define (tail->x86 t)
  (match t
    [`(return ,e) (return->x86 e)]
    [`(seq ,s ,t) (append (stmt->x86 s)
                          (tail->x86 t))]))

(define (stmt->x86 s)
  (match s
    [`(assign ,n ,e) (exec-in e n)]))

(define (return->x86 e)
  (exec-in e '(reg rax)))

;; target is either (reg RegName) or a symbol representing a var.
(define (exec-in e target)
  (let ([t (target->x86 target)])
    (match e
      [(? number?) `((movq ,(target->x86 e) ,t))]
      [(? symbol?)
       #:when (eq? e target)
       '()]
      [(? symbol?) `((movq ,(target->x86 e) ,t))]
      ['(read)
       #:when (equal? target '(reg rax))
       `((callq read_int))]
      ['(read)
       `((callq read_int)
         (movq (reg rax) ,t))]
      [`(- ,e1)
        #:when (eq? e1 target)
        `((negq ,t))]
      [`(- ,e1) `((movq ,(target->x86 e1) ,t)
                  (negq ,t))]
      [`(+ ,e1 ,e2)
        #:when (eq? e1 target)
        `((addq ,(target->x86 e2) ,t))]
      [`(+ ,e1 ,e2)
        #:when (eq? e2 target)
        `((addq ,(target->x86 e1) ,t))]
      [`(+ ,e1 ,e2)
        `((movq ,(target->x86 e1) ,t)
          (addq ,(target->x86 e2) ,t))])))

(define (target->x86 target)
  (match target
    [(? number?) `(int ,target)]
    [(? symbol?) `(var ,target)]
    ['(reg rax) target]))
