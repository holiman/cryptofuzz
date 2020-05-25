#!/bin/bash

# Move this file one level up in the hierarchy

BASE=/home/martin/workspace

export CC=clang
export CXX=clang++
export CFLAGS="-fsanitize=address,fuzzer-no-link -O2 -g "
export CXXFLAGS="-fsanitize=address,fuzzer-no-link -D_GLIBCXX_DEBUG -O2 -g "

 #git clone https://github.com/guidovranken/cryptofuzz.git
 cd $BASE/cryptofuzz/
 git checkout BLS12-381
 python gen_repository.py
 cd $BASE


echo ""
echo "Building Chia/bls-signatures"
echo ""

#git clone --recursive --depth 1 https://github.com/Chia-Network/bls-signatures.git
 # NOTE: make the 'q' variable src/publickey.hpp public instead of private
cd $BASE/bls-signatures/
#rm -rf build && mkdir build/
cd build/
#cmake ..
#make clean
#make -j$(nproc)
export CHIA_BLS_LIBBLS_A_PATH=$(realpath libbls.a)
export CHIA_BLS_INCLUDE_PATH=$(realpath ../src/)
export CHIA_BLS_RELIC_INCLUDE_PATH_1=$(realpath contrib/relic/include/)
export CHIA_BLS_RELIC_INCLUDE_PATH_2=$(realpath ../contrib/relic/include/)
cd $BASE


echo ""
echo "Building herumi/mcl"
echo ""

#git clone --depth 1 https://github.com/herumi/mcl.git
cd $BASE/mcl/
#rm -rf build && mkdir build/
cd build/
#cmake ..
#make -j$(nproc)
export MCL_LIBMCL_A_PATH=$(realpath lib/libmcl.a)
export MCL_INCLUDE_PATH=$(realpath ../include/)
cd $BASE

echo "Building chia module"
echo ""

cd $BASE/cryptofuzz/modules/chia_bls
make

echo "Building mcl module"
echo ""

cd $BASE/cryptofuzz/modules/mcl
make

echo "Building golang module"
echo ""

cd $BASE/cryptofuzz/modules/golang
make clean && make

cd $BASE/cryptofuzz/

export LIBFUZZER_LINK="-fsanitize=address,fuzzer"
export CXXFLAGS="$CXXFLAGS -DCRYPTOFUZZ_CHIA_BLS -DCRYPTOFUZZ_MCL -DCRYPTOFUZZ_NO_OPENSSL -DCRYPTOFUZZ_GOLANG "

echo "Building cryptofuzz"
echo ""

make clean && python gen_repository.py

make
