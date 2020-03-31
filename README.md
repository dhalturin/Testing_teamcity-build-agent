# TeamCity build agent images

Automate building images of vm VirtualBox with TeamCity build agents via packer. The wrapper execution artifact will be an images with OS Ubuntu 19.10 and Windows 10 Enterprise (trial).

## Requirements

- curl
- unzip
- [jq](https://stedolan.github.io/jq/)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- TeamCity server - will be used for download build agent archive

## Preparing

First step - install all packages from previous [part](#requirements). For preparing your environment, please run wrapper with flag `-p`:

```bash
$ ./packer.sh -p
```

It will check the availability of required packages and download [packer](https://packer.io/downloads.html) binary to directory `./packer/bin/`

At second you should to check a file with environment variables in the root of repository: `.env`.

## File with environment variables

The file `.env` is used for setting up user variables for packer. So you need to update at least one variable - `TC_SERVER`

### How to use

For images building you should to run wrapper with flag `-b _os_type_`:

```bash
$ ./packer.sh -b linux
$ ./packer.sh -b windows
$ ./packer.sh -b all
```

The results of images building you can find in directory `./packer/images/`:

```
./packer/images/
├── linux
│   ├── tc-linux-base
│   │   ├── tc-linux-base-disk001.vmdk
│   │   └── tc-linux-base.ovf
│   ├── tc-linux-docker-ansible
│   │   ├── tc-linux-docker-ansible-disk001.vmdk
│   │   └── tc-linux-docker-ansible.ovf
│   └── tc-linux-exporter-filebeat
│       ├── tc-linux-exporter-filebeat-disk001.vmdk
│       └── tc-linux-exporter-filebeat.ovf
└── windows
    ├── tc-windows-agent
    │   ├── tc-windows-agent-disk001.vmdk
    │   └── tc-windows-agent.ovf
    └── tc-windows-base
        ├── tc-windows-base-disk001.vmdk
        └── tc-windows-base.ovf
```

Show help message `./packer.sh -h`:

```
Automate build images with TeamCity agents

Usage: ./packer.sh [options] [arguments]

Example:

	$ ./packer.sh -p

Some of the options include:
	-b	Building images. Arguments: all / linux / windows
	-f	Force. Use this flag for rebuild images
	-h	This message
	-p	Pre-build preparation and downloading packer
```
