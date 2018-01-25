(declare (unit audio)
         (uses utils))

(use (srfi 4))

(foreign-declare "#include <stdlib.h>
                  #include <stddef.h>
                  #include <string.h>
                  #include <stdio.h>
                  #include <stdint.h>
                  #include <math.h>
                  #include <fftw3.h>")

(foreign-declare "typedef struct wav_head {
                        char chunk_id[4];
                        uint32_t chunksize;
                        char RIFF_type[4];
                  } wav_head;

                  typedef struct format_head {
                        char chunk_id[4];
                        uint32_t chunksize;
                        uint16_t compression;
                        uint16_t channels;
                        uint32_t samplerate;
                        uint32_t bytes_per_second;
                        uint16_t block_align;
                        uint16_t bits_per_samp;
                  } format_head;

                  typedef struct data_head {
                        char chunk_id[4];
                        uint32_t chunksize;
                  } data_head;")

(define open-file
  (foreign-lambda* long ((c-string path))
    "
    FILE *f = fopen(path, \"r\");
    C_return((long) f);
    "))

(define close-file
  (foreign-lambda* void ((long file))
    "
    FILE *f = (FILE *) file;
    fclose(f);
    "))

(define read-wav-head
  (foreign-lambda* long ((long file))
    "
    wav_head *wh = (wav_head *) malloc(sizeof(wav_head));
    fread(wh, sizeof(wav_head), 1, (FILE *) file);
    C_return((long) wh);
    "))

(define free-wav-head
  (foreign-lambda* void ((long wh))
    "
    free((wav_head *) wh);
    "))

(define read-format-head
  (foreign-lambda* long ((long file))
    "
    format_head *fh = (format_head *) malloc(sizeof(format_head));
    fread(fh, sizeof(format_head), 1, (FILE *) file);
    C_return((long) fh);
    "))

(define get-samplerate
  (foreign-lambda* int ((long fh))
    "
    C_return(((format_head *) fh)->samplerate);
    "))

(define free-format-head
  (foreign-lambda* void ((long fh))
    "
    free((format_head *) fh);
    "))

(define read-data-head
  (foreign-lambda* long ((long file))
    "
    data_head *dh = (data_head *) malloc(sizeof(data_head));
    fread(dh, sizeof(data_head), 1, (FILE *) file);
    C_return((long) dh);
    "))

(define free-data-head
  (foreign-lambda* void ((long dh))
    "
    free((data_head *) dh);
    "))

(define get-data-size
  (foreign-lambda* int ((long dh))
    "
    C_return(((data_head *) dh)->chunksize);
    "))

(define read-data
  (foreign-lambda* void ((s16vector buffer) (long file) (int size))
    "
    fread(buffer, size, 1, (FILE *) file);
    "))

(define detect-onsets
  (foreign-lambda* void ((f32vector outbuf) (f32vector inbuf) (int insize))
    "
    fftw_complex *in, *out;
    fftw_plan p;
    in = (fftw_complex *) fftw_malloc(sizeof(fftw_complex) * insize);
    out = (fftw_complex *) fftw_malloc(sizeof(fftw_complex) * insize);
    for (int i = 0; i < insize; ++i) {
        in[i][0] = inbuf[i];
    }
    p = fftw_plan_dft_1d(insize, in, out, FFTW_FORWARD, FFTW_ESTIMATE);

    fftw_execute(p);

    for (int i = 0; i < insize; ++i) {
        outbuf[i] = sqrt(out[i][0] * out[i][0] + out[i][1] * out[i][1]);
    }

    fftw_destroy_plan(p);
    fftw_free(inbuf);
    fftw_free(outbuf);
    "))

(define (load-wav path)
  (let* ([f (open-file path)]
         [wh (read-wav-head f)]
         [fh (read-format-head f)]
         [dh (read-data-head f)]
         [size (get-data-size dh)]
         [data-buffer (make-s16vector size 0)])
    (read-data data-buffer f size)
    (close-file f)
    (free-wav-head wh)
    (free-format-head fh)
    (free-data-head dh)
    data-buffer))

(define (pcm->amplitudes pcm)
  (let* ([len (s16vector-length pcm)]
         [ret (make-f32vector len)])
   (let loop ([i 0])
    (if (= i len)
      #f
      (begin (f32vector-set! ret i (/ (s16vector-ref pcm i) 32768.0))
             (loop (+ i 1)))))
   ret))

(define (amplitudes->onsets amp)
  (let ([buf (make-f32vector (f32vector-length amp))])
   (detect-onsets buf amp (f32vector-length amp))
   buf))
