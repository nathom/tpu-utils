# tpu-utils

Some handy scripts for tpu pods.

To install, clone this repo and create a file called `secrets.py` that contain the following 4 variables:

```python
TPU_NAME = "your-tpu-name"
ZONE = "your-zone"
PROJECT = "your-project-id"

# environment variables to inject
environment = {
    'WANDB_API_KEY': 'your-wandb-api-key',
    'HF_TOKEN': 'your-hf-token',
    'CUDA_VISIBLE_DEVICES': '-1',
    # etc.
}

# other stuff you want in .bashrc
misc_bashrc = """
set -o vi
"""
```

Then run `setup_tpu.py`, and restart the shell. 
Now you should have access to the following commands on your machine:

- `podrun <command> [-f|--file <script.sh>]`: Executes a shell command or script on all TPU workers. You can either pass the command directly or specify a file containing the script.

- `podrunpy <command> [-f|--file <script.py>]`: Executes a Python command or script on all TPU workers. You can either pass the command directly or specify a file containing the script.

- `podkill`: Terminates all Python processes running on the TPU workers.

If you want to install this on every machine:

```bash
podrunpy setup_tpu.py -i pod_commands.sh secrets.py
```

We include the two files because `setup_tpu.py` depends on them.