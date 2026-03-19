;; ---------------------------------------------------------
;; Trust Conflict Resolver
;; Resolves conflicting trust signals deterministically
;; ---------------------------------------------------------

;; -----------------------------
;; Error codes
;; -----------------------------

(define-constant ERR-INVALID-SIGNALS u600)
(define-constant ERR-UPDATE-TOO-SOON u601)

;; -----------------------------
;; Configuration constants
;; -----------------------------

(define-constant MIN-RESOLUTION-GAP u144)     ;; ~1 day
(define-constant CONFLICT-THRESHOLD u3)
(define-constant CONFLICT-PENALTY u2)
(define-constant RESOLUTION-REWARD u1)

;; -----------------------------
;; Data storage
;; -----------------------------

;; Canonical resolved trust score
(define-map resolved-trust
  principal
  uint
)

;; Last resolution block
(define-map last-resolution-block
  principal
  uint
)

;; Conflict counter
(define-map conflict-count
  principal
  uint
)

;; -----------------------------
;; Read-only helpers
;; -----------------------------

(define-read-only (get-resolved-trust (user principal))
  (default-to u0 (map-get? resolved-trust user))
)

(define-read-only (get-conflict-count (user principal))
  (default-to u0 (map-get? conflict-count user))
)

;; -----------------------------
;; Internal utilities
;; -----------------------------

(define-private (absolute-diff (a uint) (b uint)) 
  (if (> a b) (- a b) (- b a))
)

;; -----------------------------
;; Core logic
;; -----------------------------

(define-public (resolve-trust
    (positive-signal uint)
    (negative-signal uint)
    (integrity-flag uint) ;; 0 = bad, 1 = neutral, 2 = good
  )

  (let (
        (user tx-sender)
        (current-block burn-block-height)
        (last-resolve (map-get? last-resolution-block tx-sender))
       )

    (if (and (is-some last-resolve) (< (- current-block (unwrap-panic last-resolve)) MIN-RESOLUTION-GAP))
        (err ERR-UPDATE-TOO-SOON)
        
        (if (> integrity-flag u2)
            (err ERR-INVALID-SIGNALS)

              (let (
                  (current-trust (default-to u0 (map-get? resolved-trust user)))
                  (current-conflicts (default-to u0 (map-get? conflict-count user)))
                  (pos-neg (if (> positive-signal negative-signal) (- positive-signal negative-signal) u0))
                  (neg-pos (if (> negative-signal positive-signal) (- negative-signal positive-signal) u0))
                  (signal-delta (if (> positive-signal negative-signal) pos-neg neg-pos))
                 )

              ;; Severe conflict detected
              (if (> signal-delta CONFLICT-THRESHOLD)
                  (let (
                        (new-conflict-count (+ current-conflicts u1))
                        (penalized-trust
                          (if (> current-trust CONFLICT-PENALTY)
                              (- current-trust CONFLICT-PENALTY)
                              u0
                          )
                        )
                       )
                    (map-set conflict-count user new-conflict-count)
                    (map-set resolved-trust user penalized-trust)
                    (map-set last-resolution-block user current-block)
                    (ok penalized-trust)
                  )

                  ;; Signals aligned - resolve normally
                  (let (
                        (base-score
                          (if (> positive-signal negative-signal)
                              (- positive-signal negative-signal)
                              u0
                          )
                        )

                        (integrity-adjustment
                          (if (is-eq integrity-flag u2)
                              RESOLUTION-REWARD
                              u0
                          )
                        )

                        (final-score (+ base-score integrity-adjustment))
                       )
                    (map-set resolved-trust user final-score)
                    (map-set last-resolution-block user current-block)
                    (ok final-score)
                  )
              )
            )
        )
    )
  )
)
