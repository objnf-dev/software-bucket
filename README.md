# Software Bucket

A personal bucket for [Scoop](https://scoop.sh), the Windows command-line installer.

## Software

| Package | Description |
| --- | --- |
| [`fluentcleaner`](https://github.com/builtbybel/FluentCleaner) | Modern WinUI 3 edition of the transparent, community-powered CCleaner alternative for Windows. |
| [`raven`](https://github.com/mjishnu/Raven) | A free, open-source alternative Microsoft Store client for Windows. |
| [`vda-off`](https://github.com/objnf-dev/software-bucket/blob/master/scripts/vda-off.ps1) | Disable GameViewer, MuMu, and Oray virtual display adapters. |

## Installation

Add the bucket, then install a package from the list above:

```pwsh
scoop bucket add software-bucket https://github.com/objnf-dev/software-bucket
scoop install software-bucket/fluentcleaner
```

## Contributing

To make a new manifest contribution, please read the [Contributing
Guide](https://github.com/ScoopInstaller/.github/blob/main/.github/CONTRIBUTING.md)
and [App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests)
wiki page.
