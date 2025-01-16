# tpu-utils

Some handy scripts for TPU pods.

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

## Command reference

### `podrun`

**Description:**
Executes a command on all workers of a TPU VM.

**Usage:**
```sh
podrun <command> [-f|--file <script.sh>]
```

**Arguments:**
- `<command>`: The command to execute on the TPU VM workers.
- `-f|--file <script.sh>`: Optional. Specifies a script file whose contents will be executed on the TPU VM workers.

**Example:**
```sh
podrun "echo Hello, World!"
podrun -f my_script.sh
```

### `podrunpy`

**Description:**
Executes a Python script or command on all workers of a TPU VM. Supports including additional files or directories.

**Usage:**
```sh
podrunpy <script.py> [-i|--include FILE...] | -c|--command <python_code> [-i|--include FILE...]
```

**Arguments:**
- `<script.py>`: The Python script file to execute on the TPU VM workers.
- `-i|--include FILE...`: Optional. Specifies additional files or directories to include when executing the script or command.
- `-c|--command <python_code>`: Optional. Specifies a raw Python command to execute on the TPU VM workers.

**Example:**
```sh
podrunpy my_script.py
podrunpy my_script.py -i helper_module.py config.json
podrunpy -c "print('Hello, World!')" -i helper_module.py
```

### `podkill`

**Description:**
Kills all Python processes running on all workers of a TPU VM.

**Usage:**
```sh
podkill
```

**Example:**
```sh
podkill
```