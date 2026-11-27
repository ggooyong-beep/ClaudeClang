#!/usr/bin/env bash
# @brief 커버리지 계측 빌드. 컨테이너(claudeclangbuild) 안에서 실행한다.
set -euo pipefail
cmake -G Ninja -S . -B build -DCMAKE_BUILD_TYPE=Debug -DCOVERAGE=ON
cmake --build build
