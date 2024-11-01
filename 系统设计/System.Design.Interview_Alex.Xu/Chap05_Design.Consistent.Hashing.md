# Chap05 Design Consistent Hashing (一致性哈希)

## 1. The rehashing problem

## 2. Consistent hashing

### 2.1 Hash space and hash ring
### 2.2 Hash servers
### 2.3 Hash keys
### 2.4 Server lookup
### 2.5 Add a server
### 2.6 Remove a server

## 3. Two issues in the basic approach
The basic steps of consistent hashing algorithm are:
* Map servers and keys on to the ring using a uniformly distributed hash function.
* To find out which server a key is mapped to, go clockwise from the key position until the first server on the ring is found.

1. It is impossible to keep the same size of partition on the ring for all servers considering a server can be added or removed. A partition is the hash space between adjacent servers. It is possible that the size of the partitions on the ring assigned to each server is very small or fairly large.
2. It is possible to have a non-uniform key distribution on the ring.

## 4. Virtual nodes
A virtual node refers to the real node, and each server is represented by multiple virtual nodes on the ring.

As the number of virtual nodes increases, the distribution of keys becomes more balanced. This is because the standard deviation gets smaller with more virtual nodes, leading to balanced data distribution. Standard deviation measures how data are spread out.

## 5. Find affected keys

## Wrap up
The benefits of consistent hashing include:
* Minimized keys are redistributed when servers are added or removed.
* It is easy to scale horizontally because data are more evenly distributed.
* Mitigate hotspot key problem. 

Consistent hashing is widely used in read-world systems, including some notable ones:
* Partitioning component of Amazon's Dynamo database.
* Data partitioning across the cluster in Apache Cassandra.
* Discord chat application
* Akamai content delivery network
* Maglev network load balancer


## Appendix
高流量动态网站和Web应用一般都会用**分布式缓存**，如redis等，来提高并发能力，而像redis等分布式缓存采用了**一致性哈希算法**来实现请求的动态均衡。

### 1. 什么是hashing(哈希)?
各种编程语言都会有内置的HashMap、HashTable等数据结构。这些数据结构都有使用了特定的**哈希函数**，将一段数据(通常为某种对象，任意大小)映射到另一段数据（通常为整数，称作hash code）。

当输入越来越多的时候，有可能有多个不同的字符串映射到相同的数字上，这种现象称为**冲突**。冲突可以通过**开放地址法（再散列）**或和**链地址法（使用链存储冲突值）**来解决。

### 2. 扩展: 分布式哈希
在某些情况下，很有必要将哈希表分成不同部分，每部分托管在不同的服务器上面。这样能够避免单个计算机的内存无法装下整个哈希表的情况，允许构建任意大的散列表（给定足够的服务器）。

在这种情况下，对象（和它们对应的key）分布在几个服务器中。这也是分布式哈希名称来源。

利用**分布式集群**分散地存储数据，可以提高并发。但究竟怎么把对象散列到不同机器上呢？散列原则是什么？

最简单的散列方式就是哈希值直接取模(`hashCode mod N`)，根据结果散列到指定的server上，即`server = hash(key) mod N`,其中N是server数量。

### 3. Rehashing问题(再散列问题)
以上直接取模做法的问题是，当增加or减少一个server时，需要rehashing，此时但部分的`hashCode mod N`都会发生变化。
因此，大多数查询都不能命中缓存，并且原始数据可能需要再次从源检索，从而给源服务器（通常是数据库）带来沉重的负担。这可能会严重降低性能，并可能导致原始服务器崩溃。

### 4. 解决方案：一致性哈希(Consistent hashing)
基于以上问题，需要一种更好的散列方式。新的散列方式不能再依赖于服务器数量，因此，在增加or减少服务器时，需要重新散列的key-value数量会尽量减少。





## Reference
* ❇️[A Guide to Consistent Hashing](https://www.toptal.com/big-data/consistent-hashing)
  * ❇️翻译: [一致性哈希(Consistent hashing)算法](https://berryjam.github.io/2018/05/%E4%B8%80%E8%87%B4%E6%80%A7%E5%93%88%E5%B8%8C(Consistent-hashing)%E7%AE%97%E6%B3%95/)
  * CSDN: [解决哈希表的冲突-开放地址法和链地址法](https://blog.csdn.net/w_fenghui/article/details/2010387)
* ❇️ Google Research: [Consistent Hashing with Bounded Loads](https://research.google/blog/consistent-hashing-with-bounded-loads/)
* AWS: [什么是一致性哈希？](https://www.amazonaws.cn/en/knowledge/what-is-consistent-hashing/)

