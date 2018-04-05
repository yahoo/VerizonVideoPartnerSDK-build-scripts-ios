set -e

if ! which sourcery > /dev/null; then
echo "error: Sourcery is missing. Make brew install sourcery."
exit 1
fi

sources=$1
code_generation_dir=$2

sourcery --sources ${sources} \
         --sources ${code_generation_dir}/Autogeneratable.swift \
         --templates ${code_generation_dir}/${INPUT_FILE_BASE}.stencil \
         --output ${DERIVED_SOURCES_DIR}/${INPUT_FILE_BASE}_${TARGET_NAME}.generated.swift
