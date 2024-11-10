# Chap07 Design a Unique ID Generator in Distributed Systems

## 分布式ID需要满足的特点
1. 全局唯一(必要): 将多个库的主键放在一起也不会出现重复
2. 有序(必要): 避免频繁触发索引重建
3. 信息安全: 比如ID连续，可以根据订单编号可以计算一天的单量，造成信息泄漏
4. 包含时间戳: 能够快速根据ID得知生成时间


## 常规方法
### 1. UUID (Universally Unique Identifier)
* 16 Bytes, 128 bits: 这是最主要的缺点，太长

目前UUID的生成方式有不同的版本
* 基于时间的UUID
* DCE安全的UUID
* 基于名字的UUID(MD5)
* 随机UUID
* 基于名字的UUID(SHA1)

### 2. 数据库生成
* 比如MySQL的 auto_increment

### 3. 类Snowflake方法
* 8 Bytes, 64 bits
* 时间 + 机器吗 + pid + 自增序列

#### 3.1 ⚠️时钟回拨
时钟回拨，就是服务器上的时间突然倒退回之前的时间，时钟回拨会导致ID不唯一的问题。出现时钟回拨的原因可能是：
* 人为更改系统时间。
* 有时候不同的机器上需要同步时间，可能不同的机器存在误差，也会出现时钟回拨。

⚠️注意:
* 开始时间戳由程序指定，一般是ID撑撑起开始使用的时间。
* 设置好后避免更改。
* 依赖服务器时间，服务器始终回拨时可能会生成重复的ID。

⚠️为了解决时钟回拨问题，可以采取以下几种策略：
* **等待策略**：当检测到时钟回拨时，服务可以暂时拒绝生成新的ID，等待系统时钟恢复到正常状态（至少大于或等于上次生成ID时的时间戳）。这种策略可以确保ID的严格递增性，但可能会在时钟调整期间暂停服务，对系统性能造成一定的影响。
* **序列号持久化**：雪花算法原本设计中序列号是在内存中自增的，为了避免时钟回拨导致的序列号重置问题，可以将序列号持久化存储到磁盘上。这样即使服务重启或时钟回拨，服务也能继续从上次持久化的序列号开始自增，从而避免ID重复。这种策略可以在一定程度上容忍时钟回拨，但可能会影响ID的绝对时间戳准确性。

### 4. Leaf方案
#### 4.1 Leaf-segment数据库方案
* 原方案每次获取ID都需要读写一次数据库，造成数据库压力。改为proxy server批量获取，每次获取一个segment号段的值，用完之后再去数据库获取新的号段，可以大大减小对数据库的压力。
* 采用双buffer的方式，Leaf服务内部有两个号段缓存区segment。

#### 4.2 Leaf-snowflake方案
* 相对于原始的Snowflake方案，对于workerID的分配引入了Zookeeper持久顺序节点的特性自动对snowflake节点配置workerID。

### 5. Mist薄雾算法


## Reference
* [分布式ID生成器](https://soulmachine.gitbooks.io/system-design/content/cn/distributed-id-generator.html)
* [Sharding & IDs at Instagram](https://instagram-engineering.com/sharding-ids-at-instagram-1cf5a71e5a5c)
* 🟩🌟[分布式ID介绍&实现方案总结](https://javaguide.cn/distributed-system/distributed-id.html)
* [生成全局唯一ID的3个思路，来自一个资深架构师的总结](https://mp.weixin.qq.com/s?__biz=MzI4MTY5NTk4Ng==&mid=2247489561&idx=1&sn=7396f373af4efa62ba4dbecc6d7f83b3&source=41#wechat_redirect)
* [在开源项目中看到一个改良版的雪花算法，现在它是你的了。](https://www.cnblogs.com/thisiswhy/p/17611163.html)
* [如何选择合适的分布式ID生成方案？](https://www.cyningsun.com/12-26-2018/id-generator.html)
* 🟩🌟美团技术团队: [Leaf——美团点评分布式ID生成系统](https://tech.meituan.com/2017/04/21/mt-leaf.html)
* [分布式系统 - 全局唯一ID实现方案](https://pdai.tech/md/arch/arch-z-id.html)
* [雪花算法snowflake分布式id生成原理详解，以及对解决时钟回拨问题几种方案讨论](https://www.cnblogs.com/ExMan/p/16895300.html)
* 🟩🌟[雪花算法Snowflake详解：分布式ID生成原理与时钟回拨问题解决方案](https://cloud.baidu.com/article/3259226)
  * 时钟回拨问题解决方案
* 