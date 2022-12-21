local p = import '../params.libsonnet';
local params = p.components.frontend;

[
  {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "labels": {
        "app": "app",
        "service": "frontend"
      },
      "name": "frontend",
    },
    "spec": {
      "replicas": params.replicas,
      "selector": {
        "matchLabels": {
          "app": "app",
          "service": "frontend"
        }
      },
      "template": {
        "metadata": {
          "labels": {
            "app": "app",
            "service": "frontend"
          }
        },
        "spec": {
          "containers": [
            {
              "image": "dannecron/netology-devops-k8s-app:frontend-latest",
              "imagePullPolicy": "Always",
              "name": "netology-frontend",
              "env": [
                {
                  "name": "BASE_URL",
                  "value": "http://backend:9000"
                }
              ],
              "ports": [
                {
                  "name": "web",
                  "containerPort": 80
                }
              ]
            }
          ],
          "terminationGracePeriodSeconds": 30
        }
      }
    }
  },
  {
    "apiVersion": "v1",
    "kind": "Service",
    "metadata": {
      "name": "frontend"
    },
    "spec": {
      "ports": [
        {
          "name": "web",
          "port": 80
        }
      ],
      "selector": {
        "app": "app",
        "service": "frontend"
      }
    }
  }
]
