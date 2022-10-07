if [ "$#" = 0 ]; then
    set -- "base=val sub=item" "base=val sub=string"
fi

for base_sub in "$@"; do
    eval $base_sub
    eval `echo $base_sub | tr "[a-z]" "[A-Z]"`
    # echo $base $BASE $sub $SUB
    for from in prelude/*_$base"_"*.a68; do
        eval `echo "to=sub_$from" | sed "s/_$base""_/_$sub""_/g"`
        if [ "$from" -ot "$to" ]; then
            echo "$from older than $to - skipping build"
        else
            echo "$from newer than $to - building"
            WARNING="### WARNING: Built by $0 from $from ... DO NOT EDIT MANUALLY ###"
            ( echo $WARNING; sed "s/$BASE\b/$SUB/g; s/\b $base##/ $sub##/g" < "$from" ) > "$to"
        fi
    done
done
