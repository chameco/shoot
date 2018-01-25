(declare (unit level)
         (uses object utils))

(use sdl-base)

(define (make-level) (list))

(define (load-level path) (read-scm-file path))

(define (save-level path l) (write-scm-file path l))

(define (draw-level-background l screen)
  (sdl-fill-rect screen #f (make-sdl-color 255 255 255))
  (sdl-blit-surface (get-prop l 'bg) #f screen #f)
  (let ([tile-width (/ *screen-width* 10)]
        [tile-height (/ *screen-height* 10)]
        [reveal (get-prop l 'reveal)])
    (let loop ([i 0])
     (if (= i reveal)
       #f
       (begin
         (let ([srcrect (make-sdl-rect (* (remainder i 10) tile-width) (* (quotient i 10) tile-height) tile-width tile-height)]
               [destrect (make-sdl-rect (* (remainder i 10) tile-width) (* (quotient i 10) tile-height) tile-width tile-height)])
           (sdl-blit-surface (get-prop l 'newbg) srcrect screen destrect))
         (loop (+ i 1)))))))
