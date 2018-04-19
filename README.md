s2i for matlab
==============

Using [mcc](https://www.mathworks.com/help//compiler_sdk/ml_code/mcc.html) to compile shared libraries and application deployments.

Also supports building into an image that will act as a matlab license server.

### Building

First create the image

`docker build -t <image-name> .`

Then install matlab

`install.sh <image-name>`

The variables consumed by `install.sh` are as follows

- `FIK`; license file installation key (required for s2i and license server builds)
- `ML_ISO_DIR`; directory with the installation ISOs (required for s2i and license server builds)
- `IS_LM`; specify whether the license manager should be installed (optional, 1 for true, other or null for false)
- `LM_HOST_ID`; license manager host id (required for s2i builds only)
- `LM_HOST_NAME`; license manager hostname (required for s2i builds only, defaults to the build host's hostname)
- `LM_HOST_PORT`; license manager port (required for s2i builds only, defaults to 27000)

### Licenses

Licenses are never built into the image.  The handling of the license is different depending on value of `IS_LM`

- is; a stub license is used for the install and a real license must be volumed in at container runtime
- not; a network license is installed pointing to a network license manager. override with volume at container runtime

### Products

Products are specified by populating the `products` text file in this directory, see PRODUCTS.md and your license for reference.

### Running

As a license manager

`docker run --rm -it -v /my-license.dat:/license.dat -p 27000:27000 -p 27001:27001 <image-name>`

This depends on MLM being locked to a port, shown here as `27001`.
