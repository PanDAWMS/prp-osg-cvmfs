#!/bin/bash

echo `ls -lrt /cvmfs`

if [ "x${SQUID_URI}" == "x" ]; then
  echo "Missing SQUID_URI" 1>&2
  exit 1
fi
echo "CVMFS_HTTP_PROXY=\"${SQUID_URI}\"" >/etc/cvmfs/default.local


if [ "x${QUOTA_LIMIT}" != "x" ]; then
  echo "CVMFS_QUOTA_LIMIT=${QUOTA_LIMIT}" >> /etc/cvmfs/default.local
fi


if [ "x${MOUNT_REPOS}" == "x" ]; then
  echo "Missing MOUNT_REPOS" 1>&2
  exit 1
fi

# do not die on signal, try to cleanup as fast as you can
trap "/usr/local/sbin/force_unmount.sh" SIGTERM SIGINT

mps=""
for mp in `echo ${MOUNT_REPOS} |tr , ' '` ; do 
 echo "Processing /cvmfs/${mp}"

 #if [ -d /cvmfs/${mp} ]; then
   # force clean if already there
 #  echo "WARNING: Found /cvmfs/${mp}. Unmounting." | tee -a /cvmfs/cvmfs-pod.log
 #  umount -l /cvmfs/${mp}
 #  rmdir /cvmfs/${mp}
 #else
 #  echo "DID NOT SEE DIRECTORY /cvmfs/${mp}"
 #fi

 # There are situations where the above -d check does not see the directory. Force cleanup before trying to mount
 umount -l /cvmfs/${mp}
 rmdir /cvmfs/${mp}
 echo `ls -lrt /cvmfs`

 mkdir -p /cvmfs/${mp}
 mount -t cvmfs ${mp} /cvmfs/${mp}
 rc=$?
 if [ ${rc} -eq 0 ] ; then
   echo "INFO: Mounted /cvmfs/${mp}" | tee -a /cvmfs/cvmfs-pod.log
   mps="$mp $mps" #save them in reverse order
 else
   echo "ERROR: Failed to mount $mp"  | tee -a /cvmfs/cvmfs-pod.log

   # cleanup
   for mp1 in $mps; do
     umount /cvmfs/${mp1}
   done
   echo "Leaving"
   exit 2
 fi

  echo "Finished /cvmfs/${mp}"
done

echo "$mps" > /etc/mount-and-wait.mps

echo "INFO: CVMFS mountpoints started: $mps"  | tee -a /cvmfs/cvmfs-pod.log
/usr/local/sbin/wait-only.sh
echo "INFO: Terminating"   | tee -a /cvmfs/cvmfs-pod.log

# cleanup

# first try the proper way
for mp1 in $mps; do
   if [ -d /cvmfs/${mp1} ]; then
     umount /cvmfs/${mp1}
     rc=$?
     if [ $rc -ne 0 ]; then
       echo "WARNING: Failed unmounting ${mp1}"  | tee -a /cvmfs/cvmfs-pod.log
     else
       rmdir /cvmfs/${mp1}
       echo "INFO: Unmounted ${mp1}"  | tee -a /cvmfs/cvmfs-pod.log
     fi
   fi
done

# now do a pass with the most fail-safe option possible
for mp1 in $mps; do
  echo "INFO: Attempting lazy umount of ${mp1}"  | tee -a /cvmfs/cvmfs-pod.log
  umount -l /cvmfs/${mp1}
  if [ $? -eq 0 ]; then 
   echo "INFO: Lazy unmounted ${mp1}"  | tee -a /cvmfs/cvmfs-pod.log
  fi
done

# wait a tiny bit to make sure everything is cleaned up properly
sleep 2

echo "INFO: Bye"  | tee -a /cvmfs/cvmfs-pod.log

