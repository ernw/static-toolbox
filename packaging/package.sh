#!/bin/bash
if [ $# -lt 2 ];then
    echo "Usage: ${0} <commit> <version?" >&2
    echo "Example: ${0} b5bd185 7.70SVN" >&2
    exit 2
fi

commit=$1
version=$2
architectures=(aarch64 armhf x86 x86_64)
tmp_dir=$(mktemp -dt packaging.XXXXXX)
trap exit_script EXIT TERM

exit_script(){
    rm -rf "$tmp_dir"
}

echo "tmp_dir: ${tmp_dir}"

for arch in "${architectures[@]}";do
    arch_dir="${tmp_dir}/nmap-${version}-${commit}-${arch}-portable"
    mkdir -p "$arch_dir"
    find ../bin/linux/${arch}/ -name "*-${commit}" -exec cp {} "${arch_dir}" \;
    echo "version: ${version}"
    ls -la "$arch_dir"
    if [ -s "${arch_dir}/nmap-${version}-${commit}" ];then
        mv "${arch_dir}/nmap-${version}-${commit}" "${arch_dir}/nmap"
        mv "${arch_dir}/ncat-${version}-${commit}" "${arch_dir}/ncat"
        # Note: Nping version starts with "0.".
        mv "${arch_dir}/nping-0.${version}-${commit}" "${arch_dir}/nping"
    elif [ -s "${arch_dir}/nmap-${commit}" ];then
        mv "${arch_dir}/nmap-${commit}" "${arch_dir}/nmap"
        mv "${arch_dir}/ncat-${commit}" "${arch_dir}/ncat"
        mv "${arch_dir}/nping-${commit}" "${arch_dir}/nping"
    else
        echo "Nmap binaries for ${arch} not found!"
        read
        continue
    fi
    if [ -d "../data/nmap-data-${version}-${commit}" ];then
        cp -r "../data/nmap-data-${version}-${commit}" "${arch_dir}/data"
    elif [ -d "../data/nmap-data-0.${version}-${commit}" ];then
        cp -r "../data/nmap-data-0.${version}-${commit}" "${arch_dir}/data"
    else
        echo "Nmap data directory not found!"
        read
        continue
    fi
    cp run-nmap.sh "$arch_dir"
    tar czf "${tmp_dir}/nmap-${version}-${commit}-${arch}-portable.tar.gz" -C "$tmp_dir" "nmap-${version}-${commit}-${arch}-portable"
    cd "$tmp_dir"
    zip -r -q "${tmp_dir}/nmap-${version}-${commit}-${arch}-portable.zip" "nmap-${version}-${commit}-${arch}-portable"
    cd -
    rm -rf "$arch_dir"
done

echo "Finished packing. Got the following releases:"
ls -la "$tmp_dir"
echo "Ready to copy them. Press CTRL+C to arbort, RETURN to continue...."
read
cp "${tmp_dir}/"* ../packaged
