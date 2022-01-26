FROM centos:7
ARG TARGETPLATFORM

# Install CVMFS RPM
RUN yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm && \
    yum install -y cvmfs strace openssh-client

RUN yum clean all

ENV MOUNT_REPOS="atlas.cern.ch,atlas-condb.cern.ch,atlas-nightlies.cern.ch,grid.cern.ch,sft.cern.ch,sft-nightlies.cern.ch,unpacked.cern.ch"
ENV SQUID_URI="DIRECT"
ENV QUOTA_LIMIT="6000"

ADD wait-only.sh /usr/local/sbin/wait-only.sh
ADD mount-and-wait.sh /usr/local/sbin/mount-and-wait.sh
ADD unmount-and-terminate.sh /usr/local/sbin/unmount-and-terminate.sh
ADD force_unmount.sh /usr/local/sbin/force_unmount.sh

CMD ["/usr/local/sbin/mount-and-wait.sh"]

