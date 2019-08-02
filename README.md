# Desc
Based on centos7.1, the single-point elasticsearch5.4.3 and Chinese word breaker are built. The external ports are 9200 and 9300.
# Run command
docker run -itd --net=host --name elasticsearch5.4.3 -p 9200:9200 -p 9300:9300 ranzechen/elasticsearch5.4.3:latest
