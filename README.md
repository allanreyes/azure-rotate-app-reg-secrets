# Automated App Registration Secret Rotation that synchronizes with Azure Key Vault

This Function App manages app registration secrets in Entra ID and regularly rotates secrets while storing them in Azure Key Vault

## Overview

This Function App provides a solution for managing secrets associated with Azure app registrations securely. It leverages Azure Key Vault for storing secrets and implements automatic rotation of secrets based on a configurable rotation schedule.

## Features

- **Secret Rotation**: Automatically rotates secrets for app registrations stored in Key Vault based on a predefined schedule.
- **Integration with Azure Key Vault**: Leverages Azure Key Vault for secure storage and management of secrets.
- **Configurable Rotation Schedule**: Allows customization of the rotation frequency to align with specific security requirements.
- **Logging and Monitoring**: Provides comprehensive logging and monitoring capabilities for auditing and tracking secret rotation activities.

## Architecture

The Function App is built using Azure Functions, providing serverless compute to handle secret rotation tasks efficiently. It interacts with Azure Key Vault to retrieve and update secrets securely. The rotation schedule is configurable and can be adjusted as needed.

## Usage

### Prerequisites

- Azure Subscription
- Azure Key Vault
- Azure Function App

### Configuration

1. **Azure Key Vault Setup**: Create an Azure Key Vault instance and store the app registration secrets securely.
2. **Function App Configuration**: Configure the Function App with appropriate permissions to access Key Vault secrets.
3. **Secret Rotation Schedule**: Define the rotation schedule in the Function App settings or environment variables.

### Deployment

Deploy the Function App to Azure using your preferred deployment method, such as Azure CLI, Azure Portal, or Azure DevOps.

### Monitoring

Monitor the Function App's execution and logs to ensure successful rotation of secrets. Utilize Azure Monitor for comprehensive monitoring and alerting capabilities.

## Contribution

Contributions to enhance the functionality, improve performance, or fix issues are welcome. Please submit pull requests or open issues for any suggestions or bug reports.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgements

- Special thanks to 

