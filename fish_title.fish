source (dirname (status -f))/harleen_repo_context.fish

function fish_title
  if git_is_repo
    set -l repo_context (harleen_repo_context)
    set -l title $repo_context[1]
    set -l repo_path $repo_context[2]

    if test -n "$repo_path"
      set title "$title:$repo_path"
    end

    echo "$title | $_"
  else
    echo "$PWD | $_"
  end | sed "s|$HOME|~|g"
end
