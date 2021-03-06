#lang racket/base

(require ffi/unsafe ffi/unsafe/define)

(require ;"wayland-util.rkt"
         ;"wayland-private.rkt"
         "wayland-client.rkt"
         "generated/wl_display-client.rkt"
         "generated/wl_registry-client.rkt")

;; ISSUE: libc.so is a GNU ld script, ???
(define libc (ffi-lib "libc" "6"))
(define-ffi-definer define-libc libc)
(define-libc strerror (_fun _int -> _string/utf-8))

(define (registry-handle-global data registry id interface version)
  (printf "registry-handle-global: I got called!\n ~s ~s ~s ~s ~s\n"
          data registry id interface version))

(define (registry-handle-global-remove data registry name)
  (printf "registry-handle-global-remove: I got called!\n"))

;; NOTE: this is never freed:
(define registry-listener
  (make-wl_registry_listener registry-handle-global registry-handle-global-remove))

(let ((wl-display (wl_display_connect #f)))
  (unless wl-display
    (error "failed to connect to wayland display" (strerror (saved-errno))))
  (printf "connected to wayland display ~s\n" wl-display)
  (let ((wl-registry (wl_display-get_registry wl-display)))
    (unless wl-registry
      (error "failed to connect to wayland registry"))
    (printf "got registry ~s\n" wl-registry)

    (wl_registry-add-listener wl-registry registry-listener wl-display)

    (wl_display_roundtrip wl-display)

    )
  (wl_display_disconnect wl-display))
