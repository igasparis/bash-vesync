# bash-vesync
Control your Vesync smart power plugs from your terminal.

## Requirements
* curl
* jq

## Examples

### Login Information Command
`vesync.sh -l -u username -p password`
### Login Information Output
```
Token:     11111
ID:        22222
DEVICE_ID: 33333
```

### Turn on Command
`./vesync.sh -t 11111 -i 22222 -d 33333 -a on`

### Turn off Command
`./vesync.sh -t 11111 -i 22222 -d 33333 -a off`
