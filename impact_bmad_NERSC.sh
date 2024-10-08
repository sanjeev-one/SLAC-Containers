#!/bin/bash

chmod o+x $HOME

echo "If the container fails to copy files to your home directory, then due to the behavior of our \$HOME filesystem metadata server,"
echo "users will need to grant o+x permission for their top-level directory on \$HOME and other directories they wish to mount."
echo "Please see our FAQ page for more details: https://docs.nersc.gov/development/containers/shifter/faq-troubleshooting/#mounting-directories-from-home."

# Define the podman image
IMAGE="docker.io/slacact/impact-bmad:nersc"

# Define the target directory in the user's home
TARGET_DIR="$HOME/impact_bmad_container_notebooks"
mkdir -p $TARGET_DIR

# Pull the podman image - assuming automatic migration
echo "Pulling podman image $IMAGE..."
podman-hpc pull $IMAGE

# Run the Shifter container and copy files
echo "Running podman container and copying files..."
podman-hpc run -v $TARGET_DIR:/opt/copy $IMAGE /bin/bash -c "cp -rn /opt/notebooks/* /opt/copy"


echo "\n\n---------------------------------------------------------\n\n"

echo "Files have been successfully copied to $TARGET_DIR."

echo "\n\n---------------------------------------------------------\n\n"

podman-hpc run $IMAGE /bin/bash -c "/opt/conda/bin/python -m ipykernel install --prefix $HOME/.local --name env_impact_bmad --display-name Impact_Bmad_Container"

# Create the kernel.json file with the specified content
KERNEL_DIR="$HOME/.local/share/jupyter/kernels/env_impact_bmad"
KERNEL_FILE="$KERNEL_DIR/kernel.json"
mkdir -p $KERNEL_DIR

cat <<EOT > $KERNEL_FILE
{
  "argv": [
    "podman-hpc",
    "--image=slacact/impact-bmad:nersc",
    "/opt/conda/bin/python",
    "-m",
    "ipykernel_launcher",
    "-f",
    "{connection_file}"
  ],
  "display_name": "Impact_Bmad_Container",
  "language": "python",
  "metadata": {
    "debugger": true
  }
}
EOT

echo "Kernel configuration for container has been written to $KERNEL_FILE."

echo "Visit https://jupyter.nersc.gov/ to view the container."
echo "Pick the Jupyter environment called 'Impact_Bmad_Container' and find the example notebook files in your home directory."
