sudo apt install meson libwebkit2gtk-4.0-dev libgranite-dev git

git clone -b beta https://github.com/charchatzo/hartes

cd hartes

meson build

cd build

ninja

sudo ninja install
