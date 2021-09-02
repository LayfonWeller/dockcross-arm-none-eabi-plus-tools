# Introduction
Docker container that includes GCC-ARM-NONE-EABI and some tools


# Requirements
A locally downloaded copy of cppcheck-2.4.tar.bz2, gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2 and JLink_Linux_V700_x86_64.deb

# To use
Copy devcontainer.json to a working vscode project (follow instruction on how to settup)

And start a local copy of `JLink Remote Server` (on the host)
In the containter call jlink with `-IP ${DOCER_HOST_IP}`
And Jlink Gdb server with `-select ip=${DOCER_HOST_IP}`

You can get the DOCER_HOST_IP by running `getent hosts host.docker.internal | awk '{ print $1 }'` in the container
