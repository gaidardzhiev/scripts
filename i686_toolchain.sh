#!/bin/sh
#the script builds a toolchain that specifically targets https://github.com/gaidardzhiev/x86_kernel

#set vars
export TARGET=i686-elf
export PREFIX=/opt/toyos_gcc_binutils
export PATH=$PATH:$PREFIX/bin
export GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
export JOBS='-j '$GETNUMCPUS''
export GCC=12.2.0
export BINUTILS=2.40
export DIR=/home/src/compilers/toyos_gcc_binutils

#create and go to work directory
mkdir -p $DIR
cd $DIR

#get archives
wget https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS.tar.gz
wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC/gcc-$GCC.tar.gz

#extract archives
tar xf binutils-$BINUTILS.tar.gz
tar xf gcc-$GCC.tar.gz

#build binutils
mkdir build_binutils
cd build_binutils
sed -i 's/fiwix*/toyos*/g' ../binutils-$BINUTILS/config.sub
sed -i 's/START OF targmatch.h/& \
  i[3-7]86-*-toyos*)\
    targ_defvec=bfd_elf32_i386_vec\
    targ_selvecs=\
    targ64_selvecs=bfd_elf64_x86_64_vec\
    ;;/g' ../binutils-$BINUTILS/bfd/config.bfd 
sed -i 's/case ${generic_target} in/& \
  i386-*-toyos*)			fmt=elf ;;/g' ../binutils-$BINUTILS/gas/configure.tgt
touch ../binutils-$BINUTILS/ld/emulparams/elf_i386_toyos.sh
cat > ../binutils-$BINUTILS/ld/emulparams/elf_i386_toyos.sh << EOF
source_sh ${srcdir}/emulparams/elf_i386.sh
TEXT_START_ADDR=0x08000000
EOF
touch ../binutils-$BINUTILS/ld/emulparams/elf_x86_64_toyos.sh
cat > ../binutils-$BINUTILS/ld/emulparams/elf_x86_64_toyos.sh << EOF
source_sh ${srcdir}/emulparams/elf_x86_64.sh
EOF
sed -i 's/ALL_EMULATION_SOURCES/& \
	eelf_i386_toyos.c/g' ../binutils-$BINUTILS/ld/Makefile.am
sed -i 's/ALL_64_EMULATION_SOURCES/& \
	eelf_x86_64_toyos.c/g' ../binutils-$BINUTILS/ld/Makefile.am

../binutils-$BINUTILS/configure --targer=$TARGET --prefix=$PREFIX
echo "MAKEINFO = :" >> Makefile
make $JOBS all
make install

#build gcc
mkdir ../build_gcc
cd ../build_gcc
../gcc-$GCC/configure \
	--target=$TARGET \
       	--prefix=$PREFIX  \
	--without-headers \
	--with-newlib \
	--with-gnu-as \
	--with-gnu-ld \
	--enable-languages='c' \
	--enable-frame-pointer=no
make $JOBS all-gcc
make install-gcc

#build libgcc.a
make $JOBS all-target-libgcc CFLAGS_FOR_TARGET="-g -02"
make install-target-libgcc
