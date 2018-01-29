# 
![Banner](https://github.com/smc-ac/Spartan/blob/master/img/png/Spartan_banner.png)

Delphi MVC micro-framework to fast-build your apps.

## Main Topics

* [Installation](https://github.com/smc-ac/Spartan#installation)
* [Getting Started](https://github.com/smc-ac/Spartan#getting-started)
* [Commands](https://github.com/smc-ac/Spartan#commands)
* [Usability](https://github.com/smc-ac/Spartan#usability)
* [Live Examples](https://github.com/smc-ac/Spartan#live-examples)


## Getting Started

This micro-framework is intended to help Delphi developers to implement an MVC standard (or as close to that) in their projects. It will create a folder structure (Controller, Model, View and DAO), make a connection to the database, using the `lambda.ini` file, and map the chosen tables for the application.

### Commands

The basic commands are:

* `-v`    : Show framework version.
* `-c`    : Read framework configurations stored in conf.ini file.
* `stare` : Start a new Spartan application. [ name ]
* `push`  : Construct the base files using your configuration set. [ model | controller | dao ]

### Usability

The program will work in console, so it is recommended the following steps:

Create a new "VLC Forms Application" on Delphi and can open the console in your project folder. After that, execute the command:

```
spartan spare .
```

The `.` tells Spartan to create the structure in the current folder. If you want to do it in another way, use:

```
spartan spare my_awesome_project
```

Now that we have the structure, let's push the files to the well, THIS IS SPAR... NO WAIT.

The push command have two others otions: `model`, `controller` and `DAO`. They will create the files for these folders. If you use:

```
spartan push [ model | controller | dao ] 
```

the program will show the avaliable resources to be created from your database, then use:

```
spartan push model TTableName
spartan push controller TTableNameController
spartan push dao TTableNameDAO
```

but, if you're a impulsive soldier, use:

```
spartan push model *
spartan push controller *
spartan push dao *
```
### Live Examples

See Spartan in action:

#### Start new project
----------------------

![Spartan push command](https://github.com/smc-ac/Spartan/blob/master/img/gif/stare.gif)

#### SPARTANS, PUUUUUUUUUUUUUUUSH!
----------------------

![Spartan push command](https://github.com/smc-ac/Spartan/blob/master/img/gif/push.gif)

## If you don't have the files, COME AND TAKE THEM.
