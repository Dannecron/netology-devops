
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    database: {
      "pvName": "postgres-pv-stage",
      "pvPath": "/mnt/postgres/stage/data"
    }
  }
}
