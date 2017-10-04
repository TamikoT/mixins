// apiVersion: 0.1
// name: io.ksonnet.pkg.nginx-server-block
// description: NGINX (pronounced "engine-x") is an open source reverse proxy server for HTTP,
// HTTPS, SMTP, POP3, and IMAP protocols, as well as a load balancer, HTTP
// cache, and a web server (origin server).
//
// 'Server Blocks' are the NGINX equivalent of Apache vhosts (VirtualHosts) used host multiple domains with one server. You can configure a custom Server
// Block with this prototype.
//
// @param namespace string Namespace in which to put the application
// @param name string Name to give to all components.
// @param labels string Labels for deployment, defaults to {app: param_Name}.
// @param selector string Selector for service, defaults to {app: param_Name}.
//
// TODO: This may be unclear to user for what Name points. Talk about it?
// TODO: How should the ServerBlockConf be exposed to the user? Not quite sure what the default does except for setting web server to port 80.


local k = import 'ksonnet.beta.2/k.libsonnet';
local nginx = import 'incubator/nginx/nginx.libsonnet';

local namespace = "import 'param://namespace'";
local appName = "import 'param://name'";

k.core.v1.list.new([
  nginx.parts.deployment.withServerBlock(namespace, appName),
  nginx.parts.service(namespace, appName),
  nginx.parts.serverBlockConfigMap(namespace, appName),
])
