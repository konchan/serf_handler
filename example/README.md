example
=======
You may control the service and system by using serf queries.
For example,

```
serf query service_ctl "start iis MYHOST"
```

allows to start iis on MYHOST.

```
serf query system_ctl "reboot web"
```

allow to reboot the machine which has the role of web.

