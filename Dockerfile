FROM jetbrains/teamcity-agent:latest

MAINTAINER code-bross

ENV GRADLE_HOME=/usr/bin/gradle
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_NAME=bross

SHELL ["/bin/sh", "-c"]
SHELL ["/bin/sh", "-c", "apt-get update"]
SHELL ["/bin/sh", "-c", "apt-get install -y --force-yes expect git mc gradle unzip"]
SHELL ["/bin/sh", "-c", "wget curl libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 lib32ncurses5 lib32z1"]
SHELL ["/bin/sh", "-c", "apt-get clean"]
SHELL ["/bin/sh", "-c", "rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*"]

ENV PATH ${PATH}:/opt/tools

SHELL ["/bin/sh", "-c", "cd /opt"]
SHELL ["/bin/sh", "-c", "wget --output-document=android-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip android-tools.zip -d android-sdk-linux && chown -R root.root android-sdk-linux"]

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools


SHELL ["/bin/sh", "-c", "yes | sdkmanager --licenses"]
SHELL ["/bin/sh", "-c", "sdkmanager --update"]
SHELL ["/bin/sh", "-c", "yes | sdkmanager \"build-tools;29.0.3\" \"platforms;android-29\" \"ndk-bundle\" \"ndk;21.0.6113669\""]


