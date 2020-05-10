#lang racket

(provide assign-homes)

(define bytes-per-quad 8)

(define (assign-homes p)
  (match p
    [`(program ,info ((,labels . ,blocks) ..1))
     `(program ,info ,(map cons
                           labels
                           (map block-homes blocks)))]))

(define (block-homes b)
  (match b
    [`(block ,info ,insts)
      #:when (assv 'locals info)
      (let ([locals (cdr (assv 'locals info))])
        (let ([homes (create-homes locals)]
              [frame-size (compute-frame-size (length locals))])
          `(block ,(cons `(frame-size . ,frame-size) info)
                  ,(replace-vars insts homes))))]))

(define (create-homes vars)
  (let ([indices (map (lambda (i)
                        (- (* i bytes-per-quad)))
                      (range 1 (add1 (length vars))))])
    (map cons vars indices)))

(define (replace-vars insts homes)
  (map (lambda (inst)
         (replace-vars-in-inst inst homes))
       insts))

(define (replace-vars-in-inst inst homes)
  ;; HACK
  (map (lambda (piece)
         (match piece
           [`(var ,v) (let ([offset (cdr (assv v homes))])
                        `(deref rbp ,offset))]
           [other other]))
       inst))

(define (compute-frame-size local-count)
  (let* ([byte-count (* bytes-per-quad local-count)]
         [rem (remainder byte-count 16)])
    (+ rem byte-count)))

