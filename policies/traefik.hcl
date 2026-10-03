path "platform/data/traefik/*" {
  capabilities = ["read"]
}

path "platform/data/shared/crowdsec-bouncer" {
  capabilities = ["read"]
}

path "platform/data/shared/ui-basic-auth" {
  capabilities = ["read"]
}
