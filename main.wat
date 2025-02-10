(module
  (memory $mem 1) (; NOTE: At least 1 page of memory ;)
  (export "mem" (memory $mem))

  (; ----- PUBLIC FUNCTIONS ----- ;)

  (func $size (result i32)
    i32.const 50 (; Number of cells ;)
  )
  (export "size" (func $size))


  (func $arrayLength (result i32)
    call $size
    call $size
    i32.mul
  )
  (export "arrayLength" (func $arrayLength))

  (func $index (param $x i32) (param $y i32) (result i32)
    (if (result i32) (call $inRange (get_local $x) (get_local $y))
      (then
        (block (result i32)
          get_local $x
          get_local $y
          call $indexUnsafe
        )
      )
      (else (i32.const -1))
    )
  )
  (export "index" (func $index))

  (func $setCell (param $x i32) (param $y i32) (param $value i32) (result i32)
    (if (result i32) (call $inRange (get_local $x) (get_local $y))
      (then
        (block (result i32)
          get_local $x
          get_local $y
          get_local $value
          call $setCellUnsafe
          i32.const 0
        )
      )
      (else (i32.const -1))
    )
  )
  (export "setCell" (func $setCell))

  (func $getCell (param $x i32) (param $y i32) (result i32)
    (if (result i32) (call $inRange (get_local $x) (get_local $y))
      (then
        (block (result i32)
          get_local $x
          get_local $y
          call $getCellUnsafe
        )
      )
      (else (i32.const -1))
    )
  )
  (export "getCell" (func $getCell))

  (func $isAlive (param $x i32) (param $y i32) (result i32)
    (if (result i32) (call $inRange (get_local $x) (get_local $y))
      (then
        (block (result i32)
          get_local $x
          get_local $y
          call $isAliveUnsafe
        )
      )
      (else (i32.const -1))
    )
  )
  (export "isAlive" (func $isAlive))

  (func $isDead (param $x i32) (param $y i32) (result i32)
    (if (result i32) (call $inRange (get_local $x) (get_local $y))
      (then
        (block (result i32)
          get_local $x
          get_local $y
          call $isDeadUnsafe
        )
      )
      (else (i32.const -1))
    )
  )
  (export "isDead" (func $isDead))

  (func $isErr (param $val i32) (result i32)
    (i32.lt_s (get_local $val) (i32.const 0))
  )
  (export "isErr" (func $isErr))

  (func $isNotErr (param $val i32) (result i32)
    get_local $val
    call $isErr
    i32.const 1
    i32.ne
  )
  (export "isNotErr" (func $isNotErr))

  (func $alive (result i32)
    i32.const 1
  )
  (export "alive" (func $alive))

  (func $dead (result i32)
    i32.const 0
  )
  (export "dead" (func $dead))


  (; ----- PRIVATE FUNCTIONS ----- ;)


  (func $numNeighbors (export "test") (param $x i32) (param $y i32) (result i32)
    (local $res i32)
    (local $sum i32)
    i32.const 0
    set_local $sum
    (call $isAlive (i32.add (get_local $x) (i32.const 1)) (i32.add (get_local $y) (i32.const 1)))
    tee_local $res
    call $isNotErr
    (if
      (then
        get_local $sum
        get_local $res
        i32.add
        set_local $sum
      )
    )
    (call $isAlive (i32.add (get_local $x) (i32.const 1)) (i32.add (get_local $y) (i32.const 0)))
    tee_local $res
    call $isNotErr
    (if
      (then
        get_local $sum
        get_local $res
        i32.add
        set_local $sum
      )
    )
    (call $isAlive (i32.add (get_local $x) (i32.const 1)) (i32.add (get_local $y) (i32.const -1)))
    tee_local $res
    call $isNotErr
    (if
      (then
        get_local $sum
        get_local $res
        i32.add
        set_local $sum
      )
    )
    (call $isAlive (i32.add (get_local $x) (i32.const 0)) (i32.add (get_local $y) (i32.const 1)))
    tee_local $res
    call $isNotErr
    (if
      (then
        get_local $sum
        get_local $res
        i32.add
        set_local $sum
      )
    )
    (call $isAlive (i32.add (get_local $x) (i32.const 0)) (i32.add (get_local $y) (i32.const -1)))
    tee_local $res
    call $isNotErr
    (if
      (then
        get_local $sum
        get_local $res
        i32.add
        set_local $sum
      )
    )
    (call $isAlive (i32.add (get_local $x) (i32.const -1)) (i32.add (get_local $y) (i32.const 1)))
    tee_local $res
    call $isNotErr
    (if
      (then
        get_local $sum
        get_local $res
        i32.add
        set_local $sum
      )
    )
    (call $isAlive (i32.add (get_local $x) (i32.const -1)) (i32.add (get_local $y) (i32.const 0)))
    tee_local $res
    call $isNotErr
    (if
      (then
        get_local $sum
        get_local $res
        i32.add
        set_local $sum
      )
    )
    (call $isAlive (i32.add (get_local $x) (i32.const -1)) (i32.add (get_local $y) (i32.const -1)))
    tee_local $res
    call $isNotErr
    (if
      (then
        get_local $sum
        get_local $res
        i32.add
        set_local $sum
      )
    )
    get_local $sum
  )


  (func $isAliveUnsafe (param $x i32) (param $y i32) (result i32)
    call $alive
    (call $getCellUnsafe (get_local $x) (get_local $y))
    i32.eq
  )


  (func $isDeadUnsafe (param $x i32) (param $y i32) (result i32)
    call $dead
    (call $getCellUnsafe (get_local $x) (get_local $y))
    i32.eq
  )


  (func $offsetFromCoordinatesUnsafe (param $x i32) (param $y i32) (result i32)
    get_local $x
    get_local $y
    call $indexUnsafe
    i32.const 4 (; NOTE: To get a i32 offset and not only 1 byte ;)
    i32.mul
  )

  (func $offsetFromCoordinates (param $x i32) (param $y i32) (result i32)
    (if (result i32) (call $inRange (get_local $x) (get_local $y))
      (then
        (block (result i32)
          get_local $x
          get_local $y
          call $offsetFromCoordinatesUnsafe
        )
      )
      (else (i32.const -1))
    )
  )

  (func $indexUnsafe (param $x i32) (param $y i32) (result i32)
    get_local $y
    call $size
    i32.mul
    get_local $x
    i32.add
  )

  (func $inRange (param $x i32) (param $y i32) (result i32)
        (; Check x ;)
        get_local $x
        i32.const 0
        i32.ge_s

        get_local $x
        call $size
        i32.le_s

        i32.and

        (; Check y ;)
        get_local $y
        i32.const 0
        i32.ge_s

        get_local $y
        call $size
        i32.le_s

        i32.and

        (; Both need to be true ;)
        i32.and
  )

  (func $getCellUnsafe (param $x i32) (param $y i32) (result i32)
    (call $offsetFromCoordinates (get_local $x) (get_local $y))
    i32.load
  )

  (func $setCellUnsafe (param $x i32) (param $y i32) (param $value i32)
    (call $offsetFromCoordinates (get_local $x) (get_local $y))
    get_local $value
    i32.store
  )
)
