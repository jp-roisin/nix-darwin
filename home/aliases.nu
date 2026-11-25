# oh-my-zsh plugin aliases not covered by nu_scripts' git/docker alias modules
# (those are imported in home/shell.nix, which also provides git_current_branch / git_main_branch).
# Skipped: yarn's `yy` (kept for yazi), gitk/svn/wip helpers, numeric dirstack (1-9).

# --- git ---
alias g = git
alias gcB = git checkout -B
alias gcann! = git commit --verbose --all --date=now --no-edit --amend
alias gcfu = git commit --fixup
alias gclf = git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules
alias gmc = git merge --continue
alias gmff = git merge --ff-only
alias gms = git merge --squash
alias greva = git revert --abort
alias grevc = git revert --continue
alias grf = git reflog
alias grhk = git reset --keep
alias grhs = git reset --soft
alias gta = git tag --annotate
alias gwtrm = git worktree remove
def --wrapped ggpull [...rest] { git pull origin (git_current_branch) ...$rest }
def --wrapped ggpush [...rest] { git push origin (git_current_branch) ...$rest }
def ggu [branch?: string] { git pull --rebase origin ($branch | default (git_current_branch)) }
alias ggpur = ggu
def ggsup [] { git branch $"--set-upstream-to=origin/(git_current_branch)" }
def gluc [] { git pull upstream (git_current_branch) }
def gmum [] { git merge $"upstream/(git_main_branch)" }
def gprom [] { git pull --rebase origin (git_main_branch) }
def gpromi [] { git pull --rebase=interactive origin (git_main_branch) }
def gprum [] { git pull --rebase upstream (git_main_branch) }
def gprumi [] { git pull --rebase=interactive upstream (git_main_branch) }
def gpsupf [] { git push --set-upstream origin (git_current_branch) --force-with-lease --force-if-includes }
def grbom [] { git rebase $"origin/(git_main_branch)" }
def grbum [] { git rebase $"upstream/(git_main_branch)" }
def gswm [] { git switch (git_main_branch) }
def gwipe [] { git reset --hard; git clean --force -df }
def gfg [pattern: string] { git ls-files | lines | where $it =~ $pattern }

# --- docker ---
alias dps = docker ps
alias dpsa = docker ps -a
alias dsts = docker stats
alias dcprune = docker container prune
alias dipru = docker image prune -a
alias dnprune = docker network prune
alias dsprune = docker system prune

# --- docker-compose ---
alias dco = docker-compose
alias dcb = docker-compose build
alias dcdn = docker-compose down
alias dce = docker-compose exec
alias dck = docker-compose kill
alias dcl = docker-compose logs
alias dclF = docker-compose logs -f --tail 0
alias dclf = docker-compose logs -f
alias dcps = docker-compose ps
alias dcpull = docker-compose pull
alias dcr = docker-compose run
alias dcrestart = docker-compose restart
alias dcrm = docker-compose rm
alias dcstart = docker-compose start
alias dcstop = docker-compose stop
alias dcup = docker-compose up
alias dcupb = docker-compose up --build
alias dcupd = docker-compose up -d
alias dcupdb = docker-compose up -d --build

# --- brew ---
alias ba = brew autoremove
alias bcfg = brew config
alias bci = brew info --cask
alias bcin = brew install --cask
alias bcl = brew list --cask
alias bcn = brew cleanup
alias bco = brew outdated --cask
alias bcrin = brew reinstall --cask
alias bcup = brew upgrade --cask
alias bdr = brew doctor
alias bfu = brew upgrade --formula
alias bi = brew install
alias bih = brew install --HEAD
alias bl = brew list
alias bo = brew outdated
alias br = brew reinstall
alias brewp = brew pin
alias brewsp = brew list --pinned
alias brh = brew reinstall --HEAD
alias bs = brew search
alias bsl = brew services list
alias bsoff = brew services stop
alias bsoffa = brew services stop --all
alias bson = brew services start
alias bsona = brew services start --all
alias bsr = brew services run
alias bsra = brew services run --all
alias bu = brew update
alias bup = brew upgrade
alias buz = brew uninstall --zap
def bcubc [] { brew upgrade --cask; brew cleanup }
def bcubo [] { brew update; brew outdated --cask }
def bubo [] { brew update; brew outdated }
def bugbc [] { brew upgrade --greedy; brew cleanup }
def bubu [] { bubo; brew upgrade }
def bubug [] { bubo; bugbc }

# --- yarn ---
alias y = yarn
alias ya = yarn add
alias yad = yarn add --dev
alias yap = yarn add --peer
alias yb = yarn build
alias ycc = yarn cache clean
alias yd = yarn dev
alias yf = yarn format
alias yga = yarn global add
alias ygls = yarn global list
alias ygrm = yarn global remove
alias ygu = yarn global upgrade
alias yh = yarn help
alias yi = yarn init
alias yifl = yarn install --frozen-lockfile
alias yii = yarn install --frozen-lockfile
alias yin = yarn install
alias yln = yarn lint
alias ylnf = yarn lint --fix
alias yls = yarn list
alias yout = yarn outdated
alias yp = yarn pack
alias yrm = yarn remove
alias yrun = yarn run
alias ys = yarn serve
alias yst = yarn start
alias yt = yarn test
alias ytc = yarn test --coverage
alias yui = yarn upgrade-interactive
alias yuil = yarn upgrade-interactive --latest
alias yup = yarn upgrade
alias yv = yarn version
alias yw = yarn workspace
alias yws = yarn workspaces
def yuca [] { yarn global upgrade; yarn cache clean }

# --- oh-my-zsh lib (ls variants use nu's structured ls) ---
alias l = ls -la
alias la = ls -a
alias ll = ls -l
alias lsa = ls -la
alias md = mkdir
alias rd = ^rmdir

# --- autojump: `j foo` jumps using the same db zsh fills, and nu now feeds it too ---
# the autojump binary refuses to run unless its shell hook exported this (zsh's autojump.zsh does)
$env.AUTOJUMP_SOURCED = 1
def --env j [...args: string] { cd (^autojump ...$args | str trim) }
$env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD? | default [] | append {|_, dir| ^autojump --add $dir })

# --- alias tips (like zsh's alias-tips): suggest the alias with the longest matching expansion ---
$env.config.hooks.pre_execution = ($env.config.hooks.pre_execution? | default [] | append {||
  let cmd = (commandline | str trim)
  let hit = (scope aliases
    | where {|a| $cmd == $a.expansion or ($cmd | str starts-with $"($a.expansion) ")}
    | sort-by {|a| $a.expansion | str length} --reverse
    | get -o 0)
  if $hit != null { print $"(ansi blue_bold)Alias tip:(ansi reset) ($hit.name)($cmd | str substring ($hit.expansion | str length)..)" }
})
