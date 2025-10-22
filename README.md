# OBS Metal Fisheye Filter

An OBS Studio plugin that converts equirectangular (360°) video to fisheye projection using Apple Metal shaders for optimal performance on macOS.

## Features

- **High Performance**: Uses Apple Metal compute shaders for GPU-accelerated processing
- **Real-time Processing**: Converts equirectangular video to fisheye in real-time
- **Customizable Parameters**:
  - Field of View (FOV): 0° to 360°
  - Pan, Tilt, Yaw rotation controls
  - Alpha channel control for areas outside the fisheye circle
- **macOS Optimized**: Designed specifically for Apple Silicon and Intel Macs

## Requirements

- macOS 10.15 or later
- OBS Studio 28.0 or later
- Xcode Command Line Tools (for building from source)

## Installation

### Pre-built Plugin

1. Download the latest release from the [Releases](https://github.com/yourusername/Equirect2Fisheye/releases) page
2. Extract the `obs-metal-fisheye-filter.plugin` file
3. Copy it to your OBS plugins directory:
   ```bash
   cp obs-metal-fisheye-filter.plugin ~/Library/Application\ Support/obs-studio/plugins/
   ```
4. Restart OBS Studio
5. Add the "Metal Fisheye Filter" to your video sources

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Equirect2Fisheye.git
   cd Equirect2Fisheye
   ```

2. Install dependencies:
   ```bash
   brew install obs cmake pkg-config
   ```

3. Build the plugin:
   ```bash
   mkdir build
   cd build
   cmake ..
   make -j$(sysctl -n hw.ncpu)
   ```

4. Install the plugin:
   ```bash
   cp obs-metal-fisheye-filter.plugin ~/Library/Application\ Support/obs-studio/plugins/
   ```

## Usage

1. Add a video source to your OBS scene (e.g., Media Source, Camera, etc.)
2. Right-click on the source and select "Filters"
3. Click the "+" button and select "Metal Fisheye Filter"
4. Adjust the parameters:
   - **FOV**: Set the field of view for the fisheye projection (0° to 360°)
   - **Pan**: Rotate around the Y-axis (vertical rotation)
   - **Tilt**: Rotate around the X-axis (horizontal rotation)
   - **Yaw**: Rotate around the Z-axis (depth rotation)
   - **Alpha**: Set transparency for areas outside the fisheye circle (0.0 = transparent, 1.0 = opaque)

## Parameters

- **FOV (Field of View)**: Controls the angular coverage of the fisheye projection
  - 180°: Standard fisheye view
  - 360°: Full spherical coverage
  - Lower values: Zoomed-in view

- **Rotation Controls**:
  - **Pan**: Look left/right in the 360° video
  - **Tilt**: Look up/down in the 360° video
  - **Yaw**: Roll the camera view

- **Alpha**: Controls the transparency of areas outside the circular fisheye projection

## Technical Details

### Metal Shader

The plugin uses a Metal compute shader (`equirectangular_to_fisheye.metal`) that:
1. Maps fisheye coordinates to spherical coordinates
2. Applies 3D rotation transformations
3. Converts back to equirectangular UV coordinates
4. Samples the input texture with proper filtering

### Performance

- GPU-accelerated processing using Metal compute shaders
- Optimized for both Apple Silicon and Intel Macs
- Real-time performance for 4K video sources

## Development

### Project Structure

```
├── equirectangular_to_fisheye.metal    # Metal compute shader
├── obs-metal-fisheye-filter.cpp       # OBS plugin implementation
├── CMakeLists.txt                     # Build configuration
├── Info.plist.in                      # Plugin bundle metadata
└── .github/workflows/build.yml        # GitHub Actions CI/CD
```

### Building

The project uses CMake for building:

```bash
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(sysctl -n hw.ncpu)
```

### Code Signing

For distribution, the plugin must be code signed. The GitHub Actions workflow handles this automatically when creating releases.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- OBS Studio team for the excellent plugin architecture
- Apple for the Metal framework
- The open-source community for inspiration and feedback

## Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/Equirect2Fisheye/issues) page
2. Create a new issue with detailed information about your setup
3. Include OBS Studio version, macOS version, and any error messages

## Changelog

### v1.0.0
- Initial release
- Metal compute shader implementation
- FOV, Pan, Tilt, Yaw, and Alpha controls
- Real-time processing support
- macOS code signing and distribution
