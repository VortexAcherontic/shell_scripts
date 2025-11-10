#!/usr/bin/bash
###################################
# Put this file and empty.blend   #
# next to blender downloaded from #
# blender.org                     #
###################################
driver_version=$(nvidia-smi --query-gpu=driver_version | tail -n +2)
if [ $driver_version == "580.105.08"  ]; then
    echo $(nvidia-smi)
else
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    echo $SCRIPT_DIR
    $SCRIPT_DIR/blender -b $SCRIPT_DIR/empty.blend -f 20 -- --cycles-device CUDA --cycles-print-stats
fi;
# Workarounds: https://forums.developer.nvidia.com/t/unrelaibale-cuinit-with-sandboxes-and-containers-cuda-cuinit-unknown-error/333562/1
