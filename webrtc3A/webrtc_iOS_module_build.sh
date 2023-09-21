#!/usr/bin/env sh

is_debug=false
is_bitcode=false
is_copy_header=true
is_fat=true




options=${@:3}

while getopts ":dbhf" option ${options}; do
    case "$option" in
    d)
        is_debug=true
        ;;
    b)
        is_bitcode=true
        ;;
    h)
        is_copy_header=true
        ;;
    f)
        is_fat=true
        ;;
    ?)
        echo "Usage:[-d isDebug] [-b enableBitcode] [-h copyHeaders] [-f buildFat]"
        exit -1
        ;;
    esac
done

# 检查输入的模块路径
if [ ! -n ${1} ]; then
    echo "unknown lib path"
    exit 1
fi

# 检查输入的输出路径
if [ ! -n ${2} ]; then
    echo "unknown output path"
    exit 1
# 不允许输出在源码内
elif [[ ${2} == ./* ]]; then
    echo "can't use current path"
    exit 1
fi

lib_path=${1}
output_root_path=${2}

# 获取模块名字，为路径最后一部分
lib_name=$(echo "$lib_path" | awk -F "/" '{print $(NF)}')


arm64_build_path="./out/iOS_arm64"
simulator_arm64_build_path="./out/iOS_simulator_arm64"
simulator_x64_build_path="./out/iOS_simulator_x64"

mkdir -p ${arm64_build_path}
mkdir -p ${simulator_x64_build_path}
mkdir -p ${simulator_arm64_build_path}

# 分别编译模拟器和真机模块

gn gen "$arm64_build_path" --args="target_os=\"ios\" target_cpu=\"arm64\" ios_deployment_target=\"11.0\" enable_ios_bitcode=${is_bitcode} is_debug=${is_debug} is_clang=true use_custom_libcxx=false rtc_include_tests=false rtc_enable_protobuf=false"
gn gen "$simulator_x64_build_path" --args="target_os=\"ios\" target_cpu=\"x64\" target_environment = \"simulator\" ios_deployment_target=\"11.0\" enable_ios_bitcode=${is_bitcode} is_debug=${is_debug} is_clang=true use_custom_libcxx=false rtc_include_tests=false rtc_enable_protobuf=false"
gn gen "$simulator_arm64_build_path" --args="target_os=\"ios\" target_cpu=\"arm64\" target_environment = \"simulator\" ios_deployment_target=\"11.0\" enable_ios_bitcode=${is_bitcode} is_debug=${is_debug} is_clang=true use_custom_libcxx=false rtc_include_tests=false rtc_enable_protobuf=false"

ninja -C ${arm64_build_path} ${lib_name}
ninja -C ${simulator_x64_build_path} ${lib_name}
ninja -C ${simulator_arm64_build_path} ${lib_name}

output_lib_path="${output_root_path}/lib"

mkdir -p ${output_lib_path}

output_lib_arm64_path="${output_root_path}/lib/${lib_name}-arm64.a"
output_lib_simulator_x64_path="${output_root_path}/lib/${lib_name}-simulator-x64.a"
output_lib_simulator_arm64_path="${output_root_path}/lib/${lib_name}-simulator-arm64.a"

# 拷贝编译产物
lib_arm64_path="${arm64_build_path}/obj/${lib_path:1}/lib${lib_name}.a"
lib_simulator_x64_path="${simulator_x64_build_path}/obj/${lib_path:1}/lib${lib_name}.a"
lib_simulator_arm64_path="${simulator_arm64_build_path}/obj/${lib_path:1}/lib${lib_name}.a"


cp "${arm64_build_path}/obj/${lib_path:1}/lib${lib_name}.a" ${output_lib_arm64_path}
cp "${simulator_x64_build_path}/obj/${lib_path:1}/lib${lib_name}.a" ${output_lib_simulator_x64_path}
cp "${simulator_arm64_build_path}/obj/${lib_path:1}/lib${lib_name}.a" ${output_lib_simulator_arm64_path}


# 抽取头文件
if [[ ${is_copy_header} == true ]]; then
	echo "copy webrtc headers"
	output_header_path="${output_root_path}/include"
	mkdir -p ${output_header_path}
	headers=`find . -name '*.h'`
	for header in $headers
	do
		echo "copy header path: ${header}"
		ditto ${header} "${output_header_path}/${header:1}"
	done
fi

if [[ ${is_fat} == true ]]; then
    # 合并架构
    echo "create simulator fat lib"
    fat_simulator_lib_path="${output_root_path}/lib/lib${lib_name}.a"
    lipo -create  ${lib_simulator_x64_path} ${lib_simulator_arm64_path} -output ${fat_simulator_lib_path}
    
    # 生成 xcframework
    xcodebuild -create-xcframework \
    -library ${fat_simulator_lib_path} -headers ${output_root_path}/include \
    -library $lib_arm64_path -headers ${output_root_path}/include \
    -output ${output_root_path}/${lib_name}.xcframework
fi

open ${output_root_path}


