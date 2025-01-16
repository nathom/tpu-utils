podrun() {
  local command=""
  local tpu_name="{{tpu_name}}"
  local zone="{{zone}}"
  local project="{{project}}"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--file)
        if [[ -z "$2" ]]; then
          echo "Error: No file specified for -f/--file."
          return 1
        fi
        if [[ ! -f "$2" ]]; then
          echo "Error: File '$2' does not exist."
          return 1
        fi
        command=$(<"$2")  # Read the file content into the command variable
        shift 2
        ;;
      *)
        if [[ -z "$command" ]]; then
          command="$1"
          shift
        else
          echo "Error: Unexpected argument '$1'."
          return 1
        fi
        ;;
    esac
  done

  if [[ -z "$command" ]]; then
    echo "Usage: podrun <command> [-f|--file <script.sh>]"
    return 1
  fi

  gcloud compute tpus tpu-vm ssh "$tpu_name" \
      --zone="$zone" \
      --project="$project" \
      --worker=all \
      --command="$command"
}

podrunpy() {
  local script=""
  local command=""
  local includes=()
  local tpu_name="{{tpu_name}}"
  local zone="{{zone}}"
  local project="{{project}}"
  local temp_dir="/tmp/podrunpy_$$"
  local exec_command=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--command)
        if [[ -z "$2" ]]; then
          echo "Error: No command specified for -c/--command."
          return 1
        fi
        command="$2"
        shift 2
        ;;
      -i|--include)
        shift
        while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
          includes+=("$1")
          shift
        done
        ;;
      *)
        if [[ -z "$script" ]]; then
          script="$1"
          shift
        else
          echo "Error: Unexpected argument '$1'."
          return 1
        fi
        ;;
    esac
  done

  if [[ -z "$script" && -z "$command" ]]; then
    echo "Usage: podrunpy <script.py> | -c/--command <python_code> [-i|--include FILE...]"
    return 1
  fi

  if [[ -n "$script" && -n "$command" ]]; then
    echo "Error: Specify either a script file or a command, not both."
    return 1
  fi

  if [[ -n "$script" ]]; then
    if [[ ! -f "$script" ]]; then
      echo "Error: File '$script' does not exist."
      return 1
    fi
    # Create temp_dir on remote
    gcloud compute tpus tpu-vm ssh "$tpu_name" \
      --zone="$zone" \
      --project="$project" \
      --worker=all \
      --command="mkdir -p $temp_dir"

    if (( ${#includes[@]} > 0 )); then
      # Copy script and includes to temp_dir
      gcloud compute tpus tpu-vm scp "${includes[@]}" "$script" "$tpu_name:$temp_dir/" \
          --zone="$zone" \
          --project="$project" \
          --worker=all
    else
      # Copy script to temp_dir
      gcloud compute tpus tpu-vm scp "$script" "$tpu_name:$temp_dir/" \
          --zone="$zone" \
          --project="$project" \
          --worker=all
    fi
    exec_command="cd $temp_dir && python3 $(basename "$script"); rm -rf $temp_dir"
  elif [[ -n "$command" ]]; then
    if (( ${#includes[@]} > 0 )); then
      # Create temp_dir on remote
      gcloud compute tpus tpu-vm ssh "$tpu_name" \
        --zone="$zone" \
        --project="$project" \
        --worker=all \
        --command="mkdir -p $temp_dir"

      # Copy includes to temp_dir
      gcloud compute tpus tpu-vm scp "${includes[@]}" "$tpu_name:$temp_dir/" \
          --zone="$zone" \
          --project="$project" \
          --worker=all
      exec_command="cd $temp_dir && PYTHONPATH=$temp_dir python3 -c \"$command\"; rm -rf $temp_dir"
    else
      # Execute command directly
      exec_command="python3 -c \"$command\""
    fi
  fi

  gcloud compute tpus tpu-vm ssh "$tpu_name" \
    --zone="$zone" \
    --project="$project" \
    --worker=all \
    --command="$exec_command"
}


podkill() {
        podrun 'pkill -f python3; pkill -f python'
}