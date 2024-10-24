# Chapter 1. Scale From Zero to Millions of Users
1. Single server setup
   * Everything is running on one server: web app, database, cache, etc.
2. Database
   * Separating web/mobile traffic and database servers allows them to be scaled independently.
   * Traditional relation database and non-relational database
3. Vertical scaling vs **Horizontal scaling**
4. Load balancer
   * A load balancer evenly distributes incoming traffic among web servers that are defined in a load-balanced set.
5. Database replication
    * Database replication can be used in many database management systems, usually with a master/slave relationship between the original (master) and the copies (slaved).
    * A master database generally only supports write operations.
    * A slave database gets copies of the data from the master database and only supports read operations.
    * In production systems, promoting a new master is more complicated as the data in a slave database might not be up to date. The missing data needs to be updated by running data recovery scripts.
6. Cache 
   * A cache is a temporary storage are that stores results in memory so that subsequent requests are served more quickly.
   * The cache tier is a temporary data store layer, much faster than the database.
   * Considerations for using cache:
     * Decide when to use case: when data is read frequently but modified infrequently
     * Expiration policy
     * Consistency
     * Mitigating failures: A single point of failure (SPOF)
     * Eviction policy (缓存驱逐)
7. Content Delivery Network (CDN)
    * A CDN is a network of geographically dispersed servers used to deliver static content. CDN servers cache static content like images, videos, CSS, JavaScript files, etc.
    * Considerations of using a CDN:
      * Cost: Caching infrequently used assets provides no significant benefits so you should consider moving them out of the CDN.
      * Setting an appropriate cache expiry.
      * CDN fallback
      * Invalidating files
8. Stateless web tier
   * For this, we need to move state (for instance user session data) out of the web tier. A good practice is to store session data in the persistent storage such as relational database or NoSQL.
   * Stateful architecture: A stateful server remembers client data (state) from one request to the next.
   * Stateless architecture: A stateless server keeps no state information. HTTP requests from users can be sent to any web servers, which fetch state data from a shared data store. State data is stored in a shared data store and kept out of web servers.
9. Data centers
    * In normal operation, users are geoDNS-routed, also known as geo-routed, to the closest data center. geoDNS is a DNS service that allows domain names to be resolved to IP addresses based on the location of a user.
10. Message queue
    * A message queue is a durable component, stored in memory, that supports asynchronous communication.
    * Decoupling makes the message queue a preferred architecture for building a scalable and reliable application.
11. Logging, metrics, automation
    * Logging: Monitoring error logs is important because it helps to identify errors and problems in the system.
    * Metrics: Collecting different types of metrics help us to gain business insights and understand hte health status of the system. Some of the following metrics are useful:
      * Host level metrics: CPU, Memory, Disk I/O, etc
      * Aggregated level metrics: for example, the performance of the entire database tier, cache tier, etc.
      * Key business metrics: daily active users, retention, revenue, etc.
    * Automation: When a system gets big and complex, we need to build or leverage automation tools to improve productivity. Continuous integration is a good practice.
12. Adding message queues and different tools
13. Database scaling
    * Vertical scaling, also known as scaling up, is the scaling by adding more power (CPU, RAM, DISK, etc) to an existing machine.
    * Horizontal scaling, also known as sharding, is the practice of adding more servers.
    * Resharding data
    * Celebrity problem
    * Join and de-normalization
14. Millions of users and beyond
