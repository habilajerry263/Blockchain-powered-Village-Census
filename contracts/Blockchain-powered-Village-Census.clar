(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))
(define-constant ERR_INVALID_INPUT (err u400))
(define-constant ERR_CENSUS_LOCKED (err u423))

(define-data-var census-active bool true)
(define-data-var total-population uint u0)
(define-data-var total-households uint u0)
(define-data-var census-round uint u1)
(define-data-var registration-deadline uint u0)

(define-map residents
  { resident-id: uint }
  {
    name: (string-ascii 100),
    age: uint,
    household-id: uint,
    registered-at: uint,
    verified: bool,
    registrar: principal
  }
)

(define-map households
  { household-id: uint }
  {
    head-of-household: uint,
    address: (string-ascii 200),
    members-count: uint,
    created-at: uint,
    last-updated: uint,
    verified: bool
  }
)

(define-map census-officers
  { officer: principal }
  {
    active: bool,
    appointed-at: uint,
    households-assigned: uint
  }
)

(define-map resident-counter
  { round: uint }
  { next-id: uint }
)

(define-map household-counter
  { round: uint }
  { next-id: uint }
)

(define-map village-stats
  { round: uint }
  {
    total-residents: uint,
    total-households: uint,
    verified-residents: uint,
    census-start: uint,
    census-end: uint,
    completed: bool
  }
)

(define-private (get-next-resident-id)
  (let
    (
      (current-round (var-get census-round))
      (counter-data (default-to { next-id: u1 } (map-get? resident-counter { round: current-round })))
    )
    (get next-id counter-data)
  )
)

(define-private (get-next-household-id)
  (let
    (
      (current-round (var-get census-round))
      (counter-data (default-to { next-id: u1 } (map-get? household-counter { round: current-round })))
    )
    (get next-id counter-data)
  )
)

(define-private (increment-resident-counter)
  (let
    (
      (current-round (var-get census-round))
      (current-id (get-next-resident-id))
    )
    (map-set resident-counter
      { round: current-round }
      { next-id: (+ current-id u1) }
    )
  )
)

(define-private (increment-household-counter)
  (let
    (
      (current-round (var-get census-round))
      (current-id (get-next-household-id))
    )
    (map-set household-counter
      { round: current-round }
      { next-id: (+ current-id u1) }
    )
  )
)

(define-public (appoint-census-officer (officer principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (map-set census-officers
      { officer: officer }
      {
        active: true,
        appointed-at: stacks-block-height,
        households-assigned: u0
      }
    ))
  )
)

(define-public (remove-census-officer (officer principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (map-set census-officers
      { officer: officer }
      {
        active: false,
        appointed-at: u0,
        households-assigned: u0
      }
    ))
  )
)

(define-public (create-household (address (string-ascii 200)))
  (let
    (
      (household-id (get-next-household-id))
      (current-height stacks-block-height)
    )
    (asserts! (var-get census-active) ERR_CENSUS_LOCKED)
    (asserts! (> (len address) u0) ERR_INVALID_INPUT)
    (increment-household-counter)
    (var-set total-households (+ (var-get total-households) u1))
    (ok (map-set households
      { household-id: household-id }
      {
        head-of-household: u0,
        address: address,
        members-count: u0,
        created-at: current-height,
        last-updated: current-height,
        verified: false
      }
    ))
  )
)

(define-public (register-resident (name (string-ascii 100)) (age uint) (household-id uint))
  (let
    (
      (resident-id (get-next-resident-id))
      (current-height stacks-block-height)
      (household-data (unwrap! (map-get? households { household-id: household-id }) ERR_NOT_FOUND))
    )
    (asserts! (var-get census-active) ERR_CENSUS_LOCKED)
    (asserts! (and (> (len name) u0) (> age u0)) ERR_INVALID_INPUT)
    (increment-resident-counter)
    (var-set total-population (+ (var-get total-population) u1))
    (map-set households
      { household-id: household-id }
      (merge household-data {
        members-count: (+ (get members-count household-data) u1),
        last-updated: current-height,
        head-of-household: (if (is-eq (get head-of-household household-data) u0) resident-id (get head-of-household household-data))
      })
    )
    (ok (map-set residents
      { resident-id: resident-id }
      {
        name: name,
        age: age,
        household-id: household-id,
        registered-at: current-height,
        verified: false,
        registrar: tx-sender
      }
    ))
  )
)

(define-public (verify-resident (resident-id uint))
  (let
    (
      (resident-data (unwrap! (map-get? residents { resident-id: resident-id }) ERR_NOT_FOUND))
      (officer-data (unwrap! (map-get? census-officers { officer: tx-sender }) ERR_UNAUTHORIZED))
    )
    (asserts! (get active officer-data) ERR_UNAUTHORIZED)
    (asserts! (var-get census-active) ERR_CENSUS_LOCKED)
    (ok (map-set residents
      { resident-id: resident-id }
      (merge resident-data { verified: true })
    ))
  )
)

(define-public (verify-household (household-id uint))
  (let
    (
      (household-data (unwrap! (map-get? households { household-id: household-id }) ERR_NOT_FOUND))
      (officer-data (unwrap! (map-get? census-officers { officer: tx-sender }) ERR_UNAUTHORIZED))
    )
    (asserts! (get active officer-data) ERR_UNAUTHORIZED)
    (asserts! (var-get census-active) ERR_CENSUS_LOCKED)
    (ok (map-set households
      { household-id: household-id }
      (merge household-data { verified: true })
    ))
  )
)

(define-public (update-resident (resident-id uint) (name (string-ascii 100)) (age uint))
  (let
    (
      (resident-data (unwrap! (map-get? residents { resident-id: resident-id }) ERR_NOT_FOUND))
    )
    (asserts! (var-get census-active) ERR_CENSUS_LOCKED)
    (asserts! (or (is-eq tx-sender (get registrar resident-data)) (is-some (map-get? census-officers { officer: tx-sender }))) ERR_UNAUTHORIZED)
    (asserts! (and (> (len name) u0) (> age u0)) ERR_INVALID_INPUT)
    (ok (map-set residents
      { resident-id: resident-id }
      (merge resident-data {
        name: name,
        age: age,
        verified: false
      })
    ))
  )
)

(define-public (set-census-status (active bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set census-active active)
    (ok active)
  )
)

(define-public (start-new-census-round)
  (let
    (
      (current-round (var-get census-round))
      (current-height stacks-block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set village-stats
      { round: current-round }
      {
        total-residents: (var-get total-population),
        total-households: (var-get total-households),
        verified-residents: u0,
        census-start: current-height,
        census-end: u0,
        completed: false
      }
    )
    (var-set census-round (+ current-round u1))
    (var-set census-active true)
    (var-set total-population u0)
    (var-set total-households u0)
    (ok (var-get census-round))
  )
)

(define-public (complete-census-round)
  (let
    (
      (current-round (- (var-get census-round) u1))
      (current-height stacks-block-height)
      (stats (unwrap! (map-get? village-stats { round: current-round }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set census-active false)
    (ok (map-set village-stats
      { round: current-round }
      (merge stats {
        census-end: current-height,
        completed: true
      })
    ))
  )
)

(define-read-only (get-resident (resident-id uint))
  (map-get? residents { resident-id: resident-id })
)

(define-read-only (get-household (household-id uint))
  (map-get? households { household-id: household-id })
)

(define-read-only (get-census-officer (officer principal))
  (map-get? census-officers { officer: officer })
)

(define-read-only (get-village-stats (round uint))
  (map-get? village-stats { round: round })
)

(define-read-only (get-current-census-info)
  {
    active: (var-get census-active),
    round: (var-get census-round),
    total-population: (var-get total-population),
    total-households: (var-get total-households),
    current-height: stacks-block-height
  }
)

(define-read-only (is-census-officer (address principal))
  (match (map-get? census-officers { officer: address })
    officer-data (get active officer-data)
    false
  )
)
