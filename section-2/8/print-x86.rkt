#lang racket

(provide print-x86)

;; Print a program as a valid x86 assembly program

(define segment-info
  (string-join (list "\t.section .text" "\t.globl main") "\n"))

(define conclusion-block
  '(block () ((movq (reg rax) (reg rbx))
              (movq (int 1) (reg rax))
              (int (int #x80)))))

(define (print-x86 p)
  (match p
    [`(program ,info ((,labels . ,blocks) ...))
     (displayln (string-join
                 (cons segment-info
                       (map show-block
                            (cons 'conclusion labels)
                            (cons conclusion-block blocks)))
                 "\n"))]
    [else (error 'print-x86 "Invalid program: ~a" p)]))

(define (show-block label block)
  (match block
    [`(block ,info ,insts)
     (string-append (show-label label)
                    "\n"
                    (string-join (map show-inst insts) "\n"))]
    [else (error 'show-block "Invalid block: ~a" block)]))

(define (show-label label)
  (string-append (symbol->string label) ":"))

(define (show-inst inst)
  (match inst
    [`(,op ,args ...)
     (string-append "\t"
                    (symbol->string op)
                    "\t"
                    (string-join (map show-arg args) ", "))]
    [else (error 'show-inst "Invalid inst: ~a" inst)]))

(define (show-arg arg)
  (match arg
   [`(int ,n) (string-append "$" (number->string n))]
   [`(reg ,r) (string-append "%" (symbol->string r))]
   [`(deref ,r ,i) (string-append (number->string i)
                                 "("
                                  (show-reg r)
                                  ")")]
   [(? symbol?) (symbol->string arg)]
   [else (error 'show-arg "Invalid arg: ~a" arg)]))

(define (show-reg r)
  (string-append "%" (symbol->string r)))
