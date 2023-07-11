resource "zentral_osquery_configuration" "default" {
  name           = "Default"
  description    = "A simple configuration used for the CircleCI example"
  inventory_apps = true
}

resource "zentral_osquery_enrollment" "default" {
  configuration_id      = zentral_osquery_configuration.default.id
  meta_business_unit_id = zentral_meta_business_unit.default.id
}
