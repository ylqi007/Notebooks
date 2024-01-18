Java虚拟机(JVM)在执行Java程序的过程中，会把它所管理的内存划分为若干个不同的数据区域。这些区域有各自的用途，以及创建和销毁的时间，有的区域会随着虚拟机进程的启动而一直存在，有的区域则是依赖用户线程的启动和结束而建立和销毁。

![](images/Fig_001_JVM_Architecture.jpg)
中间红色矩形中表示的即使运行时数据区(Runtime Data Area)。

Runtime Data Area可分成五个区域
1. Program Counter Register
2. Virtual Machine Stack
3. Native Method Stack
4. Heap
5. Method Area

根据是否为线程共享可以分为：
* 线程私有：程序计数器、虚拟机栈、本地方法区
* 线程共享：堆、方法区, *堆外内存（Java7的永久代或JDK8的元空间、代码缓存）*

## 1. Program Counter Register
* **作用:** PC寄存器用来存储指向下一条指令的地址，即将要执行的指令代码。由**执行引擎**读取下一条指令。
* 因为CPU需要不停的切换各个线程，这时候切换回来以后，就得知道接着从哪开始继续执行。JVM的字节码解释器就需要通过改变PC寄存器的值来明确下一条应该执行什么样的字节码指令。
* 多线程在一个特定的时间段内只会执行其中某一个线程方法，CPU会不停的做任务切换，这样必然会导致经常中断或恢复。为了能够准确的记录各个线程正在执行的当前字节码指令地址，所以为每个线程都分配了一个PC寄存器，每个线程都独立计算，不会互相影响。
* 在JVM规范中，每个线程都有它自己的程序计数器，是线程私有的，生命周期与线程的生命周期一致。
* 它是唯一一个在 JVM 规范中没有规定任何`OutOfMemoryError`情况的区域。

## 2. Java Virtual Machine Stack
* Java虚拟机栈(Java Virtual Machine Stacks)，早期也叫Java栈。**每个线程**在创建的时候都会创建一个虚拟机栈，其内部保存一个个的栈帧(Stack Frame)，对应着一次次 Java方法调用，**是线程私有的，生命周期和线程一致**。
* **作用:** 主管 Java 程序的运行，它保存方法的局部变量、部分结果，并参与方法的调用和返回。
* JVM直接对虚拟机栈的操作只有两个：每个方法执行，伴随着入栈（进栈/压栈），方法执行结束出栈。
* **栈不存在垃圾回收问题**

**栈中可能出现的异常:**Java虚拟机规范允许*Java虚拟机栈*的大小是动态的或者是固定不变的
1. 如果采用**固定大小的Java虚拟机栈**，那每个线程的Java虚拟机栈容量可以在线程创建的时候独立选定。如果线程请求分配的栈容量超过Java虚拟机栈允许的最大容量，Java虚拟机将会抛出一个`StackOverflowError`异常。
2. 如果**Java虚拟机栈**可以动态扩展，并且在尝试扩展的时候无法申请到足够的内存，或者在创建新的线程时没有足够的内存去创建对应的虚拟机栈，那Java虚拟机将会抛出一个`OutOfMemoryError`异常。

### 2.1 栈的内部结构
![](images/Fig_002_JVM_Stack.Frame.jpg)
每个栈帧(Stack Frame)中存储着：
1. 局部变量表(Local Variables)
2. 操作数栈(Operand Stack), (或称为表达式栈)
3. 动态链接(Dynamic Linking): 指向运行时常量池的
4. 方法引用方法返回地址(Return Address): 方法正常退出或异常退出的地址
5. 一些附加信息





## Reference
* 原文链接：https://pdai.tech/md/java/jvm/java-jvm-struct.html
