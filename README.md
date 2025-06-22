# Fortran Modular (90/77) Project Template 🚀

This project provides a clean, modular template for developing scientific applications in Fortran using CMake. It supports separation of concerns via directories for modules, libraries, tests, and executables, and it includes helper scripts for building, running, and testing.

## 📦 Features

- Modular Fortran 90/77 code organization
- CMake-based build system
- Built-in support for unit testing
- Template-based project initialization
- Automatic file generation with variable substitution
- Git-ready structure

---
## 🛠 Project Structure
```
my_project/
├── src/ # Main program source files
├── modules/ # Fortran modules (e.g., physics models)
├── libF77/ # Auxiliary F77 routines
├── tests/ # Unit test programs
├── bin/ # Output binaries
├── scripts/ # Utility shell scripts
├── CMakeLists.txt # Main CMake build configuration
├── run.sh # Script to run the executable
├── install.sh # Script to configure and build the project
├── test.sh # Script to run the tests
└── .gitignore
```
---

## ⚙️ Requirements

- [CMake >= 3.21](https://cmake.org/download/)
- [GFortran](https://gcc.gnu.org/fortran/)
- [inotify](https://man7.org/linux/man-pages/man7/inotify.7.html)
- Make (on Unix-like systems)

Make sure these tools are available in your PATH, executing `cmake --version`, `gfortran --version`, `inotifywait -h` and `make --version` should work.

Or install automatically using the `launch.sh` script:

```bash
 cd cmake-fortran-90-77/my_project/
 chmod +x launch.sh
 ./launch.sh install
```

---

## 🚀 Getting Started

To initialize a new project from the template:

```bash
 cd cmake-fortran-90-77/
 chmod +x install.sh
 ./install.sh
```

---
## 📄 Template Rendering

The initialization script automatically renders all .in template files using environment variables (e.g., $PROJECT_NAME), placing the processed outputs in the correct directories.


## 🚀 Build and Run Manually

### 1. Build

In the created project folder, e.g. `my_project/`, run the commands:
```bash
mkdir build
cd build
cmake ..
make
cd ..
```

The main executable will be generated in:

```bash
bin/my_project.bin
```

### 2. Run the Program

```bash
./bin/my_project.bin
```

Expected output:

```kotlin
========== T4C FORTRAN PROJECT ==========
Physical function result =   10.0000000000000
```

---

## ✅ Tests

This project uses [CTest](https://cmake.org/cmake/help/latest/manual/ctest.1.html) for automated testing.

### 1. Run Tests:

In the created project folder, e.g. `my_project/`, run the commands:
```bash
cd build
ctest
cd ..
```

### 2. Expected Output:

```bash
Test project /path/to/build
    Start 1: run_tests
1/1 Test #1: run_tests ..................   Passed
```
---

## 🔄 Auto-Rebuild/Run/Test (Optional)

For development, you can enable automatic rebuilds when Fortran files change, in the created project folder, e.g. `my_project/`, run the commands:
```bash
 chmod +x launch.sh
 ./launch.sh watch
```

To run the project/test automatically:

```bash
 ./launch.sh run
```
and

```bash
 ./launch.sh test
```

---

## 🔍 Library Description

### 🔧 `libF77/`

Contains legacy utility subroutines (Fortran 77), such as `print_banner`.

### 📐 `modules/`

Contains reusable modern Fortran modules. Example:

```fortran
function model_function(x)
  y = x**2 + 1
```

---

## 🧪 Test Structure

`tests/test.f90` validates `model_function` with a simple case:

```fortran
x = 2.0d0
y = model_function(x)
if (abs(y - 5.0d0) < 1.0d-6) then
   print *, 'Test OK.'
```

---

## 🛠️ Customization

- Add new libraries to `libF77/` or `modules/` and include them in their respective `CMakeLists.txt`.
- Expand the main executable in `src/`.
- Create new tests in `tests/` and register them using `add_test(...)`.

---

## 📄 License

This project is free for academic and educational use.

---

## 👨‍🔬 Author

Rodrigo Nascimento  
Contact: _[physikices@proton.me]_  
Project: my_project
