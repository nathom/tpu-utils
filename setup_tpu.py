import os
from secrets import TPU_NAME, ZONE, PROJECT, environment, misc_bashrc

def format_environment_script(environment):
    export_str = 'export {key}={value}'
    export_commands = [export_str.format(key=key, value=value) for key, value in environment.items()]
    return '\n'.join(export_commands)

def format_script(tpu_name, zone, project):
    with open('pod_commands.sh') as f:
        script = f.read()
    format_key = {
        'tpu_name': tpu_name,
        'zone': zone,
        'project': project
    }
    for k, v in format_key.items():
        script = script.replace("{{" + k + "}}", v)
    return script
    
if __name__ == '__main__':
    commands_script = format_script(TPU_NAME, ZONE, PROJECT)
    home = os.environ['HOME']
    
    script_path = os.path.join(home, '.tpu_commands')
    with open(script_path, 'w') as f:
        f.write(commands_script)
        
    environment_script = format_environment_script(environment)
    environment_script_path = os.path.join(home, '.environment')
    with open(environment_script_path, 'w') as f:
        f.write(environment_script)
        
    bashrc_path = os.path.join(home, '.bashrc')
    script_paths = [script_path, environment_script_path]
    source_command = '\n'.join(f"source {path}" for path in script_paths)
    bashrc_append = f"\n{misc_bashrc}\n{source_command}\n"
    
    already_sourced = False
    with open(bashrc_path) as bashrc:
        if bashrc_append in bashrc.read():
            already_sourced = True
            
    if not already_sourced:
        with open(bashrc_path, 'a') as bashrc:
            bashrc.write(bashrc_append)
            
    print('Setup complete! Please restart your shell to use the TPU commands.')