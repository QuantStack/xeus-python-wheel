#!/bin/bash

set -e -x

# Compile wheels
for PYBIN in /opt/python/cp3*/bin; do
    if [ "${PYBIN}" != "/opt/python/cp34-cp34m/bin" ]; then
        "${PYBIN}/pip" install -r /io/dev-requirements.txt
        "${PYBIN}/pip" wheel /io/ -w /io/wheelhouse/
        # "${PYBIN}/pip" wheel /io/ --verbose -w /io/wheelhouse/
    fi
done

# Install packages and test
for PYBIN in /opt/python/cp3*/bin; do
    export LD_LIBRARY_PATH_BU=$LD_LIBRARY_PATH
    export PATH_BU=$PATH
    export PATH=${PYBIN}:$PATH
    if [ "${PYBIN}" == "/opt/python/cp34-cp34m/bin" ]; then
        continue
    elif [ "${PYBIN}" == "/opt/python/cp35-cp35m/bin" ]; then
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/_internal/cpython-3.5.9/lib
    elif [ "${PYBIN}" == "/opt/python/cp36-cp36m/bin" ]; then
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/_internal/cpython-3.6.10/lib
    elif [ "${PYBIN}" == "/opt/python/cp37-cp37m/bin" ]; then
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/_internal/cpython-3.7.6/lib
    else
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/_internal/cpython-3.8.1/lib
    fi
    "${PYBIN}/pip" install xeus-python --no-index -f /io/wheelhouse
    (cd /io/test; "${PYBIN}/pytest" . -v)
    export PATH=$PATH_BU
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH_BU
done

