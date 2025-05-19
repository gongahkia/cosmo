all:config

config:
	sudo apt-get update
	sudo apt-get install -y luajit libluajit-5.1-dev
	sudo apt-get install -y git build-essential meson ninja-build libfreetype6-dev luajit
	git clone https://github.com/franko/graph-toolkit.git
	cd graph-toolkit
	meson setup -Dlua=luajit build
	meson compile -C build
	sudo mkdir -p /usr/local/lib/lua/5.1/
	sudo cp build/src/graph.so /usr/local/lib/lua/5.1/
	sudo mkdir -p /usr/local/share/lua/5.1/
	sudo cp src/graph.lua /usr/local/share/lua/5.1/