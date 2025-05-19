.PHONY: all install clean

all: install

install:
	@echo "beginning installation"
	sudo apt-get update
	sudo apt-get install -y luajit libluajit-5.1-dev
	sudo apt-get install -y git build-essential meson ninja-build libfreetype6-dev
	sudo apt-get install -y love
	@echo "installation is complete"

clean:
	rm -rf graph-toolkit
	rm -f love-console