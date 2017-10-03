local k = import 'ksonnet.beta.2/k.libsonnet';
local nginx = import '../nginx.libsonnet';

local namespace = "dev-alex";
local appName = "nginx-app";

k.core.v1.list.new([
  nginx.parts.deployment.hasVhost(namespace, appName),
  nginx.parts.service(namespace, appName),
  nginx.parts.vhost(namespace, appName)
])
