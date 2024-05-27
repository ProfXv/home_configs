for ptc in http https ftp; do export ${ptc}_proxy=${ptc}://127.0.0.1:7890; done
export rsync_proxy=$http_proxy
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
