# Chap04 Design a Rate Limiter

The benefits of using an API rate limiter:
1. Prevent resource starvation caused by Denial of Service (Dos) attack. A rate limiter prevetns Dos attacks, either intentional or unintentional, by blocking the excess calls.
2. Reduce cost. Limiting the number of calls that use paid third party APIs is essential to reduce costs.
3. Prevent servers from being overloaded. To reduce server load, a rate limiter is used to filter our excess requests caused by bots or users' misbehavior.

## Step 1: Understand the problem and establish design scope


## Step 2: Propose high-level design Algorithms for rate limiting
### 2.1 Where to put the rate limiter

### 2.2 Algorithms for rate limiter
#### 1. Token bucket algorithm
#### 2. Leaking bucket algorithm
#### 3. Fixed window counter algorithm
#### 4. Sliding window log algorithm
#### 5. Sliding window counter algorithm

### 2.3 High-level architecture


## Step 3. High-level architecture
### 3.1 Rate limiting rules

### 3.2 Exceeding the rate limit: APIs return a HTTP response code 429 (too many requests)
Rate limiter headers: The rate limiter returns the following HTTP headers to clients
   * X-Ratelimit-Remaining: The remaining number of allowed requests within the window.
   * X-Ratelimit-Limit: The number of seconds to wait until you can make a request again without being throttled.

### 3.3 Detailed design

### 3.4 Rate limiter in a distributed environment
There are two challenges when scaling the system to support multiple servers and concurrent threads:
1. Race condition
   * Locks are the most obvious solution for solving race condition. However, locks will significantly slow down the system.
   * Two strategies are commonly used to solve the problem: Lua script & sorted sets data structure in Redis.
2. Synchronization issue
   * To support millions of users, one rate limiter server might not be enough to handle the traffic.
   * **When multiple rate limiter servers are used, synchronization is required.**

### 3.5 Performance optimization
1. Multi-data center setup is crucial for a rate limiter because latency is high for users located far away from the data center. Traffic is automatically routed to the closest edge server to reduce latency.
2. Synchronize data with an eventual consistency model.

### 3.6 Monitoring
After the rate limiter is put in place, it is importance to gather analytics data to check whether the rate limiter is effective. Primarily, we want to make sure:
1. The rate limiting algorithm is effective
2. The rate limiting rules are effective.


## Step 4. Wrap up
### 4.1 Different algorithms of rate limiting 
* Token bucket
* Leaking bucket
* Fixed window
* Sliding window log
* Sliding window counter

### 4.2 System architecture
1. rate limiter in a distributed environment
2. performance optimization and monitoring
3. hard vs soft rate limiting
4. rate limiting at different levels
   1. At the application level (HTTP: layer 7)
   2. At the network layer (IP addresses)
   3. Avoid being rate limited. Design your client with best practices:
      * Use client cache to avoid making frequent API calls
      * Understand the limit and do not send too many requests in a short time frame
      * Include code to catch exceptions or errors so your client can gracefully recover from exceptions
      * Add sufficient back off time to retry logic
