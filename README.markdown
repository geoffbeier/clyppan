# About

Clyppan is a Free and Open Source clipboard history application for Mac OS X that's always at your fingertips.

![screenshot!](http://github.com/omh/clyppan/raw/d570ee86c47e675ad8734b6f86e806e4af47d75d/Clyppan-screenshot.png)

# Installation

## Requirements

To build Clyppan you need Xcode 3.1 and Leopard 10.5.6.


## Building

Create a new directory and clone Clyppan and the Collections repository:

    mkdir clyppan-git
    cd clyppan-git
    git clone git://github.com/omh/clyppan.git
    git clone git://github.com/omh/collections.git

After cloning you should have a directory structure like this:

    clyppan-git
      |-- clyppan
      |-- collections

Open Interface Builder, go to Preferences -> Plug-ins, click the + button, browse to `clyppan-git/clyppan/Frameworks/` and add the `ShortcutRecorder.ibplugin`.

To build open clyppan-git/clyppan/Clyppan.xcodeproj in Xcode and hit the build button.


# License

All code, except where otherwise noted, is licensed under the New BSD license. 

    Copyright (c) 2009, Ole Morten Halvorsen
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without modification, 
    are permitted provided that the following conditions are met:
    
    - Redistributions of source code must retain the above copyright notice, this list 
      of conditions and the following disclaimer.
    - Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials 
      provided with the distribution.
    - Neither the name of Clyppan nor the names of its contributors may be used to endorse or 
      promote products derived from this software without specific prior written permission.
    
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
    OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
    THE POSSIBILITY OF SUCH DAMAGE.