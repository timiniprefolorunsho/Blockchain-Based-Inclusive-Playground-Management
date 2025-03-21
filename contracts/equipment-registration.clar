;; Equipment Registration Contract
;; Records details of accessible play structures

(define-data-var last-equipment-id uint u0)

(define-map equipment
  uint
  {
    name: (string-ascii 100),
    equipment-type: (string-ascii 50),
    accessibility-features: (string-ascii 500),
    location: (string-ascii 100),
    installation-date: uint,
    status: (string-ascii 20), ;; "active", "maintenance", "decommissioned"
    manufacturer: (string-ascii 100),
    age-range: (string-ascii 50),
    last-inspection: uint,
    owner: principal
  }
)

;; Register new playground equipment
(define-public (register-equipment
    (name (string-ascii 100))
    (equipment-type (string-ascii 50))
    (accessibility-features (string-ascii 500))
    (location (string-ascii 100))
    (installation-date uint)
    (manufacturer (string-ascii 100))
    (age-range (string-ascii 50))
  )
  (let
    (
      (new-id (+ (var-get last-equipment-id) u1))
      (caller tx-sender)
    )
    ;; Update equipment ID counter
    (var-set last-equipment-id new-id)

    ;; Store equipment details
    (map-set equipment
      new-id
      {
        name: name,
        equipment-type: equipment-type,
        accessibility-features: accessibility-features,
        location: location,
        installation-date: installation-date,
        status: "active",
        manufacturer: manufacturer,
        age-range: age-range,
        last-inspection: block-height,
        owner: caller
      }
    )

    (ok new-id)
  )
)

;; Update equipment status
(define-public (update-equipment-status
    (equipment-id uint)
    (new-status (string-ascii 20))
  )
  (let
    (
      (equip (unwrap! (map-get? equipment equipment-id) (err u404)))
      (caller tx-sender)
    )
    ;; Check if caller is the owner
    (asserts! (is-eq caller (get owner equip)) (err u403))

    ;; Validate status
    (asserts! (or (is-eq new-status "active")
                  (is-eq new-status "maintenance")
                  (is-eq new-status "decommissioned"))
              (err u400))

    ;; Update equipment status
    (map-set equipment
      equipment-id
      (merge equip { status: new-status })
    )

    (ok true)
  )
)

;; Record equipment inspection
(define-public (record-inspection (equipment-id uint))
  (let
    (
      (equip (unwrap! (map-get? equipment equipment-id) (err u404)))
      (caller tx-sender)
    )
    ;; Check if caller is the owner
    (asserts! (is-eq caller (get owner equip)) (err u403))

    ;; Update last inspection date
    (map-set equipment
      equipment-id
      (merge equip { last-inspection: block-height })
    )

    (ok true)
  )
)

;; Get equipment details
(define-read-only (get-equipment (equipment-id uint))
  (map-get? equipment equipment-id)
)

;; Get total equipment count
(define-read-only (get-equipment-count)
  (var-get last-equipment-id)
)
