#lang racket

(require racket/cmdline)
(require "./remove-complex.rkt")
(require "./uniquify.rkt")
(require "./explicate-control.rkt")
(require "./select-insts.rkt")
(require "./uncover-locals.rkt")
(require "./assign-homes.rkt")
(require "./patch-insts.rkt")
(require "./prep-blocks.rkt")
(require "./show-x86.rkt")

(define compile
  (compose
    show-x86
    prep-blocks
    patch-insts
    assign-homes
    uncover-locals
    select-insts
    explicate-control
    uniquify
    remove-complex))

(define file-to-compile
  (command-line
    #:args (filename)
    filename))

(let ([p `(program () ,(file->value file-to-compile))])
  (display (compile p)))
