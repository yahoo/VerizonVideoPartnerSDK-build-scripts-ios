set -e

if ! which sourcery > /dev/null; then
echo "error: Sourcery is missing. Make brew install sourcery."
exit 1
fi

sources=$1
code_generation_dir=$2
file_name=$3

if [ -f ${file_name} ]
then
    rm ${file_name}
fi
sourcery --sources ${sources} \
         --sources ${code_generation_dir}/Autogeneratable.swift \
         --templates ${code_generation_dir}/${INPUT_FILE_BASE}.stencil \
         --output ${file_name}

