param location string
param appInsightsName string

resource applicationInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output instrumentationKey string = applicationInsight.properties.InstrumentationKey
