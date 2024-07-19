#!/bin/bash

rel_cutoffs="10 20 30 40 50 60 70 80 90 100"

basis_file=BASIS_SET
potential_file=GTH_POTENTIALS
template_file=template.inp
input_file=Si_bulk8.inp

cutoff=250

for ii in $rel_cutoffs ; do
    work_dir=rel_cutoff_${ii}Ry
    if [ ! -d $work_dir ] ; then
        mkdir $work_dir
    else
        rm -r $work_dir/*
    fi
    sed -e "s/LT_cutoff/${cutoff}/g" \
        -e "s/LT_rel_cutoff/${ii}/g" \
        $template_file > $work_dir/$input_file
    cp $basis_file $work_dir
    cp $potential_file $work_dir
done
