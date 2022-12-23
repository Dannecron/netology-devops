
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    backend: {
      replicas: 3,
    },
    frontend: {
      replicas: 3,
    },
    database: {
      "pvName": "postgres-pv-production",
      "pvPath": "/mnt/postgres/production/data"
    },
  }
}
