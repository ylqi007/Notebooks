## `docker run` reference
Docker runs processes in isolated containers. A container is a process which runs on a host. 

Docker在隔离的容器中运行进程。容器是运行在主机上的进程。这个主机可以是本地的，也可以是远程的。当操作员(operator)运行`docker run`时，运行的容器进程是隔离的，因为它有自己的文件系统、自己的网络，以及与主机分离的、自己的进程数。 