```shell
# You can run the following command in a terminal to get the complete installation path. 
➜  ~ /usr/libexec/java_home --verbose
Matching Java Virtual Machines (3):
    17.0.9 (x86_64) "Oracle Corporation" - "Java SE 17.0.9" /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
    17.0.8 (x86_64) "Amazon.com Inc." - "Amazon Corretto 17" /Users/ylqi007/Library/Java/JavaVirtualMachines/corretto-17.0.8.1/Contents/Home
    11.0.19 (x86_64) "Homebrew" - "OpenJDK 11.0.19" /usr/local/Cellar/openjdk@11/11.0.19/libexec/openjdk.jdk/Contents/Home
/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home

➜  ~ brew uninstall openjdk@11

Uninstalling /usr/local/Cellar/openjdk@11/11.0.19... (673 files, 298.2MB)
➜  ~

➜  ~ /usr/libexec/java_home --verbose
Matching Java Virtual Machines (2):
    17.0.9 (x86_64) "Oracle Corporation" - "Java SE 17.0.9" /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
    17.0.8 (x86_64) "Amazon.com Inc." - "Amazon Corretto 17" /Users/ylqi007/Library/Java/JavaVirtualMachines/corretto-17.0.8.1/Contents/Home
/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home

➜  ~ /usr/libexec/java_home --verbose
Matching Java Virtual Machines (1):
    17.0.8 (x86_64) "Amazon.com Inc." - "Amazon Corretto 17" /Users/ylqi007/Library/Java/JavaVirtualMachines/corretto-17.0.8.1/Contents/Home
/Users/ylqi007/Library/Java/JavaVirtualMachines/corretto-17.0.8.1/Contents/Home
```

If you need to use multiple versions of Java, you can add the following function to your `~/.zshrc` to easily set `JAVA_HOME` for your current shell, e.g. run `jdk 17` to use Java 17 in the current session.
```bash
function jdk() {
    if [[ "${1}" == "8" ]]; then
        version="1.8"
    else
        version="${1}"
    fi
    unset JAVA_HOME
    export JAVA_HOME=$(/usr/libexec/java_home -v "${version}")
}
```

## Reference
* [Differences Amazon Corretto and OpenJDK](https://stackoverflow.com/questions/53305934/differences-amazon-corretto-and-openjdk)
* [Amazon Corretto Documentation](https://docs.aws.amazon.com/corretto/)
* [Amazon Corretto 11 User Guide](https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/what-is-corretto-11.html)
* [Amazon Corretto 17 User Guide](https://docs.aws.amazon.com/corretto/latest/corretto-17-ug/what-is-corretto-17.html)