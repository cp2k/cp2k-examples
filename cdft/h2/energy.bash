#!/bin/bash
set -e
usage="$(basename "$0") [-h] [-p path] [-c cores] [-m mpi] [-x mode] -- program to run the CP2K CDFT tutorial calculations

where:
    -h  show this help text
    -p  path to CP2K installation (default: .)
    -c  number of MPI processes to use for calculation (default: 2)
    -m  name and path of program to execute MPI programs (default: mpiexec)
    -x  define which type of calculation should be run. accepts keywords 'all', 'dft', 'fragment', 'cdft', 'ci', 'results' (default: none)
    -d  define a list of distances to use in calculation. accepts keywords 'short' (fewer distances, faster to run), 'long' (default: short)"

ncores=2
path="."
mpi_program="mpiexec"
run_dft="FALSE"
run_fragment="FALSE"
run_cdft="FALSE"
run_ci="FALSE"
run_results="FALSE"
use_distance="short"

while getopts ':hp:c:m:x:d:' option; do
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
        x)
            case "$OPTARG" in
                all)
                    echo "Running DFT, Fragment, CDFT and CDFT-CI calculations and summarizing results" >&2
                    run_dft="TRUE"
                    run_fragment="TRUE"
                    run_cdft="TRUE"
                    run_ci="TRUE"
                    run_results="TRUE";;
                dft)
                    echo "Running DFT calculations" >&2
                    run_dft="TRUE";;
                fragment)
                    echo "Running Fragment calculations" >&2
                    run_fragment="TRUE";;
                cdft)
                    echo "Running CDFT calculations" >&2
                    run_cdft="TRUE";;
                ci)
                    echo "Running CDFT-CI calculations" >&2
                    run_ci="TRUE";;
                results)
                    echo "Summarizing results" >&2
                    run_results="TRUE";;
                *)
                    echo "illegal value passed to -x" >&2
                    echo "$usage" >&2
                    exit 1 ;;
            esac
            ;;
        d)
            case "$OPTARG" in
                short)
                    use_distance="short";;
                long)
                    use_distance="long";;
                *)
                    echo "illegal value passed to -d" >&2
                    echo "$usage" >&2
                    exit 1 ;;
            esac
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
        -e "s/EXTERNAL_CENTER_SYS/${center_sys}/g" \
        -e "s|EXTERNAL_WFNRESTART_1|${wfnfile1}|g" \
        -e "s/EXTERNAL_RESTART_WFN_1/${restart_wfn}/g" \
        -e "s|EXTERNAL_WFNRESTART_2|${wfnfile2}|g" \
        -e "s/EXTERNAL_RESTART_WFN_2/${restart_wfn}/g" \
        -e "s/EXTERNAL_BECKE_STR1/${strength1}/g" \
        -e "s/EXTERNAL_BECKE_TARGET1/${target1}/g" \
        -e "s/EXTERNAL_BECKE_STR2/${strength2}/g" \
        -e "s/EXTERNAL_BECKE_TARGET2/${target2}/g" \
        -e "s/EXTERNAL_BECKE_ACTIVE/${use_becke}/g" \
        -e "s/EXTERNAL_CHARGE/${charge}/g" \
        -e "s/EXTERNAL_SAVE_CUBE/${save_cube}/g" \
        -e "s/EXTERNAL_BECKE_FRAG_CONS/${use_frag}/g" \
        -e "s|EXTERNAL_BECKE_FRAG_A|${frag1}|g" \
        -e "s|EXTERNAL_BECKE_FRAG_SPIN_A|${frag1spin}|g" \
        -e "s|EXTERNAL_BECKE_FRAG_B|${frag2}|g" \
        -e "s|EXTERNAL_BECKE_FRAG_SPIN_B|${frag2spin}|g" \
        -e "s|EXTERNAL_BECKE_ATOM|${active_atom}|g" \
        -e "s|EXTERNAL_BECKE_DUMMY|${dummy_atom}|g" \
        "${template}.inp" > "${template}_run.inp"
}

# Initialize default values for global variables
template="energy"
xyzfile="dummy.xyz"
project_file="dummy"
center_sys="ON"
wfnfile1="dummy.wfn"
wfnfile2="dummy.wfn"
restart_wfn="FALSE"
strength1="0"
target1="0"
strength2="0"
target2="0"
use_becke="FALSE"
charge="1"
save_cube="FALSE"
use_frag="FALSE"
frag1="dummy.cube"
frag1spin="dummy.cube"
frag2="dummy.cube"
frag2spin="dummy.cube"
active_atom="1"
dummy_atom="2"

case "$use_distance" in
    short)
        declare -a distancelist=($(seq -f '%.2f' 0.5 0.05 0.55));; # && seq -f '%.2f' 2.0 2.0 10.0));;
    long)
        declare -a distancelist=($(seq -f '%.2f' 0.5 0.05 1.5 && seq -f '%.2f' 2.0 0.5 10.0));;
esac
echo " "
printf "Calculations are performed for distances: %s \n" "${distancelist[*]}"
echo " "
total=${#distancelist[*]}
# Standard DFT calculation with different H-H distances
template="energy"
xyzbase="h2-dist"
xyzpath="./XYZ"
wfnbase="./KS/"
if [[ "$run_dft" == "TRUE" ]]; then
    mkdir -p KS
    echo " "
    echo "Starting DFT ground state calculations"
    for (( i=0; i<=$(( $total-1 )); i++ ));
    do
        distance="${distancelist[$i]}"
        xyzfile="${xyzpath}/${xyzbase}-${distance}.xyz"
        project_file="${xyzbase}-${distance}-pbe-energy-q${charge}"
        # Lets try to restart from the wave function converged at the previous distance
        if [[ "$i" -ne "0" ]]; then
            restart_wfn="TRUE"
            prev=$((i-1))
            prev_distance=${distancelist[$prev]}
            wfnfile1="${wfnbase}/${xyzbase}-${prev_distance}-pbe-energy-q${charge}-1_0.wfn"
        else
            restart_wfn="FALSE"
            wfnfile1="dummy.wfn"
        fi
        # Fill in template
        fill_template
        # Run calculation
        echo "Calculating DFT ground state for H-H distance: " $distance
        $run_cp2k "${template}_run.inp" >> "${project_file}.out"
        completed=$(grep "PROGRAM ENDED AT" "${project_file}.out")
        # Check for succesful completion
        if ! [[ -n "$completed" ]]; then
            echo "Something went wrong with the calculation. Check the output file: " "${project_file}.out"
            exit 1
        fi
        mv ${project_file}* ${wfnbase}/
    done
fi

if [[ "${run_fragment}" == "TRUE" ]]; then
    # Standard DFT calculation for fragments {1,2} with different H-H distances
    save_cube="TRUE"
    center_sys="OFF"
    wfnbase="./Frag/"
    cube_path="./Cube"
    mkdir -p $cube_path
    mkdir -p $wfnbase
    for frag in 1 2;
    do
        echo " "
        echo "Starting DFT ground state calculation for fragment " $frag
        for charge in 0 1;
        do
            for (( i=0; i<=$(( $total-1 )); i++ ));
            do
                distance="${distancelist[$i]}"
                xyzfile="${xyzpath}/${xyzbase}-${distance}-frag-${frag}.xyz"
                project_file="${xyzbase}-${distance}-frag-${frag}-pbe-energy-q${charge}"
                # Lets try to restart from the wave function converged at the previous distnace
                if [[ "$i" -ne "0" ]]; then
                    restart_wfn="TRUE"
                    prev=$((i-1))
                    prev_distance=${distancelist[$prev]}
                    wfnfile1="${wfnbase}/${xyzbase}-${prev_distance}-frag-${frag}-pbe-energy-q${charge}-1_0.wfn"
                else
                    restart_wfn="FALSE"
                    wfnfile1="dummy.wfn"
                fi
                # Fill in template
                fill_template
                # Run calculation
                echo "Calculating DFT ground state for fragment 1, charge state (" $charge ") at H-H distance: " $distance
                $run_cp2k "${template}_run.inp" >> "${project_file}.out"
                completed=$(grep "PROGRAM ENDED AT" "${project_file}.out")
                # Check for succesful completion
                if ! [[ -n "$completed" ]]; then
                    echo "Something went wrong with the calculation. Check the output file: " "${project_file}.out"
                    exit 1
                fi
                mv *cube $cube_path/
                mv ${project_file}* ${wfnbase}/
            done
        done
    done
fi
# CDFT calculations: constrain the charge of the first H atom
if [[ "${run_cdft}" == "TRUE" ]]; then
    save_cube="FALSE"
    use_becke="TRUE"
    use_frag="TRUE"
    charge="1"
    cube_path="./Cube"
    center_sys="ON"
    wfnbase="./CDFT/"
    mkdir -p $wfnbase
    active_atom="1"
    dummy_atom="2"
    # Dummy, we are using fragment constraints
    target="0"
    for state in 1 2;
    do
        echo " "
        echo "Starting CDFT calculation for state " $state
        for (( i=0; i<=$(( $total-1 )); i++ ));
        do
            distance="${distancelist[$i]}"
            xyzfile="${xyzpath}/${xyzbase}-${distance}.xyz"
            project_file="${xyzbase}-${distance}-cdft-state${state}"
            # Lets try to restart from the wave function converged at the previous distance
            if [[ "$i" -ne "0" ]]; then
                restart_wfn="TRUE"
                prev=$((i-1))
                prev_distance=${distancelist[$prev]}
                wfnfile1="${wfnbase}/${xyzbase}-${prev_distance}-cdft-state${state}-1_0.wfn"
                strength1=$(grep "Strength" "${wfnbase}/${xyzbase}-${prev_distance}-cdft-state${state}.out" | tail -1 | awk '{print $5}')
            # Fallback to unconstrained wave function
            else
                restart_wfn="TRUE"
                wfnfile1="./KS/${xyzbase}-${distance}-pbe-energy-q1-1_0.wfn"
                target1="0.0"
                strength1="0.0"
            fi
            if [[ "${state}" == "1" ]]; then
                frag1="${cube_path}/${xyzbase}-${distance}-frag-1-pbe-energy-q1-ELECTRON_DENSITY-1_0.cube"
                frag1spin="${cube_path}/${xyzbase}-${distance}-frag-1-pbe-energy-q1-SPIN_DENSITY-1_0.cube"
                frag2="${cube_path}/${xyzbase}-${distance}-frag-2-pbe-energy-q0-ELECTRON_DENSITY-1_0.cube"
                frag2spin="${cube_path}/${xyzbase}-${distance}-frag-2-pbe-energy-q0-SPIN_DENSITY-1_0.cube"
            elif [[ "${state}" == "2" ]]; then
                frag1="${cube_path}/${xyzbase}-${distance}-frag-1-pbe-energy-q0-ELECTRON_DENSITY-1_0.cube"
                frag1spin="${cube_path}/${xyzbase}-${distance}-frag-1-pbe-energy-q0-SPIN_DENSITY-1_0.cube"
                frag2="${cube_path}/${xyzbase}-${distance}-frag-2-pbe-energy-q1-ELECTRON_DENSITY-1_0.cube"
                frag2spin="${cube_path}/${xyzbase}-${distance}-frag-2-pbe-energy-q1-SPIN_DENSITY-1_0.cube"
            else
                echo "Unknown CDFT state: ${state}. Accepts values 1 and 2."
                exit 1
            fi
            # Fill in template
            fill_template
            # Run calculation
            echo "Calculating CDFT state " $state " at H-H distance: " $distance
            $run_cp2k "${template}_run.inp" >> "${project_file}.out"
            completed=$(grep "PROGRAM ENDED AT" "${project_file}.out")
            # Check for succesful completion
            if ! [[ -n "$completed" ]]; then
                echo "Something went wrong with the calculation. Check the output file: " "${project_file}.out"
                exit 1
            fi
            mv ${project_file}* ${wfnbase}/
        done
    done
fi

if [[ "${run_ci}" == "TRUE" ]]; then
    template="energy_mixed"
    outpath="./CDFT-CI/"
    wfnbase="./CDFT/"
    mkdir -p $outpath
    echo " "
    echo "Starting CDFT-CI calculation"

    for (( i=0; i<=$(( $total-1 )); i++ ));
    do
        distance="${distancelist[$i]}"
        xyzfile="${xyzpath}/${xyzbase}-${distance}.xyz"
        project_file="${xyzbase}-${distance}-cdftci"
        # Use converged wavefunctions as restarts
        wfnfile1="${wfnbase}/${xyzbase}-${distance}-cdft-state1-1_0.wfn"
        wfnfile2="${wfnbase}/${xyzbase}-${distance}-cdft-state2-1_0.wfn"
        # Get converged constraint strengths and taget values
        strength1=$(grep "Strength of constraint" "${wfnbase}/${xyzbase}-${distance}-cdft-state1.out" | tail -1 |  awk '{print $5}')
        strength2=$(grep "Strength of constraint" "${wfnbase}/${xyzbase}-${distance}-cdft-state2.out" | tail -1 |  awk '{print $5}')
        target1=$(grep "Target value of constraint" "${wfnbase}/${xyzbase}-${distance}-cdft-state1.out" | tail -1 |  awk '{print $6}')
        target2=$(grep "Target value of constraint" "${wfnbase}/${xyzbase}-${distance}-cdft-state2.out" | tail -1 |  awk '{print $6}')

        # Fill in template
        fill_template
        # Run calculation
        echo "Calculating electronic coupling between CDFT states for H-H distance: " $distance
        $run_cp2k  "${template}_run.inp" >> "${project_file}.out"
        completed=$(grep "PROGRAM ENDED AT" "${project_file}.out")
        # Check for succesful completion
        if ! [[ -n "$completed" ]]; then
            echo "Something went wrong with the calculation. Check the output file: " "${project_file}.out"
            exit 1
        fi
        mv ${project_file}* ${outpath}/
    done
fi

if [[ "${run_results}" == "TRUE" ]]; then
    ci_outpath="./CDFT-CI"
    ks_outpath="./KS"
    outfile="cdftci-results.dat"
    echo "Collecting results from KS and CDFT-CI calculations to file: " $outfile
    rm -f $outfile
    touch $outfile
    awk 'BEGIN {print "#Distance \t Energy (PBE) \t Energy (CDFT-CI PBE)"}' >> $outfile

    for (( i=0; i<=$(( $total-1 )); i++ ));
    do
        distance="${distancelist[$i]}"
        project_file="${ci_outpath}/${xyzbase}-${distance}-cdftci.out"
        grep_string="Ground state energy:"
        print_num="4"
        energy=$(grep "$grep_string" "$project_file" | tail -1 | awk -vb="${print_num}" '{print $b}')
        grep_string="ENERGY|"
        print_num="9"
        project_file="${ks_outpath}/${xyzbase}-${distance}-pbe-energy-q1.out"
        ks_energy=$(grep "$grep_string" "$project_file" | tail -1 | awk -vb="${print_num}" '{print $b}')
        echo $distance "      " $energy "    " $ks_energy >> $outfile
    done
fi
