# Setup for testing with Python
## Python setup
If you are familiar with Python then all that is needed is:
* A Python 3.5 installation
   * Anaconda is the easiest option.
* Installation of the  [streamsx](https://pypi.python.org/pypi/streamsx) package using pip: `pip install streamsx`

ADD link to step by step python setup for others.

## Testing using Streaming Analytics service
### Overview
Tests are run using the Streaming Anaytics service on IBM's Cloud platform. No local install of IBM Streams is required.

_Note: use of the service for testing will contribute to usage for billing purposes._

### Setup

CREDENTIALS SETUP.

## Testing using a local IBM Streams install
### Overview
Tests can be run against a standalone or a distributed instance using a local install of IBM Streams 4.2 or later.
For distributed the instance may be a cluster and remote to the local machine (where the tests are being run), but a local install of IBM Streams is still required (for the command line tools to submit a job etc.).
### streamsx package
IBM Streams install includes a version of the `streamsx` package as an SPL toolkit under `$STREAMS_INSTALL/toolkits/com.ibm.streamsx.topology`. If you have installed the package using `pip` then it is likely that the pip version will be a newer version than the one in the install. It is recommended to use the latest version from pip.

To ensure your tests are always referring to the correct version ensure that the environment variable `PYTHONPATH` is correct. Note that PYTHONPATH is modified by the Streams environment setup script: `$STREAMS_INSTALL/bin/streamsprofile.sh`.
* If you have installed `streamsx` using `pip` then you need to ensure that `PYTHONPATH` does not refer to the SPL toolkit in the install, thus it must *not* contain `$STREAMS_INSTALL/toolkits/com.ibm.streamsx.topology/opt/python/packages`.
* If you are using the version from the install and have not installed `streamsx` using `pip` then `PYTHONPATH` is set correctly when you set your environment using `$STREAMS_INSTALL/bin/streamsprofile.sh`. If you have subsequently modified `PYTHONPATH` then you need to ensure that it contains `$STREAMS_INSTALL/toolkits/com.ibm.streamsx.topology/opt/python/packages`.

### Standalone
### Quick Start Edition (QSEVM)


