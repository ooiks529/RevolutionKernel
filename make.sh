# Make mrproper
echo "Cleaning Source"
echo "Building Config"

make clean mrproper -j64

# Set config

make latona_galaxysl_defconfig -j64

# Make modules

rm *.log

echo "Compiling Modules"

make -j64 modules > ../compile-module.log 2>&1

echo "Copy modules"

find -name '*.ko' -exec cp -av {} ../tools/out/system/lib/modules/ \;

echo "Building zImage" 

make clean

make -j64 zImage > ../compile-zImage.log 2>&1

echo "Repacking the Kernel now"

cd ..

rm *.zip

echo "Packing Kernel"

rm tools/unpack/zImage
cp latona/arch/arm/boot/zImage tools/unpack/zImage

cd tools
rm out/boot.img

tools/mkbootimg --kernel unpack/zImage --ramdisk unpack/boot.img-ramdisk.gz -o out/boot.img --base 10000000

cd out

cd system/lib/modules

echo "Strip modules for size"

for m in $(find . | grep .ko | grep './')
do
        echo $m

/home/ooi/android/ics/system/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-strip --strip-unneeded $m
done

cd ../../../

rm *.zip

zip -r BETA_KERNEL#$vrsn.zip META-INF system boot.img

cp BETA_KERNEL#$vrsn.zip ../../BETA_KERNEL#$vrsn.zip

echo "Done"

