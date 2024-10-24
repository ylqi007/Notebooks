# Chap02 Back of the Envelope Estimation

## 1. Power of two

## 2. Latency numbers every programmer should know
* Memory is fast but the disk is slow.
* Avoid disk seeks if possible.
* Simple compression algorithms are fast.
* Compress data before sending it over the internet if possible.
* Data centers are usually in different regions, and it takes time to send data between them.

## 3. Availability numbers
High availability is the ability of a system to be continuously operational for a desirably long period of time. 
High availability is measured as a percentage, with 100% means a service that has 0 downtime. 
Most services fall between 99% and 100%.

A service level agreement (SLA) is a commonly used term for service providers. This is an agreement between you (the service provider) and your customer, and this agreement formally defines the level of uptime your service will deliver.

## 4. Example: Estimate Twitter QPS and storage requirements

## 5. Tips
* Rounding and Approximation: 四舍五入和近似值。
* Write down your assumptions: 
* Label your units:
* Commonly asked back-of-the-envelop estimations:
  * QPS, Query per Second
  * Peak QPS: 2 * QPS
  * Storage
  * Cache
  * number of servers, etc