package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// Runtime version info
	moduleVersion!: string
	kubeVersion!:   string

	// Metadata (common to all resources)
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}
	metadata: labels: "toolkit.fluxcd.io/tenant": metadata.name

	fluxServiceAccount: string | *"flux"

	role: "namespace-admin" | "cluster-admin" | *"namespace-admin"

	resourceQuota: {
		kustomizations: int | *100
		helmreleases:   int | *100
	}

	imagePullSecrets?: [...#PullSecretSpec]
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	imagePullSecrets: [for i, spec in config.imagePullSecrets {#PullSecret & {#config: config, #spec: spec}}]

	objects: {
		namespace: #Namespace & {#config: config}
		serviceAccount: #ServiceAccount & {#config: config, #imagePullSecrets: [for i in imagePullSecrets {{name: i.metadata.name}}]}
		roleBinding: #NamespaceAdmin & {#config: config}
		resourcequota: #ResourceQuota & {#config: config}
	}

	if config.role == "cluster-admin" {
		objects: clusterRoleBinding: #ClusterAdmin & {#config: config}
	}

	if imagePullSecrets != _|_ {
		objects: {for i in imagePullSecrets {"\(i.#spec.name)": i}}
	}
}
