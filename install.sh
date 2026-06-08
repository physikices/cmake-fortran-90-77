#!/usr/bin/env bash
set -euo pipefail

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
COLOR_SCRIPT="$SCRIPT_DIR/.dev/termcolors.sh"

if [[ -f "$COLOR_SCRIPT" ]]; then
    source "$COLOR_SCRIPT"
else
    GREEN="" YELLOW="" RED="" RESET=""
fi

# Prompt for project name
read -rp "Enter project name (default: my_project): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-my_project}

if [[ ! "$PROJECT_NAME" =~ ^[A-Za-z0-9_-]+$ ]]; then
    echo "${RED}Invalid project name. Use only letters, numbers, underscores, and hyphens.${RESET}" >&2
    exit 1
fi

read -rp "Enter project description: " PROJECT_DESC

# Create project directories
DEST_DIR="$SCRIPT_DIR/$PROJECT_NAME"
mkdir -p "$DEST_DIR"/{src,modules,libF77,tests,bin,.dev}

# Copy color utility
if [[ -f "$COLOR_SCRIPT" ]]; then
    cp "$COLOR_SCRIPT" "$DEST_DIR/.dev/termcolors.sh"
else
    {
        printf '%s\n' '#!/usr/bin/env bash'
        printf '%s\n' 'GREEN=$(tput setaf 2 2>/dev/null || echo "")'
        printf '%s\n' 'YELLOW=$(tput setaf 3 2>/dev/null || echo "")'
        printf '%s\n' 'BLUE=$(tput setaf 4 2>/dev/null || echo "")'
        printf '%s\n' 'RED=$(tput setaf 1 2>/dev/null || echo "")'
        printf '%s\n' 'CYAN=$(tput setaf 6 2>/dev/null || echo "")'
        printf '%s\n' 'RESET=$(tput sgr0 2>/dev/null || echo "")'
    } > "$DEST_DIR/.dev/termcolors.sh"
fi

# Function to render templates
escape_sed_replacement() {
    printf '%s' "$1" | sed -e 's/[\/&|\\]/\\&/g'
}

render_template() {
    local template_file="$1"
    local output_file="$2"
    local escaped_project_name
    local escaped_project_desc
    local cmake_project_desc

    cmake_project_desc="${PROJECT_DESC//\\/\\\\}"
    cmake_project_desc="${cmake_project_desc//\"/\\\"}"
    escaped_project_name="$(escape_sed_replacement "$PROJECT_NAME")"
    escaped_project_desc="$(escape_sed_replacement "$cmake_project_desc")"

    sed -e "s|@PROJECT_NAME@|$escaped_project_name|g" \
        -e "s|@PROJECT_DESC@|$escaped_project_desc|g" \
        "$template_file" > "$output_file"
}

# Generate files from templates
render_template "$TEMPLATE_DIR/CMakeLists.txt.in" "$DEST_DIR/CMakeLists.txt"
render_template "$TEMPLATE_DIR/libF77_CMakeLists.txt.in" "$DEST_DIR/libF77/CMakeLists.txt"
render_template "$TEMPLATE_DIR/tests_CMakeLists.txt.in" "$DEST_DIR/tests/CMakeLists.txt"
render_template "$TEMPLATE_DIR/utils.f.in" "$DEST_DIR/libF77/utils.f"
render_template "$TEMPLATE_DIR/physics_model.f90.in" "$DEST_DIR/modules/physics_model.f90"
render_template "$TEMPLATE_DIR/main.f90.in" "$DEST_DIR/src/main.f90"
render_template "$TEMPLATE_DIR/test.f90.in" "$DEST_DIR/tests/test.f90"
render_template "$TEMPLATE_DIR/gitignore.in" "$DEST_DIR/.gitignore"
render_template "$TEMPLATE_DIR/fortls.json.in" "$DEST_DIR/.fortls.json"
render_template "$TEMPLATE_DIR/launch.sh.in" "$DEST_DIR/launch.sh"
chmod +x "$DEST_DIR/launch.sh"

# Inicializar Git
cd "$DEST_DIR"
git init
git add .
if ! git commit -m "Initial commit for $PROJECT_NAME"; then
    echo "${YELLOW}Git commit skipped. Configure user.name and user.email, then commit manually if needed.${RESET}"
fi

echo "  ${GREEN}-> Project \"$PROJECT_NAME\" created successfully in:${RESET} \"$DEST_DIR\"."
