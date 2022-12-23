{{/*
Dynamic hostpath for database PV
*/}}
{{- define "project.database.pv.hostpath" -}}
{{- print .Values.database.hostVolumePath "/" .Release.Namespace "/" .Values.environment }}
{{- end }}
