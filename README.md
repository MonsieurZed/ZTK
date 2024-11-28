# Zed's Toolkit

Open source setup tool

Here is my take on a setup tool CTT Style

![picture.png](./assets/picture.png)

#### Running it

```
irm https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/main.ps1 | iex
```

or

```
irm zedcorp.fr/t | iex
```

You can also run the dev branch like this

```
irm zedcorp.fr/t?dev | iex
```

## What is it ?

Zed's Toolkit aim to make a fresh install of windows easier by providing a all in one installer tools.

- Bulk install package from Winget, Chocolatey, any executable Path, archive Path or Iso Path.
- Per browers extensions link opener
- Access user folders
- Access to windows interface
- Access to useful irm-iex tools

## What next ?

- Better UI/UX
- Redegit tweaks
- Package search
- Multi Language support

## Running Locally

Git clone this project then run the following command

```
 . '.\tools\debug.ps1'
```

This will create a debug file in temp where you can specify the path of your project

Now next time you run the main.ps1 or the `irm | iex` command it will use your local file instead of thoose on github

## Licence

- This project is under the licence GNU3

## Author

- [MonsieurZed](https://github.com/MonsieurZed)

![picture.png](./assets/sharky.png)
