# sdnc web image


## folder structure

| folder | description |
| ------ | ----------- |
| /opt/bitnami/nginx/conf/server_blocks/http(s)_site.conf | nginx config |
| /opt/bitnami/nginx/conf/server_blocks/location.rules | forwarding rules for nginx |
| /app/odlux | http content files (html, js, css, ...) |
| /app/odlux.application.list | application list file |
| /app/opm.py | Odlux package manager for install or uninstall apps |
| /app/init.d/ | autoinstall folder for opm |

## Default app order

| index | application |
| ----- | ----------- |
| 1 | connectApp |
| 10 | faultApp |
| 20 | maintenanceApp |
| 30 | configurationApp |
| 55 | performanceHistoryApp |
| 70 | inventoryApp |
| 75 | eventLogApp |
| 90 | mediatorApp |
| 200 | helpApp |


## usage

### auto installation

To auto install additional applications for odlux they can be easily injected before startup into the ```/app/init.d/``` folder. There are two options of file format allowed.

[1] The first fileformat is e.g. 55linkCalculationApp.jar but also .zip is allowed. The important thing is that a number is leading the app package to specify the order number where the menu item is ordered in the menu bar. So the linkCalculationApp would be located between performanceApp and inventoryApp.

[2] The second is the default jar format, like it would be installed into the opendaylight karaf environment, including a blueprint and the sources. There the filename is not important because application name and index will be detected by the blueprint information.


### manual method
```
opm install --name myApp --index 53 --file myarchive.zip
```
```
opm install --url https://link-to-my-odlux-application.jar
```

```
opm uninstall --name myApp
```

```
opm list
```

