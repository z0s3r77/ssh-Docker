# Content
-   [**Free code script**](#free-code-script)
-   [**Introduction**](#introduction)
-   [**Docker description**](#docker-description)
-   [**Dockerfile description**](#dockerfile-description)
-   [**Implementing bash with docker**](#implementing-bash-with-docker)

# Free code script

This is a free creation script,assigned in the subject of informatic systems,aimed to implement basic bash script knowledge in pairs :dizzy:

## Introduction

this is a task assigned in the subject of  informatic systems,aimed to implement basic bash script knowledge in pairs.This group is formed by [Sebastián Estacio](https://github.com/z0s3r77) & [Samuel Piedra](https://github.com/SPiedra955) :raising_hand:

## Docker description

Docker is an open source software used to deploy applications inside virtual containers. Containerisation allows multiple applications to run in different complex environments. For example, Docker allows the WordPress content management system to run on Windows, Linux and macOS systems without any problems.

## Dockerfile description

A Dockerfile is a simple text file or document that includes a series of instructions that need to be executed consecutively to fulfil the necessary processes for the creation of a new image.

This set of instructions is known as a command line and will be responsible for indicating the steps to follow for the assembly of an image in Docker, that is, the elements necessary for the development of a container in Docker.

So the images in Dockerfile are created from a specific command called docker build, which will be responsible for providing the tools for the system to follow the instructions that the user has indicated on the command line.

## Implementing bash with Docker

For this script we have combined a bash script with a Dockerfile:

* The bash script executes a series of commands to act as a CLI and at the same time execute a series of processes such as installing, updating programs in a docker       container and creating a test user but before that we must have a container created with the port 22.

* Dockerfile this file is the second part of the script,were we are in the case that we don't have a container created with a port 22 yet,then this file creates a container.
