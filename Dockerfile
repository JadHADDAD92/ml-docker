FROM nvidia/cuda:11.1.1-runtime-ubuntu20.04
# Configure Timezone so apt doesn't hang
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install convenience packages
RUN apt update --fix-missing && \
    apt install -y git tree python3-pip python3-pip libsndfile1 sox ffmpeg mediainfo

# Create symlinks
RUN ln -s /usr/bin/pip3 /usr/bin/pip && \
    ln -s /usr/bin/python3 /usr/bin/python

# Install pip packages
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Create the user
ARG USERNAME=mluser
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    # Add sudo support.
    apt-get update && \
    apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME

ENV SHELL /bin/bash

CMD tail -f /dev/null
