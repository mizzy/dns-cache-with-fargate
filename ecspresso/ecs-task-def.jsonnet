{
  containerDefinitions: [
    {
      name: 'unbound',
      image: 'mizzy/unbound:latest',
      logConfiguration: {
        logDriver: 'awslogs',
        options: {
          'awslogs-group': '/ecs/test',
          'awslogs-region': 'ap-northeast-1',
          'awslogs-stream-prefix': 'unbound',
        },
      },
      environment: [
        {
          name: 'FORWARD_ADDR',
          value: '172.31.0.2', # Amazon Route 53 Resolver
        },
      ],
      command: [
        'sh',
        '-c',
        std.join(
          ';',
          [
            'echo nameserver 127.0.0.1 > /etc/resolv.conf',
            'echo search ap-northeast-1.compute.internal >> /etc/resolv.conf',
            '/unbound.sh',
          ]
        ),
      ],
      ulimits: [
        {
          name: 'nofile',
          softLimit: 8236,
          hardLimit: 8236,
        },
      ],
    },
    {
      name: 'nginx',
      essential: true,
      image: 'nginx:latest',
      logConfiguration: {
        logDriver: 'awslogs',
        options: {
          'awslogs-group': '/ecs/test',
          'awslogs-region': 'ap-northeast-1',
          'awslogs-stream-prefix': 'nginx',
        },
      },
    },
  ],
  cpu: '256',
  executionRoleArn: '{{ tfstate `aws_iam_role.ecs_task_execution_role.arn` }}',
  family: 'unbound-cache-test',
  memory: '512',
  networkMode: 'awsvpc',
  requiresCompatibilities: [
    'FARGATE',
  ],
  taskRoleArn: '{{  tfstate `aws_iam_role.ecs_task_role.arn` }}',
}
