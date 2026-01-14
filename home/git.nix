{
  lib,
  useremail,
  ...
}:
{
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ~/.gitconfig
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user = {
        name = "jp-roisin";
        email = useremail;
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      core.editor = "nvim";
      merge.conflictstyle = "diff3";
      rerere.autoupdate = true;
    };

    includes = [
      {
        # use diffrent email & name for work
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work/";
      }
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "side-by-side";
    };
  };
}
