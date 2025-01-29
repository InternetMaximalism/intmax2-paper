{ vimUtils, fetchFromGitHub }:
{
  colemak = vimUtils.buildVimPlugin {
    name = "colemak";
    src = ./vim-colemak-shai;
    dependencies = [ ];
  };
}
