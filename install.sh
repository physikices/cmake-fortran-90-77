#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/.term/colors.sh"

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
COLOR_SCRIPT="$SCRIPT_DIR/.term/colors.sh"

# Prompt for project name
read -rp "Enter project name (default: my_project): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-my_project}

read -rp "Enter project description: " PROJECT_DESC

# Create project directories
DEST_DIR="$SCRIPT_DIR/$PROJECT_NAME"
mkdir -p "$DEST_DIR"/{src,modules,libF77,tests,bin,.term}

# Copy color utility
cp "$COLOR_SCRIPT" "$PROJECT_NAME/.term/colors.sh"

# Function to render templates
render_template() {
    local template_file="$1"
    local output_file="$2"

    sed -e "s|@PROJECT_NAME@|$PROJECT_NAME|g" \
        -e "s|@PROJECT_DESC@|$PROJECT_DESC|g" \
        "$template_file" > "$output_file"
}

# Generate files from templates
render_template "$TEMPLATE_DIR/CMakeLists.txt.in" "$PROJECT_NAME/CMakeLists.txt"
render_template "$TEMPLATE_DIR/libF77_CMakeLists.txt.in" "$PROJECT_NAME/libF77/CMakeLists.txt"
render_template "$TEMPLATE_DIR/tests_CMakeLists.txt.in" "$PROJECT_NAME/tests/CMakeLists.txt"
render_template "$TEMPLATE_DIR/utils.f.in" "$PROJECT_NAME/libF77/utils.f"
render_template "$TEMPLATE_DIR/physics_model.f90.in" "$PROJECT_NAME/modules/physics_model.f90"
render_template "$TEMPLATE_DIR/main.f90.in" "$PROJECT_NAME/src/main.f90"
render_template "$TEMPLATE_DIR/test.f90.in" "$PROJECT_NAME/tests/test.f90"
render_template "$TEMPLATE_DIR/gitignore.in" "$PROJECT_NAME/.gitignore"
render_template "$TEMPLATE_DIR/launch.sh.in" "$PROJECT_NAME/launch.sh"
# Inicializar Git
cd "$DEST_DIR"
git init
git add .
git commit -m "Initial commit for $PROJECT_NAME"

echo "  ${GREEN}-> Project \"$PROJECT_NAME\" created successfully in:${RESET} \"$DEST_DIR\"."
