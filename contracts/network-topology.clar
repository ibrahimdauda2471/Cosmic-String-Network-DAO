;; Network Topology Management Contract

(define-data-var topology-count uint u0)

(define-map network-topologies
  uint
  {
    creator: principal,
    name: (string-ascii 100),
    description: (string-utf8 1000),
    dimensions: uint,
    node-count: uint,
    edge-data: (buff 1024),
    timestamp: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_TOPOLOGY (err u404))

(define-public (create-topology (name (string-ascii 100)) (description (string-utf8 1000)) (dimensions uint) (node-count uint) (edge-data (buff 1024)))
  (let
    (
      (topology-id (+ (var-get topology-count) u1))
    )
    (map-set network-topologies
      topology-id
      {
        creator: tx-sender,
        name: name,
        description: description,
        dimensions: dimensions,
        node-count: node-count,
        edge-data: edge-data,
        timestamp: block-height
      }
    )
    (var-set topology-count topology-id)
    (ok topology-id)
  )
)

(define-public (update-topology (topology-id uint) (name (string-ascii 100)) (description (string-utf8 1000)) (dimensions uint) (node-count uint) (edge-data (buff 1024)))
  (let
    (
      (topology (unwrap! (map-get? network-topologies topology-id) ERR_INVALID_TOPOLOGY))
    )
    (asserts! (is-eq tx-sender (get creator topology)) ERR_NOT_AUTHORIZED)
    (ok (map-set network-topologies
      topology-id
      (merge topology {
        name: name,
        description: description,
        dimensions: dimensions,
        node-count: node-count,
        edge-data: edge-data,
        timestamp: block-height
      })
    ))
  )
)

(define-read-only (get-topology (topology-id uint))
  (map-get? network-topologies topology-id)
)

(define-read-only (get-topology-count)
  (var-get topology-count)
)

