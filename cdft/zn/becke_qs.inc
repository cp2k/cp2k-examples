&QS
  METHOD GPW
  EPS_DEFAULT 1.0E-12
  MAP_CONSISTENT
  EXTRAPOLATION ASPC
  EXTRAPOLATION_ORDER 4
  @IF ( ${BECKE_ACTIVE} == TRUE )
    ! CDFT loop settings
    ! Please note that prior to CP2K version 7.0,
    ! Becke constraints were separate from the CDFT section
    &CDFT
      TYPE_OF_CONSTRAINT BECKE
      ! Compute Becke charges?
      ATOMIC_CHARGES  TRUE
      ! Constraint strength and target values
      ! Give one value per constraint
      STRENGTH        ${BECKE_STR}
      TARGET          ${BECKE_TARGET}
      ! Constraint definitions, each repetition defines a new constraint
      &ATOM_GROUP
        ATOMS 1
        COEFF 1
        CONSTRAINT_TYPE CHARGE
      &END ATOM_GROUP
      ! No constraint applied but calculate charges
      &DUMMY_ATOMS
        ATOMS 2
      &END DUMMY_ATOMS
      ! CDFT convergence and optimizer settings
      &OUTER_SCF ON
        TYPE CDFT_CONSTRAINT
        EXTRAPOLATION_ORDER 2
        MAX_SCF 10
        ! Convergence threshold
        EPS_SCF 1.0E-3
        ! Optimizer selection:
        ! Now Newton's method with backtracking line search
        OPTIMIZER NEWTON_LS
        ! Optimizer (initial) step size
        STEP_SIZE -1.0
        ! Note that the section CDFT_OPT exists in CP2K version >= 6.1
        ! Remove section for CP2K version 5.1 (keywords are unchanged)
        &CDFT_OPT ON
          ! Line search settings
          MAX_LS 5
          CONTINUE_LS
          FACTOR_LS 0.5
          ! Finite difference settings for Jacobian matrix
          JACOBIAN_STEP 1.0E-2
          JACOBIAN_FREQ 1 1
          JACOBIAN_TYPE FD1
          JACOBIAN_RESTART FALSE
        &END CDFT_OPT
      &END
      ! Settigs specific to Becke constraints
      &BECKE_CONSTRAINT
        ! Take atomic radii into account?
        ADJUST_SIZE     FALSE
        ATOMIC_RADII    0.63 0.32
        ! Cutoff scheme
        CUTOFF_TYPE     ELEMENT
        ELEMENT_CUTOFF  7.0
        ! Perform Becke partitioning only within the space
        ! spanned by constraint atom centered spherical Gaussians
        ! (reduces cost for solvated systems)
        CAVITY_CONFINE  TRUE
        CAVITY_SHAPE    VDW
        EPS_CAVITY      1.0E-7
        IN_MEMORY       TRUE
        SHOULD_SKIP     TRUE
      &END BECKE_CONSTRAINT
      ! Print information about CDFT calculation
      &PROGRAM_RUN_INFO ON
        &EACH
          QS_SCF 1
        &END EACH
        COMMON_ITERATION_LEVELS 2
        ADD_LAST NUMERIC
        FILENAME ./${NAME}
      &END PROGRAM_RUN_INFO
    &END CDFT
  @ENDIF
&END QS
