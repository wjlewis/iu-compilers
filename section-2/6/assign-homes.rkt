#lang racket

(provide assign-homes)

;; Assign each var a location on the stack

(define (assign-homes p)
  (match p
    [`(program ,info ((,labels . ,blocks) ...))
     #:when (assv 'locals info)
     (let ([homes (generate-homes (cdr (assv 'locals info)))])
       `(program ((var-count . ,(length homes)) ,@info)
         ,(map (lambda (l b)
                 `(,l . ,(assign-homes-in-block b homes)))
               labels blocks)))]
    [else (error 'assign-homes "Invalid program: ~a" p)]))

(define (assign-homes-in-block block homes)
  (match block
    [`(block ,info ,stmts)
     `(block ,info ,(map (lambda (s) (assign-homes-in-stmt s homes))
                         stmts))]
    [else (error 'assign-homes-in-block "Invalid block: ~a" block)]))

(define (assign-homes-in-stmt stmt homes)
  (match stmt
    [`(movq ,a ,b)
     `(movq ,(assign-home a homes) ,(assign-home b homes))]
    [`(addq ,a ,b)
     `(addq ,(assign-home a homes) ,(assign-home b homes))]
    [`(negq ,a)
     `(negq ,(assign-home a homes))]
    [`(callq ,label) stmt]
    [`(jmp ,label) stmt]
    [else (error 'assign-homes-in-stmt "Invalid stmt: ~a" stmt)]))

(define (assign-home place homes)
  (match place
    [`(var ,v) `(deref rbp ,(cdr (assv v homes)))]
    [`(reg ,r) place]
    [`(int ,n) place]
    [else (error 'assign-home "Invalid place: ~a" place)]))

(define (generate-homes names [offset 1])
  (if (empty? names)
      empty
      (cons `(,(first names) . ,(* offset -8))
            (generate-homes (rest names) (add1 offset)))))
