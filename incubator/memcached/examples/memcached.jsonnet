local k = import 'ksonnet.beta.2/k.libsonnet';
local memcached = import '../memcached.libsonnet';

local myNamespace = "dev-alex";
local myName = "memcached";

k.core.v1.list.new([
  memcached.parts.pbd(myNamespace, myName),
  memcached.parts.statefulset(myNamespace, myName),
  memcached.parts.service(myNamespace, myName),
])