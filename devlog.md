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
