# Chap03 A Framework for System Design Interviews
What is an interviewer looking for in a system design interview?
1. Many think that system design interview is all about a person's technical design skills. It is much more than that. An effective system design interview gives strong signals about a person's ability to collaborate, to work under pressure, and to resolve ambiguity constructively. The ability to ask good questions is also an essential skill, and many interviewers specifically look for this skill.
2. A good interviewer also looks for red flags.
   1. Over-engineering is a real disease of many engineers as they delight in design purity and ignore tradeoffs.
   2. Other red flags include narrow mindedness, stubbornness, etc.

## 1. A 4-Step process for effective system design interview
### Step 1. Understand the problem and establish design scope (3 - 10 minutes)
* In a system interview, giving out an answer quickly without thinking gives you no bonus points. Do not jump right in to give a solution. Slow down.
* One of the most important skills as an engineer is to ask the right questions, make the proper assumptions, and gather all the information needed to build a system. So, do not be afraid to ask questions.

What kind of questions to ask? Ask questions to understand the exact requirements. Here is a list of questions to help you get started:
* What specific features are we going to build?
* How many users does the product have?
* How fast does the company anticipate to scale up? What are the anticipated scales in 3 months, 6 months, and a year?
* What is the company’s technology stack? What existing services you might leverage to simplify the design?

### Step 2. Propose high-level design and get buy-in (10 - 15 minutes)
In this step, we aim to develop a high-level design and reach an agreement with interviewer on the design.
* Come up with an initial blueprint for the design.
* Draw box diagrams with key components on the whiteboard or paper.
* Do back-of-the-envelope calculations to evaluate if your blueprint fits the scale constraints.

### Step 3. Design deep dive (10 - 25 minutes)
At this step, you and your interviewer should have already achieved the following objectives:
* Agreed on the overall goals and features scope.
* Sketched out a high-level blueprint for the overall design.
* Obtained feedback from your interviewer on the high-level design.
* Had some initial ideas about areas to focus on in deep dive based on her feedback.

### Step 4. Wrap up (3 - 5 minutes)
In this final step, the interviewer might ask you a few follow-up questions or give you the freedom to discuss other additional points. Here are a few directions to follow:
* The interviewer might want you to identify the system bottlenecks and discuss potential improvements. Never say your design is perfect and nothing can be improved.
* It could be useful to give the interviewer a recap of your design. 
* Error cases (server failure, network loss, etc.) are interesting to talk about.
* Operation issues are worth mentioning. How do you monitor metrics and error logs? How to roll out the system?
* How to handle the next scale curve is also an interesting topic.
* Propose other refinements you need if you had more time

### Time allocation on each step
* Step 1: Understand the problem and establish design scope: 3 - 10 minutes
* Step 2: Propose high-level design and get buy-in: 10 - 15 minutes
* Step 3: Design deep dive: 10 - 25 minutes
* Step 4: Wrap: 3 - 5 minutes