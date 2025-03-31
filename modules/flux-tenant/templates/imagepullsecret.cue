package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#PullSecretSpec: {
	name!:     string
	registry!: string
	username!: string
	password!: string
}

#PullSecret: timoniv1.#ImagePullSecret & {
	#config:   #Config
	#spec:     #PullSecretSpec
	#Meta:     #config.metadata
	#Suffix:   "-pull-\(#spec.name)"
	#Registry: #spec.registry
	#Username: #spec.username
	#Password: #spec.password
}
