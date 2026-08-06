# Harleen Theme. Made with <3.

if not functions -q harleen_repo_context
  function harleen_repo_context
    if not git_is_repo
      return 1
    end

    set -l root_folder (command git rev-parse --show-toplevel 2>/dev/null)
    set -l git_dir_raw (command git rev-parse --git-dir 2>/dev/null)
    set -l git_common_dir_raw (command git rev-parse --git-common-dir 2>/dev/null)
    set -l current_dir (command pwd -P 2>/dev/null)
    set -l git_dir
    set -l git_common_dir

    switch $git_dir_raw
      case '/*'
        set git_dir $git_dir_raw
      case '*'
        set git_dir (command realpath "$current_dir/$git_dir_raw" 2>/dev/null)
    end

    switch $git_common_dir_raw
      case '/*'
        set git_common_dir $git_common_dir_raw
      case '*'
        set git_common_dir (command realpath "$current_dir/$git_common_dir_raw" 2>/dev/null)
    end

    set -l project_name (basename (dirname $git_common_dir))
    set -l worktree_name
    if test "$git_dir" != "$git_common_dir"
      set worktree_name (basename $root_folder)
    end
    set -l repo_path (echo $current_dir | sed -e "s|^$root_folder/*||")

    echo $project_name
    echo $worktree_name
    echo $repo_path
  end
end

function fish_prompt
  # Retrieving status of last command
  # Directly using it to set colors for displaying prompt symbols
  test $status -ne 0;
    and set -l last_status_colors 666 aaa f02093
    or set -l last_status_colors 666 aaa 03adf1

  # Defining some helper functions for playing with colors.
  # Thanks to http://www.colourlovers.com/palette/4537580/lisa_frank_rainbow~ for the colors inspiration :)
  set -l color_pink   (set_color -o f02093)
  set -l color_yellow (set_color -o fdf215)
  set -l color_green  (set_color -o abd543)
  set -l color_blue   (set_color -o 03adf1)
  set -l color_purple (set_color -o a23095)
  set -l color_dim    (set_color -o c0c0c0)
  set -l color_cyan   (set_color -o 2fd7c4)
  set -l color_off    (set_color -o normal)

  # Defining symbols to use for information in Git repositories
  set -l stashed  "^"
  set -l ahead    "↑"
  set -l behind   "↓"
  set -l diverged "⥄ "
  set -l dirty    "*"
  set -l none     ""

  # Displaying useful information in case of browsing a Git repository
  if git_is_repo
    set -l repo_context (harleen_repo_context)
    set -l project_name $repo_context[1]
    set -l worktree_name $repo_context[2]
    set -l repo_path $repo_context[3]

    echo -n -s $color_blue "(" $color_dim $project_name
    if test -n "$worktree_name"
      echo -n -s " " $color_cyan "[worktree]" $color_dim
    end
    if test -n "$repo_path"
      echo -n -s $color_blue ":" $color_dim $repo_path
    end
    echo -n -s $color_blue ")" $color_off " "

    # Writing an indication in case there's some stashed content in the repository
    if git_is_stashed
      echo -n -s $color_purple $stashed $color_off
    end

    # Starting displaying information about the current branch
    echo -n -s $color_pink "(" $color_off

    # Displaying a marker in case the repository isn't clean
    if git_is_touched
      echo -n -s $color_yellow $dirty $color_off " "
    else
      echo -n -s " "
    end

    # Displaying the branch name
    echo -n -s $color_dim (git_branch_name) $color_off " "
    # Displaying information about the branch status
    echo -n -s $color_green (git_ahead $ahead $behind $diverged $none) $color_off

    # Ending the display :)
    echo -n -s $color_pink ")" $color_off " "

  else
    # Displaying the path we're at using short path by default.
    set cwd (basename (prompt_pwd))
    echo -n -s $color_blue "("$color_dim $cwd $color_blue")" $color_off " "
  end

  # Finally display the prompt symbols
  for color in $last_status_colors
    echo -n (set_color $color)">"
  end

  # And one last space. It does everything.
  echo -n -s " " $color_off

end
