;; Cosmic String Simulation Management Contract

(define-data-var simulation-count uint u0)

(define-map cosmic-string-simulations
  uint
  {
    creator: principal,
    name: (string-ascii 100),
    description: (string-utf8 1000),
    parameters: (list 10 int),
    topology-id: uint,
    status: (string-ascii 20),
    result-hash: (optional (buff 32)),
    timestamp: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_SIMULATION (err u404))

(define-public (create-simulation (name (string-ascii 100)) (description (string-utf8 1000)) (parameters (list 10 int)) (topology-id uint))
  (let
    (
      (simulation-id (+ (var-get simulation-count) u1))
    )
    (asserts! (is-some (contract-call? .network-topology get-topology topology-id)) ERR_INVALID_SIMULATION)
    (map-set cosmic-string-simulations
      simulation-id
      {
        creator: tx-sender,
        name: name,
        description: description,
        parameters: parameters,
        topology-id: topology-id,
        status: "pending",
        result-hash: none,
        timestamp: block-height
      }
    )
    (var-set simulation-count simulation-id)
    (ok simulation-id)
  )
)

(define-public (update-simulation-status (simulation-id uint) (new-status (string-ascii 20)))
  (let
    (
      (simulation (unwrap! (map-get? cosmic-string-simulations simulation-id) ERR_INVALID_SIMULATION))
    )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get creator simulation))) ERR_NOT_AUTHORIZED)
    (ok (map-set cosmic-string-simulations
      simulation-id
      (merge simulation { status: new-status })
    ))
  )
)

(define-public (set-simulation-result (simulation-id uint) (result-hash (buff 32)))
  (let
    (
      (simulation (unwrap! (map-get? cosmic-string-simulations simulation-id) ERR_INVALID_SIMULATION))
    )
    (asserts! (is-eq tx-sender (get creator simulation)) ERR_NOT_AUTHORIZED)
    (ok (map-set cosmic-string-simulations
      simulation-id
      (merge simulation {
        status: "completed",
        result-hash: (some result-hash)
      })
    ))
  )
)

(define-read-only (get-simulation (simulation-id uint))
  (map-get? cosmic-string-simulations simulation-id)
)

(define-read-only (get-simulation-count)
  (var-get simulation-count)
)

