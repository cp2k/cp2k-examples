#!/bin/bash

rel_cutoffs="10 20 30 40 50 60 70 80 90 100"

cp2k_bin=cp2k.popt
input_file=Si_bulk8.inp
output_file=Si_bulk8.out
no_proc_per_calc=2
no_proc_to_use=16

counter=1
max_parallel_calcs=$(expr $no_proc_to_use / $no_proc_per_calc)
for ii in $rel_cutoffs ; do
    work_dir=rel_cutoff_${ii}Ry
    cd $work_dir
    if [ -f $output_file ] ; then
        rm $output_file
    fi
    mpirun -np $no_proc_per_calc $cp2k_bin -o $output_file $input_file &
    cd ..
    mod_test=$(echo "$counter % $max_parallel_calcs" | bc)
    if [ $mod_test -eq 0 ] ; then
        wait
    fi
    counter=$(expr $counter + 1)
done
wait
