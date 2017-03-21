# Nginx docker container

# 特性

##### - 目录结构
```
/data/www # web 目录
/data/conf/nginx # nginx 配置目录
/data/logs/nginx-access # nginx access-log 目录
```
当上述目录不存在时，容器将自动新建

##### - log

```
/data/logs/nginx-access # nginx 访问日志目录
/data/logs/nginx-error.log # nginx 错误日志
/data/logs/supervisord.log # supervisord 日志
```

##### - 修改 nginx 配置后，自动重启（nginx -s reload）

监控目录 `/data/conf/nginx/` 改动，当发生修改时，nginx 自动重启.

##### - Nginx 状态页

Nginx 状态页配置在默认 vhost 中，url 为 `/nginx_status`
```
curl http://127.0.0.1/nginx_status
```
示例输出:  
```
Active connections: 1 
server accepts handled requests
11475 11475 13566 
Reading: 0 Writing: 1 Waiting: 0
```


## 使用

```
docker run -d --name=web --net=host -v /data/web:/data docker.oa.com/g_raygu/nginx:1.8.0-alpine
```

然后可以通过浏览器访问 http://SERVER_IP/

## 参考
参考：
- [million12/docker-centos-supervisor](https://github.com/million12/docker-centos-supervisor)
- [million12/docker-nginx](https://github.com/million12/docker-nginx)
- [nginxinc/docker-nginx:1.8.1](https://github.com/nginxinc/docker-nginx/blob/1.8.1/stable/alpine/Dockerfile)
