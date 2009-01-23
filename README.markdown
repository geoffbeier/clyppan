ABOUT
-----

Clyppan is a Free and Open Source clipboard history application for Mac OS X that's always at your fingertips.



INSTALLATION
------------

Requirements
============

To build Clyppan you need Xcode 3.1 and Leopard 10.5.6.


Building
========

Create a new directory and clone Clyppan and the Collections repository:

    mkdir clyppan-git
    cd clyppan-git
    git clone git://github.com/omh/clyppan.git
    git clone git://github.com/omh/collections.git

After cloning you should have a directory structure like this:

    clyppan-git
      |-- clyppan
      |-- collections

To build open clyppan-git/clyppan/Clyppan.xcodeproj in Xcode and hit the build button.