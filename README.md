# dotfiles
oxonium's dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Install
```
sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply oxonium0215
```

## Update
```
chezmoi update -v
```

## Commit
```
chezmoi cd
```
```
git add .
git commit -m "<Your update commit message>"
git push -u origin main
```

## Apply
```
chezmoi diff
```
```
chezmoi -v apply
```
