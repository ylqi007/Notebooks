# 安装Tomcat
⚠️注意: 通过运行`./startup.sh`安装完Tomcat之后，会默认开始Tomcat，即可以通过`localhost:8080`访问到Tomcat页面。如果想再开启一个Tomcat Service，必须要先终止当前Tomcat Service
```shell
➜  bin ./startup.sh
Using CATALINA_BASE:   /usr/local/apache-tomcat-10.1.28
Using CATALINA_HOME:   /usr/local/apache-tomcat-10.1.28
Using CATALINA_TMPDIR: /usr/local/apache-tomcat-10.1.28/temp
Using JRE_HOME:        /Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk/Contents/Home
Using CLASSPATH:       /usr/local/apache-tomcat-10.1.28/bin/bootstrap.jar:/usr/local/apache-tomcat-10.1.28/bin/tomcat-juli.jar
Using CATALINA_OPTS:
Tomcat started.

➜  bin pwd
/usr/local/apache-tomcat-10.1.28/bin

➜  bin ./shutdown.sh
Using CATALINA_BASE:   /usr/local/apache-tomcat-10.1.28
Using CATALINA_HOME:   /usr/local/apache-tomcat-10.1.28
Using CATALINA_TMPDIR: /usr/local/apache-tomcat-10.1.28/temp
Using JRE_HOME:        /Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk/Contents/Home
Using CLASSPATH:       /usr/local/apache-tomcat-10.1.28/bin/bootstrap.jar:/usr/local/apache-tomcat-10.1.28/bin/tomcat-juli.jar
Using CATALINA_OPTS:
```

* [A Beginner’s Guide: Installing Apache Tomcat on Your Mac](https://medium.com/@raju6508/a-beginners-guide-installing-apache-tomcat-on-your-mac-11fa0995f3c7)
* https://tomcat.apache.org/download-10.cgi
