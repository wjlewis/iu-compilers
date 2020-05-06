#lang racket

(require racket/cmdline)
(require "./1/uniquify.rkt")
(require "./2/remove-complex.rkt")
(require "./3/explicate-control.rkt")
(require "./4/uncover-locals.rkt")
(require "./5/select-instructions.rkt")
(require "./6/assign-homes.rkt")
(require "./7/patch-instructions.rkt")
(require "./8/print-x86.rkt")

(define compile
  (compose print-x86
           patch-instructions
           assign-homes
           select-instructions
           uncover-locals
           explicate-control
           remove-complex-opera*
           uniquify))

(define file-to-compile
  (command-line
    #:args (filename)
    filename))

(compile `(program ()
            ,(file->value file-to-compile)))
