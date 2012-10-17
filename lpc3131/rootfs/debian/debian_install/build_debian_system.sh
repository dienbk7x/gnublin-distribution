#!/bin/bash
# Bash script that creates a Debian rootfs or even a complete bootable SD-Card for the Embedded Projects Gnublin board
# Should run on current Debian or Ubuntu versions
# Author: Ingmar Klein (ingmar.klein@hs-augsburg.de)
# Edited by Benedikt Niedermayr (niedermayr@embedded-projects.net)
#



# This program (including documentation) is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License version 3 (GPLv3; http://www.gnu.org/licenses/gpl-3.0.html ) for more details.

trap cleanup INT
source $root_path/rootfs/debian/debian_install/build_functions.sh		 # functions called by this main build script

#########################
###### Main script ######
#########################


check_priviliges # check if the script was run with root priviliges

mkdir -p ${output_dir} # main directory for the build process
if [ "$?" = "0" ]
then
	echo "Output directory '${output_dir}' successfully created."
else
	echo "ERROR while trying to create the output directory '${output_dir}'. Exiting now!"
	exit 1
fi


mkdir ${output_dir}/tmp # subdirectory for all downloaded or local temporary files
if [ "$?" = "0" ]
then
	echo "Subfolder 'tmp' of output directory '${output_dir}' successfully created."
else
	echo "ERROR while trying to create the 'tmp' subfolder '${output_dir}/tmp'. Exiting now!"
	exit 2
fi

check_n_install_prerequisites # see if all needed packages are installed and if the versions are sufficient

create_n_mount_temp_image_file # create the image file that is then used for the rootfs

do_debootstrap # run debootstrap (first and second stage)

disable_mnt_tmpfs # disable all entries in /etc/init.d trying to mount temporary filesystems (tmpfs), in order to save precious RAM

do_post_debootstrap_config # do some further system configuration

######################################################
###Hier den Kernel ins rootfs einfügen(vor compress!)#
######################################################
cp $root_path/kernel/$kernel_name/arch/arm/boot/zImage $root_path/kernel/$kernel_name
compress_debian_rootfs # compress the resulting rootfs

if [ "${create_disk}" = "yes" ]
then
	partition_n_format_disk # SD-card: make partitions and format
	finalize_disk # copy the bootloader, rootfs and kernel to the SD-card
fi

#tar -xzvpf "${output_dir}/${output_filename}.tar.${tar_format}" -C "${output_dir}"
#cp -rp /home/brenson/Arbeitsfläche/Projekte/Terrarien_steuerung/Gnublin_rfs/debian_filesystem/Gnublin_Debian/Temperatur_steuerung /home/brenson/Arbeitsfläche/Projekte/Terrarien_steuerung/Gnublin_rfs/debian_filesystem/Gnublin_Debian/own /media/d3bb4f51-bf46-43b6-8948-7daf946ee77f/root/

#cp /media/d3bb4f51-bf46-43b6-8948-7daf946ee77f/linux-2.6.33/arch/arm/boot/zImage /media/d3bb4f51-bf46-43b6-8948-7daf946ee77f/

#cp -rp /home/brenson/tmp/lib/modules /media/d3bb4f51-bf46-43b6-8948-7daf946ee77f/lib/
exit 0