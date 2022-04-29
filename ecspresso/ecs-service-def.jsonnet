{
  deploymentConfiguration: {
    deploymentCircuitBreaker: {
      enable: false,
      rollback: false,
    },
    maximumPercent: 200,
    minimumHealthyPercent: 100,
  },
  desiredCount: 1,
  enableECSManagedTags: false,
  launchType: 'FARGATE',
  networkConfiguration: {
    awsvpcConfiguration: {
      assignPublicIp: 'ENABLED',
      securityGroups: [
        '{{ tfstate `aws_security_group.ecs.id` }}',
      ],
      subnets: [
        'subnet-0899f7e0d49b472de',
      ],
    },
  },
  placementConstraints: [],
  placementStrategy: [],
  platformVersion: 'LATEST',
  schedulingStrategy: 'REPLICA',
  serviceRegistries: [],
  enableExecuteCommand: true,
}
