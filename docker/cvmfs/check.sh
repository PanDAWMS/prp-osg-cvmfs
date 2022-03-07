#!/bin/bash

#
# We use a separate bash script to get a clean exit signal (here, not in parent)
#

echo "$$" > /etc/mount-and-wait.pid

while :
do
  df_out=$(df)
	for mp in `echo ${MOUNT_REPOS} |tr , ' '` ; do
    echo "`date`: checking /cvmfs/${mp}" | tee -a /cvmfs/cvmfs-pod.log

     if [ `echo $df_out | grep ${mp} | wc -l` -eq 0 ]; then
       echo "`date`: /cvmfs/${mp} is DOWN" | tee -a /cvmfs/cvmfs-pod.log
       if [ ! -f /dev/shm/unmounting.lck ]; then
         umount -l /cvmfs/${mp}
         rmdir /cvmfs/${mp}
         echo `date && ls -lrt /cvmfs` | tee -a /cvmfs/cvmfs-pod.log

         mkdir -p /cvmfs/${mp}
         mount -t cvmfs ${mp} /cvmfs/${mp}
         rc=$?
         if [ ${rc} -eq 0 ] ; then
           echo "`date`: INFO: Mounted /cvmfs/${mp}" | tee -a /cvmfs/cvmfs-pod.log
         else
           echo "`date`: ERROR: Failed to mount $mp"  | tee -a /cvmfs/cvmfs-pod.log
           echo "`date`: INFO: Killing leftover processes"
           ps aux | grep cvmfs | grep ${mp} | awk '{print $2}' | xargs -l kill -9
           rc_kill=$?
           if [ ${rc_kill} -eq 0 ] ; then
               echo "`date`: INFO: Killed leftover processes for ${mp}" | tee -a /cvmfs/cvmfs-pod.log
           else
               echo "`date`: ERROR: Failed to kill leftover processes for ${mp}" | tee -a /cvmfs/cvmfs-pod.log
           fi
         fi
         sleep 5
       fi
    else
      echo "`date`: /cvmfs/${mp} is OK" | tee -a /cvmfs/cvmfs-pod.log
    fi
  done
	sleep 10
done

