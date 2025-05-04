docker build -t sm:pg14 . &&
docker run -it -v ./:/buildoutput sm:pg14
