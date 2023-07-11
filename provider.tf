terraform {
  required_providers {
    zentral = {
      source = "zentralopensource/zentral"
    }
  }
}

provider "zentral" {
  # URL where the API endpoints are mounted in the Zentral deployment.
  # The ZTL_API_BASE_URL environment variable can be used instead.
  # base_url = "https://zentral.example.com/api/"

  # Zentral service account (better) or user API token.
  # This is a secret, it must be managed using a variable.
  # The ZTL_API_TOKEN environment variable can be used instead.
  # token = var.api_token
}
