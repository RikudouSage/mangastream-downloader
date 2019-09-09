# MangaStream Downloader

This is a simple app written in Qt, it allows you to download manga from MangaStream.

Usage is pretty simple, just open the app, choose manga title and chapter and then press "Download".

After downloading the manga will be in new directory "manga" created in the app base directory. The app will also display the full path to the manga directory.

Download for [Windows](https://github.com/RikudouSage/mangastream-downloader/releases/download/v1.3.0/MangaStreamDownloader.exe) or [Ubuntu/Linux Mint](https://github.com/RikudouSage/mangastream-downloader/releases/latest)

---

### Compiling on Ubuntu/Debian/Mint

#### With system libraries

1) First install all dependencies:
    - `apt-get update`
    - `apt-get install git build-essential qtbase5-dev qtdeclarative5-dev qt5-default qttools5-dev-tools libssl-dev`
    - > You might need to prepend the commands with sudo if you're not logged in as root 
    - > If you are on Ubuntu 18.04, install libssl1.0-dev instead of libssl-dev
2) Clone project
    - git clone https://github.com/RikudouSage/mangastream-downloader
3) Get into the directory
    - cd mangastream-downloader
4) Compile it
    - qmake && make
5) Run it!
    -./mangastream-downloader

#### With docker

1. Configure for docker:
    - `./configure-docker`
2. Compile:
    - Systems with libssl 1.0:
        - `docker run --rm -it -v $(pwd):/app rikudousage/qt-static:5.9 -c "cd /app && qmake mangastream-downloader.pro && make"`
    - Systems with libssl 1.1:
        - `docker run --rm -it -v $(pwd):/app rikudousage/qt-static:5.13 -c "cd /app && qmake mangastream-downloader.pro && make"`
3. Run:
    - ./mangastream-downloader

### Warranty

This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
