rm -rf /dev/shem/*; echo 100 > /sys/devices/system/cpu/intel_pstate/min_perf_pct; sync; echo 1 > /proc/sys/vm/compact_memory; echo 3 > /proc/sys/vm/drop_caches
numactl --physcpubind=0-27 --membind=0 Release_OMP/ov_mlperf --scenario SingleStream --mode Accuracy --mlperf_conf_filename "mlperf.conf" --user_conf_filename "scripts/ssdmobilenet_user.conf" --data_path "/root/CK-TOOLS/dataset-coco-2017-val/" --dataset coco --model_path models/ssd-mobilenet/ssd-mobilenet_int8.xml --model_name ssd-mobilenet --nstreams 1 --nireq 1 --nthreads 28 --batch_size 1 --device cpu --nwarmup_iters 1000