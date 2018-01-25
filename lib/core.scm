(declare (unit core)
         (uses audio utils graphics object level))

(use sdl-base
     posix)

(define (initialize-display)
  (sdl-init SDL_INIT_VIDEO)
  (sdl-wm-set-caption "shoot" #f)
  (let ([screen (sdl-set-video-mode 0 0 16 0)])
   (if screen
     (begin
       (initialize-graphics (cons (sdl-surface-width screen) (sdl-surface-height screen)))
       screen)
     (log-err "Failed to initialize display"))))

(define (main-game-loop initial-state initial-globals screen event-handler draw-handler update-handler)
  (let ([event (make-sdl-event)])
   (let loop ([state initial-state]
              [running #t]
              [camera (cons 0 0)]
              [globals initial-globals]
              [time (get-current-time)])
     (if running
       (begin
         (sdl-delay 5)
         (draw-handler state camera globals screen)
         (let ([newtime (get-current-time)])
          (if (< (- newtime time) 40)
            (loop state running camera globals time)
            (call-with-values (lambda ()
                                (let event-poll-loop ([s state]
                                                      [r running]
                                                      [c camera]
                                                      [g globals])
                                  (if (sdl-poll-event! event)
                                    (call-with-values (lambda () (event-handler s r c g event))
                                                      event-poll-loop)
                                    (values s r c g))))
                              (lambda (state running camera globals) (call-with-values (lambda () (update-handler state running camera globals))
                                                                                       (lambda (s r c g) (loop s r c g newtime))))))))))))

(define (draw-handler state camera globals screen)
  (draw-level-background (get-prop globals 'level) screen)
  (let loop ([l state])
   (if (not (null? l))
     (begin
       (draw-object (car l) camera screen)
       (loop (cdr l)))))
  (sdl-flip screen))

(define (update-handler state running camera globals)
  (let loop ([l state]
             [s '()]
             [g globals])
   (if (null? l)
     (values s running camera g)
     (call-with-values (lambda () (update-object (car l) g))
                       (lambda (_o _g) (loop (cdr l) (if _o (cons _o s) s) _g))))))
