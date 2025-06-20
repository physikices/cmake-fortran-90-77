#!/bin/bash

set -e

YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

read -p "Enter the project name (default: my_project): " PROJ
PROJ=${PROJ:-my_project}
echo "Creating project: $PROJ"

mkdir -p $PROJ/{src,libF77,modules,tests,bin}
cd $PROJ

### CMakeLists.txt principal
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.21)
project(app_exe
  VERSION 0.1.0
  DESCRIPTION "Fortran package devel-environment"
  LANGUAGES Fortran
)

enable_language(Fortran)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

add_subdirectory(libF77)
add_subdirectory(modules)
add_subdirectory(tests)
enable_testing()

add_executable(${PROJECT_NAME})
target_sources(${PROJECT_NAME} PRIVATE src/main.f90)
target_link_libraries(${PROJECT_NAME}
  PRIVATE ${PROJECT_NAME}-modules
  PRIVATE ${PROJECT_NAME}-libF77
)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/modules)
EOF

### src/main.f90
cat > src/main.f90 << 'EOF'
program main
  use physics_model
  implicit none
  double precision :: x, result

  x = 3.0d0
  call print_banner()
  result = model_function(x)
  print *, 'Resultado da função física =', result
end program main
EOF

### libF77/utils.f
cat > libF77/utils.f << 'EOF'
      subroutine print_banner()
      print *, '========== T4C FORTRAN PROJECT =========='
      return
      end
EOF

### libF77/CMakeLists.txt
cat > libF77/CMakeLists.txt << 'EOF'
file(GLOB lib_sources CONFIGURE_DEPENDS *.f)
add_library(${PROJECT_NAME}-libF77 STATIC ${lib_sources})
target_include_directories(${PROJECT_NAME}-libF77 PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
EOF

### modules/physics_model.f90
cat > modules/physics_model.f90 << 'EOF'
module physics_model
  implicit none
contains
  function model_function(x) result(y)
    double precision, intent(in) :: x
    double precision :: y
    y = x**2 + 1.0d0
  end function model_function
end module physics_model
EOF

### modules/CMakeLists.txt
cat > modules/CMakeLists.txt << 'EOF'
file(GLOB module_sources CONFIGURE_DEPENDS *.f90)

add_library(${PROJECT_NAME}-modules STATIC ${module_sources})
target_include_directories(${PROJECT_NAME}-modules PUBLIC ${CMAKE_CURRENT_BINARY_DIR})

set_target_properties(${PROJECT_NAME}-modules PROPERTIES
  Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)
EOF

### tests/test.f90
cat > tests/test.f90 << 'EOF'
program test_model
  use physics_model
  implicit none
  double precision :: x, y

  x = 2.0d0
  y = model_function(x)

  if (abs(y - 5.0d0) < 1.0d-6) then
     print *, 'Teste OK.'
     stop 0
  else
     print *, 'Teste falhou: y =', y
     stop 1
  end if
end program test_model
EOF

### tests/CMakeLists.txt
cat > tests/CMakeLists.txt << 'EOF'
enable_testing()

add_executable(test_${PROJECT_NAME} test.f90)
target_link_libraries(test_${PROJECT_NAME}
  PRIVATE ${PROJECT_NAME}-modules
  PRIVATE ${PROJECT_NAME}-libF77
)
target_include_directories(test_${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/modules)

add_test(NAME run_tests COMMAND test_${PROJECT_NAME})
EOF

### .gitignore
cat > .gitignore << 'EOF'
# Build artifacts
/build/
/bin/
/*.mod
/*.o
/CMakeFiles/
/CMakeCache.txt
/Makefile
/install_manifest.txt

# Editor/OS files
*.swp
*.swo
*.DS_Store
EOF

## main scripts
cat > install.sh << 'EOF'
#!/usr/bin/env bash

set -euo pipefail

# Use tput for portable color output
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# Optional: allow setting build directory via argument or environment variable
BUILD_DIR="${1:-${BUILD_DIR:-build}}"

echo "${BLUE}Removing previous build directory: $BUILD_DIR${RESET}"
rm -rf "$BUILD_DIR"

echo "${YELLOW}Configuring project with CMake...${RESET}"
cmake -S . -B "$BUILD_DIR"

echo "${CYAN}Building project...${RESET}"
cmake --build "$BUILD_DIR"

echo "${CYAN}Build completed successfully.${RESET}"
EOF

###
cat > run.sh << 'EOF'
#!/usr/bin/env bash

set -euo pipefail

BIN_DIR="../bin"
BUILD_DIR="build"
EXECUTABLE="app_exe"

# Ensure build directory exists
if ! cd "$BUILD_DIR"; then
    echo "Error: build directory '$BUILD_DIR' not found." >&2
    exit 1
fi

cmake ..
cmake --build .

# Ensure bin directory exists
if ! cd "$BIN_DIR"; then
    echo "Error: bin directory '$BIN_DIR' not found." >&2
    exit 1
fi

if [[ ! -x "$EXECUTABLE" ]]; then
    echo "Error: Executable '$EXECUTABLE' not found or not executable." >&2
    exit 1
fi

# Use tput for portable color output
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)
echo "${CYAN}Executing $EXECUTABLE${RESET}"
./"$EXECUTABLE"

EOF
###
cat > test.sh << 'EOF'
#!/usr/bin/env bash

# Run CTest in the build directory and exit if it fails
if ! ctest --test-dir build; then
    echo "CTest failed." >&2
    exit 1
fi
EOF

### Inicializa Git
chmod +x install.sh run.sh test.sh
git init
git add .
git commit -m "Initial commit: Fortran modular project with CMake"



echo "-> ${BLUE}Project $PROJ successfully built.${RESET}"
echo "-> To rebuild the project:"
echo "   ${YELLOW}cd $PROJ/${RESET}"
echo "   ${CYAN}./install.sh${RESET}"
echo "-> run and test the project:"
echo "   ${YELLOW}cd $PROJ/${RESET}"
echo "   ${CYAN}./run.sh${RESET} && ${CYAN}./test.sh${RESET}"
