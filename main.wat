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
    (if (result i32) (call $inRange (local.get $x) (local.get $y))
      (then
        (block (result i32)
          local.get $x
          local.get $y
          call $indexUnsafe
        )
      )
      (else (i32.const -1))
    )
  )
  (export "index" (func $index))

  (func $setCell (param $x i32) (param $y i32) (param $value i32) (result i32)
    (if (result i32) (call $inRange (local.get $x) (local.get $y))
      (then
        (block (result i32)
          local.get $x
          local.get $y
          local.get $value
          call $setCellUnsafe
          i32.const 0
        )
      )
      (else (i32.const -1))
    )
  )
  (export "setCell" (func $setCell))

  (func $getCell (param $x i32) (param $y i32) (result i32)
    (if (result i32) (call $inRange (local.get $x) (local.get $y))
      (then
        (block (result i32)
          local.get $x
          local.get $y
          call $getCellUnsafe
        )
      )
      (else (i32.const -1))
    )
  )
  (export "getCell" (func $getCell))

  (func $isAlive (param $x i32) (param $y i32) (result i32)
    (if (result i32) (call $inRange (local.get $x) (local.get $y))
      (then
        (block (result i32)
          local.get $x
          local.get $y
          call $isAliveUnsafe
        )
      )
      (else (i32.const -1))
    )
  )
  (export "isAlive" (func $isAlive))

  (func $isDead (param $x i32) (param $y i32) (result i32)
    (if (result i32) (call $inRange (local.get $x) (local.get $y))
      (then
        (block (result i32)
          local.get $x
          local.get $y
          call $isDeadUnsafe
        )
      )
      (else (i32.const -1))
    )
  )
  (export "isDead" (func $isDead))

  (func $isErr (param $val i32) (result i32)
    (i32.lt_s (local.get $val) (i32.const 0))
  )
  (export "isErr" (func $isErr))

  (func $isNotErr (param $val i32) (result i32)
    local.get $val
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

  (func $updateCells
    (local $x i32)
    (local $y i32)
    (loop $iter_x
      i32.const 0
      local.set $y
      (loop $iter_y
          local.get $x
          local.get $y
          call $updateCell

          local.get $y
          i32.const 1
          i32.add
          local.tee $y

          call $size
          i32.lt_s
          br_if $iter_y
      )
      local.get $x
      i32.const 1
      i32.add
      local.tee $x

      call $size
      i32.lt_s
      br_if $iter_x
    )
    i32.const 0 (; Destination ;)
    call $arrayLength (; Source ;)
    call $arrayLength (; Length ;)
    memory.copy (; Copy the new updated cells to the public facing buffer ;)
  )

  (func $updateCell (param $x i32) (param $y i32)
    (local $neigs i32)
    (local $isal i32)
    local.get $x
    local.get $x
    call $isAlive
    local.set $isal

    local.get $x
    local.get $x
    call $numNeighbors
    local.set $neigs

    local.get $isal
    (if
      (then
        (; Currently ALIVE ;)
        local.get $neigs
        call $staysAlive
        (if
          (then
            (call $setNewCellUnsafe (local.get $x) (local.get $y) (call $alive))
          )
          (else
            (call $setNewCellUnsafe (local.get $x) (local.get $y) (call $dead))
          )
        )
      )
      (else
        (; Currently DEAD ;)
        local.get $neigs
        call $becomesAlive
        (if
          (then
            (call $setNewCellUnsafe (local.get $x) (local.get $y) (call $alive))
          )
          (else
            (call $setNewCellUnsafe (local.get $x) (local.get $y) (call $dead))
          )
        )
      )
    )
  )

  (func $staysAlive (param $neigs i32) (result i32)
      (; If it has two or three neighbors ;)
      local.get $neigs
      i32.const 2
      i32.eq

      local.get $neigs
      i32.const 3
      i32.eq

      i32.or
  )

  (func $becomesAlive (param $neigs i32) (result i32)
      (; If it has three neighbors ;)
      local.get $neigs
      i32.const 3
      i32.eq
  )

  (func $numNeighbors (param $x i32) (param $y i32) (result i32)
    (local $res i32)
    (local $sum i32)
    i32.const 0
    local.set $sum
    (call $isAlive (i32.add (local.get $x) (i32.const 1)) (i32.add (local.get $y) (i32.const 1)))
    local.tee $res
    call $isNotErr
    (if
      (then
        local.get $sum
        local.get $res
        i32.add
        local.set $sum
      )
    )
    (call $isAlive (i32.add (local.get $x) (i32.const 1)) (i32.add (local.get $y) (i32.const 0)))
    local.tee $res
    call $isNotErr
    (if
      (then
        local.get $sum
        local.get $res
        i32.add
        local.set $sum
      )
    )
    (call $isAlive (i32.add (local.get $x) (i32.const 1)) (i32.add (local.get $y) (i32.const -1)))
    local.tee $res
    call $isNotErr
    (if
      (then
        local.get $sum
        local.get $res
        i32.add
        local.set $sum
      )
    )
    (call $isAlive (i32.add (local.get $x) (i32.const 0)) (i32.add (local.get $y) (i32.const 1)))
    local.tee $res
    call $isNotErr
    (if
      (then
        local.get $sum
        local.get $res
        i32.add
        local.set $sum
      )
    )
    (call $isAlive (i32.add (local.get $x) (i32.const 0)) (i32.add (local.get $y) (i32.const -1)))
    local.tee $res
    call $isNotErr
    (if
      (then
        local.get $sum
        local.get $res
        i32.add
        local.set $sum
      )
    )
    (call $isAlive (i32.add (local.get $x) (i32.const -1)) (i32.add (local.get $y) (i32.const 1)))
    local.tee $res
    call $isNotErr
    (if
      (then
        local.get $sum
        local.get $res
        i32.add
        local.set $sum
      )
    )
    (call $isAlive (i32.add (local.get $x) (i32.const -1)) (i32.add (local.get $y) (i32.const 0)))
    local.tee $res
    call $isNotErr
    (if
      (then
        local.get $sum
        local.get $res
        i32.add
        local.set $sum
      )
    )
    (call $isAlive (i32.add (local.get $x) (i32.const -1)) (i32.add (local.get $y) (i32.const -1)))
    local.tee $res
    call $isNotErr
    (if
      (then
        local.get $sum
        local.get $res
        i32.add
        local.set $sum
      )
    )
    local.get $sum
  )


  (func $isAliveUnsafe (param $x i32) (param $y i32) (result i32)
    call $alive
    (call $getCellUnsafe (local.get $x) (local.get $y))
    i32.eq
  )


  (func $isDeadUnsafe (param $x i32) (param $y i32) (result i32)
    call $dead
    (call $getCellUnsafe (local.get $x) (local.get $y))
    i32.eq
  )


  (func $offsetFromCoordinatesUnsafe (param $x i32) (param $y i32) (result i32)
    local.get $x
    local.get $y
    call $indexUnsafe
    i32.const 4 (; NOTE: To get a i32 offset and not only 1 byte ;)
    i32.mul
  )

  (func $offsetFromCoordinates (param $x i32) (param $y i32) (result i32)
    (if (result i32) (call $inRange (local.get $x) (local.get $y))
      (then
        (block (result i32)
          local.get $x
          local.get $y
          call $offsetFromCoordinatesUnsafe
        )
      )
      (else (i32.const -1))
    )
  )

  (func $indexUnsafe (param $x i32) (param $y i32) (result i32)
    local.get $y
    call $size
    i32.mul
    local.get $x
    i32.add
  )

  (func $inRange (param $x i32) (param $y i32) (result i32)
        (; Check x ;)
        local.get $x
        i32.const 0
        i32.ge_s

        local.get $x
        call $size
        i32.le_s

        i32.and

        (; Check y ;)
        local.get $y
        i32.const 0
        i32.ge_s

        local.get $y
        call $size
        i32.le_s

        i32.and

        (; Both need to be true ;)
        i32.and
  )

  (func $getCellUnsafe (param $x i32) (param $y i32) (result i32)
    (call $offsetFromCoordinates (local.get $x) (local.get $y))
    i32.load
  )

  (func $setCellUnsafe (param $x i32) (param $y i32) (param $value i32)
    (call $offsetFromCoordinates (local.get $x) (local.get $y))
    local.get $value
    i32.store
  )

  (func $setNewCellUnsafe (param $x i32) (param $y i32) (param $value i32)
    (call $offsetFromCoordinates (local.get $x) (local.get $y))
    local.get $value
    call $arrayLength (; Have an second array to store the new updated cells ;)
    i32.add
    i32.store
  )
)
