# DevLog — My Personal Development Journal

> **⚠️ Note:** *This is not documentation.  
> It's a personal development log — part diary, part roadmap, part changelog.  
> It's where I explore, plan, make mistakes, and learn by doing.*
---
## 👋 Hey there

My name is Yaroslav, and I’m on my way to becoming a DevOps Engineer.  
I’m actively learning the tools, practices, and methodologies behind DevOps — and this project is my personal training ground.

Everything you see here is the result of experimenting, learning from mistakes, and trying to build things the right way.  
It’s not meant to be a production-ready solution — it's a hands-on lab where I apply what I learn in real-world-like scenarios. However, I try to stay close to the production environment.


## 📓 What's in this Log


- **Plans and roadmaps**
- **Implementation notes**
- **Personal thoughts on tech decisions**
---
---

#### Repository initialized
*Jul, 22*

>Project has started. The initial foundation has been laid.

✓ Kubernetes manifests written  
✓ Immich successfully deployed to Linode LKE cluster  
✓ External access via LoadBalancer (EXTERNAL-IP) configured

*Manifests are organized into groups, each with a dedicated README.*

*Unfortunately, ReadWriteMany (RWX) access could not be implemented due to limited experience.  
Linode does not offer native RWX storage like AWS EFS, so an NFS server and CSI driver must be set up manually.*

*This issue will be addressed after migrating to a different Kubernetes provider.*

Next step:  
- Create a Helm chart to simplify deployment

---
#### Add Helm Chart
*Jul, 26* 
> Added a packaged Helm chart.

*Deployment is now significantly simplified.  
I plan to use this chart in future CI/CD pipelines.*  

*All parameters have been templated for easy configuration via values.yaml.  
The namespace is created separately, as is the injection of Sealed Secret.*

---
### The Project has been restructured.
*Oct, 29*

✓ helm/ and k8s/ moved to archived/ and no relevant\
✓ From now, IaC is located in [archived/](./archived)\
✓ Work resumed.

*Returned to work with new knowledge.*\
*Preparing for active development.*\
*Configured Terraform Remote Backend (S3).*

---
### Added basic VPC module
*Oct, 31*

✓ Add /modules/vpc\
✓ Defined resources — VPC, Public and Private Subnets\
✓ Changed module connection way from local to git with tags

---
### New resources in Public Subnet
*Nov, 03*

✓ Add Internet Gateway\
✓ Add Route Table\
✓ Add NACL, Inbound/Outbound rules\
✓ A bit of refactoring

---
### Private Subnet and NAT Gateway
*Nov, 04*

✓ Add Private Subnet's in 2 AZ, Route Tables and Routes\
✓ Add NAT Gateway and ElasticIP per-AZ

---
### A little bug fixes
*Nov, 05*

*Next step: forming the Elastic Kubernetes Service module and future cluster.*

---
### Add 2 new modules
*Nov, 09*

✓ Add EKS (Elastic Kubernetes Service) module.\
✓ Add KMS (Key Management Service) module.

Small changes:
- IAM Role for Control Plane
- KMS Key for EKS etcd secrets encryption
- KMS Alias
- KMS Key Policy

---
*Nov, 18*

*I've decided to move away from Kubernetes and EKS for this project.*\
*Building a solid infrastructure with k8s in the cloud without enough experience was harder than I thought.*\
*I know Kubernetes fairly well, but working with it in AWS is different. Realized I was spending too much time for complexity.*\
*Don't regret a time though. I got deeper into k8s and learned how AWS services work. That experience will be useful in the future.*

*Now I'm redesigning the architecture for ECS + Fargate.*\
*Plans are not constant.*

✓ Add VERSION files to all modules and remove Git Tags\
✓ Move EKS module directory to [archived/](.archived/) \
✓ A little refactoring

---
*Nov, 22*

*I'm still working on the VPC module. Today I was added some new resources and outputs for them.*

✓ NACL Inbound HTTP for ALB redirecting HTTP > HTTPS\
✓ Flow Log and S3 Bucket for him\
✓ VPC Endpoint Gateway for S3 

*Next, I will move on to refactoring KMS (AWS Key Management Service).*

---
*Nov, 23*

*Today I'm rewrote the KMS module. Split module into **cloudwatch_logs_key.tf** and **secrets_manager_key.tf***

*I will continue to build this module as other modules are created.*

---
*Dec, 03*

*Last week I wasn't idle, I redesigned architecture to move to EFS.*\
*Sadly, the Immich app cannot save media content straight to S3 Bucket, so it needs shared storage, such as Elastic File Storage.*\
*I did not reject S3 Bucket, but now it does the role of the storage for backups EFS.*\
*Also, I created the Secrets Manager module. It's incomplete now, still working on it.*

---
*Dec, 04*

*Starting today I've been working on EFS module. The basic version is already ready!*

✓ Add EFS File System, Access Point, Mount Targets\
✓ Add KMS key for encryption\
✓ Variables, outputs

---
*Dec, 10*

*I refused the AWS Backup service because it does nt comply with my architecture and cost too expensive. The backup storage (S3) must be mirrored to the primary storage (EFS) and uptated every day.*

*Well, I added*

✓ DataSync module\
✓ S3 Bucket for backup storage, policies, encryption\
✓ IAM roles and policies\
✓ DataSync task, source & destination resources

*I will add restore tasks and SNS later*

---
*Dec, 14*

*Yesterday, I added **Restore Task** for the DataSync module. It's used in case of total destruction to copy backup data from S3 to a new primary EFS.*

*Today, I created the **Route53 Internal** module. Right now, it is full of placeholders, as not all modules are created yet. I added a record for monitoring for future use, but it's not being used yet. I'm still in process of determining the exact monitoring stack.*

---
*Dec, 17*

*Today I added RDS module I've been working on for last week. I also added the KMS Key for it.*

*Since today, I'll start working on ElastiCache Redis module.*

---
*Dec, 21*

*Today I worked on the **ElastiCache Redis** module.*\
*I created a **replication group, subnet group and SG**, and closed the placeholders with Redis SG in the ECS module and Route53 module.*

*My architecture contains **1 primary node** and **1 replica**.*\
*Only the **engine logs** type is enabled for logs because at the moment I dont see the need for more detailed logs.*

***Important:** the Immich architecture does not support TLS and password for Redis, so I had to reject them.*

---
*Dec, 28-30*

*Last week was very stressful, with a lot of work to be done. But in order:*

*1. The domain **immich.ronchese.pp.ua** was registered.*\
*2. Multi-Zone Application Load Balancer was configured.*\
*3. TLS/SSL Certificates were configured.*\
*4. Route53 Public Hosted Zone and a few records were added.*\
*After that, preparations began for the first full deploy.*

*I was surprised that deploy went well, for the most part. There were the following issues:*

*1. Missing CloudWatch Log Group for DataSync backup logs. It just so happened that I missed it. I created a quick fix.*\
*2. Supported Redis version and PostgreSQL parameters were fixed.*\
*3. Errors in the **Sid** IAM Policies fields in various modules were corrected.*\
*4. The Health Check block type for ECS Services was corrected.*

*There were two main issues, namely:*

*1. RDS Aurora enables SSL encryption by default. While analysing errors in logs and experimenting with setting the **rds.force_ssl** parameter, it became clear that Immich App does not support SSL for database. Accordingly, I had to **set the parameter to 0, disabling SSL***\
*2. The second problem was the incorrect transmission of the generated password for the database. The password was transmitted in JSON format with two field, username and password, instead of one.*\
*There Were also several minor fixes.*

*As a result, the infrastructure has been successfully deployed in the AWS Cloud, and appllication is available.*

*What`s next?*

*Work is far from complete.*\
*The first things to do is to refactor all the existing code, remove temporary placeholders, and replace deprecated resources and arguments.*\
*Next, I plan to create a specific monitoring stack.*

*There are many other plans, but I don`t want to talk about right now. More to come!*

*P.S. I will update project description soon and add the architectural diagram, which needs to be tidied up. I will get to it...in the next year.*

---
*Jan, 16*

*Update README, near-term plans, added architectural diagram (which, however, is not 100% complete).*

*No major changes yet.*\
*January was not without work; I am actively working on implementing CI/CD and automated testing.*

---
*Jan, 23*

*Today I added the first automated contract tests using Schemathesis + pyTest.Now there are a few tests, I'll add more in the next days.*

*I split the tests into endpoints groups and ran them independently. I was forced to do this because the OpenAPI Specification JSON is so complex (27k lines) and I don't have enough RAM to run them all. But it's opening a few more futures.*\
*Fisrt, I can run every contract separately, which is quite comfortable for debugging.*\
*Second, I moved some logic to the conftest file to avoid code duplication.*

*There was some problems in Immich design. Production environment doesn't give OpenAPi JSON file, it's only available in dev env. This cannot be configured anyway, so there is nothing I can do. I took the openapi.json from dev container and it almost corectly works with prod env. Yes, not perfect idea, but at least it is working.*

*I also plan to add functional tests, which are make CRUD operationson endpoints to ensure that functionality is working. Most likely, I'll use requests library.*

---
*Jan, 24*

*I have completed the contract tests and added almost all endpoints. Some endpoints incorrectly processed by the server and do not meet the specification. So, I excluded them.*

*All that's left is to write functional CRUD tests.*


---
*Jan, 26*

*Today I wrote basic functional tests. Not many because of lack of time. Tomorrow I'll complete TestAlbumCRUD and continue writing tests.*

*Briefly about the solution:*

*I decided to use **requests + pytest**, ideally combination for my case.
**api_client.py** contains all HTTP method's. You can put all request arguments you need after the endpoint.*\
***validators,py** contains two function-validator to avoid code duplication. Their names answer the question what they do. In **check_list_response()** you can change **min_length** argument, default - 0.*\
*In **conftest.py** are located pytest fixtures. It almost the same as conftest.py in contract/, without unused fixtures.*

---
*Jan, 27*

*Completed test_album.py, fixed some bugs. Nothing new.*

---
*Jan, 29*

*Added tests for /assets.*

*The Immich API doesn't support bulk operations for GET, POST, UPDATE, so I discarded them.*

*Still having a lack of time, that's why tempo of writing tests is so slow.*