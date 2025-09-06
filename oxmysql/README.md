# oxmysql

A MySQL resource for FiveM that uses [node-mysql2](https://github.com/sidorares/node-mysql2) instead of [mysqljs](https://github.com/mysqljs/mysql).

## Features

- Asynchronous queries
- Prepared statements
- Transaction support
- Promises and callbacks
- MySQL 8.0 support
- Improved performance over mysql-async
- mysql-async compatibility layer

## Installation

1. Download the latest release from [GitHub](https://github.com/overextended/oxmysql/releases)
2. Extract the files to your server's resources folder
3. Add `ensure oxmysql` to your server.cfg (before any resources that use it)
4. Configure your database connection in your server.cfg

## Configuration

Add the following to your server.cfg:

