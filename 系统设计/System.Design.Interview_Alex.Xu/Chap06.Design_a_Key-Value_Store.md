# Chap06. Design a Key-Value Store

A `key-value` store, also referred to as a key-value database, is a non-relational database.

In a key-value pair, **the key must be unique**, and the value associated with the key can be accessed through the key.

* Amazon DynamoDB
* Memcached
* Redis

## 1. 

## 2. Single server key-value store
Even though memory access is fast, fitting everything in memory may be impossible due to the space constraint. Two optimizations can be done to fit more data in a single server:
* Data compression 
* Store only frequently used data in memory and the rest on disk

Even with these optimizations, a single server can reach its capacity very quickly. A distributed key-value store is required to support big data.

## 3. Distributed key-value store
CAP: Consistency, Availability, Partition Tolerance

CAP theorem states it is impossible for a distributed system to simultaneously provide more than two of these three guarantees: consistency, availability, and partition tolerance. Let us establish a few definitions.
* **Consistency**: consistency means all clients see the same data at the same time no matter which node they connect to. 无论client连接到哪一个server，都能读取到一致的数据。
* **Availability**: availability means any client which requests data gets a response even if some of the nodes are down. 即使有server down，client依然可以获取data。
* **Partition Tolerance**: a partition indicates a communication break between two nodes. 分区表示两个节点之间的通信中断。分区容忍度意味着尽管出现网络分区，系统仍可继续运行。


* Partition tolerance means the system continues to operate despite network partitions.

## System components
### 1. Data partition: Consistent Hashing
There are two challenges while partitioning the data:
* Distribute data across multiple servers evenly
* Minimize data movement when nodes are added or removed

Using **Consistent Hashing** to partition data has the following advantages:
1. Automatic scaling. 自动添加or减少server depending on the load
2. Heterogeneity(异质性).

### 2. Data replication
To achieve high availability and reliability, data must be replicated asynchronously over N servers, where N is a configurable parameter.


### 3. Consistency
Since data is replicated at multiple nodes, it must be synchronized across replicas. Quorum consensus can guarantee consistency for both read and write operations. 仲裁共识可以保证读写操作的一致性。
* N = the number of replicas
* W = a write quorum of size W
* R = a read quorum of size R

A **coordinator** acts as a proxy between the client and the nodes.
* The configuration of W, R, and N is a typical tradeoff between latency and consistency.
  * If W = 1 or R = 1, an operation is returned quickly because a coordinator only needs to wait for a response from any of the replicas.
  *  If W or R > 1, the system offers better consistency; however, the query will be slower because the coordinator must wait for the response from the slowest replica.

**If W + R > N, strong consistency is guaranteed because there must be at least one overlapping node that has the latest data to ensure consistency.**

#### Consistency models
* String consistency: any read operation returns a value corresponding to the result of the most updated write data item. A client never sees out-of-date data.
* Weak consistency:
* Eventual consistency:

### 4. Inconsistency resolution: versioning
Replication gives high availability but causes inconsistencies among replicas. Versioning and vector locks are used to solve inconsistency problems. Versioning meaning treating each data modification as a new immutable version of data.

A vector clock is a `[server, version]` pair associated with a data item. It can be used to check if one version precedes, succeeds, or in conflict with others.

### 5. Handling failures
#### 1. Failure detection
* Gossip protocol: Each node maintains a node membership list, which contains member IDs and heartbeat counters. 

#### 2. Handling temporary failures
* Hinted handoff (提示切换)

#### 3. Handling permanent failures
* Anti-entropy: Anti-entropy involves comparing each piece of data on replicas and updating each replica to the newest version. A Merkle tree is used for inconsistency detection and minimizing the amount of data transferred.

#### 4. Handling data center outage
* To build a system capable of handling data center outage, it is important to replicate data across multiple data centers. Even if a data center is completely offline, users can still access data through the other data centers.

### 6. System architecture diagram
Main features of the architecture are listed as follows:
1. Clients communicate with the key-value store through simple APIs: `get(key)` and `put(key, value)`.
2. A coordinator is a node that acts as a proxy between the client and the key-value store.
3. Node are distributed on a ring using consistent hashing.
4. Data is replicated at multiple nodes.
5. There is no single point of failure as every node has the same set of resposibilities.

As the design is decentralized, each node performs many tasks:
1. Client API
2. Conflict resolution
3. Replication
4. Failure detection
5. Failure repair mechanism
6. Storage engine
7. ...


### 7. Write path
### 8. Read path
### 9. Summary

