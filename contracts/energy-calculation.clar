;; Energy Calculation System Contract

(define-data-var calculation-count uint u0)

(define-map energy-calculations
  uint
  {
    simulation-id: uint,
    calculator: principal,
    energy-value: int,
    calculation-method: (string-ascii 50),
    timestamp: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_CALCULATION (err u404))

(define-public (submit-energy-calculation (simulation-id uint) (energy-value int) (calculation-method (string-ascii 50)))
  (let
    (
      (calculation-id (+ (var-get calculation-count) u1))
    )
    (asserts! (is-some (contract-call? .cosmic-string-simulation get-simulation simulation-id)) ERR_INVALID_CALCULATION)
    (map-set energy-calculations
      calculation-id
      {
        simulation-id: simulation-id,
        calculator: tx-sender,
        energy-value: energy-value,
        calculation-method: calculation-method,
        timestamp: block-height
      }
    )
    (var-set calculation-count calculation-id)
    (ok calculation-id)
  )
)

(define-public (update-energy-calculation (calculation-id uint) (energy-value int) (calculation-method (string-ascii 50)))
  (let
    (
      (calculation (unwrap! (map-get? energy-calculations calculation-id) ERR_INVALID_CALCULATION))
    )
    (asserts! (is-eq tx-sender (get calculator calculation)) ERR_NOT_AUTHORIZED)
    (ok (map-set energy-calculations
      calculation-id
      (merge calculation {
        energy-value: energy-value,
        calculation-method: calculation-method,
        timestamp: block-height
      })
    ))
  )
)

(define-read-only (get-energy-calculation (calculation-id uint))
  (map-get? energy-calculations calculation-id)
)

(define-read-only (get-calculation-count)
  (var-get calculation-count)
)

