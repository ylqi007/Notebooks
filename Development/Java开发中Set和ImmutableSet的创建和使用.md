[toc]

## 1. Constructe an immutable set
An immutable object will not change its internal state once we create it. This makes it thread-safe by default. 

Suppose we have a `HashSet` instance with some values, making it immutable will create a "read-only" version of our set, and any attempt to modify its state will throw `UnsupportedOperationException`.

So, why do we need immutable set? Certainly, the most common use case of an immutable set is a multi-threaded environment. So, we can share immutable data across the threads without worrying about the synchronization.

Meanwhile, there is an important point to keep in mind: immutability pertains only to the set and not to its elements. Furthermore, we can modify the instance references of the set elements without a problem.


### 1. Create Immutable Sets in Core Java
```java
Set<String> set = new HashSet<>();
set.add("Canada");
set.add("China");

Set<String> unmodifiableSet = Collections.unmodifiableSet(set);
```

### 2. Create Immutable Sets in Java 9
Since Java 9, the `Set.of(elements)` static factory is available for creating immutable sets:
```java
Set<String> immutableSet = Set.of("Canada", "China");
```

### 3. Create Immutable Sets in Guava
Another way that we can construct an immutable set is by using Guava’s `ImmutableSet` class. It copies the existing data into a new immutable instance. As a result, the data inside ImmutableSet won’t change when we alter the original Set.

Like the core Java implementation, any attempt to modify the created immutable instance will throw `UnsupportedOperationException`.

#### 3.1 Using `ImmutableSet.of()`
With the `ImmutableSet.of()` method we can instantly create an immutable set with the given values:
```java
Set<String> immutableSet = ImmutableSet.of("Canada", "China");
```

#### 3.2 Using `ImmutableSet.bulder()`
```java
ImmutableSet<String> immutableSet = ImmutableSet.<String>builder()
    .add("Hello")
    .add(new String("未读代码"))
    .build();
immutableSet.forEach(System.out::println);
```

#### 3.3 Using `ImmutableSet.copyOf()`: 从其他集合中拷贝创建 
Simply put, the `ImmutableSet.copyOf()` method returns a copy of all elements in the set. So after changing the initial set, the immutable instance will stay the same.
```java
Set<String> immutableSet = ImmutableSet.copyOf(set);
```

#### ⚠️注意事项
1. 使用 Guava 创建的不可变集合是拒绝 null 值的，因为在 Google 内部调查中，95% 的情况下都不需要放入 null 值。
2. 使用 JDK 提供的不可变集合创建成功后，原集合添加元素会体现在不可变集合中，而 Guava 的不可变集合不会有这个问题。
3. 如果不可变集合的元素是引用对象，那么引用对象的属性是可以更改的。


## 2. `Set`在开发中的应用
### 1. 需要类型推断时
```java
ImmutableSet.<String>of();
Collections.<String>emptySet();
```
This syntax is useful for manually specifying type arguments any time the type inference fails.

### 2. 创建static final Set
```java
private static final Set<String> TYPES = Set.of("A", "B");  // Since JDK9
private static final Set<String> TYPES = ImmutableSet.of("A", "B"); // With Guava
```
如果是用JDK9及以后版本，直接用`Set.of(...)`即可。




## Reference
* [Immutable Set in Java](https://www.baeldung.com/java-immutable-set)
* [Interface java.util.Set<E> (JDK9)](https://docs.oracle.com/javase/9/docs/api/java/util/Set.html)
* [What's the difference between Collections.unmodifiableSet() and ImmutableSet of Guava?](https://stackoverflow.com/questions/5611324/whats-the-difference-between-collections-unmodifiableset-and-immutableset-of)
* [passing ImmutableSet in place of Set?](https://stackoverflow.com/questions/2149235/passing-immutableset-in-place-of-set)
* ✅ [善用google guava提高编程效率](https://vincentruan.github.io/2020/03/18/%E5%96%84%E7%94%A8google-guava%E6%8F%90%E9%AB%98%E7%BC%96%E7%A8%8B%E6%95%88%E7%8E%87/)
* [为什么强烈推荐 Java 程序员使用 Google Guava 编程](https://zhuanlan.zhihu.com/p/111434404)
* [Guava - 拯救垃圾代码，写出优雅高效，效率提升N倍](https://www.51cto.com/article/630601.html)
* [Java 技术开发专题系列之【Guava Collections】实战使用相关 Guava 不一般的集合框架](https://xie.infoq.cn/article/687ecdffb8d7e71a9b3181a7a)