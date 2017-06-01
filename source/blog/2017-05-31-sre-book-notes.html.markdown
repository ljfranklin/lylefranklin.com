# Notes from Site Reliability Engineering

Text: https://landing.google.com/sre/book/

We recently held a book club at Pivotal for Google's Site Reliability Engineering book.
For posterity, here are my notes from the reading.

## Chapter 1 - Introduction

- Developers and System Admins have somewhat opposed goals: Releasing new features to prod quickly vs keeping the site stable.
- Google has a Site Reliability Engineering team that builds tooling to automate many Ops tasks, with a maximum of 50% of time spent on manual ops work and the rest of the time on development of automation.
- First section seems kinda dismissive of the traditional Ops skillset: "SRE is what happens when you ask a software engineer to design an operations team"
- If it's hard for Google to hire good SREs, what chance to other companies have?
- Interesting that SRE is still a separate team. They mention that if the SRE is having trouble keeping up, they pull product developers into the on-call rotation as a feedback mechanism, but feedback is not as strong as if product developer was usually on-call.
- Liked the "100% is the wrong reliability target" section. Keeps things in perspective that 100% and 99.999% are pretty indistinguishable to users.
- Error budget is a neat idea w.r.t. "spending" the error budget. If you already attempted a risky rollout that didn't go well last week, maybe wait til next month to launch the next risky feature.

## Chapter 2 - The Production environment at Google

- Borg (by extension K8S) and BOSH performs similar jobs, although Borg has a stronger focus on bin-packing and scheduling batch jobs, like a mash-up between Diego and BOSH.
  - Maybe something like Chris and Jim's Crucible gets us closer to resource limits
  - BOSH needs better support for A/B testing
  - Service discovery was a BOSH shortcoming for a long time as it favored static IPs. But the new BOSH DNS feature should fix this.

## Chapter 3 - Embracing Risk

- The idea of maximum availability is interesting. If your reliability is too high, are you not taking enough risks or added too much redundant machines?
- Tracking reliability improvements or regressions over time seems super key. Do we know if our project has become more of less reliable in the last 6 months?
- I really like the request success rate as a better metric than uptime. Uptime treats an outage during peak hours the same as an outage when few people are using it. Also a flaky service could still technically say they are still have solid uptime.
- I like that the authors try to keep things in perspective. Going from 99.9% to 99.99% may actually lose you money if the added engineering cost outweighs the added revenue. And if ISPs' error rate is 1% to 0.1%, can the user even tell the difference between 99.9% and 99.99%.

## Chapter 4 - Service Level Objectives

- "The Global Chubby Planned Outage" is a neat strategy for finding components that are misusing the service. The SREs will intentionally take down the Chubby lock service if it is over its availability SLO in order to quickly identify components that have an unreasonable expectation of reliability.
- Collecting client-side metrics, e.g. how long before the page rendered, seem useful but more difficult to track.
- "Choose just enough SLOs to provide good coverage of your system’s attributes"
- "It’s better to start with a loose target that you tighten than to choose an overly strict target that has to be relaxed when you discover it’s unattainable."
- SLO as a prioritization mechanism feels like a nice way to track goals via objective numbers, e.g. is this implementation getting us closer or farther from our goal

## Chapter 5 - Eliminating Toil

- I like the differentiation between overhead and toil, especially the "no enduring value" part:
  - Overhead: "Overhead is often work not directly tied to running a production service, and includes tasks like team meetings, setting and grading goals, snippets, and HR paperwork."
  - Toil: "Toil is the kind of work tied to running a production service that tends to be manual, repetitive, automatable, tactical, devoid of enduring value, and that scales linearly as a service grows."
- "If you’re too willing to take on toil, your Dev counterparts will have incentives to load you down with even more toil"
- Should we start doing this to help our managers? - "Googlers record short free-form summaries, or "snippets," of what we’ve worked on each week."

## Chapter 6 - Monitoring Distributed Systems

- I like the distinction between black-box and white-box monitoring
  - White-box: exposing internal system metrics emitted by components, might help predict problems / trends
  - Black-box: externally visible behavior as seen by the end-user, indicates that something is wrong right now
- For "Why Monitor?", we definitely have Alerting, Dashboards, and Debugging, but Long-term trends and Experiments over time could help us be pro-active.
- Four Golden Signals:
  - Latency: Time it takes to serve a request
  - Traffic: How much demand is on your system, e.g. requests per second
  - Errors: Rate of failed requests
  - Saturation: How much extra capacity does your system have?
- +1 to keeping your monitoring as simple as possible to avoid a brittle maintenance mess
  - Review metrics every so often to see if not useful ones can be removed
- Checklist for designing an alert seems useful, I especially like "Pages should be about a novel problem or an event that hasn’t been seen before."

## Chapter 7 - The Evolution of Automation at Google

> If we have to staff humans to do the work, we are feeding the machines with the blood, sweat, and tears of human beings. Think The Matrix with less special effects and more pissed off System Administrators.

- If possible, have a system that requires no "glue" automation at all to keep running. Lofty goal but good to keep in mind which changes belong in ad-hoc tooling vs in the product as a proper feature.
- Liked their ProdTest example which discusses a test suite that tells the Operator exactly what part of the system is failing. Would love to have more that on CF rather smoke tests that only try to push apps.
- Does Pivotal suffer from any poor organizational incentives, e.g.:
  - A team whose primary task is to speed up the current turnup has no incentive to reduce the technical debt of the service-owning team running the service in production later.
  - A team not running automation has no incentive to build systems that are easy to automate.
  - A product manager whose schedule is not affected by low-quality automation will always prioritize new features over simplicity and automation.
- Thoughts on preventing: "Inevitably, then, a situation arises in which the automation fails, and the humans are now unable to successfully operate the system."

## Chapter 8 - Release Engineering

- Release engineering metrics such as "time from code change to deployment" seem valuable
- Philosophy of Release Engineering:
  - Self-Service: Enable teams to run their own release process
  - High Velocity: Easier to troubleshoot if there are fewer changes between deploys
  - Hermetic Builds: Build process should be self-contained to ensure consistency and reproduciblity
  - Enforcement of Policies and Procedures: Create a release process (e.g. code reviews, PM clicks the release button, etc.) and setup policies and ACLs to make sure it is followed.
- Google uses a tool called Bazel to create their build artifacts
- Their typical git release flow is to create release branches that never merge back to mainline and cherry-pick bug fixes onto the release branch
- Although we perform the same release actions with Concourse as Google does with Rapid, it feels a bit like each team reinvents the wheel with their custom Concourse pipelines.
- Would be nice if BOSH had better support for A/B rollouts, e.g. deploy this update to 10% of jobs.

## Chapter 9 - Simplicity

- Is the complexity in this problem essential or accidental (Fred Brookes - No Silver Bullet).
- Favoring boring solutions over clever/complicated as long as they both do the job
  - E.g. do you implement an interesting Raft based leader election algorithm or can we just lock a row in the database?
- Keep your APIs as minimal as possible, know when to say no

## Chapter 10 - Practical Alerting

- This chapter is a somewhat deep technical dive into Google's metric collection and analysis system. Would be useful if you were about to design your own monitoring tooling, but not a ton of takeaways at a high level.
- The expvar Golang package adds an HTTP handler that exposes some public variables over an HTTP endpoint
  - https://golang.org/pkg/expvar/

## Chapter 11 - Being On-Call

- Being on-call should strike a balance between quantity (percent of time spent doing on-call activities) and the quality (number of incidents that occurred while on-call).
  - Quantity: Spend at least 50% of time doing engineering, no more that 25% of reminder should be on-call
  - Quality: If too many incidents occur on a given on-call shift, the SRE will not have time to properly perform the incident response responsibilities such as: root-cause analysis, remediation, and follow-up activities like writing a postmortem and fixing bugs. Google found these activities take ~6 hours on average, so there is a max of 2 incidents per 12 hour shift of on-call.
- Three keys to success in on-call policy:
  - Clear escalation paths
  - Well-defined incident-management procedures
  - A blameless postmortem culture
- Poorly designed monitoring can contribute to Operational Overload: "All paging alerts should also be actionable"
  - Related, each incident should ideally generate one alert, not a cascade of related alerts, as it adds noise.
- Going on-call too rarely (Operation Underload) can also be dangerous as SREs can get out-of-touch with the system
  - Can shrink the team or perform exercises (fire drills) that allow SREs to practice for production incidents

## Chapter 12 - Effective Troubleshooting

- Troubleshooting workflow: Triage -> Examine -> Diagnose -> Test/Treat -> ( Repeat as necessary) -> Cure
- I wonder how a bug queue for interrupts would work as compared to slack interrupts?
- "make the system work as well as it can under the circumstances"
  - puts the focus on getting back to stable rather than immediately diving into root cause
- Make a list of hypotheses and test them in descending order of likelihood
- Take notes while you debug!

## Chapter 13 - Emergency Response

- This chapter gives several case studies of emergency responses within Google
- Intentionally break your systems to see if they fail in the way you expect
- Test your rollback procedure in a test environment in case your testing goes awry
- Does our company keep a list of past outages? Should engineering team be required to review this list?

## Chapter 14 - Managing Incidents

- Roles during an Incident:
  - Commander: Assigns responsibilities and roles to others during the incident. Holds all positions they have not delegated.
  - Ops lead: Works with commander to apply operational tools to resolve the incident
  - Communicator: Public face of the incident, gives periodic updates to stakeholders and creates an incident writeup.
  - Planner: Helps facilitate by filling bugs, ordering dinner, arranging handoffs, etc.
- There should be a real-time document that is jointly editable and is updated throughout the incident
- Quickly declare an incident if any of these is true:
  - Do you need to involve a second team in fixing the problem?
  - Is the outage visible to customers?
  - Is the issue unsolved even after an hour’s concentrated analysis?

## Chapter 15 - Postmortem Culture: Learning from Failure

- "A postmortem is a written record of an incident, its impact, the actions taken to mitigate or resolve it, the root cause(s), and the follow-up actions to prevent the incident from recurring."
- When to schedule a postmortem examples:
  - User-visible downtime or degradation beyond a certain threshold
  - Data loss of any kind
  - On-call engineer intervention (release rollback, rerouting of traffic, etc.)
  - A resolution time above some threshold
  - A monitoring failure (which usually implies manual incident discovery)
- Creating a valuable postmortem writeup:
  - Was key incident data collected for posterity?
  - Are the impact assessments complete?
  - Was the root cause sufficiently deep?
  - Is the action plan appropriate and are resulting bug fixes at appropriate priority?
  - Did we share the outcome with relevant stakeholders?
- Ensure your writeup gets reviewed by others
- We should try this: "In a monthly newsletter, an interesting and well-written postmortem is shared with the entire organization."
- The effort of writing up a postmortem should have clear value for the organization, otherwise it is toil

## Chapter 16 - Tracking Outages

- Main takeaway was tracking trends over time
  - Is the number of alerts increasing or decreasing over time?
  - Are there trends across multiple teams?
  - Is a single component causing trouble in multiple services?

## Chapter 17 - Testing for Reliability

- "If you haven't tried it, assume it's broken."
- Mean Time to Repair: how long did it take it fix the issue?
- Mean Time Between Failures: how long since the last failure?
- Hermetic: "server in a box", can your tests be run on a single machine with no network connection?
- In the Creating a Test and Build Environment section, it sounds like SREs typically come into in-progress projects and are tasked with backfilling tests. The book even mentions the possibility that "Conducting unit tests for every key function and class is a completely overwhelming prospect if the current test coverage is low or nonexistent."
- Liked the example of building safeguards into a risky bit of DB automation:
  - Use a separate tool to place a barrier in the replication configuration so that the replica cannot pass its health check. As a result, the replica isn’t released to users.
  - Configure the risky software to check for the barrier upon startup. Allow the risky software to only access unhealthy replicas.
  - Use the replica health validating tool you use for black-box monitoring to remove the barrier.
- When should we write tests for our automation tools?

## Chapter 18 - Software Engineering in SRE

- This chapter details the design and development of a capacity planning tool developed by SREs within Google.
- "team size should not scale directly with service growth."
- When performing capacity planning, it is more flexible to specify intent rather than asking for exact specs.
  - E.g. prefer "I want to run service Foo at 5 nines of reliability." to "I want 50 cores in clusters X, Y, and Z for service Foo."
- When building even internal tools, find target users and advocate for your product if you want it to get adopted.
- "In selecting engineers to work on an SRE software development product, we’ve found great benefit from creating a seed team that combines generalists who are able to get up to speed quickly on a new topic with engineers possessing a breadth of knowledge and experience."

## Chapter 19 - Load Balancing at the Frontend

- This chapter focuses on load balancing between datacenters
- "Ideal" load balancing varies depending on the service
  - e.g. search service favors low latency while video upload favors high throughput
  - maybe search always routes to the nearest datacenter while upload favors the most underutilized connection
- First LB layer: DNS
  - This section gives a detailed list of issues that come up when trying to load balance via DNS. Good example of something that seems somewhat straightforward at face value but has a ton of hidden complexity
- Second LB layer: Virtual IP Address
  - IP shared across many devices, typically tied to a network load balancer
  - LB can encapsulate the original packet with Generic Routing Encapsulation (GRE) and forwards the wrapped packet to the destination backend. This backend can unwrap the packet and process the inner packet as normal.
  - Note that bigger packets could exceed the Maximum Transmission Unit (MTU) of the network, requiring the packet to be disassembled to put over the network and reassembled on the other end.

## Chapter 20 - Load Balancing in the Datacenter

- This chapter centers around the question: "How do we decide which backend should receive a given client request?"
- Many of the techniques are concerned with minimizing the difference in load between the most-utilized and least-utilized backends.
- "In an ideal case, the load for a given service is spread perfectly over all its backend tasks and, at any given point in time, the least and most loaded backend tasks consume exactly the same amount of CPU."
- In addition to ensuring a datacenter has enough resources to handle the client load, another goal is to minimize the amount of "wasted" (reserved but unused) resources, e.g. CPU.
- Flow control: simple LB approach, set a maximum number of connections per backend, mark backend as unhealthy if max connections is reached
  - Causes issues if limit is set too high or too low
- Lame duck: backend can be in three states: Healthy, refusing connections (crashed or draining), Lame duck (healthy but asks that no more requests be sent)
  - Help facilitate gracefully draining away connections before shutdown
- Subsetting: limit the backends a given client can connect to a given subset.
  - Keeps the total number of open connections lower, reducing CPU/memory overhead
  - Details a backend shuffling algorithm that yielded very uniform distributions
- Simple round robin: make an ordered list of backends, route a given request to the next backend in the list, repeat
- Least-Loaded round robin: route request to the backend with the least active requests
  - Be sure to account for the number of errors as backend has recently returned to avoid routing the most requests to an unhealthy backend
  - In practice, Google found least-loaded didn't perform any better that simple round robin in the worst case
- Weighted Round Robin: use backend-provided info (e.g. CPU usage) to proportionally route requests to the most underutilized backends
  - This resulted in a tight grouping between the least and most utilized backends

## Chapter 21 - Handling Overload

- One option to mitigate overload is to serve degraded responses under load, e.g. return a possibly stale cached result rather than computing the up-to-date value.
- Recommends favoring CPU time per request to requests per second as a metric for load as different requests may result in wildly different computation time
- Enforce per-customer limits so a single misbehaving consumer doesn't bring down the whole system
- As returning an "out of quota" response still consumes server resources, client should also throttle themselves if they start receiving quota error responses
- All clients include a Criticality with their requests, allow backends to prioritize traffic:
  - CRITICAL_PLUS: serious user impact if dropped
  - CRITICAL: default for prod systems, some user impact if dropped
  - SHEDDABLE_PLUS: some unavailability is expected, e.g. retryable batch jobs
  - SHEDDABLE: frequent unavailability is fine
- If a backend is overloaded, it can drop the least critical requests first
- Google's rule of thumb: don't retry the same request more than three times and each client should not exceed retries as 10% of total requests.
- Don't nest retries, if a nested client already retries three times, that client's client shouldn't retry against the same backend
- A quick spike in connections from a large batch job can be mitigated by forwarding batch jobs through a batch proxy to aid rate limiting
- Summary: "a backend task provisioned to serve a certain traffic rate should continue to serve traffic at that rate without any significant impact on latency, regardless of how much excess traffic is thrown at the task"

## Chapter 22 - Addressing Cascading Failures

- "If at first you don't succeed, back off exponentially."
- A common example of cascading failure is one server falling over, causing the load to double on an adjacent server, causing that server to fall over under load
- Symptoms of CPU resource exhaustion:
  - All requests become slower
  - Increased number of active requests
  - Increased request queue length
- Symptoms of memory exhaustion:
  - Tasks are killed off due to exceeding quota limits
  - Increased rate of garbage collection
- Running out of file descriptors mean no new network connections can be created
- These various symptoms can also interact with each other, e.g. no CPU causes more in-flight requests which eats more RAM
- Preventing server overload:
  - perform load tests and failover tests
  - serve degraded results (e.g. stale cache) which are cheaper to compute
  - reject requests when overloaded, e.g. rate limiting
  - higher level LBs should rate limit themselves if they receive rate limit responses from backends
  - perform capacity planning
- For systems with steady traffic, keep your request queue length small (e.g. &gt 50% of thread pool size) and reject further requests. This allows LBs to quickly retry against another backend. Use longer queues for more "bursty" systems
- Blindly retrying can make an overload worse. "Always use randomized exponential backoff when scheduling retries"
- Consider limiting the number of retries an entire server can make during a given interval
- Think about retries at the system level to avoid an exponential number of retries (e.g. A retries 5 times talking to B, B retries 5 times talking to C, 25 total retries)
- If a client has a 10 second response timeout, ideally the server should not waste time picking the request off the queue if the 10 second timeout has already elapsed. Passing a deadline through the system can avoid wasting time on requests that the client has already given up on.
- Watch out for latency / performance hits due a "cold cache"
  - Some tech stacks perform much better after the system has fully initialized and received enough requests to build up a cache
- Understand how a system responds under load by adding load until the system breaks
  - Knowing the breaking point can aid in capacity planning
  - Can the system recover gracefully once the load goes back to normal?
- Recovering from cascading failure:
  - Add more resources (CPU, Backends, etc)
  - Temporarily disable certain healthchecks to avoid unnecessary process restarts
  - Restart servers, may help if some requests are jamming the system
  - Drop a percentage of the requests until the system recovers
  - Enter degraded mode
  - Turn off non-critical clients, e.g. batch jobs
  - If certain queries are causing the load, reject only those queries

## Chapter 23 - Managing Critical State: Distributed Consensus for Reliability

- Summary: fairly meaty chapter that discusses several distributed consensus approaches, use cases they address, and pitfalls
- CAP theorem - A system cannot simultaneously have all three of the following properties:
  - Consistent views of the data at each node
  - Availability of the data at each node
  - Tolerance to network partitions
- ACID: Atomicity, Consistency, Isolation, and Durability
- BASE: Basically Available, Soft state, and Eventual consistency
  - These relaxed constraints can yield performance improvements not possible with ACID systems, at the cost of more complicated logic needed to interact with these systems
-  STONITH (Shoot The Other Node in the Head) involves a follower node telling the master node to shutdown when the follower can't contact the master
  - Cheap solution for avoiding split brain, but is dangerous and can result in both nodes shooting each other due to a failing network
- Byzantine failure: a process passing incorrect messages due to a bug or malicious activity
- FLP impossibility result: "no asynchronous distributed consensus algorithm can guarantee progress in the presence of an unreliable network."
  - Have to assume the network is healthy most of the time and is able to make progress
- Paxos consensus algorithm: "Paxos operates as a sequence of proposals, which may or may not be accepted by a majority of the processes in the system. If a proposal isn’t accepted, it fails. Each proposal has a sequence number, which imposes a strict ordering on all of the operations in the system."
- Google recommends providing consensus as a service rather than implementing the logic in libraries as consensus systems tend to be more difficult to deploy
- "A replicated state machine (RSM) is a system that executes the same set of operations, in the same order, on several processes"
  - RSM can be built on top of a consensus algorithm to replay the same operations on all nodes
- lease system: avoids locks being kept forever by requiring that client renew the lock periodically
- To optimize for read-heavy workloads, nodes can acquire a read lease on a subset of data for a short period of time. Any change to this data must be acknowledged by the nodes holding the lease. This means nodes can often immediately return their cached data as they know it has not changed
- When dealing with geographically distributed consensus systems (e.g. between US and Europe) a hierarchical quorum approach may avoid a single machine loss increasing latency for the whole system
- Things to monitor in a consensus system:
  - The number of members running in each consensus group, and the status of each process (healthy or not healthy)
  - Persistently lagging replicas
  - Whether or not a leader exists
  - Number of leader changes
  - Consensus transaction number
  - Number of proposals seen; number of proposals agreed upon
  - Throughput and latency

## Chapter 24 - Distributed Periodic Scheduling with Cron

- This chapter details a distributed cron system build at Google
- The high-level requirement were: tolerance to single machine failure, support crontab scheduling functionality (at 12:00, on Fridays, etc), and prefer skipping a job to running it twice
- "Base services for which outages have wide impact (such as cron) should have very few dependencies"
- If a leader dies before receiving confirmation that a job completed, what should we do (right answer depends on the type of job):
  - Skip the job, don't attempt to re-run
  - Always re-run the job, assumes the job is idempotent
  - Add a hook to verify with an external service whether the job seems to have run
- To keep high performance and reliability, this system stores logs on local disk and persists periodic snapshots into a distributed filestore
- Cron users tend to schedule things at midnight, which can causing a large number of machine to perform work at the same time in a datacenter. Allowing teams to say "run once a day, the exact time doesn't matter" can help distribute the load.

## Chapter 25 - Data Processing Pipeline

- What is a data pipeline: A system that reads in data, transforms it in some way, and outputs new data. Traditionally run periodically like a cron job
- multiphase pipelines: break down complex jobs by feeding the output of a simpler job as the input into the next job
- MapReduce: a design model that combines Map steps (performing transformation or filtering of each item in the input) and Reduce steps (summarizing the input data, e.g. counting or calculating the mean)
- Pipelining of big data is usually architected around "embarrassingly parallel" jobs, where a workflow can be broken into chucks small enough to be worked on individually on smaller machines rather than requiring a single supercomputer to do the entire workload.
- We've been bitten by lack of monitoring on background jobs on my current team recently
- Moiré load pattern: if two or more periodic pipelines happen to be scheduled at the same time, their resource usage will momentarily be added together causing strain on the cluster
- The Google Workflow scheduling system ensures correct results for a given task by requiring workers to obtain and renew a least for a job, record the version number of the task that they are working on, and ensuring each worker writes its output to a unique filename. If any of these properties are not true, the worker will not be able to commit and will discard its work

## Chapter 26 - Data Integrity: What You Read Is What You Wrote

- Good reminder that user perception is what matters. If no data was lost, but your inbox is not displaying some items due to a UI bug, the user will think the data was lost and lose some trust in the product.
- "data integrity means that services in the cloud remain accessible to users"
- "No one really wants to make backups; what people really want are restores."
- Is your backup actually usable in the event of disaster recovery?
- "Delivering a Recovery System, Rather Than a Backup System"
- Can you prove you can recover from a disaster in X hours?
- Deletes in Google systems go through three phases:
  - Soft user delete: user can click a button to undelete the item
  - Soft application delete: support can click a button to undelete the item
  - Hard delete: data can only be recovered by restoring from a backup
- This handles many cases of "user-error" deletions
- To speed up restores, quicker more expensive storage can be used for recent backups and older backups can be moved to cheaper slower storage
- Challenges in designing for Restore:
  - Referential integrity between datastores
  - Schema changes
  - Aging code
  - Zero-downtime data migrations
  - Evolving integration points with other services
- Google adds data validations pipelines (typically large batch jobs like MapReduce) to verify the data integrity of popular services
- "Continuously test the recovery process as part of your normal operations" and "Set up alerts that fire when a recovery process fails to provide a heartbeat indication of its success"
- Includes a detailed case study around a large, week-long restore process to address data loss on Google Music

## Chapter 27 - Reliable Product Launches at Scale

- Google has a Launch Coordination Engineering (LCE) team to help product teams launch successfully to a large user base while avoiding outages
  - This team performs periodic audits and gives guidance on best practices for building a reliable production system and aids in coordination between teams
- Teams follow a Product Launch Checklist which lists common problems and mitigations. Ideally these recommendations are rooted in previous case studies where a service launch suffered to avoid an endless checklist of low value items.
- A centralized LCE team can help reduce duplicated effort across teams by driving re-use of services like rate limiting.
- Does Pivotal have any launch checklists?
- Some example topics to cover in a launch checklist:
  - Architecture and Dependencies
  - Integration
  - Capacity Planning
  - Failure Modes
  - Client Behavior
  - Processes and Automation
  - Development Process
  - External Dependencies
  - Rollout Planning
- You can "soften" launches by rolling out incrementally possibly by limiting new sign-ups per day and only upgrading X% of devices before proceeding with the rest

## Chapter 28 - Accelerating SREs to On-Call and Beyond

- This chapter starts with a list of patterns and anti-patterns around onboarding
- SRE's should be onboarded with a mix of "thinking" activities and "doing" activities
  - Doing: Shadowing on-call, breaking and fixing real systems
  - Thinking: reading post-mortems, disaster role playing
- "Trial by fire" onboarding may be a smell that the team is more reactive than proactive
- Sounds like the SRE teams are required to maintain a large set of docs detailing the operation of each service
- Google gives new SRE's a "starter project" like: "Making a trivial user-visible feature change in a serving stack, and subsequently shepherding the feature release all the way through to production. Understanding both the development toolchain and the binary release process encourages empathy for the developers."
- Google offers classes to its SREs like "Reverse Engineering a Production Service (without help from its owners)."
- Onboarding exercise: Have the junior team member attempt to reverse engineer a diagram of the system and check it with a senior team member
- Use past post-mortems as a teaching resource
- Wheel of Misfortune: role-play a previous outage as if you were on call. Can be guided by a team member who experienced the outage or is familiar with the details. Learn from past experiences
- Learn by breaking staging environments
  - Have a senior SRE break a system and have junior SRE fix it
  - Break a system to see if you monitoring works as expected
- Start by shadowing someone else on-call to ease into it

## Chapter 29 - Dealing with Interrupts

- Three main interrupt categories:
  - Pages: production alerts and their fallout
  - Tickets: customer requests that require you to take an action
  - Ongoing Operational Activities: toil, manual steps to perform a deploy, ad-hoc questions
- Talks about the benefits of "flow state", how does this match with our pairing approach?
- Don't be afraid to ask for help when dealing with interrupts
- Important to build expectations around which responsibilities take priority
  - "A person should never be expected to be on-call and also make progress on projects"
- Use slower on-call rotations to do low context cleanup tasks like updating docs
- Perform periodic reviews of past tickets to try to find patterns and fix the root cause

## Chapter 30 - Embedding an SRE to Recover from Operational Overload

- This chapter describes the process of lending an experienced SRE to an overloaded team to teach the team to be more effective and identify problems
- "Remember that your job is to make the service work, not to shield the development team from alerts."
- Start by making a list of the team's biggest sources of stress, then identify problems waiting to happen
- We've fallen into this trap in the past: "People might ignore problems for months at a time because they believe the new solution that's on the horizon obviates temporary fixes."
- Common alerts that don't require action should be removed or the root cause fixed
- Google places a strong emphasis on well-defined SLOs and how closely the service is matching them as a measure of the team's effectiveness
- Focus on teaching the team to succeed without you, not fixing all the issues yourself

## Chapter 31 - Communication and Collaboration in SRE

- weekly production meeting: the SRE describe the state of the service they are in charge of to interested parties, 30-60 minutes
  - "we talk in detail about the operational performance of the service, and relate that operational performance to design, configuration, or implementation, and make recommendations for how to fix the problems"
- Look for opportunities for sharing tooling cross-team rather than re-inventing the wheel.
- The included case study details the motivation and creation of Viceroy, a dashboard system built by SRE teams
  - Started with many team rolling their own one-off solutions, eventually boiled down to two general solutions, and finally a single general system was created by combining the previous two systems.
- Get SRE involved early so they can weigh in on architectural decisions
- Also includes a case study where product and SRE teams worked together to migrate a service's datastore
  - Worked together from the start and collaborated closely throughout
  - Product teams would add a feature and SRE team would help verify it worked in staging

## Chapter 32 - The Evolving SRE Engagement Model

- This chapter describes the process of the SRE team taking ownership of a service
- SRE teams attempt to understand and improve a service w.r.t.:
  - System architecture and interservice dependencies
  - Instrumentation, metrics, and monitoring
  - Emergency response
  - Capacity planning
  - Change management
  - Performance: availability, latency, and efficiency
- Not every service needs an SRE team or the SRE may not have the capacity
  - Documentation or ad-hoc consultation by SRE team can sometimes be used instead
- Starts with a Production Readiness Review (PRR): used to identify the specific reliability needs of a service
  - Verifies service meets standards for production readiness and sets expectations for collaboration between devs and SRE
  - Sets objectives for improving reliability of service
- Once concrete design changes are agreed upon:
  - Improvements are prioritized based upon importance for service reliability.
  - The priorities are discussed and negotiated with the development team, and a plan of execution is agreed upon.
  - Both SRE and product development teams participate and assist each other in refactoring parts of the service or implementing additional features.
- Getting SRE involved early in the design phase can help avoid large architectural changes down the line
- Dark Launch: Deploy the new service alongside the old, route a "copy" of some percentage of user traffic to the new system but don't show the response to the user
- To avoid duplicated effort across services, the SRE process should strive for shared Best Practices and re-usable frameworks/tooling
- Shared logging structure and metrics can enable re-use of monitoring and alerting systems

## Chapter 33 - Lessons Learned from Other Industries

- Disaster and Recovery Testing (DiRT) drills: attempt to push production systems in order to find weaknesses
- From the manufacturing industry, safety is the highest priority and employees must feel empowered to speak up if something looks off
- Safety conscience industries practice live drills multiple times a week. Simulations are not a complete replacement for actual testing in a live system.
- May industries, especially health care, require certifications. Would these provide value in software engineering?
- Nuclear facilities have fallback systems for every primary system, sometimes several fallback systems (defense in depth)
- Many other industries perform postmortems while this practice is somewhat new to SE. Many of these industries and required by law to perform postmortems due to federal regulations.
- Some industries strongly favored humans over automation (U.S. Navy) while other are trying to replace humans entirely (manufactoring)
  - Navy controls nuclear submarine, hard requirements for safety over speed
  - Manufacturing wants to cut costs above all
  - Automation is a double-edged sword, it move incredibly quickly but can also do a lot of damage in a short time
- Some industries like telcoms follow the rule " if it works now, don't change it.", still using technologies from the 1980's.
- For me, this chapter highlights the relative lack of maturity of our industry. A website dealing with highly sensitive data might look to hire a "javascript ninja" rather than a careful software engineer.
- Overall the software industry strongly favors velocity over reliability compared to other industries. Unlike a pacemaker, no one dies if Google is down for a few minutes.

## Conclusion

- Google SRE grew from a few hundred engineers in 2006 to over 1,000 in 2016.
- The VP of SRE attributes their success to having the group that runs the system in production have direct influence over the design/development of the system in order to make it easier to manage.
- Reminder that the number of humans required to maintain the system should not scale linearly with usage.

## Appendices

- [Availability percentage vs Allowed unavailability window](https://landing.google.com/sre/book/chapters/availability-table.html)
- [Best Practices](https://landing.google.com/sre/book/chapters/service-best-practices.html)
  - Sanity check your inputs to avoid rogue automation
  - Perform progressive rollouts to mitigate risk, e.g. canary deploys
  - Define SLO's from the user's perspective, e.g. measure error rates on the client rather than at the server
  - Use Error Budgets as a mechanism for assessing risk as well as setting a common goal
  - Monitoring should result in either a Page, a Ticket, or simply Logged. Don't send an email alert and expect someone to notice it.
  - Conduct Postmortems to help build a blameless culture and avoid repeat incidents
  - Use Capacity Planning to avoid service overload and validate capacity via load testing
  - Services should attempt to gracefully handle overload, e.g. serving stale results or drop excess requests
  - "SRE teams should spend no more than 50% of their time on operational work; operational overflow should be directed to the product development team". Helps encourage automation over wasted effort and builds empathy between SRE and Product teams
- [Example Incident State Document](https://landing.google.com/sre/book/chapters/incident-document.html)
- [Example Postmortem](https://landing.google.com/sre/book/chapters/postmortem.html)
- [Launch Coordination Checklist](https://landing.google.com/sre/book/chapters/launch-checklist.html)
- [Example Production Meeting Minutes](https://landing.google.com/sre/book/chapters/production-meeting.html)
