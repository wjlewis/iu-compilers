#lang racket

(provide lookup extend fresh-name)

(define (lookup name env)
  (match (assv name env)
    [`(,_ . ,v) v]
    [else (error 'lookup "Unbound name: ~a" name)]))

(define (extend env name value)
  (cons `(,name . ,value) env))

(define (fresh-name hint used)
  (let loop ([cand hint] [index 1])
    (if (not (memv cand used))
      cand
      (loop (append-index hint index)
            (add1 index)))))

(define (append-index name i)
  (string->symbol
    (string-append (symbol->string name)
                   "."
                   (number->string i))))
