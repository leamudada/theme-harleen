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

function fish_title
  if git_is_repo
    set -l repo_context (harleen_repo_context)
    set -l title $repo_context[1]
    set -l worktree_name $repo_context[2]
    set -l repo_path $repo_context[3]

    if test -n "$worktree_name"
      set title "$title [worktree]"
    end

    if test -n "$repo_path"
      set title "$title:$repo_path"
    end

    echo "$title | $_"
  else
    echo "$PWD | $_"
  end | sed "s|$HOME|~|g"
end
