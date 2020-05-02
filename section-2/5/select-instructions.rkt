#lang racket

(provide select-instructions)

;; The X86_0 language:
;; Reg   => rsp | rbp | rax | rbx | rcx | rdx | rsi | rdi
;;       |  r8 | r9 | r10 | r11 | r12 | r13 | r14 | r15
;; Arg   => (int Int) | (reg Reg) | (deref Reg Int) | (var Name)
;; Instr => (addq Arg Arg) | (subq Arg Arg) | (movq Arg Arg)
;;       |  (jmp Label) | (negq Arg) | (callq Label) | (pushq Arg)
;;       |  (popq Arg)
;; Block => (block Info Instr ..1)
;; X86_0 => (program Info ((Label . Block) ..1))

;; Translate (roughly) C0 toX86_0.

(define (select-instructions p)
  (match p
    [`(program ,info ((,labels . ,tails) ...))
     `(program ,info
       ,(map (lambda (l t)
               `(,l . (block () ,(tail t 'conclusion))))
            labels tails))]
    [else (error 'select-instructions "Invalid program: ~a" p)]))

(define (tail t cont)
  (match t
    [`(return ,e) `(,@(exp e '(reg rax)) (jmp ,cont))]
    [`(seq ,s ,t1) (append (stmt s) (tail t1 cont))]
    [else (error 'tail "Invalid tail: ~a" t)]))

(define (stmt s)
  (match s
    [`(assign ,v ,e) (exp e `(var ,v))]
    [else (error 'stmt "Invalid stmt: ~a" s)]))

(define (exp e target)
  (match e
    [(? number?) `((movq ,(arg e) ,target))]
    [(? symbol?)
     #:when (matches-target? e target)
     '()]
    [(? symbol?) `((movq ,(arg e) ,target))]
    ['(read) `((callq read_int)
               (movq (reg rax) ,target))]
    [`(- ,a)
     #:when (matches-target? a target)
     `((negq ,target))]
    [`(- ,a) `((movq ,(arg a) ,target)
               (negq ,target))]
    [`(+ ,a1 ,a2)
     #:when (matches-target? a1 target)
     `((addq ,(arg a2) ,target))]
    [`(+ ,a1 ,a2)
     #:when (matches-target? a2 target)
     `((addq ,(arg a1) ,target))]
    [`(+ ,a1 ,a2) `((movq ,(arg a1) ,target)
                    (addq ,(arg a2) ,target))]
    [else (error 'exp "Invalid expression: ~a" e)]))

(define (matches-target? name target)
  (match target
    [`(var ,v) (eq? v name)]
    [else #f]))

(define (arg a)
  (match a
    [(? number?) `(int ,a)]
    [(? symbol?) `(var ,a)]
    [else (error 'arg "Invalid arg: ~a" a)]))
