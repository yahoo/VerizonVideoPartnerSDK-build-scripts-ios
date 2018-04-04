set -e

if ! which sourcery > /dev/null; then
echo "error: Sourcery is missing. Make brew install sourcery."
exit 1
fi

templates=$1
output=$2

sourcery --sources sources/ --templates "${INPUT_FILE_DIR}/${INPUT_FILE_NAME}" --output "${DERIVED_SOURCES_DIR}/${INPUT_FILE_BASE}_${TARGET_NAME}.generated.swift"

