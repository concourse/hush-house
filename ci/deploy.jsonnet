local deployments = std.extVar('deployments');

local deploymentsResources = [{
  name: 'deployment-' + deployment,
  type: 'git',
  source: {
    uri: 'https://github.com/cirocosta/hush-house',
    path: 'deployments/' + deployment,
  },
} for deployment in deployments];

local deploymentsJobs = [{
  name: 'deploy-' + deployment,
  serial: true,
  plan: [
    {
      aggregate: [
        {
          get: 'maintenance-image',
        },
        {
          get: 'charts-repository',
        },
        {
          get: 'hush-house',
          resource: 'deployment-' + deployment,
          trigger: true,
        },
        {
          task: 'helm-values',
          config: {
            platform: 'linux',
            image_resource: {
              type: 'registry-image',
              source: {
                repository: 'busybox',
              },
            },
            run: {
              path: '/bin/sh',
              args: [
                '-ce',
                "echo '((" + deployment + "-values-b64))' | base64 -d > ./helm-values/.values.yaml",
              ],
            },
            outputs: [
              {
                name: 'helm-values',
              },
            ],
          },
        },
      ],
    },
    {
      task: 'run',
      file: 'hush-house/ci/helm-deploy.yml',
      params: {
        DEPLOYMENT: deployment,
      },
      image: 'maintenance-image',
    },
  ],
} for deployment in deployments];

{
  resources: deploymentsResources + [
    {
      name: 'charts-repository',
      type: 'git',
      source: {
        branch: 'gh-pages',
        uri: 'https://((github-token))@github.com/concourse/charts',
      },
    },
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
