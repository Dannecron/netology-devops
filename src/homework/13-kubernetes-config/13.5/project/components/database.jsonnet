local p = import '../params.libsonnet';
local params = p.components.database;

[
  {
    "apiVersion": "v1",
    "kind": "ConfigMap",
    "metadata": {
      "name": "postgres-config",
      "labels": {
        "app": "postgres"
      }
    },
    "data": {
      "POSTGRES_DB": "news",
      "POSTGRES_USER": "db_user",
      "POSTGRES_PASSWORD": "db_passwd",
      "PGDATA": "/var/lib/postgresql/data"
    }
  },
  {
    "apiVersion": "v1",
    "kind": "PersistentVolume",
    "metadata": {
      "name": params.pvName,
      "labels": {
        "type": "local",
        "app": "postgres"
      }
    },
    "spec": {
      "storageClassName": "manual",
      "capacity": {
        "storage": "1Gi"
      },
      "accessModes": [
        "ReadWriteMany"
      ],
      "hostPath": {
        "path": params.pvPath
      }
    }
  },
  {
    "apiVersion": "v1",
    "kind": "PersistentVolumeClaim",
    "metadata": {
      "name": "postgres-pv-claim",
      "labels": {
        "app": "postgres"
      }
    },
    "spec": {
      "storageClassName": "manual",
      "accessModes": [
        "ReadWriteMany"
      ],
      "resources": {
        "requests": {
          "storage": "1Gi"
        }
      }
    }
  },
  {
    "apiVersion": "apps/v1",
    "kind": "StatefulSet",
    "metadata": {
      "labels": {
        "app": "app",
        "service": "database",
        "db-kind": "postgresql"
      },
      "name": "db",
    },
    "spec": {
      "selector": {
        "matchLabels": {
          "app": "app",
          "service": "database",
          "db-kind": "postgresql"
        }
      },
      "serviceName": "postgres",
      "replicas": 1,
      "podManagementPolicy": "Parallel",
      "updateStrategy": {
        "type": "RollingUpdate"
      },
      "template": {
        "metadata": {
          "labels": {
            "app": "app",
            "service": "database",
            "db-kind": "postgresql"
          }
        },
        "spec": {
          "terminationGracePeriodSeconds": 60,
          "containers": [
            {
              "name": "postgres",
              "image": "postgres:13-alpine",
              "imagePullPolicy": "IfNotPresent",
              "ports": [
                {
                  "name": "postgresql",
                  "containerPort": 5432,
                  "protocol": "TCP"
                }
              ],
              "envFrom": [
                {
                  "configMapRef": {
                    "name": "postgres-config"
                  }
                }
              ],
              "volumeMounts": [
                {
                  "mountPath": "/var/lib/postgresql/data",
                  "name": "postgredb"
                }
              ]
            }
          ],
          "volumes": [
            {
              "name": "postgredb",
              "persistentVolumeClaim": {
                "claimName": "postgres-pv-claim"
              }
            }
          ]
        }
      }
    }
  },
  {
    "apiVersion": "v1",
    "kind": "Service",
    "metadata": {
      "name": "postgres"
    },
    "spec": {
      "type": "ClusterIP",
      "clusterIP": "None",
      "ports": [
        {
          "name": "postgresql",
          "port": 5432,
          "targetPort": "postgresql",
          "protocol": "TCP"
        }
      ],
      "selector": {
        "service": "database",
        "db-kind": "postgresql"
      }
    }
  }
]
