#lang racket

(require rackunit
         "select-instructions.rkt")

(check-equal?
 (select-instructions
  '(program () ((start . (seq (assign x 3)
                         (seq (assign y (+ x x))
                         (seq (assign z (read))
                         (return (+ y z)))))))))
 '(program ()
   ((start . (block () ((movq (int 3) (var x))
                        (movq (var x) (var y))
                        (addq (var x) (var y))
                        (callq read_int)
                        (movq (reg rax) (var z))
                        (movq (var y) (reg rax))
                        (addq (var z) (reg rax))
                        (jmp conclusion)))))))

(check-equal?
 (select-instructions
  '(program () ((start . (seq (assign x 42)
                         (return (+ x x))))
                (another . (seq (assign x 3)
                           (seq (assign y (- x))
                           (return y)))))))
 '(program ()
   ((start . (block () ((movq (int 42) (var x))
                        (movq (var x) (reg rax))
                        (addq (var x) (reg rax))
                        (jmp conclusion))))
    (another . (block () ((movq (int 3) (var x))
                          (movq (var x) (var y))
                          (negq (var y))
                          (movq (var y) (reg rax))
                          (jmp conclusion)))))))
