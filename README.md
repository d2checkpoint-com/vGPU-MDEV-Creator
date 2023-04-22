# Nvidia vGPU MDEV Device Creator

This script helps you create mdev devices with Nvidia vGPU profiles. It automates the process of generating UUIDs, creating XML files, and defining, starting, and setting the devices to autostart.

## Requirements

* An Nvidia GPU that supports vGPU
* `mdevctl` command-line tool
* `lshw` command-line tool
* `uuidgen` command-line tool

## Usage

The script requires root privileges to run. It takes the following arguments:

* **Required arguments:**
  * `-p` or `--profile`: The Nvidia vGPU profile to use.
  * `-n` or `--number`: The number of mdev devices to create.

* **Optional arguments:**
  * `-f` or `--file`: The name of the file to store UUIDs (default: `vgpu`).
  * `-F` or `--folder`: The base folder for storing UUIDs and XML files (default: `/vgpu`).

To run the script, use the following command:

```bash
sudo ./vgpu_mdev_creator.sh -p <Nvidia_Profile> -n <Number_of_mdev_devices> [-f <file_name>] [-F <base_folder>]```

Replace `<Nvidia_Profile>` with the desired Nvidia vGPU profile, `<Number_of_mdev_devices>` with the number of mdev devices you want to create, and optionally specify `<file_name>` and `<base_folder>` if you want to use non-default values.

## Example

To create 2 mdev devices with the `nvidia-63` profile, you can run the script as follows:

```sudo ./vgpu_mdev_creator.sh -p nvidia-63 -n 2```

This command will create 2 mdev devices using the `nvidia-63` profile and store the UUIDs in the `/vgpu/vgpu.uuid` file. It will also create XML files in the /vgpu/vgpu-dev/ folder for each UUID.

If you want to use a custom file name and folder, you can run the script as follows:

```sudo ./vgpu_mdev_creator.sh -p nvidia-63 -n 2 -f custom_vgpu -F /custom_vgpu```

This command will create 2 mdev devices using the `nvidia-63` profile and store the UUIDs in the `/custom_vgpu/custom_vgpu.uuid` file. It will also create XML files in the `/custom_vgpu/custom_vgpu-uuid/` folder for each UUID.

## License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.
