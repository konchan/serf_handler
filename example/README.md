example
=======
You may control the service and system by using serf queries.
For example,

```
serf query -tag role=web start iis
```

allows to start iis on the machine which has the role of web.

```
serf query -node your_host reboot
```

allow to reboot on your_host.

