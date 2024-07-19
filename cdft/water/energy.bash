#!/bin/bash
set -e
usage="$(basename "$0") [-h] [-p path] [-c cores] [-m mpi] -- program to run the CP2K CDFT tutorial calculations

where:
    -h  show this help text
    -p  path to CP2K installation (default: .)
    -c  number of MPI processes to use for calculation (default: 2)
    -m  name and path of program to execute MPI programs (default: mpiexec)"

ncores=2
path="."
mpi_program="mpiexec"

while getopts ':hp:c:m:' option; do
    case "$option" in
        h)
            echo "$usage"
            exit
            ;;
        p)
            path="$OPTARG"
            ;;
        c)
            ncores="$OPTARG"
            if ! [[ $ncores =~ ^-?[0-9]+$ ]]; then
                echo "value passed to -c must be an integer" >&2
                echo "$usage" >&2
                exit 1
            fi
           ;;
        m)
            mpi_program="$OPTARG"
            ;;
        :)
            printf "missing argument for -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
       \?)
            printf "illegal option: -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

export CP2K_PATH="$path"
cp2k_suffix=".popt"
if [[ $ncores =~ 1 ]]; then
    mpi_command=""
    cp2k_suffix=".sopt"
else
    mpi_command="$mpi_program -n $ncores"
fi
run_cp2k="$mpi_command ${CP2K_PATH}/cp2k${cp2k_suffix}"

# Define function to fill CP2K input file template
# Note this function relies on global variables without explicitly checking
# if the variables are actually defined
# CP2K will complain and crash if the variable is incorrectly defined
fill_template () {
    sed -e "s|EXTERNAL_XYZNAME|${xyzfile}|g" \
        -e "s/EXTERNAL_PROJNAME/${project_file}/g" \
        -e "s|EXTERNAL_WFNRESTART_1|${wfnfile}|g" \
        -e "s/EXTERNAL_RESTART_WFN_1/${restart_wfn}/g" \
        -e "s/EXTERNAL_CENTER_SYS/${center_sys}/g" \
        -e "s/EXTERNAL_SAVE_CUBE/${save_cube}/g" \
        -e "s/EXTERNAL_BECKE_ACTIVE/${use_becke}/g" \
        -e "s/EXTERNAL_BECKE_STR/${strength}/g" \
        -e "s/EXTERNAL_BECKE_TARGET/${target}/g" \
        -e "s/EXTERNAL_BECKE_FRAG_CONS/${use_frag}/g" \
        -e "s/EXTERNAL_BECKE_RADII/${use_radii}/g" \
        -e "s|EXTERNAL_BECKE_FRAG_A|${frag1}|g" \
        -e "s|EXTERNAL_BECKE_FRAG_SPIN_A|${frag1spin}|g" \
        -e "s|EXTERNAL_BECKE_FRAG_B|${frag2}|g" \
        -e "s|EXTERNAL_BECKE_FRAG_SPIN_B|${frag2spin}|g" \
        "${template}.inp" > "${template}_run.inp"
}

# Initialize default values for global variables
template="energy"
xyzfile="dummy.xyz"
project_file="dummy"
wfnfile="dummy.wfn"
restart_wfn="FALSE"
center_sys="ON"
save_cube="FALSE"
strength="0"
target="0"
use_becke="FALSE"
use_frag="FALSE"
use_radii="FALSE"
frag1="dummy.cube"
frag2="dummy.cube"
frag1spin="dummy.cube"
frag2spin="dummy.cube"

# Standard DFT calculation
template="energy"
xyzfile="water-dimer.xyz"
project_file="${xyzfile%%.xyz}-pbe-energy"
# Fill in template
fill_template
# Run calculation and save energy
echo "Calculating DFT ground state"
$run_cp2k  "${template}_run.inp" >> "${project_file}.out"
dft_energy=$(grep "ENERGY|" "${project_file}.out" | awk '{print $9}')

# Calculate the charge tansfer energy without atomic size adjustments i.e.
# perform a CDFT calculation so that both water molecules are charge neutral (8 valence electrons)
# Take a close look at the atomic charges after CDFT step 1 (the standard DFT wavefunction) to see the effect
# of using/not using atomic size adjustments
use_becke="TRUE"
use_radii="FALSE"
target="8.0"
strength="0.0"
# Restart from standard DFT wavefunction
restart_wfn="TRUE"
wfnfile="${project_file}-1_0.wfn"
project_file="${xyzfile%%.xyz}-cdft-noadj"
# Fill in template
fill_template
# Run calculation and save energy
echo "Calculating CDFT solution with Becke constraint"
$run_cp2k  "${template}_run.inp" >> "${project_file}.out"
noadj_energy=$(grep "ENERGY|" "${project_file}.out" | awk '{print $9}')

# Calculate charge tansfer energy with atomic size adjustments
use_radii="TRUE"
target="8.0"
strength="0.0"
project_file="${xyzfile%%.xyz}-cdft-withadj"
# Fill in template
fill_template
# Run calculation and save energy
echo "Calculating CDFT solution with Becke constraint and atomic size adjustments"
$run_cp2k  "${template}_run.inp" >> "${project_file}.out"
adj_energy=$(grep "ENERGY|" "${project_file}.out" | awk '{print $9}')

# Calculate charge tansfer energy with fragment based constraints
# First, save the electron densities of the isolated fragments to cube files
# Note that the fragments atoms are frozen in the same configuration they have in the full system
# Fragment 1
xyzfile="water-dimer-frag-a.xyz"
project_file="${xyzfile%%.xyz}-pbe-energy"
use_becke="FALSE"
use_radii="FALSE"
restart_wfn="FALSE"
center_sys="OFF"
save_cube="TRUE"
target="0.0"
strength="0.0"
wfnfile="dummy.wfn"
use_frag="FALSE"
frag1="dummy.cube"
frag2="dummy.cube"
frag1spin="dummy.cube"
frag2spin="dummy.cube"
# Fill in template
fill_template
# Run calculation
echo "Calculating DFT ground state for fragment 1"
$run_cp2k  "${template}_run.inp" >> "${project_file}.out"

# Fragment 2
xyzfile="water-dimer-frag-b.xyz"
project_file="${xyzfile%%.xyz}-pbe-energy"
# Fill in template
fill_template
# Run calculation
echo "Calculating DFT ground state for fragment 2"
$run_cp2k "${template}_run.inp" >> "${project_file}.out"

# Fragment based CDFT calculation without atomic size adjustments
xyzfile="water-dimer.xyz"
project_file="${xyzfile%%.xyz}-cdft-frag-noadj"
use_becke="TRUE"
use_radii="FALSE"
restart_wfn="TRUE"
wfnfile="${xyzfile%%.xyz}-pbe-energy-1_0.wfn"
center_sys="ON"
save_cube="FALSE"
# The constraint target value is calculated using the isolated fragment densities
target="0.0"
strength="0.0"
use_frag="TRUE"
frag1="water-dimer-frag-a-pbe-energy-ELECTRON_DENSITY-1_0.cube"
frag2="water-dimer-frag-b-pbe-energy-ELECTRON_DENSITY-1_0.cube"
frag1spin="water-dimer-frag-a-pbe-energy-SPIN_DENSITY-1_0.cube"
frag2spin="water-dimer-frag-b-pbe-energy-SPIN_DENSITY-1_0.cube"
# Fill in template
fill_template
# Run calculation and save energy
echo "Calculating CDFT solution with fragment Becke constraint"
$run_cp2k "${template}_run.inp" >> "${project_file}.out"
frag_noadj_energy=$(grep "ENERGY|" "${project_file}.out" | awk '{print $9}')

# Fragment based CDFT calculation with atomic size adjustments
project_file="${xyzfile%%.xyz}-cdft-frag-adj"
use_radii="TRUE"
# Fill in template
fill_template
# Run calculation and save energy
echo "Calculating CDFT solution with fragment Becke constraint and atomic size adjustments"
$run_cp2k "${template}_run.inp" >> "${project_file}.out"
frag_adj_energy=$(grep "ENERGY|" "${project_file}.out" | awk '{print $9}')

echo "Simulations ended successfully"
echo ""
echo "Summary of charge transfer energies (in mHa)"
awk -v method="Becke" -v x=$dft_energy -v y=$noadj_energy 'BEGIN {printf "%22s: %8.4f\n", method, 1000*(x-y)}'
awk -v method="Becke + radii" -v x=$dft_energy -v y=$adj_energy 'BEGIN {printf "%22s: %8.4f\n", method, 1000*(x-y)}'
awk -v method="Fragment Becke" -v x=$dft_energy -v y=$frag_noadj_energy 'BEGIN {printf "%22s: %8.4f\n", method, 1000*(x-y)}'
awk -v method="Fragment Becke + radii" -v x=$dft_energy -v y=$frag_adj_energy 'BEGIN {printf "%22s: %8.4f\n", method, 1000*(x-y)}'
