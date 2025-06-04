provider "azurerm" {
  features {}
  subscription_id = "xxxxxxxxxxxxxxxxxxxxxxxxx" # Can be passed via `-backend-config=`"subscription_id=<subscription id>"` in the `init` command.
  # subscription_id =  "ddd80bb1-e975-46a2-8031-350d0703129f" # Can be passed via `-backend-config=`"subscription_id=<subscription id>"` in the `init` command.

}