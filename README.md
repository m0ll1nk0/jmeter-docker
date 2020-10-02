# jmeter-docker
A sample project used for load testing in the Azure cloud.

It builds a docker image with jmeter inside, call a jmeter .jmx file, waits for its execution and uploads results into a storage blob.

Jmeter test plan file (test-plan.jmx) can be opened in GUI mode and modified accordingly. 

Jmeter download link - https://jmeter.apache.org/download_jmeter.cgi.

Runtime environment variables can be set, i.e. Azure DevOps Release Variables:

- *base_url* - base url of the app under test;
- *uri* - uri path;
- *duration* - duration of the test in seconds;
- *threads* - threads to be triggered;
- *throughput* - desired throughput per minute;

In order to have jmeter report uploaded into a blob stroage azure cli variables (AZURE_STORAGE_CONTAINER_NAME and AZURE_STORAGE_CONNECTION_STRING) in Dockerfile must be updated

Clone the repo:
```
git clone https://github.com/m0ll1nk0/jmeter-docker.git
```

Local run:
```
docker build --pull --rm -f Dockerfile -t jmeterdocker:latest .
```

Run from Azure DevOps Release Pipeline:
- add a build Dockerfile task with arguments;
  
  ```
  --build-arg duration=$(duration) --build-arg base_url=$(base_url) --build-arg uri=$(uri) --build-arg threads=$(threads) --build-arg throughput=$(throughput) --build-arg rid=$(Release.ReleaseId) --build-arg eid=$(System.JobName) 
  ```
- at release time set desired var values;