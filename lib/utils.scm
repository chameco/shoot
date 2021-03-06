(declare (unit utils))

(use posix)

(define (log-err msg)
  (display (string-append "Error: " msg) (current-error-port))
  (newline (current-error-port))
  (exit 1))

(define (debug msg)
  (display msg (current-error-port))
  (newline (current-error-port))
  msg)

(define (read-scm-file path)
  (if (regular-file? path)
    (with-input-from-file
      path
      (lambda () (read)))
    (log-err (string-append "File \"" path "\" does not exist."))))

(define (write-scm-file path data)
  (with-output-to-file
    path
    (lambda () (write data))))

(define *pi* 3.141592654)

(define (get-current-time) (current-milliseconds))

(define (square x) (* x x))

(define (id x) x)

(define (sign x) (if (= x 0) 0 (/ x (abs x))))

(define (get-prop o p)
  (let ([r (assq p o)])
   (if r
     (cdr (assq p o))
     (log-err (string-append "Invalid property \"" (symbol->string p) "\"")))))

(define (keep-first alist k)
  (let loop ([l alist])
   (if (null? l)
     '()
     (if (eq? (caar l) k)
       (cons (car l)
             (let loop2 ([l2 (cdr l)])
              (if (null? l2)
                '()
                (if (eq? (caar l2) k)
                  (loop2 (cdr l2))
                  (cons (car l2) (loop2 (cdr l2)))))))
       (cons (car l) (loop (cdr l)))))))

(define (add-pos p1 p2)
  (cons (+ (car p1) (car p2)) (+ (cdr p1) (cdr p2))))

(define (set-prop o p v) (keep-first (cons (cons p v) o) p))

(define (calculate-angle point origin)
  (let* ([deltax (- (car point) (car origin))]
         [deltay (- (cdr point) (cdr origin))]
         [theta (atan (/ deltay deltax))])
    (if (< deltax 0)
      (+ theta *pi*)
      theta)))
