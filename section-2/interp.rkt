#lang racket

(require racket/cmdline)
(require "r1.rkt")

(define file-to-interp
  (command-line
    #:args (filename)
    filename))

(meaning `(program ()
            ,(file->value file-to-interp)))
