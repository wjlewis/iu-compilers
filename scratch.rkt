(let ([x (+ (let ([y (let ([z 13]) (- z))])
                     (+ y y))
            (+ 42 8))])
  (+ x (read)))
