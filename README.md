# MangaStream Downloader

This is a simple app written in Qt, it allows you to download manga from MangaStream.

Usage is pretty simple, just open the app, choose manga title and chapter and then press "Download".

After downloading the manga will be in new directory "manga" created in the app base directory. The app will also display the full path to the manga directory.

Windows users can download compiled version [here](https://github.com/RikudouSage/mangastream-downloader/releases).

Ubuntu 17.04 (zesty) users can download compiled version [here](https://github.com/RikudouSage/mangastream-downloader/releases).

---

### Compiling on Ubuntu/Debian/Mint

1) First install all dependencies:

	apt-get update && apt-get install git build-essential qtbase5-dev qtdeclarative5-dev qt5-default qttools5-dev-tools

2) Clone project

	git clone https://github.com/RikudouSage/mangastream-downloader
   
3) Get into the directory

	cd mangastream-downloader
    
4) Compile it

	qmake && make
    
5) Run it!

	./mangastream-downloader
