;; ------------------------------------------------------
;; EduReward-STX: Incentivized Learning Contract
;; Students stake STX to enroll in courses and earn rewards if they succeed
;; Teachers/Oracles validate results
;; ------------------------------------------------------

;; Removed invalid impl-trait line - not needed for this contract

;; ------------------------------
;; DATA STRUCTURES
;; ------------------------------

(define-data-var reward-pool uint u0) ;; Accumulated pool from failed students

(define-map courses
  {id: uint}
  {
    teacher: principal,
    fee: uint,
    reward-share: uint, ;; % of fee teacher takes
    active: bool
  }
)

(define-map enrollments
  {student: principal, course-id: uint}
  {
    staked: uint,
    passed: bool,
    claimed: bool
  }
)

(define-data-var course-counter uint u0)

;; ------------------------------
;; ERRORS
;; ------------------------------

(define-constant ERR-NOT-TEACHER (err u100))
(define-constant ERR-NOT-ENROLLED (err u101))
(define-constant ERR-ALREADY-ENROLLED (err u102))
(define-constant ERR-NOT-ACTIVE (err u103))
(define-constant ERR-ALREADY-CLAIMED (err u104))
(define-constant ERR-NOT-PASSED (err u105))

;; ------------------------------
;; FUNCTIONS
;; ------------------------------

;; Create a new course
(define-public (create-course (fee uint) (reward-share uint))
  (let ((id (+ (var-get course-counter) u1)))
    (begin
      (var-set course-counter id)
      (map-set courses {id: id}
        {
          teacher: tx-sender,
          fee: fee,
          reward-share: reward-share,
          active: true
        })
      (ok id)
    )
  )
)

;; Enroll in a course (stake STX as fee)
(define-public (enroll (course-id uint))
  (let ((course (map-get? courses {id: course-id})))
    (match course
      course-data
      (if (get active course-data)
        (if (is-none (map-get? enrollments {student: tx-sender, course-id: course-id}))
          (begin
            ;; Added try! to check transfer result
            (try! (stx-transfer? (get fee course-data) tx-sender (as-contract tx-sender)))
            (map-set enrollments {student: tx-sender, course-id: course-id}
              {
                staked: (get fee course-data),
                passed: false,
                claimed: false
              })
            (ok "Enrolled successfully")
          )
          ERR-ALREADY-ENROLLED
        )
        ERR-NOT-ACTIVE
      )
      (err u404) ;; Course not found
    )
  )
)

;; Teacher marks result (pass/fail)
(define-public (submit-result (course-id uint) (student principal) (did-pass bool))
  (let ((course (map-get? courses {id: course-id})))
    (match course
      course-data
      (if (is-eq tx-sender (get teacher course-data))
        (let ((enrollment (map-get? enrollments {student: student, course-id: course-id})))
          (match enrollment
            e
            (begin
              (map-set enrollments {student: student, course-id: course-id}
                {
                  staked: (get staked e),
                  passed: did-pass,
                  claimed: false
                })
              (if did-pass
                ;; Replaced emoji with ASCII text
                (ok "Student passed")
                (begin
                  (var-set reward-pool (+ (var-get reward-pool) (get staked e)))
                  ;; Replaced emoji with ASCII text
                  (ok "Student failed")
                )
              )
            )
            ERR-NOT-ENROLLED
          )
        )
        ERR-NOT-TEACHER
      )
      (err u404)
    )
  )
)

;; Claim reward if passed
(define-public (claim-reward (course-id uint))
  (let ((enrollment (map-get? enrollments {student: tx-sender, course-id: course-id})))
    (match enrollment
      e
      (if (get passed e)
        (if (not (get claimed e))
          (let ((reward (/ (var-get reward-pool) u10))) ;; Example: flat reward share
            (begin
              ;; Added try! to check transfer result
              (try! (stx-transfer? (+ (get staked e) reward) (as-contract tx-sender) tx-sender))
              (map-set enrollments {student: tx-sender, course-id: course-id}
                {
                  staked: (get staked e),
                  passed: true,
                  claimed: true
                })
              ;; Replaced emoji with ASCII text
              (ok "Reward claimed")
            )
          )
          ERR-ALREADY-CLAIMED
        )
        ERR-NOT-PASSED
      )
      ERR-NOT-ENROLLED
    )
  )
)
