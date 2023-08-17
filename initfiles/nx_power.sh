#!/vendor/bin/sh
#
# Copyright (C) 2023 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

script=$0

model=$(getprop ro.hardware)        # Model
sku=$(getprop ro.boot.hardware.sku) # SKU
oc=$(getprop ro.boot.oc)            # Overclock
dvfsb=$(getprop ro.boot.dvfsb)      # T210B01 SLT DVFS
dvfsc=$(getprop ro.boot.dvfsc)      # T210B01 HIOPT DVFS
limit=$(getprop ro.boot.gpulim)     # T210B01 GPU limit

/vendor/bin/log -t "$script" -p i "**** GENERATING POWER RC FOR ARCH:" $model "SKU:" $sku "****"
/vendor/bin/log -t "$script" -p i "**** FEATURES: OC:" $oc "DVFSB:" $dvfsb "DVFSC:" $dvfsc "GPU LIMIT: " $limit "****"

outfile=/data/vendor/nvcpl/power.nx.rc
rm -f $outfile
touch $outfile

# Reset overclock back to 0
echo 0 > /sys/kernel/tegra_cpufreq/overclock

# Set default clocks (based on HOS T210 limits)
max_cpu="1785000 1785000 1428000"
max_gpu="921600 768000 460800"
min_gpu="0 0 0"

if [ "$sku" = "odin" ]; then
    # Set T210 CPU clocks
    if [ $oc = 1 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 1)"
        echo 1 > /sys/kernel/tegra_cpufreq/overclock
        max_cpu="1887000 1887000 1785000"
    elif [ $oc = 2 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 2)"
        echo 1 > /sys/kernel/tegra_cpufreq/overclock
        max_cpu="1989000 1989000 1785000"
    elif [ $oc = 3 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 3--UNSTABLE!)"
        echo 1 > /sys/kernel/tegra_cpufreq/overclock
        max_cpu="2091000 2091000 1785000"
    fi
    # WAR: Set min GPU clocks to avoid awful UI perf
    min_gpu="153600 153600 153600"
elif [ "$sku" = "vali" ]; then
    max_gpu="768000 768000 460800"

    # Limit Vali GPU with dvfsb and oc enabled to 844 MHz
    if [ $dvfsb = 1 ] && [ $oc -gt 0 ]; then
        echo 1 > /sys/kernel/tegra_cpufreq/overclock
        max_gpu="844000 844000 768000"
    fi

    # Set Vali CPU clocks (B01 without OC Tier 4)
    if [ $oc = 1 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 1, WITHIN SAFE LIMITS)"
        max_cpu="1963500 1963500 1785000"
    elif [ $oc = 2 ] && [ $dvfsb = 1 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 2)"
        echo 1 > /sys/kernel/tegra_cpufreq/overclock
        max_cpu="2091000 2091000 1785000"
    elif [ $oc = 3 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 3--UNSTABLE!)"
        echo 1 > /sys/kernel/tegra_cpufreq/overclock
        max_cpu="2295000 2295000 2091000"
    fi
elif [ "$sku" = "modin" ] || [ "$sku" = "frig" ]; then
    # Set T210B01 GPU clock limits based on flags
    if [ $oc -gt 1 ]; then
        if [ $dvfsb = 1 ] || [ $limit = 1 ]; then
            max_gpu="1075000 1075000 998400"
        elif [ $dvfsc = 1 ]; then
            max_gpu="1228800 1228800 998400"
        else
            max_gpu="1267200 1267200 998400"
        fi
    elif [ $oc -gt 0 ]; then
        max_gpu="998400 998400 921600"
    fi

    # Set T210B01 CPU clocks
    if [ $oc = 1 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 1, WITHIN SAFE LIMITS)"
        max_cpu="1963500 1963500 1785000"
    elif [ $oc = 2 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 2)"
        echo 1 > /sys/kernel/tegra_cpufreq/overclock
        max_cpu="2091000 2091000 1785000"
    elif [ $oc = 3 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 3--UNSTABLE!)"
        echo 1 > /sys/kernel/tegra_cpufreq/overclock
        max_cpu="2295000 2295000 2091000"
    elif [ $oc = 4 ] && [ $dvfsb = 1 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 4--UNSTABLE!)"
        echo 1 > /sys/kernel/tegra_cpufreq/overclock
        max_cpu="2397000 2397000 2091000"
    fi
fi

/vendor/bin/log -t "$script" -p i "RESULT: CPU:" $max_cpu "GPU:" $max_gpu

echo "# This file is auto-generated. Do not modify."                    >> $outfile
echo "# Key   Docked Perf   Docked Opt / Undocked Perf   Undocked Opt"  >> $outfile
echo "NV_DEFAULT_MODE 0"                                                >> $outfile
echo "panelresolution=-1X-1"                                            >> $outfile
echo "NV_MAX_FREQ $max_cpu"                                             >> $outfile
echo "NV_MIN_FREQ 0 0 0"                                                >> $outfile
echo "NV_MAX_GPU_FREQ $max_gpu"                                         >> $outfile
echo "NV_MIN_GPU_FREQ $min_gpu"                                         >> $outfile
echo "NV_APM_CPU_BOOST 5 5 0"                                           >> $outfile
echo "NV_APM_GPU_BOOST 5 5 0"                                           >> $outfile
echo "NV_APM_FRT_BOOST 5 5 0"                                           >> $outfile
echo "NV_APM_FRT_MIN 20 20 15"                                          >> $outfile
echo "NV_APM_LOADAPPFRT 0 0 0"                                          >> $outfile
