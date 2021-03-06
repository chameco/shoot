(declare (unit object)
         (uses utils graphics))

(use sdl-base)

(define *object-prototypes* (make-hash-table))

(define (make-prototype name #!key (radius 10) (speed 0) (update-chain '()))
  (hash-table-set! *object-prototypes* name (list
                                              (cons 'texture (string-append "textures/" name ".png"))
                                              (cons 'radius radius)
                                              (cons 'speed speed)
                                              (cons 'update-chain update-chain))))

(define (get-prototype name)
  (hash-table-ref *object-prototypes* name))

(define (make-object name pos rot #!key (moving #f) (dest #f) (owner #f))
  (list (cons 'proto (get-prototype name))
        (cons 'pos pos)
        (cons 'rot rot)
        (cons 'moving moving)
        (cons 'dest dest)
        (cons 'owner owner)))

(define (get-prop-proto o p)
  (get-prop (get-prop o 'proto) p))

(define (object-contains-point object p)
  (let* ([pos (get-prop object 'pos)]
         [ox (car pos)]
         [oy (cdr pos)]
         [x (car p)]
         [y (cdr p)]
         [rad (get-prop-proto object 'radius)]
         [distance (abs (sqrt (+ (square (- x ox)) (square (- y oy)))))])
    (< distance rad)))

(define (select-object state p modifier)
  (let loop ([l state])
   (if (null? l)
     '()
     (if (object-contains-point (car l) p)
       (cons (modifier (car l)) (cdr l))
       (cons (car l) (loop (cdr l)))))))

(define (select-object-owned-by state owner modifier)
  (let loop ([l state])
   (if (null? l)
     '()
     (if (eq? (get-prop (car l) 'owner) owner)
       (cons (modifier (car l)) (cdr l))
       (cons (car l) (loop (cdr l)))))))

(define (update-object object globals)
  (let loop ([l (get-prop-proto object 'update-chain)]
             [o object]
             [g globals])
   (if (null? l)
     (values o g)
     (call-with-values (lambda () ((car l) o g))
                       (lambda (_o _g) (loop (cdr l) _o _g))))))

(define (draw-object object camera screen)
  (let* ([pos (get-prop object 'pos)]
         [x (inexact->exact (round (car pos)))]
         [y (inexact->exact (round (cdr pos)))]
         [rad (get-prop-proto object 'radius)])
    (draw-rectangle screen camera (cons x y) (cons (* rad 2) (* rad 2)) (make-sdl-color 0 0 0))))

(define (move-object-to o d)
  (set-prop (set-prop (set-prop o 'dest d) 'rot (calculate-angle d (get-prop o 'pos))) 'moving #t))

(define (object-move-update o g)
  (values (if (get-prop o 'moving)
            (set-prop o 'pos (cons
                               (+ (car (get-prop o 'pos)) (* (cos (get-prop o 'rot)) (get-prop-proto o 'speed)))
                               (+ (cdr (get-prop o 'pos)) (* (sin (get-prop o 'rot)) (get-prop-proto o 'speed)))))
            o)
          g))

(define (object-spin-update o g)
  (values (if (get-prop o 'moving)
            (set-prop o 'rot (+ (get-prop o 'rot) 0.01))
            o)
          g))

(define (object-stop-at-dest-update o)
  (values (if (and (get-prop o 'moving) (get-prop o 'dest))
            (if (object-contains-point o (get-prop o 'dest))
              (set-prop o 'moving #f)
              o)
            o)
          g))
