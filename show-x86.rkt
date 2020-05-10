#lang racket

(provide show-x86)

(define (show-x86 p)
  (match p
    [`(program ,_ ((,labels . ,blocks) ..1))
      (string-append header
                     "\n"
                     (string-join
                       (map show-block labels blocks)
                       "\n")
                     "\n")]))

(define (show-block label b)
  (match b
    [`(block ,_ ,insts)
      (string-append (show-label label)
                     "\n"
                     (string-join
                       (map show-inst insts)
                       "\n"))]))

(define (show-label text)
  (string-append (symbol->string text) ":"))

(define (show-inst inst)
  (string-append
    "\t"
    (match inst
      [`(,op ,a1) (string-append (symbol->string op)
                                 "\t"
                                 (show-arg a1))]
      [`(,op ,a1 ,a2) (string-append (symbol->string op)
                                     "\t"
                                     (show-arg a1)
                                     ", "
                                     (show-arg a2))])))

(define (show-arg a)
  (match a
    [(? symbol?) (symbol->string a)]
    [`(int ,n) (string-append "$" (number->string n))]
    [`(reg ,r) (string-append "%" (symbol->string r))]
    [`(deref ,r ,o) (string-append (number->string o)
                                   "(%"
                                   (symbol->string r)
                                   ")")]))

(define header
  (string-append
    "\t.section .text"
    "\n"
    "\t.globl main"))
