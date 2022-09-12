#!/bin/bash

re_ignore="Copyright ......... Marcel van der Veer <algol68g@xs4all.nl>.
*|This is free software covered by the GNU General Public License.
*|There is ABSOLUTELY NO WARRANTY for Algol 68 Genie;
*|not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*|See the GNU General Public License for more details.
*|Please report bugs to Marcel van der Veer <algol68g@xs4all.nl>."

m=30
esc=`echo | tr "\012" "\033"`
for color in black red green yellow blue magenta cyan white; do
    eval fg_$color="$esc[$m"m";"
    ((m=m+1))
done

pass(){
    echo $fg_green"PASS: $@$fg_white"
    pass_l="$pass_l$pass_sep$2"
    pass_sep=" "
}

fail(){
    echo $fg_red"FAIL: $@$fg_white"
    fail_l="$fail_l$fail_sep$2"
    fail_sep=" "
}

version(){
     "$1" --version | egrep -v "$ignore"
}

diff_opt="-D unit_test_result"
diff_opt=""

for prog in "$@"; do
    if [ ! -f "$prog" ]; then
        fail "MISSING" "$prog"
        continue
    fi
    basename_prog="$(basename "$prog")"
    dirname_prog="$(dirname "$prog")"
    mkdir -p "$dirname_prog/candidate"
    for compiler in "a68g --quiet"; do
        basename_compiler="$(basename $compiler)"
        benchmark="$dirname_prog/benchmark/$basename_prog.benchmark.lst"
        candidate="$dirname_prog/candidate/$basename_prog.$basename_compiler.candidate.lst"
        diff="$dirname_prog/candidate/$basename_prog.$basename_compiler.diff.lst"
        diff="$dirname_prog/candidate/$basename_prog.$basename_compiler.diff.lst"

        ( $compiler "$prog" 2>&1 ) > "$candidate"
        if [ ! -f "$benchmark" ]; then 
            fail "$compiler" "$prog$fg_white" 
            echo MISSING: try "$fg_yellow""cp" "$candidate" "$benchmark$fg_white"
        elif diff $opt_diff "$benchmark" "$candidate" > "$diff"; then
            pass "$compiler" "$prog" 
        else
            fail "$compiler" "$prog" 
            echo MISSING: try "$fg_yellow""vimdiff"  "$candidate" "$benchmark$fg_white"
            version $compiler
            # for file in "$prog" $diff; do
            for file in $diff; do
                echo "=== $file ==="
                cat "$file"
            done
        fi
    done
done
[ -z "$pass_l" ] && pass_l="None"
echo "$fg_green"PASSED:" $pass_l$fg_white"
[ -z "$fail_l" ] && fail_l="None"
echo "$fg_red"FAILED:" $fail_l$fg_white"
