# ls2_easybuild_toolchain

Please look at [ls2](https://github.com/FredHutch/ls2) for details on how to build these Dockerfiles and how to use them to deploy the same software to a local archive.

This container adds:

* An easybuild toolchain

## Building this container

Build this container with:

`docker build . --tag fredhutch/ls2_easybuild_toolchain:<name-ver> --build-arg TOOLCHAIN=<name-ver>`

Note that `TOOLCHAIN` has no default value and not setting it will cause the build to fail.

## Using this to deploy outside the container

If you want to use this container to deploy identically to a location outside the container, these are the steps:

1. Build the container normally
1. Run the container with the deploy script:
 * `docker run -ti --rm -v <outside_vol>:<outside_vol> --user root -e OUT_UID=${UID} -e OUT_GID=<GID> fredhutch/ls2_<repo_name>:<version> /bin/bash /ls2/deploy.sh`

## FAQ on the ls2 deploy step

*Do I need to do this step?*

No, once the initial container build is done, you have a container with the specified software pacakge(s) built and installed.

*Why a second deploy step?*

We use an NFS-mounted software volume to ensure our software is consistent across our HPC cluster and other Linux systems. This is the method we use to ensure the same software builds are present on our software volume and in ls2 containers.

*Why do the outside_vol and "inside" outside_vol have to match?*

Paths will be coded into the installed modulesfiles, so locations must be the same everywhere.

*What are OUT_UID and stuff?*

You will want the files written outside the container (in software volume) to be written by an owner and a group that make sense outside the container. Also, for collaboration (multiple builders if you choose), a common group is required. Note also that `OUT_PREFIX` and `<outside_vol>` must match

*What about multiple builders (building under user accounts)?*

You will want to have all builder accounts be members of the same group. That group should own your PREFIX (ex: /app) folder, and that folder should have the setgid bit set (ex: chmod g+s /app). 

*Ben, I work with you and just want to update this software package!*

Ok, to simple update the software version, run these commands:

1. `docker build . --tag fredhutch/ls2_toolchain:<eb_name> --build-arg TOOLCHIN=<eb_name>`
1. `docker push fredhutch/ls2_toolchain:<eb_name>`
1. `docker run -ti --rm -v /app:/app --user root -e OUT_UID=${UID} OUT_GID=158372 fredhutch/ls2_toolchain:<eb_name> /bin/bash /ls2/deploy.sh`

This runs the successfully built `ls2_toolchain` container with our /app mounted, and then installs the toolchain environment modules as the OUT_UID with group OUT_GID to preserve permissions in /app. It also configures and updates the system cache.
