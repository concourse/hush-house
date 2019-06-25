# worker-tracing

The `worker-tracing` deployment is an experimental deployment of a Concourse worker (just like [`worker`](../worker/README.md)) that exposes tracing information regarding the steps involved in creating containers to a Zipkin receiver.

So far, it collected some interesting stats already: see https://github.com/concourse/concourse/issues/3424#issuecomment-498244531.

Note.: this is *highly* experimental and uses a fork of `guardian`: https://github.com/cirocosta/guardian/tree/tracing.
