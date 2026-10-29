{{/*
Expand the name of the chart.
*/}}
{{- define "visa-k8s-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the namespace for the controller deployment.
*/}}
{{- define "visa-k8s-controller.namespace" -}}
{{- default .Release.Namespace .Values.controller.namespace -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "visa-k8s-controller.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "visa-k8s-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "visa-k8s-controller.labels" -}}
helm.sh/chart: {{ include "visa-k8s-controller.chart" . }}
{{ include "visa-k8s-controller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "visa-k8s-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "visa-k8s-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "visa-k8s-controller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "visa-k8s-controller.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Expand the name of the web cloud provider.
*/}}
{{- define "visa-k8s-web-cloud-provider.name" -}}
{{- default "visa-k8s-web-cloud-provider" .Values.webCloudProvider.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the namespace for the web cloud provider deployment.
*/}}
{{- define "visa-k8s-web-cloud-provider.namespace" -}}
{{- default .Release.Namespace .Values.webCloudProvider.namespace -}}
{{- end }}

{{/*
Create a default fully qualified app name for the web cloud provider.
*/}}
{{- define "visa-k8s-web-cloud-provider.fullname" -}}
{{- if .Values.webCloudProvider.fullnameOverride }}
{{- .Values.webCloudProvider.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "web-cloud-provider" .Values.webCloudProvider.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels for web cloud provider
*/}}
{{- define "visa-k8s-web-cloud-provider.labels" -}}
helm.sh/chart: {{ include "visa-k8s-controller.chart" . }}
{{ include "visa-k8s-web-cloud-provider.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for web cloud provider
*/}}
{{- define "visa-k8s-web-cloud-provider.selectorLabels" -}}
app.kubernetes.io/name: {{ include "visa-k8s-web-cloud-provider.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use for web cloud provider
*/}}
{{- define "visa-k8s-web-cloud-provider.serviceAccountName" -}}
{{- if .Values.webCloudProvider.serviceAccount.create }}
{{- default (include "visa-k8s-web-cloud-provider.fullname" .) .Values.webCloudProvider.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.webCloudProvider.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the ConfigMap name for the web cloud provider
*/}}
{{- define "visa-k8s-web-cloud-provider.configMapName" -}}
{{- if .Values.webCloudProvider.existingConfigMap }}
{{- .Values.webCloudProvider.existingConfigMap }}
{{- else }}
{{- printf "%s-config" (include "visa-k8s-web-cloud-provider.fullname" .) }}
{{- end }}
{{- end }}
