local deployments = std.extVar('deployments-with-creds') +
                    std.extVar('deployments-without-creds');

local deploymentsResources = [{
  name: 'deployment-' + deployment.name,
  type: 'git',
  source: {
    uri: 'https://((github-token))@github.com/cirocosta/hush-house',
    paths: ['deployments/' + deployment.name + '/'],
  },
} for deployment in deployments];


local deploymentsJobs = [{
  name: 'deploy-' + deployment.name,
  serial: true,
  plan: [
    {
      aggregate: [
        { get: 'maintenance-image' },
        {
          get: 'hush-house',
          resource: 'deployment-' + deployment.name,
          trigger: true,
        },

      ] + if deployment.withCreds then [{
        task: 'helm-values',
        config: {
          platform: 'linux',
          image_resource: {
            type: 'registry-image',
            source: { repository: 'busybox' },
          },
          run: {
            path: '/bin/sh',
            args: [
              '-ce',
              "echo '((" + deployment.name + "-values-b64))' | base64 -d > ./helm-values/.values.yaml",
            ],
          },
          outputs: [{ name: 'helm-values' }],
        },
      }] else [],
    },
    {
      task: 'run',
      file: 'hush-house/ci/tasks/helm-deploy.yml',
      params: {
        DEPLOYMENT: deployment.name,
        DEPLOYMENT_TYPE: (if deployment.withCreds then 'with-creds' else 'without-creds'),
      },
      image: 'maintenance-image',
    },
  ],
} for deployment in deployments];

{
  resources: deploymentsResources + [
    {
      name: 'maintenance-image',
      type: 'registry-image',
      source: {
        repository: 'cirocosta/charts-maintenance',
      },
    },
  ],
  jobs: deploymentsJobs,
}
