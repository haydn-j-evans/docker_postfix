#!/usr/bin/env bash
set -e
cd integration-tests

run_test() {
    echo
    echo
    echo "☆☆☆☆☆☆☆☆☆☆ $1 ☆☆☆☆☆☆☆☆☆☆"
    echo
    (
        cd "$1"
        docker-compose up --build --abort-on-container-exit --exit-code-from tests
        docker-compose down
    )
}

if [[ $# -gt 0 ]]; then
    while [[ -n "$1" ]]; do
        run_test "$1"
        shift
    done
else
    for i in `find -maxdepth 1 -type d`; do
        i="$(basename "$i")"
        if [ "$i" == "tester" ] || [ "$i" == "." ] || [ "$i" == ".." ]; then
            continue
        fi
        run_test $i
    done
fi