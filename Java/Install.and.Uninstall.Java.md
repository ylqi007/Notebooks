## Install Java JDKs
After installing different java versions, they are installed under `/Library/Java/JavaVirtualMachines/`
```shell
➜  ~ tree /Library/Java/JavaVirtualMachines -L 1
/Library/Java/JavaVirtualMachines
├── amazon-corretto-11.jdk
├── amazon-corretto-17.jdk
└── amazon-corretto-8.jdk

4 directories, 0 files
```

You can use `/usr/libexec/java_home -V`
```shell
➜  ~ /usr/libexec/java_home -V
Matching Java Virtual Machines (3):
    17.0.9 (x86_64) "Amazon.com Inc." - "Amazon Corretto 17" /Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk/Contents/Home
    11.0.21 (x86_64) "Amazon.com Inc." - "Amazon Corretto 11" /Library/Java/JavaVirtualMachines/amazon-corretto-11.jdk/Contents/Home
    1.8.0_402 (x86_64) "Amazon" - "Amazon Corretto 8" /Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
/Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk/Contents/Home
```

You can run the following command in a terminal to get the complete installation path.
```shell
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

## Setting Up `JAVA_HOME` and `PATH`
Most programs rely on the `JAVA_HOME` and `PATH` environment variables to find Java installations. These environment variables can be set in our shell configuration file.
In macOS, it uses `zsh` by default which uses `~/.zshrc` as the configuration file. Open up the file in your favorite text editor and add the following lines:
```shell
export JAVA_HOME=$(dirname $(dirname $(realpath /usr/bin/java)))
exprot PATH=$JAVA_HOME/bin:$PATH
```
* ⚠️注意: 测试是否可用

Once you've edited the file, source it by running:
```shell
source ~/.zshrc
```

Afterwards, check if Java has been correctly installed by running:
```shell
java -version
```

Notes:
1. We purposely use `export JAVA_HOME=$(dirname $(dirname $(realpath /usr/bin/java)))` instead of `export JAVA_HOME=/usr` to ensure all Java tools + commands are from the same installation.
2. While this requires us to do an extra `source ~/.zshrc` after each `sudo alternatives --config java` to re-solve the path, this prevents mixing of Java tool + command versions and is ultimately more concise (no need to re-run `alternatives` for every Java tool + command).

### 1. Switching between versions
If you have multiple versions of Java installed, you can switch between them with `alternatives` by running
```shell
sudo alternatives --config java && source ~/.zshrc
```
This will bring up an interactive prompt which lets you choose between different Java installations.


## Switch Java JDK Version
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

**Switch JDK version and check JDK version**
```shell
# Switch to JDK8
jdk 8
java -version

# Switch to JDK11
jdk 11
java -version

# Switch to JDK17
jdk 17
java -version
```


## Reference
* [Differences Amazon Corretto and OpenJDK](https://stackoverflow.com/questions/53305934/differences-amazon-corretto-and-openjdk)
* [Amazon Corretto Documentation](https://docs.aws.amazon.com/corretto/)
* [Amazon Corretto 8 User Guide](https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/what-is-corretto-8.html) (Can find JDK8 download link here)
* [Amazon Corretto 11 User Guide](https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/what-is-corretto-11.html) (Can find JDK11 download link here)
* [Amazon Corretto 17 User Guide](https://docs.aws.amazon.com/corretto/latest/corretto-17-ug/what-is-corretto-17.html) (Can find JDK17 download link here)
* Command `/usr/libexec/java_home --help`: Returns the path to a Java home directory from the current user's settings.