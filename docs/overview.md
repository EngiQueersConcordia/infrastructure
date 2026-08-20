# Physical Nodes

## Jenny
Self-operated server in B annex. Storage node and large compute node.

- Model: PowerEdge R720xd
- CPU: 80 cores @ 3.30 GHz (2 x Intel® Xeon® E5-2670 v2 (40))
- Memory: 125.80 GiB (8 x Samsung 16GB DDR3-1600MHz ECC Registered RDIMM)
- Disk: 931 GiB RAID 1 (2 x WD Blue SA510 2.5 1000GB)

## ENA
OVH operated VPS. Mainly used to traverse the concordia network. Also runs a handful of workloads on occasion.

- Model: VPS-1 2026 
- CPU: 4 cores @ 3.10 GHz
- Memory: 7.55 GiB
- Disk: 75 GiB


# Software

## Core software
This software forms the bedrock of our infrastructure upon which everything else sits.


### Talos Linux
Specialized linux distribution for running k8s (Kubernetes). Heavily locked down for security reasons and can only run
things inside containers aka pods in k8s terminology (including virtual machines).


### Wireguard
One of the very few workloads that don't run inside a container but directly on the host system. Sets up a secure VPN
connection between ENA and Jenny for internal network traffic. See vpn_net.md for details.


### Kubernetes
Multi-machine clustered general purpose code execution platform. Manages all workloads running on the cluster, ensuring
they can connect to each other, access storage, be terminated if there's a problem, etc. Basically acts as a proxy to
the OS while allowing for advanced management of running workloads.

While we do have a significant amount of control over k8s, it is partly managed by talos linux for us.

Subcomponents:
- etcd (Database used by k8s to keep track of things)
- apiserver (Web API we use to control k8s)
- scheduler (Schedules pods onto nodes)
- controller-manager (Runs automatic background system tasks such as restarting failed pods)
- kubelet (Allows k8s to control a node)
- coredns (Provides an internal DNS server for workloads to find each other)


### Local CCM
Ensures that whenever a node is registered into k8s, its internal and external IP are auto-discovered and entered into
k8s.


### Cilium
CNI plugin. Core workload that provides networking for all other workloads. Handles both internal traffic 
(pod-to-pod) and external traffic (pod-to-world or world-to-pod). Also enforces firewall rules to isolate pods from 
each other (i.e., the minecraft server shouldn't be allowed to talk to the authentication database).

Hubble is a subcomponent of cilium and enables us to have visibility into the network traffic. It records metadata 
about all connections to help debug and monitor traffic flow.


### Kubelet Serving Certificate Approver
Because we trust all of our nodes, we can use this tool to automatically approve their internal certificate requests.
This means we don't have to manually accept the certificate renewals and helps us towards our goal of having the 
cluster automatically heal itself when an issue arises.


### Descheduler
A basic periodic job that runs every 5 minutes and finds failed pods that should be deleted. They're usually 
kept around by k8s for debugging purposes to analyze failures, but for the sake of having the cluster auto heal from 
failures, we delete them automatically after 15 minutes.

A secondary purpose of the descheduler is to move around pods if one node is overloaded (usually ENA when Jenny 
reboots for updates because all services try to migrate over to ENA and overwhelm the node).


## Support software
This software does nothing on its own but helps other software run by providing services intended for internal use.


### Sealed Secrets
Because all of our config files are public on codeberg (GitHub alternative), we need to be able to store credentials 
somehow. Sealed secrets allow us to encrypt all our credentials with a private key only stored on the cluster. They 
are automatically decrypted on the cluster for use by the system.


### Cert Manager
This tool automates TLS certificate renewal via LetsEncrypt. It is the k8s equivalent to certbot. It is also able to 
generate self-signed certificates for internal use.

As we use OVH to host our public DNS records, Cert Manager Webhook OVH acts as a bridge for Cert Manager to complete 
automated DNS validation to issue us certifications.


### KubeVirt
KubeVirt is a system to be able to run virtual machines on k8s. These VMs run inside pods like any other workload 
but otherwise do act as fully fledged virtual machines. For operational and security reasons, virtual machines are 
not ideal for us, and I would like to eventually remove KubeVirt from our cluster. Currently only used to run Juan's 
Vivado VM.

CDI is a subcomponent of KubeVirt and acts as a bridge between the storage format for KubeVirt and the storage 
format in use by k8s/openebs.


### OpenEBS
OpenEBS is the storage manager we use. By default, all pods on k8s use ephemeral storage, which means that all data 
is lost when the pod is destroyed. To be able to store data persistently, a storage manager is required to allocate 
and maintain persistent volumes. While OpenEBS supports replicated storage across many nodes, we have it configured 
in local-only mode on Jenny, so all of our data resides on the server in the B-annex; there isn't enough total 
storage space available on ENA for it to be worth doing anything else. All volumes are isolated and have a max size 
limit to ensure system stability.


### Minecraft Ingress
This workload acts as a proxy to other minecraft servers and allows us to serve multiple minecraft servers on the 
same IP and port so users can connect either to minecraft-a.engiqueersconcordia.ca or 
minecraft-b.engiqueersconcordia.ca without needing to worry about ports and such. Connections are forwarded to the 
backend server through the PROXY protocol to preserve the IP address of the player (enabling us to IP ban users if 
needed).


### Cloud Native PostgreSQL
This tool enables us to quickly deploy PostgreSQL databases through the use of a custom k8s resource type instead of 
having to manually configure a new database each time we need one.


### RustFS
Originally deployed for storing monitoring logs (ended up not using it for that), RustFS is an S3-compatible storage 
solution entirely self-hosted on our own infrastructure. Candidate for removal as it is not currently being used for 
anything.


### Authentik
Authentik is a self-hosted authentication and authorization solution. We use it to have a single username for all of 
our self-hosted infrastructure. While configured to only allow logging in via passkeys, I am considering enabling 
the use of Google accounts to log in due to usability concerns with passkeys on certain device/browser combos.


## Deployment software
This is software that helps us turn a git repository into software actually running on our cluster


### ArgoCD
ArgoCD is a standard tool that monitors one or more git repositories for k8s manifests and automatically handles the 
deployment of such manifest files. The idea here is that because we use git to store all k8s manifests, our cluster 
configuration is automatically "backed up" in git. Also, because everything is in git, there's no forgotten about 
config files left on the cluster, as if a manifest is deleted from git, ArgoCD will delete it from the cluster.


### Harbor
Self-hosted docker registry. Lets us store docker images on our infrastructure for deployment. Might replace it with 
the GitHub hosted registry as self-hosting our own docker registry causes issues; for example, when jenny goes down 
for reboots, k8s tries to move the website to ENA, but fails as the docker image is stored on jenny, which is down for 
reboots.


## Application software
This is software that serves a direct purpose intended for use by human beings.


### Headlamp
Graphical web interface to visualize, explore and modify k8s resources instead of using command line tools.


### Website
Workload powering the website at engiqueersconcordia.ca. Currently, it is a static scrape of our previous WordPress 
site hosted at engiqueers.ecaconcordia.ca. There are unrealized vague plans to develop a new website to replace the 
current one. 


### Redbot
Our instance of the Discord Red Bot framework. It is the bot running the EngiQueers Concordia Discord bot in our 
primary Discord server. Currently, it has no commands enabled, but we will be able to easily add new ones if/when 
needed. 


### Xonotic
An instance of a free open source Quake-like first-person arena shooter. It is accessible at xonotic.
engiqueersconcordia.ca via 
the xonotic game client. 


### Juan Vivado VM
This VM is a left-over from the previous proxmox based infrastructure where Juan set up a virtual machine containing 
Vivado for his, at the time, personal use with plans to open up access to others at a future date. For the sake of 
continuity, the VM has been ported over to the new infrastructure. However, this should be considered to be an 
exception, and in the future I would like to avoid allocating virtual machines to individuals due to performance and
management challenges associated with virtualized workloads compared to standard containerized workloads. I am 
considering putting in the work to migrate this virtual machine into a normal container to get rid of the VM and of 
KubeVirt.


## Monitoring software
This software is used to both ensure the stability of our infrastructure in the event of technical failures and to 
monitor untrusted workloads we may run on behalf of our members or other parties.


### Loki
Loki is a log ingestion, storage and indexing system. All of our logs are forwarded into Loki for future analysis 
when needed. Currently, we have no maximal log retention period, but we should probably set one eventually after 
analyzing the quantity of produced logs.  

Alloy is a subcomponent of Loki that acts as the ingestion point; it connects to k8s to monitor the logs of all pods 
for ingestion into Loki, it also configures the labels for each log message to help Loki with indexing.


### Metrics server
This component exposes through an API performance metrics collected by k8s for consumption by other monitoring 
services. It is used by Prometheus to collect performance data and by the descheduler to detect heavy resource 
utilization to balance the load between nodes.


### Prometheus
Prometheus is a time series metric collection and storage system; it keeps track of numerical values over time such 
as, for example, memory usage of a pod.

It has several "exporter" subcomponents which monitor various things about the cluster and its nodes.


### Alert Manager
Alert Manager continually monitors Prometheus metrics and evaluates them against a list of rules. If any rule is 
triggered, a message is sent to the Discord #serverbus channel for manual review. The goal here is to not let the 
system fail without anyone knowing about it; whenever a problem happens which cannot be self-healed, someone should 
be informed of what happened and sometimes how to fix it. For example, if we ever run out of storage space, a rule 
will detect the situation and trigger a notification so that we may review what is taking up space and clear it.


### Grafana
Grafana is a general-purpose dashboard for data visualization. Currently, we use it to graph out Prometheus metrics 
over time and display Loki logs.


# Networking
Networking is generally handled by cilium to give us a flat virtual network where everything can talk to everything 
internally (provided that firewall rules permit it). Cilium also ensures that if an incoming connection to ENA wants 
to talk to a pod running on Jenny, the connection will be internally forwarded to Jenny through the Concordia network.

To be able to communicate between ENA and Jenny through the Concordia NAT'd network, a Wireguard tunnel is 
established between the two machines. Manual static routes have been configured to enable routing from one node to 
the other via that tunnel. All internal k8s components also communicate over that tunnel. 