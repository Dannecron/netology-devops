local p = import '../params.libsonnet';
local params = p.components.backend;

[
  {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "labels": {
        "app": "app",
        "service": "backend"
      },
      "name": "backend",
    },
    "spec": {
      "replicas": params.replicas,
      "selector": {
        "matchLabels": {
          "app": "app",
          "service": "backend"
        }
      },
      "template": {
        "metadata": {
          "labels": {
            "app": "app",
            "service": "backend"
          }
        },
        "spec": {
          "containers": [
            {
              "image": "dannecron/netology-devops-k8s-app:backend-latest",
              "imagePullPolicy": "Always",
              "name": "netology-backend",
              "env": [
                {
                  "name": "DATABASE_URL",
                  "value": "postgresql://db_user:db_passwd@postgres:5432/news"
                }
              ],
              "ports": [
                {
                  "name": "web",
                  "containerPort": 9000
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
      "name": "backend",
    },
    "spec": {
      "ports": [
        {
          "name": "web",
          "port": 9000
        }
      ],
      "selector": {
        "app": "app",
        "service": "backend"
      }
    }
  }
]
