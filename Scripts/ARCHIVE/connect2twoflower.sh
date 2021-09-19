# http://unix.stackexchange.com/questions/25055/ssh-via-multiple-hosts
# http://www.lorrin.org/blog/2014/01/10/one-liner-ssh-via-jump-box-using-proxycommand/
#ssh -i server_key.pem -o "ProxyCommand ssh -W %h:%p -i key_for_jumpbox.pem root@home.lofland.net:38920" chrisl8@ubuntu
ssh -o "ProxyCommand ssh -W %h:%p iamyourgod@ekpyroticfrood.asuscomm.com -p 38919" chrisl8@twoflower
