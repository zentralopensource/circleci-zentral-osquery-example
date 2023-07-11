resource "zentral_osquery_query" "santa_sysext_check" {
  name = "Santa Sysext Check"
  sql = trimspace(
    <<-EOQ
    WITH expected_sysexts(team, identifier, version) AS (
      VALUES ('EQHXZ8M8AV', 'com.google.santa.daemon', '2023.5')
    ) SELECT expected_sysexts.*,
    CASE WHEN system_extensions.uuid IS NOT NULL THEN 'OK' ELSE 'FAILED' END ztl_status
    FROM expected_sysexts
    LEFT JOIN system_extensions ON (
      system_extensions.team = expected_sysexts.team
      AND system_extensions.identifier = expected_sysexts.identifier
      AND system_extensions.version >= expected_sysexts.version
      AND system_extensions.state = 'activated_enabled'
    )
    EOQ
  )
  platforms                = ["darwin"]
  description              = "Compliance check for the latest Santa version"
  compliance_check_enabled = true
  scheduling = {
    interval            = 120
    log_removed_actions = false
    pack_id             = zentral_osquery_pack.first_pack.id
    snapshot_mode       = true
  }
}

resource "zentral_osquery_query" "mdm_managed_tcc" {
  name = "MDM managed TCC"
  sql = trimspace(
    <<-EOQ
    SELECT plist.* FROM plist
    WHERE path = '/Library/Application Support/com.apple.TCC/MDMOverrides.plist'
    EOQ
  )
  platforms = ["darwin"]
}
