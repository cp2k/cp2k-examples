&FORCE_EVAL
  METHOD QMMM
  &DFT
    BASIS_SET_FILE_NAME BASIS_MOLOPT 
    POTENTIAL_FILE_NAME GTH_POTENTIALS
    &MGRID
      COMMENSURATE
      CUTOFF 400
      NGRIDS 5
    &END MGRID
    &QS
      METHOD GPW
      EXTRAPOLATION ASPC
      EXTRAPOLATION_ORDER 3
    &END QS
    &SCF
      MAX_SCF 300
       SCF_GUESS ATOMIC
     # SCF_GUESS RESTART 
      EPS_SCF 1.0E-6
      &OT
        PRECONDITIONER  FULL_SINGLE_INVERSE
        MINIMIZER DIIS
      &END
    &END SCF
    &XC
      &XC_FUNCTIONAL PBE
      &END XC_FUNCTIONAL
        &VDW_POTENTIAL
          DISPERSION_FUNCTIONAL PAIR_POTENTIAL
          &PAIR_POTENTIAL
           TYPE DFTD3
           CALCULATE_C9_TERM .TRUE.
           REFERENCE_C9_TERM
           PARAMETER_FILE_NAME dftd3.dat
           REFERENCE_FUNCTIONAL PBE
           R_CUTOFF [angstrom] 16.0
          # &PRINT_DFTD
          # &END
          &END PAIR_POTENTIAL
        &END VDW_POTENTIAL
    &END XC
  &END DFT

  &MM
    &FORCEFIELD
      &CHARGE
        ATOM Pt
        CHARGE 0
      &END CHARGE
      &CHARGE
        ATOM H
        CHARGE 0
      &END CHARGE
      &CHARGE
        ATOM O
        CHARGE 0
      &END CHARGE

      &SPLINE
       EPS_SPLINE 1.E-5
       #EMAX_SPLINE 2.0
      &END

       &NONBONDED
        &EAM
          atoms Pt Pt
          PARM_FILE_NAME Pt.pot
        &END EAM
 #for O Pt interaction: these are terms V1+V2 of Siepmann-Sprik potential
        &GENPOT
           atoms O Pt
           FUNCTION A/r^alpha-C/r^6
           VARIABLES r
           PARAMETERS A alpha C 
           VALUES 71059.888 11.0 29.48697
           RCUT  12
        &END GENPOT

        &LENNARD-JONES
          atoms O O
          EPSILON 0.0
          SIGMA 3.166
          RCUT 12
        &END LENNARD-JONES
        &LENNARD-JONES
          atoms H H
          EPSILON 0.0
          SIGMA 3.166
          RCUT 12
        &END LENNARD-JONES
        &LENNARD-JONES
          atoms H O
          EPSILON 0.0
          SIGMA 3.166
          RCUT 12
        &END LENNARD-JONES
        &LENNARD-JONES
          atoms H Pt
          EPSILON 0.0
          SIGMA 3.166
          RCUT 12
        &END LENNARD-JONES
      &END

    &END FORCEFIELD

    &POISSON
      &EWALD
        EWALD_TYPE ewald
        ALPHA .44
        GMAX 21
      &END EWALD
    &END POISSON
  &END MM

  &QMMM
    # use keyword CENTER NEVER for GEO_OPT/MD run and QM/MM
    # otherwise convergence of GEO_OPT is difficult (inaccuracy in forces) 
    CENTER NEVER
    &CELL
      ABC [angstrom]  33.2623 28.8060  35.0
      PERIODIC XYZ
    &END CELL

    &QM_KIND O
     MM_INDEX 577 
    &END QM_KIND

    &QM_KIND H
     MM_INDEX 578 579
    &END QM_KIND

    &IMAGE_CHARGE
     MM_ATOM_LIST 1..576
     WIDTH 3.5
    &END IMAGE_CHARGE

    &PRINT
     &IMAGE_CHARGE_INFO
     &END
    &END

  &END QMMM

  &SUBSYS
    &CELL
      ABC [angstrom]  33.2623 28.8060  35.0
      PERIODIC XYZ
    &END CELL
    &TOPOLOGY
      COORD_FILE_NAME Pt_1H2O.xyz 
      COORDINATE xyz
    &END

    &KIND H
      BASIS_SET DZVP-MOLOPT-SR-GTH
      POTENTIAL GTH-PBE-q1
    &END KIND

    &KIND O
      BASIS_SET DZVP-MOLOPT-SR-GTH
      POTENTIAL GTH-PBE-q6
    &END KIND
  &END SUBSYS
&END FORCE_EVAL
