  
FROM jetbrains/teamcity-agent:2019.2.1

MAINTAINER rkd2468

ENV VERSION_TOOLS "7583922"

ENV ANDROID_SDK_ROOT "/sdk"
# Keep alias for compatibility
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV PATH "$PATH:${ANDROID_SDK_ROOT}/tools"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update \
 && apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-11-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      locales \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN rm -rf /opt/java/openjdk
RUN mv /usr/lib/jvm/java-11-openjdk-amd64 /opt/java/openjdk

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /tools.zip \
 && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
 && unzip /tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
 && rm -v /tools.zip

RUN mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/tools


RUN rm -rf $ANDROID_SDK_ROOT/licenses/* 

RUN mkdir -p $ANDROID_SDK_ROOT/licenses/ \
 && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-sdk-license \
 && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license \
 && yes | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses >/dev/null

ADD packages.txt /sdk
RUN mkdir -p /root/.android \
 && touch /root/.android/repositories.cfg \
 && ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt \
 && ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} ${PACKAGES}
 
 
 
#------------------------------------------------------
# --- Android NDK


# download
RUN mkdir /opt/android-ndk-tmp
RUN cd /opt/android-ndk-tmp && curl -s https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip > /opt/android-ndk-tmp/ndk.zip
# uncompress
RUN cd /opt/android-ndk-tmp && chmod a+x /opt/android-ndk-tmp/ndk.zip
RUN unzip /opt/android-ndk-tmp/ndk.zip -d /opt/android-ndk-tmp/ndk
# move to it's final location
RUN cd /opt/android-ndk-tmp && mv /opt/android-ndk-tmp/ndk /opt/android-ndk
# remove temp dir
RUN rm -rf /opt/android-ndk-tmp
# add to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}
