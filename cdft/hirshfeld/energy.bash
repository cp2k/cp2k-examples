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
        -e "s|EXTERNAL_WFNRESTART_1|${wfnfile1}|g" \
        -e "s/EXTERNAL_RESTART_WFN_1/${restart_wfn}/g" \
        -e "s|EXTERNAL_WFNRESTART_2|${wfnfile2}|g" \
        -e "s/EXTERNAL_RESTART_WFN_2/${restart_wfn}/g" \
        -e "s/EXTERNAL_CONSTR_ACTIVE/${use_constr}/g" \
        -e "s/EXTERNAL_CONSTR_STR1/${strength1}/g" \
        -e "s/EXTERNAL_CONSTR_TARGET1/${target1}/g" \
        -e "s/EXTERNAL_CONSTR_STR2/${strength2}/g" \
        -e "s/EXTERNAL_CONSTR_TARGET2/${target2}/g" \
        -e "s/EXTERNAL_SHAPEFN/${shapefn}/g" \
        -e "s/EXTERNAL_GAUSSIAN/${gaussian}/g" \
        "${template}.inp" > "${template}_run.inp"
}

# Initialize default values for global variables
template="energy"
xyzfile="dummy.xyz"
project_file="dummy"
wfnfile1="dummy.wfn"
wfnfile2="dummy.wfn"
restart_wfn="FALSE"
strength1="0"
target1="0"
strength2="0"
target2="0"
use_constr="FALSE"
shapefn="GAUSSIAN"
gaussian="DEFAULT"

# Standard DFT calculation
template="energy"
xyzfile="Zn2-5A.xyz"
project_file="${xyzfile%%.xyz}-pbe-energy"
# Fill in template
fill_template
# Run calculation
echo "Calculating DFT ground state"
$run_cp2k "${template}_run.inp" >> "${project_file}.out"

# CDFT calculation: constrain the charge of the first Zn to +1/0 (i.e. 11/12 valence electrons)
# Also test different constraint formalisms
use_constr="TRUE"
restart_wfn="TRUE"
for shapefn in "gaussian" "density";
do
    for state in 1 2;
    do
        echo "Calculating CDFT state" $state ", Hirshfeld shape function " $shapefn
        if [[ "$state" == "1" ]]; then
            target1="11.0"
        else
            target1="12.0"
        fi
        # Restart from standard DFT wavefunction
        strength1="0.0"
        wfnfile1="${xyzfile%%.xyz}-pbe-energy-1_0.wfn"
        project_file="${xyzfile%%.xyz}-cdft-state$state-shapefn-$shapefn"
        # Fill in template
        fill_template
        # Run calculation
        $run_cp2k  "${template}_run.inp" >> "${project_file}.out"
    done
done

# Calculate electronic coupling between calculated CDFT states
target1="11.0"
target2="12.0"
template="energy_mixed"
for shapefn in "gaussian" "density";
do
    project_file="${xyzfile%%.xyz}-mixed-cdft-shapefn-$shapefn"
    # Use converged wavefunctions as restarts
    wfnfile1="${xyzfile%%.xyz}-cdft-state1-shapefn-$shapefn-1_0.wfn"
    wfnfile2="${xyzfile%%.xyz}-cdft-state2-shapefn-$shapefn-1_0.wfn"
    # Get converged constraint strengths
    strength1=$(grep "Strength" "${xyzfile%%.xyz}-cdft-state1-shapefn-$shapefn.out" | tail -1 |  awk '{print $5}')
    strength2=$(grep "Strength" "${xyzfile%%.xyz}-cdft-state2-shapefn-$shapefn.out" | tail -1 |  awk '{print $5}')
    # Fill in template
    fill_template
    # Run calculation
    echo "Calculating electronic coupling between CDFT states, Hirshfeld shape function " $shapefn
    $run_cp2k  "${template}_run.inp" >> "${project_file}.out"
done

echo "Simulations ended successfully"