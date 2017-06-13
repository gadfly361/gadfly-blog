{:title "From a Clean Install of Ubuntu to Re-natal"
 :layout :post
 :tags  ["clojurescript" "reagent" "react-native"]
 :toc true
 :issue-id "2"}


Updated: *November 14, 2016*

**Goal**: Share how to set up [re-natal](https://github.com/drapanjanas/re-natal) v0.3.x (i.e., cljs + reagent +
re-frame + figwheel + react-native) on Ubuntu 16.04 LTS for android
application development.

Requirements:

-   Clean install of Ubuntu 16.04 (**not** in a VM)
-   25 GB of disk space (with everything installed, I used 21.8 GB of disk space)
-   16 GB of RAM (with everything running, I used 8.4 GB of RAM)

## **Step 1** Install Chrome

Get the debian package.

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

And install it.

    sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
    sudo apt-get install -f -y
    rm google-chrome-stable_current_amd64.deb

To verify that you have chrome installed.

    google-chrome --version

Should produce something like: `Google Chrome 53.0.2785.116`. To see
chrome in your launcher, you may have to log out and log back in
again.

## **Step 2** Install Java

    sudo apt-get install -y openjdk-8-jdk

To verify that you have java installed.

    java -version

## **Step 3** Install Leiningen

    wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
    chmod a+x lein
    sudo mv lein /usr/local/bin/
    lein

To verify that you have lein installed.

    lein -v

## **Step 4** Install Git

    sudo apt-get install -y git

To verify that you have git installed.

    git --version

## **Step 5** Install Node

    curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
    sudo apt-get install -y nodejs

To verify that you have node installed.

    node -v

## **Step 6** Install React Native

    sudo npm install -g react-native-cli

## **Step 7** Install Re-natal

    sudo npm install -g re-natal

## **Step 8** Install Watchman

Prerequisites.

    sudo apt-get install -y automake
    sudo apt-get install -y python-dev

Install watchman.

    git clone https://github.com/facebook/watchman.git
    cd watchman
    git checkout v4.1.0  # the latest stable release
    ./autogen.sh
    ./configure
    make
    sudo make install

Post install.

    echo 256 | sudo tee -a /proc/sys/fs/inotify/max_user_instances
    echo 32768 | sudo tee -a /proc/sys/fs/inotify/max_queued_events
    echo 65536 | sudo tee -a /proc/sys/fs/inotify/max_user_watches
    watchman shutdown-server

To verify that you have watchman installed.

    watchman -v

## **Step 9** Download android studio

Download some 32 bit stuff.

    sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1

Download android studio [here](https://developer.android.com/studio/index.html), and unzip it. Note, your version may vary.

    unzip android-studio-ide-145.3360264-linux.zip

Run android studio:

    cd android-studio/bin/ && ./studio.sh

Select `I do not have a previous version of Studio or I do not want to
import my settings.` and then click `Ok`.

A welcome page will appear, click `Next`.

For install type, choose `Standard`, then click `Next` until you get
to `Finish` and click that. A bunch of things will get installed, then
click `Finish` again.

---

At this point, you should see the standard welcome screen when you
launch Android Studio. At the bottom, click `configure`, then click `SDK Manager`. It should
open with `Andorid SDK` highlighted in the left bar. In the bottom
right, select `Show Package Details`. Select the following additional
options under **Android 6.0 (Marshmallow)**:

-   Google APIs
-   Android SDK Platform 23
-   Sources for Android 23
-   Intel x86 Atom System Image
-   Intel x86 Atom<sub>64</sub> System Image
-   Google APIs Intel x86 Atom System Image
-   Google APIs Intel x86 Atom<sub>64</sub> System Image

Go to SDK Tools tab and select `Show Package Details`.  Under `Android
SDK Build-Tools`, select version 23.01.

Click `Apply`, confirm the change to install, accept the license
agreements, then click `Finish`. You can now close android studio.

Add the following lines to `~/.bashrc`.

    export ANDROID_HOME=~/Android/Sdk
    export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

Source your .bashrc file.

    source ~/.bashrc

## **Step 10** Install Virtualbox

    sudo apt-get install -y virtualbox

## **Step 11** Install Genymotion

Go [here](https://www.genymotion.com/) and create a Genymotion account. Sign in, click the `Download`
link in the top banner, and then click the `Download for Ubuntu
(64bit) button`.

Make the file executable. Note, your version may vary.

    chmod +x genymotion-2.8.0-linux_x64.bin

Run the file.

    ./genymotion-2.8.0-linux_x64.bin

When prompted, type `y` to install to the current directory or `n` to
install somewhere else.

cd into the genymotion directory that was created, and start up
genymotion.

    cd genymotion
    ./genymotion

You will be prompted to create your first virtual device, click `yes`.
Next, click the `Sign In` link at the bottom right.

After signing in, select `Samsung Galaxy S6 - 6.0.0 - API 23 -
1440x2560` and create the virtual device. Click `Finish`.

You should return to a list of your devices.

Go to `Settings`, click on the `ADB` tab. Select 'Use custom Android SDK tools' and enter the path of your Android SDK, which should be something like `/home/<username>/Android/Sdk`.


## **Step 12** Create and run your first app

### Create an app from the re-natal template.

    re-natal init FutureApp
    cd future-app

### Start Genymotion (if it isn't already running)

    ./genymotion

### Start a simulated android device

In Genymotion, select the device you made earlier and hit `Start`.

### Prepare the app

In another terminal:

    re-natal use-android-device genymotion
    re-natal use-figwheel

### Start figwheel

    lein figwheel android

### Start react-native

In another terminal:

    react-native start

### Run the app

In yet another terminal:

    react-native run-android

### Verify the figwheel REPL is connected to the simulated app

In the figwheel REPL type:

    (js/alert "Hello, world!")

You should see an alert pop-up in the simulated app.

### Verify that you can debug remotely in a browser

In the simulated app, press `Ctrl + M`. Select `enable debug
remotely`, which should take you to `localhost:8081/debugger-ui`. Once
there press `Ctrl + Shift + J`, this should open the developer's
console.  In the figwheel REPL, type:

    (js/console.log "Hello, console!")

You should see the message printed to the developer's console.

## Thanks for Reading

If you have any questions, I can be reached in the #reagent channel of
the [clojurians](http://clojurians.net/) slack group.

Cheers, gadfly361
