patch_file="${PWD}/specs.patch"
specs_dir=$(dirname $(gcc --print-file specs))
(cd $specs_dir && patch < $patch_file)
