FROM docker-registry.domain.department/rdbo/common/jdk11-devel:latest

#get Command line tools only from https://developer.android.com/studio/index.html#command-tools
ARG CMD_LINE_V=commandlinetools-linux-192.168.1.2_latest.zip \
    SDK_URL=https://dl.google.com/android/repository/commandlinetools-linux-192.168.1.2_latest.zip \
    #TOOLS VERSIONS
    BUILD_TOOLS_V=30.0.3 \
    PLATFORMS_ANDROID_V=31

ENV ANDROID_SDK_ROOT="/tmp/android_home/" \
    #optional
    ANDROID_PREFS_ROOT="/tmp/android_home/"

WORKDIR /tmp

USER root

# create folders, download, unpack and delete zip
# sdkamanager must be in subdir latest

RUN mkdir -p "$ANDROID_SDK_ROOT"/cmdline-tools/latest \
    && cd "$ANDROID_SDK_ROOT"/cmdline-tools/ \
    && curl -o cmdtool.zip $SDK_URL \
    && unzip cmdtool.zip \
    && mv "$ANDROID_SDK_ROOT"/cmdline-tools/cmdline-tools/* "$ANDROID_SDK_ROOT"/cmdline-tools/latest \
    && rm cmdtool.zip \
    && rm -r cmdline-tools \
    && cd "$ANDROID_SDK_ROOT"/cmdline-tools/latest/bin \
    && ./sdkmanager --update \
# HERE WE INSTALL TOOLS AND CONFIRM LICENSES
    && echo y | ./sdkmanager --install "platforms;android-$PLATFORMS_ANDROID_V" "build-tools;$BUILD_TOOLS_V" \
# define the user who will actually run the container this solves permissions problem
    && ./sdkmanager --list_installed \
    && useradd --uid 1001 jenkins-agent
