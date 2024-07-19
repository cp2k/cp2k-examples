&FORCE_EVAL
  METHOD FIST
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
#this gives you the term V3+V4 of Siepmann-sprik potential
#needs to be in  separate force_eval since 
#first reason: different cutoffs for O-Pt interactions here, Fist crashes/stops otherwise
#second reason: the EAM neighbor lists are not protected when using other manybody potentials
#               like Siepmann-Sprik or Tersoff
       &NONBONDED
        &SIEPMANN
         ATOMS  O Pt
         RCUT 3.2
        &END

        &LENNARD-JONES
          atoms O O
          EPSILON 0.0
          SIGMA 3.166
          RCUT 12
        &END LENNARD-JONES
        &LENNARD-JONES
          atoms Pt Pt
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

  &SUBSYS
    &CELL
      ABC [angstrom]  33.2623 28.8060  35.0
      PERIODIC XYZ
    &END CELL
    &TOPOLOGY
      COORD_FILE_NAME Pt_1H2O.xyz 
      COORDINATE xyz
    &END
  &END SUBSYS
&END FORCE_EVAL
