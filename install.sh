wget https://ftp.gnu.org/gnu/gawk/gawk-4.1.4.tar.xz
tar xvf gawk-4.1.4.tar.xz 
cd gawk-4.1.4/ 
sh ./configure
sudo make
sudo make install
sudo make clean
/usr/local/bin/gawk -W version
