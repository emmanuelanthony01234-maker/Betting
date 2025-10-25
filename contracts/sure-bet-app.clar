;; surebet-app
;; Clarity contract for a decentralized betting odds prediction platform

(define-data-var bet-counter uint u0)

(define-map bets
    { id: uint }
    {
        predictor: principal,
        event: (string-ascii 50),
        predicted-odds: uint,
        status: (string-ascii 10),
    }
)

;; Submit a betting odds prediction
(define-public (submit-prediction
        (event (string-ascii 50))
        (predicted-odds uint)
    )
    (begin
        (asserts! (> (len event) u0) (err u1))
        (asserts! (> predicted-odds u0) (err u2))
        (let ((id (var-get bet-counter)))
            (map-set bets { id: id } {
                predictor: tx-sender,
                event: event,
                predicted-odds: predicted-odds,
                status: "pending",
            })
            (var-set bet-counter (+ id u1))
            (ok id)
        )
    )
)

;; Validate a prediction
(define-public (validate-prediction (id uint))
    (match (map-get? bets { id: id })
        bet
        (if (is-eq (get status bet) "pending")
            (begin
                (map-set bets { id: id } {
                    predictor: (get predictor bet),
                    event: (get event bet),
                    predicted-odds: (get predicted-odds bet),
                    status: "validated",
                })
                (ok "Prediction validated")
            )
            (err u3)
        )
        ;; not pending
        (err u4)
    )
    ;; bet not found
)

;; Dispute a prediction
(define-public (dispute-prediction (id uint))
    (match (map-get? bets { id: id })
        bet
        (if (and (is-eq (get status bet) "pending") (is-eq tx-sender (get predictor bet)))
            (begin
                (map-set bets { id: id } {
                    predictor: (get predictor bet),
                    event: (get event bet),
                    predicted-odds: (get predicted-odds bet),
                    status: "disputed",
                })
                (ok "Prediction disputed")
            )
            (err u5)
        )
        ;; not pending or not predictor
        (err u6)
    )
    ;; bet not found
)