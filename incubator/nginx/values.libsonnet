{
  fullname: "nginx-app",
  imageTag: "1.10.2-r3",
  imagePullPolicy: "IfNotPresent",

  vhost:
    |||
    # example PHP-FPM vhost
    server {
      listen 0.0.0.0:80;
      root /app;
      location / {
        index index.html index.php;
      }
      location ~ \.php$ {
        fastcgi_pass phpfpm-server:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
      }
    }
  |||
}
