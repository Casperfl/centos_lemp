# Quick LEMP Installation

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://choosealicense.com/licenses/mit/)
[![version](https://img.shields.io/badge/version-1.0-blue)](https://img.shields.io/badge/version-1.0-blue)


> Quick Installation LEMP on VBox or server using CentOS 7

## Description
This is a quick LEMP installation for use on a local Vbox + CentOS 7 machine (minimal).
Using LEMP as a minimum template for server sharing.

## Supported System
- CentOS-7.x minimal (recommend)
- CentOS-7.x

## Software
- Nginx 17.9
- Php-fpm 7.4
- MariaDB 10.4

## Install

> Three installation options: on a public server, on a local server with or without shared resources

### Remote or Local without share resources
Clone repo and run
```sh
$ git clone https://github.com/SCaeR42/centos_lemp.git centos_lemp && cd centos_lemp && bash centos7_lemp.sh
```
On next step choose `second` option
```sh
How to set lemp?
  1.) local: set settings & domain path to /lemp dir
  2.) remote: all lemp seting is default
  q.) Quit
```
> 2.) remote: all lemp seting is default

### Local with share resources
For use on local with VBox + CentOS 7 and share resources, before install you need create on host folder structure for use it.

Base structure
```
└───lemp/
    └───domains/
    └───mysql/
    └───nginx/
```
OR with conf files
```
└───lemp/
    └───domains/
        └───domains1/
            └───index.php
            └───php.ini
    └───mysql/
    └───nginx/
        └───conf.d/
            └───default.conf
        └───nginx.conf
```
Then add to share VBox main folder `/lemp` to `/lemp`

Then clone repo and run
```sh
$ git clone https://repo-url centos_lemp && cd centos_lemp && bash bash centos7_lemp.sh
```
On next step choose `first` option
```sh
How to set lemp?
  1.) local: set settings & domain path to /lemp dir
  2.) remote: all lemp seting is default
  q.) Quit
```
> 1.) local: set settings & domain path to /lemp dir

In the next step, you need to choose to copy the configs to a shared directory or use the existing
```sh
Copy nginx *.conf to /lemp/nginx folders and override it ? (y/n)
```
- if you created structure `without` conf files say `y`
- if you created structure `with` conf files say `n`



! note: if you selected `y` and you have configuration files in public folders, they will be overridden

## Usage

Usage as normal LEMP server

For local version you have access to configuration files and app files on host machine

## Run tests

Check running services
```sh
systemctl status nginx
systemctl status php-fpm
```

Open in you browser url by ip
`http://192.0.0.10/`
or
`http://192.0.0.10/index.php` for showed phpinfo()

## Author

👤 **SCaeR42@SpaceCoding**

* Website: [spacecoding.net](https://spacecoding.net/)
* Github: [@Casperfl](https://github.com/SCaeR42)

## Show your support

Give a ⭐️ if this project helped you!

## License

Copyright (C) 2013 - 2020 [spacecoding.net](https://spacecoding.net/)

Licensed under the [MIT]([LICENSE](https://choosealicense.com/licenses/mit/)) License.
