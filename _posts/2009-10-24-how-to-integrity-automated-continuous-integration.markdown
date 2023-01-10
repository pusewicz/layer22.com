---
title: How To&colon; Integrity automated continuous integration server with Ruby Enterprise, Passenger and Nginx
date: 2009-01-10 18:00 +0100
tags: [ruby, integrity, passenger]
redirect_from: /post/221889559/how-to-integrity-automated-continuous-integration
---

[Integrity](http://integrityapp.com/) is a [Continuous Integration](http://en.wikipedia.org/wiki/Continuous_Integration) server solution which is very easy to set up, especially when you work with [Git](http://git-scm.com/) projects. In this short tutorial, I am going to show you hot to get up and running with Integrity in a couple of simple steps. We are going to build a box with [Ruby Enterprise](http://www.rubyenterpriseedition.com/), [Passenger](http://www.modrails.com/) and [Nginx](http://nginx.net/) as a web server.

General packages
----------------

First step is to get all the build essentials required to compile Ruby and Passenger.

    sudo apt-get install build-essential


Now let’s create a directory, where we can download software to:

    mkdir ~/src
    cd src


Ruby Enterprise Edition
-----------------------

Ruby Enterprise Edition requires OpenSSL, Readline, Zlib development libraries. We also want to install SQLite 3 development package, because Integrity currently only works with SQLite.

    sudo apt-get install libssl-dev libreadline-dev libz-dev libsqlite3-dev


Now, we have to download Ruby Enterprise edition and install it:

    wget http://rubyforge.org/frs/download.php/64475/ruby-enterprise-1.8.7-20090928.tar.gz
    tar -zxf ruby-enterprise-1.8.7-20090928.tar.gz
    cd ruby-enterprise-1.8.7-20090928/
    sudo ./installer


Let’s symlink the executables to some standard path:

    cd /opt/ruby-enterprise-1.8.7-20090928/bin/
    for i in *; do sudo ln -s /opt/ruby-enterprise-1.8.7-20090928/bin/$i /usr/local/bin/$i; done


Nginx
-----

Ruby Enterprise automatically installs Passenger gem. Let’s use it to install Nginx:

    sudo passenger-install-nginx-module --auto --auto-download


Installer will ask you to choose installatio directory. Just confirm the default.

Integrity
---------

Integrity come as a gem. We will also add the IRC notification mechanism. Here I’m using [Gemcutter](http://gemcutter.org/) as a repository of choice.

    sudo gem install gemcutter
    gem tumble
    sudo gem install integrity integrity-irc shout-bot
    sudo gem install do_sqlite3 -v0.9.11


Make sure that `data_objects`, `data_mapper` and `do_sqlite3` are the same and only version in Rubygems. Otherwise we can have problems where wrong versions are being loaded.

Now, let’s create a place where we want to install our own instance of Integrity:

    sudo mkdir /apps
    sudo /opt/ruby-enterprise-1.8.7-20090928/bin/integrity install /apps/integrity --passenger


Notice the `--passenger` option. It tells the installer to create Passenger friendly directory layout.

Last things to do is actual configuration. We have to tell Nginx and Passenger that we want to run our new app:

    sudo vim /opt/nginx/conf/nginx.conf


Modify the `server` section to look similar to this:

    server {
        listen       80;
        server_name  localhost;
        root   /apps/integrity/public;
        passenger_enabled on;
    }


Integrity comes with two configuration files. Let’s tell the app what domain it’s going to use editing this file:

    sudo vim /apps/integrity/config.yml


Also, we want to add the IRC notifier:

    sudo vim /apps/integrity/config.ru


Add this after current require lines:

    require "integrity/notifier/irc"


Next, we have to migrate the SQLite database like so:

    sudo /opt/ruby-enterprise-1.8.7-20090928/bin/integrity migrate_db /apps/integrity/config.yml


Fix the permissions

    sudo chown -R `whoami`:nogroup /apps
    sudo chmod -R g+w /apps


Start Nginx server

    sudo /opt/nginx/sbin/nginx


Voila! We have our Integrity server up and running! Go launch the browser and go to the domain you have chosen before. You are probably going to work with Git. Make sure you have `git-core` package installed.
