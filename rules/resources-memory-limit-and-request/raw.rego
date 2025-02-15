package armo_builtins


# Fails if pod doas not have container with memory-limit or request
deny[msga] {
    pod := input[_]
    pod.kind == "Pod"
    container := pod.spec.containers[i]
	not request_or_limit_memory(container)
	fixPaths := [{"path": sprintf("spec.containers[%v].resources.limits.memory", [format_int(i, 10)]), "value": "YOUR_VALUE"}, 
				{"path": sprintf("spec.containers[%v].resources.requests.memory", [format_int(i, 10)]), "value": "YOUR_VALUE"}]

	msga := {
		"alertMessage": sprintf("Container: %v does not have memory-limit or request", [ container.name]),
		"packagename": "armo_builtins",
		"alertScore": 7,
		"fixPaths": fixPaths,
		"failedPaths": [],
		"alertObject": {
			"k8sApiObjects": [pod]
		}
	}
}

# Fails if workload doas not have container with memory-limit or request
deny[msga] {
    wl := input[_]
	spec_template_spec_patterns := {"Deployment","ReplicaSet","DaemonSet","StatefulSet","Job"}
	spec_template_spec_patterns[wl.kind]
    container := wl.spec.template.spec.containers[i]
    not request_or_limit_memory(container)
	fixPaths := [{"path": sprintf("spec.containers[%v].resources.limits.memory", [format_int(i, 10)]), "value": "YOUR_VALUE"}, 
				{"path": sprintf("spec.containers[%v].resources.requests.memory", [format_int(i, 10)]), "value": "YOUR_VALUE"}]

	msga := {
		"alertMessage": sprintf("Container: %v in %v: %v   does not have memory-limit or request", [ container.name, wl.kind, wl.metadata.name]),
		"packagename": "armo_builtins",
		"alertScore": 7,
		"fixPaths": fixPaths,
		"failedPaths": [],
		"alertObject": {
			"k8sApiObjects": [wl]
		}
	}
}

# Fails if cronjob doas not have container with memory-limit or request
deny[msga] {
  	wl := input[_]
	wl.kind == "CronJob"
	container = wl.spec.jobTemplate.spec.template.spec.containers[i]
    not request_or_limit_memory(container)
	fixPaths := [{"path": sprintf("spec.containers[%v].resources.limits.memory", [format_int(i, 10)]), "value": "YOUR_VALUE"}, 
				{"path": sprintf("spec.containers[%v].resources.requests.memory", [format_int(i, 10)]), "value": "YOUR_VALUE"}]

    msga := {
		"alertMessage": sprintf("Container: %v in %v: %v   does not have memory-limit or request", [ container.name, wl.kind, wl.metadata.name]),
		"packagename": "armo_builtins",
		"alertScore": 7,
		"fixPaths": fixPaths,
		"failedPaths": [],
		"alertObject": {
			"k8sApiObjects": [wl]
		}
	}
}

request_or_limit_memory(container) {
	container.resources.limits.memory
	container.resources.requests.memory
}
