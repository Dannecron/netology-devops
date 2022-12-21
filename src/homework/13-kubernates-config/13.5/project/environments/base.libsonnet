
// this file has the baseline default parameters
{
  components: {
    backend: {
      replicas: 1
    },
    frontend: {
      replicas: 1
    },
    database: {
      "pvName": "postgres-pv",
      "pvPath": "/mnt/postgres/data"
    },
  },
}
