# meerkat-feng-capture
Code for capture of meerkat feng using PSRDADA / SPEAD2

Boot up a container using:

docker run -tid --name=mkrecv-dev-mlnx-3.3-test --device=/dev/infiniband/rdma_cm --device=/dev/infiniband/uverbs0 --device=/dev/infiniband/umad0 --device=/dev/infiniband/ucm0 --device=/dev/infiniband/issm0 --device=/dev/infiniband/issm1 --device=/dev/infiniband/umad1 --ulimit "memlock=-1" --net=host mkrecv-mlnx-4.1-ubuntu:latest
