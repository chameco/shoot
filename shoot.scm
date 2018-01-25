(declare (uses core event graphics audio))

(use sdl-base
     sdl-img)

(define (make-parametric x y) (cons x y))
(define (eval-parametric p t) (cons ((car p) t) ((cdr p) t)))

(define (player-update o g)
  (values (let ([pressed (get-prop g 'pressed)])
           (cond
             [(get-prop pressed 'up)
              (let ([p (set-prop o 'moving #t)])
                (if (get-prop pressed 'left)
                  (set-prop p 'rot (* 5/4 *pi*))
                  (if (get-prop pressed 'right)
                    (set-prop p 'rot (* 7/4 *pi*))
                    (set-prop p 'rot (* 3/2 *pi*)))))]
             [(get-prop pressed 'down)
              (let ([p (set-prop o 'moving #t)])
                (if (get-prop pressed 'left)
                  (set-prop p 'rot (* 3/4 *pi*))
                  (if (get-prop pressed 'right)
                    (set-prop p 'rot (* 1/4 *pi*))
                    (set-prop p 'rot (* 1/2 *pi*)))))]
             [(get-prop pressed 'left) (set-prop (set-prop o 'moving #t) 'rot *pi*)]
             [(get-prop pressed 'right) (set-prop (set-prop o 'moving #t) 'rot 0)]
             [else (set-prop o 'moving #f)]))
          g))

(define (projectile-update o g)
  (let ([para (get-prop o 'movefunc)]
        [curx (car (get-prop o 'pos))]
        [cury (cdr (get-prop o 'pos))])
    (if (or (< curx (- (/ *screen-width* 2))) (> curx (/ *screen-width* 2)) (< cury (- (/ *screen-height* 2))) (> cury (/ *screen-height* 2)))
      (values #f (set-prop g 'level (set-prop (get-prop g 'level) 'reveal (+ (get-prop (get-prop g 'level) 'reveal) 1))))
      (values (set-prop o 'pos (add-pos (get-prop o 'startpos) (eval-parametric para (- (get-current-time) (get-prop o 'spawntime))))) g))))

(define (spawn-projectile pos mf)
  (set-prop (set-prop (set-prop (make-object "projectile" pos 0) 'spawntime (get-current-time)) 'movefunc mf) 'startpos pos))

(make-prototype "projectile" radius: 5 update-chain: (list projectile-update))
(make-prototype "player" radius: 10 speed: 10 update-chain: (list player-update object-move-update))

;(define onsets (amplitudes->onsets (pcm->amplitudes (load-wav "test.wav"))))
;(debug onsets)

(main-game-loop
  (list (make-object "player" (cons 100 100) 0 moving: #f owner: 'player)
        (spawn-projectile (cons -600 -450)
                          (make-parametric (lambda (t) (* (sin (/ t 100)) 60))
                                           (lambda (t) (/ t 10))))
        (spawn-projectile (cons -300 -300)
                          (make-parametric (lambda (t) (* (/ t 100) (sin (/ t 100))))
                                           (lambda (t) (* (/ t 100) (cos (/ t 100)))))))
  `((pressed . ((up . #f) (down . #f) (left . #f) (right . #f)))
    (level . ((bg . ,(img-load "background.png"))
              (newbg . ,(img-load "new_background.png"))
              (reveal . 0))))
  (initialize-display)
  base-event-handler
  draw-handler
  update-handler)
