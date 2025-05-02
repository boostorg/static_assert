#!/bin/bash

# Copyright 2020 Rene Rivera, Sam Darwin
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.txt or copy at http://boost.org/LICENSE_1_0.txt)

set -e
set -x
export TRAVIS_BUILD_DIR=$(pwd)
export DRONE_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=$DRONE_BRANCH
export VCS_COMMIT_ID=$DRONE_COMMIT
export GIT_COMMIT=$DRONE_COMMIT
export REPO_NAME=$DRONE_REPO
export PATH=~/.local/bin:/usr/local/bin:$PATH

if [ "$DRONE_JOB_BUILDTYPE" == "boost" ]; then

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
cd ..
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule update --init tools/boostdep
cp -r $TRAVIS_BUILD_DIR/* libs/static_assert
python tools/boostdep/depinst/depinst.py static_assert
./bootstrap.sh
./b2 headers

echo '==================================> SCRIPT'

echo "using $TOOLSET : : $COMPILER ;" > ~/user-config.jam
./b2 -j 3 libs/static_assert/test toolset=$TOOLSET cxxstd=$CXXSTD

elif [ "$DRONE_JOB_BUILDTYPE" == "6e7f14933e-d40de7c77a" ]; then

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
cd ..
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule update --init tools/boostdep
cp -r $TRAVIS_BUILD_DIR/* libs/static_assert
python tools/boostdep/depinst/depinst.py static_assert
./bootstrap.sh
./b2 headers

echo '==================================> SCRIPT'

mkdir __build__ && cd __build__
cmake -DBOOST_ENABLE_CMAKE=1 -DBoost_VERBOSE=1 -DBOOST_INCLUDE_LIBRARIES=static_assert ..
ctest --output-on-failure -R boost_static_assert

elif [ "$DRONE_JOB_BUILDTYPE" == "fe011f0001-fda7c76df5" ]; then

echo '==================================> INSTALL'

ln -s $DRONE_BUILD_DIR ../static_assert;
BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
git clone -b $BOOST_BRANCH https://github.com/boostorg/config.git ../config

echo '==================================> SCRIPT'

cd test/cmake_subdir_test && mkdir __build__ && cd __build__
cmake ..
cmake --build .
cmake --build . --target check

elif [ "$DRONE_JOB_BUILDTYPE" == "6e7f14933e-120499f489" ]; then

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
cd ..
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule update --init tools/boostdep
cp -r $TRAVIS_BUILD_DIR/* libs/static_assert
python tools/boostdep/depinst/depinst.py static_assert
./bootstrap.sh
./b2 headers

echo '==================================> SCRIPT'

mkdir __build__ && cd __build__
cmake -DBOOST_ENABLE_CMAKE=1 -DBoost_VERBOSE=1 -DBOOST_INCLUDE_LIBRARIES="static_assert;config" -DCMAKE_INSTALL_PREFIX=~/.local ..
cmake --build . --target install
cd ../libs/static_assert/test/cmake_install_test && mkdir __build__ && cd __build__
cmake -DCMAKE_INSTALL_PREFIX=~/.local ..
cmake --build .
cmake --build . --target check

fi
