(declare (unit event)
         (uses object utils graphics))

(use sdl-base)

(define (base-event-handler state running camera globals event)
  (let ([event-type (sdl-event-type event)])
   (cond
     [(= event-type SDL_QUIT) (values state #f camera globals)]
     [(= event-type SDL_KEYDOWN)
      (let ([keysym (sdl-event-sym event)])
        (cond
          [(= keysym SDLK_w) (values state running camera (set-prop globals 'pressed (set-prop (get-prop globals 'pressed) 'up #t)))]
          [(= keysym SDLK_s) (values state running camera (set-prop globals 'pressed (set-prop (get-prop globals 'pressed) 'down #t)))]
          [(= keysym SDLK_a) (values state running camera (set-prop globals 'pressed (set-prop (get-prop globals 'pressed) 'left #t)))]
          [(= keysym SDLK_d) (values state running camera (set-prop globals 'pressed (set-prop (get-prop globals 'pressed) 'right #t)))]
          [else (values state running camera globals)]))]
     [(= event-type SDL_KEYUP)
      (let ([keysym (sdl-event-sym event)])
        (cond
          [(= keysym SDLK_w) (values state running camera (set-prop globals 'pressed (set-prop (get-prop globals 'pressed) 'up #f)))]
          [(= keysym SDLK_s) (values state running camera (set-prop globals 'pressed (set-prop (get-prop globals 'pressed) 'down #f)))]
          [(= keysym SDLK_a) (values state running camera (set-prop globals 'pressed (set-prop (get-prop globals 'pressed) 'left #f)))]
          [(= keysym SDLK_d) (values state running camera (set-prop globals 'pressed (set-prop (get-prop globals 'pressed) 'right #f)))]
          [else (values state running camera globals)]))]
     [else (values state running camera globals)])))
