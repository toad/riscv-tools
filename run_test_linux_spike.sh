#!/bin/bash
TEST=$1
TESTNAME=$(basename "$TEST")
rm -Rf mnt-tmp
mkdir mnt-tmp
mkdir mnt-tmp/bin
if ! test -z "$2"
then
        if ! test -d "$2"; then echo Second argument must be a directory to merge into the root image; exit 2; fi
        cp -a "$2"/* mnt-tmp/
fi
BLOCKS=${3:-65536}
INODES=${4:-1024}
rm -f run-test.sh
echo "#!/bin/ash" > run-test.sh
echo "if $TESTNAME; then echo \"COMPLETED SPIKE LINUX TEST\"; else echo \"FAILED SPIKE LINUX TEST\"; fi" >> run-test.sh
chmod +x run-test.sh
cp $TEST mnt-tmp/bin/$TESTNAME
./make_root.sh run-test.sh mnt-tmp/ $BLOCKS $INODES
set -m
LOG=log.test
echo | spike +disk=root.bin linux-3.14.13/vmlinux > $LOG 2>&1 &
JOBPID=$(jobs -l | grep spike | tr --squeeze " " | cut -d " " -f 2)
echo Job pid is $JOBPID
tail -n +0 --follow=name $LOG 2>/dev/null | while read x; do x=$(echo "$x" | tr -d "\r\n"); if test "$x" == "COMPLETED SPIKE LINUX TEST"; then echo Successful completion; kill $JOBPID; rm $LOG; exit 0; fi; if test "$x" == "FAILED SPIKE LINUX TEST"; then echo Failed; cat $LOG; kill $JOBPID; exit 1; fi; echo "$x"; done
rm -Rf mnt-tmp run-test.sh root.bin
