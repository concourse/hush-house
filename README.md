CONCOURSE HUSH-HOUSE

> A hush house is an enclosed, noise-suppressed facility used for testing aircraft systems,
> including propulsion, mechanics, electronics, pneumatics, and others.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg/512px-EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg)

```
WHY

        - To have a Concourse deployment on top of k8s where the team can experiment and load-test
        Concourse itself in a controlled manner, without affecting the lives of those who are
        being the CI pair of the day and/or deploying code through Prod and expecting things to
        work.

        - So that people can break things without affecting others

        - So that k8s can become a first class thing in our development cycle

        - Exercise more the helm chart


K8S CHEAT SHEET
        Contexts
                These are the equivalent of Concourse `target`s, storing auth, API endpoint,
                and namespace information in each of them.

                Get the current context

                        kubectl config current-context

                Change something in a context

                        kubectl config set-context $context $something_to_change

                Set the context to use

                        kubectl config use-context $context

        Namespace
                A virtual segregation between resources in a single cluster.

		The namespace to target is supplied via the `--namespace` flag, or having
		a default namespace set to the context.

			kubectl config set-context $context --namespace=$namespace


        Checking server and client version

                kubectl version

                ps.: it's fine to diverge 2 minors.


        Listing worker nodes

                kubectl get nodes --namespace=$NS
                kubectl describe nodes --namespace=$NS


K8S ARCHITECTURE

        kube-proxy
                - Routes network traffic to load-balanced *services* in the k8s cluster.
                - Must be present on every node in the cluster (thus, deployed as daemon
                  set).


        kube-dns
                - Provides naming and discovery for the services defined in the cluster.
                - The kubelet passes DNS to each container with the --cluster-dns=<dns-service-ip> flag.




TODO
	METRICS:
		- we should probably make use of `kubernetes-pod` as a way
		  of scraping metrics, instead of `k8s-service-endpoint` in
		  our helm chart.

	GENERAL:
		- how to give all resources of a node to a pod?
			nodeSelector?
		- what are tolerations?
		- how to grow the filesystem associated w/ concourse?
		- make use of SIGUSR1 and SIGUSR2  (https://github.com/concourse/concourse-bosh-release/commit/a3ebf6a292fd8cc79a9ae0dcc7088ae1d5018514)
		  for worker shutdown?
		- what does READY and LIVE mean?
			WEB:
				- READY:
					* atc can take simple requests
						* implicitly verifies if it has working
						  connections with the DB
						* implicitly verifies that the process can take
						  incoming connections.

				- LIVE:
					* the process is up and can take incoming requests

			WORKER:
				- READY:
					* the process is up
					* garden & baggageclaim responds
					* garden can create a simple container
					* baggageclaim can create a simple volume

				- LIVE:
					* the process is up and able to respond to
					  requests.
					* garden responds
					* baggageclaim responds
```
