
### Description
Getting latest release version from terraform-azurerm-provider changelog and send description to teams-channel via webhook script

### Variables
| Name              | Description                                                                          |
|-------------------|--------------------------------------------------------------------------------------|
| REPO              | The Owner/Name Of Repository like ansible/ansible-runner, kubernetes/kubernetes etc. |
| TEAMS_URL         | The URL of the Teams incoming webhook                                                |
| LAST_RELEASE_FILE | The file to store the last release tag                                               |

### Webhook Output Example
![alt text](https://github.com/Ihar-Ratner/changelog-webhook/blob/main/webhook.example.jpg?raw=true)
