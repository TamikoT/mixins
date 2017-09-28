local k = import 'ksonnet.beta.2/k.libsonnet';

{
  parts:: {
    pbd(namespace, name):: {
      local defaults = {
        pdbMinAvailable: 3,
      },

      apiVersion: "policy/v1beta1",
      kind: "PodDisruptionBudget",
      metadata: {
        namespace: namespace,
        name: name,
      },
      spec: {
        selector: {
          matchLabels: {
            app: name
          },
        },
        minAvailable: defaults.pdbMinAvailable,
      },
    },

    statefulset(name, namespace, labels={app:name}, antiAffinity="hard"):: {
      local defaults = {
        replicaCount: 3,
        resources: {
          requests: {
            memory: "64Mi",
            cpu: "50m",
          },
        },
        image: "memcached:1.4.36-alpine",
        imagePullPolicy: "IfNotPresent",
        // imagePullPolicy: change to "Always" if the imageTag is "latest"
        memcached: {
          maxItemMemory: 64,
          verbosity: "v",
          extendedOptions: "modern",
        },
      },

      apiVersion: "apps/v1beta1",
      kind: "StatefulSet",
      metadata: {
        namespace: namespace,
        name: name,
        labels: labels,
      },
      spec: {
        serviceName: name,
        replicas: defaults.replicaCount,
        template: {
          metadata: {
            labels: labels
          },
          spec: {
            affinity: {
              podAntiAffinity:
                if antiAffinity == "hard" then {
                  requiredDuringSchedulingIgnoredDuringExecution: [
                    {
                      topologyKey: "kubernetes.io/hostname",
                      labelSelector: { matchLabels: labels },
                    },
                  ],
                } else if antiAffinity == "soft" then {
                  preferredDuringSchedulingIgnoredDuringExecution: [
                    {
                      weight: 5,
                      podAffinityTerm: [
                        {
                          topologyKey: "kubernetes.io/hostname",
                          labelSelector: { matchLabels: labels },
                        },
                      ],
                    },
                  ],
                } else {},
            },
            containers: [
              {
                name: name,
                image: defaults.image,
                imagePullPolicy: defaults.imagePullPolicy,
                command: [
                  "memcached",
                  "-m " + defaults.memcached.maxItemMemory ] +
                if "extendedOptions" in defaults.memcached
                then [ "-o", defaults.memcached.extendedOptions ] +
                if "verbosity" in defaults.memcached
                then [ defaults.memcached.verbosity ],
                ports: [
                  {
                    name: "memcache",
                    containerPort: "11211",
                  }
                ],
                livenessProbe: {
                  tcpSocket: { port: "memcache" },
                  initialDelaySeconds: 30,
                  timeoutSeconds: 5,
                },
                readinessProbe: {
                  tcpSocket: { port: "memcache" },
                  initialDelaySeconds: 5,
                  timeoutSeconds: 1,
                },
                resources: defaults.resources,
              },
            ],
          },
        },
      },
    },

    service(namespace, name, selector={app: name}):: {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        namespace: namespace,
        name: name,
        labels: { app: name },
      },
      spec: {
        clusterIP: "None",
        ports: [
          {
            name: "memcache",
            port: 11211,
            targetPort: "memcache"
          },
        ],
        selector: selector,
      },
    },
  },
}