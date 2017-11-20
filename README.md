s2i for matlab
==============

Using [mcc](https://www.mathworks.com/help//compiler_sdk/ml_code/mcc.html) to compile shared libraries and application deployments.


### Configuration

- `ML_ISO_DIR`; directory with the installation ISOs
- `LM_HOST_ID`; license manager host id
- `LM_HOST_NAME`; license manager hostname
- `FIK`; license file installation key

### Using

Use as container

`docker run --rm -it --add-host my-license-server:192.168.0.1 matlab:compiler bash`
